package asstatemachine
{
	import flash.errors.IllegalOperationError;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	/** 
	 * A state representation. 
	 * Is a part of the hirerarchichal states structure (ASStateMachine is hirerarchical)
	 */
	public class State 
	{
		private var _name:String;
		private var _from:Object;
		private var _parent:State;
		private var _parents:Array;
		private var _children:Object;
		private var _locked:Boolean;
		private var _initial:Boolean;
		private var _initialState:State;
		private var _dispatcher:EventDispatcher;
		private var _allow:Array;
		
		/**
		 * Initializer constructor.
		 * <p>Intended for nesting in that way:</p>
		 * <code>
		  sm = new StateMachine("SM", [
				new State("disconnected", true, ["try_connect"]),
				new State("connecting", false, ["connect_fail","connected_ok"]),
				new State("connected", false, ["io_error","disconnect"], [
					new State("no_room", true),
					new State("owning_room"),
					new State("own_room"),
					new State("listing_rooms"),
					new State("joining_room"),
					new State("join_room"),
					new State("exiting_room")
				])
			]);
		  </code>
		 * @param	name 		State name
		 * @param	initial		This is the initial state in the machine or parent state
		 * @param	arrChild	Array of child states
		 * @param	arrFrom		Array of states where can come from
		 */
		public function State(name:String, initial:Boolean = false, allow:Array = null, arrChild:Array = null, arrFrom:Array = null)
		{
			_name = name;
			_from = null;
			_allow = allow;
			_children = new Object();
			_initialState = null;
			
			_initial = initial;
			
			_parents = [];
			_locked = false;
			
			if (_allow == null)
				_allow = [];
			
			if (arrChild)
				addChildren(arrChild);
				
			if (arrFrom)
				setFrom(arrFrom);
				
			_dispatcher = new EventDispatcher();
		}
		
		/**
		 * Is state locked?
		 * @default false
		 */
		public function get locked():Boolean
		{
			return _locked;
		}
		
		/**
		 * Get the state name
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * Get tha valid states where can come from
		 */
		public function get from():Object
		{
			return _from;
		}
		
		/**
		 * Get or set an array of allowed signals
		 */
		public function get allow():Array
		{
			return _allow;
		}
		
		public function set allow(allow:Array):void
		{
			_allow = allow;
		}
		
		
		/**
		 * The parent state. Only the top level state (the state machine itself) has a null parent
		 * @default null
		 */
		public function get parent():State
		{
			return _parent;
		}
		
		public function set parent(p:State):void
		{
			if (_locked)
				throw new IllegalOperationError("state is locked");
			
			 _parent = p;
		}
		
		/**
		 * Get an ancestor array. Is calculated at lock time. 
		 */
		public function get parents():Array
		{
			if (!_locked)
				throw new IllegalOperationError("state is not locked");
				
			return _parents;
		}
		
		/**
		 * Get an array of brothers (childs of parent). Includes itself
		 */
		public function get brothers():Object
		{
			return _parent == null ? null : _parent._children;
		}
		
		/**
		 * Get or sets if this is the initial state
		 * @default null
		 */
		public function get initial():Boolean
		{
			if (!_locked)
				throw new IllegalOperationError("state is not locked");
				
			return _initial;
		}
		
		public function set initial(b:Boolean):void
		{
			if (_locked)
				throw new IllegalOperationError("state is locked");
				
			_initial = b;
		}
		
		/**
		 * Get the initial child state
		 */
		public function get initialState():State
		{
			if (!_locked)
				throw new IllegalOperationError("state is not locked");
				
			return _initialState;
		}
		
		/**
		 * Check if can come from <code>state</code>
		 * @param	state	The state coming state
		 * @return	true if can
		 */
		public function acceptFrom(state:State):Boolean
		{
			return _from == null || _from[state] != null;
		}
		
		/**
		 * The array of states where can com from.
		 * <p>An empty array means that can come from any other state</p>
		 * @param	f	Accepted from states or empty array to accept any
		 */
		public function setFrom(f:Array):void
		{
			if (_locked)
				throw new IllegalOperationError("state is locked");
			
			if (f.length == 0)	
			{
				_from = null;
				return;
			}
			
			_from = new Object();
			
			for each (var s:State in f) 
			{
				_from[s] = s;
			}
		}
		
		/**
		 * The children.
		 */
		public function get children():Object
		{
			return _children;
		}
		
		/**
		 * A shorter alias for children
		 */
		public function get s():Object //alias for children
		{
			return _children;
		}
		
		/**
		 * Add the <code>children</code> to current children
		 * @param	children	children to add
		 */
		public function addChildren(children:Array):void
		{
			if (_locked)
				throw new IllegalOperationError("state is locked");
			
			for each (var s:State in children) 
			{
				_children[s] = s;
				s._parent = this;
			}
		}
		
		/**
		 * Add one child to current children
		 * @param	child	child to add
		 */
		public function addChild(child:State):void
		{
			if (_locked)
				throw new IllegalOperationError("state is locked");
				
			_children[child] = child;
			child._parent = this;
		}
		
		/**
		 * Locks the sate and it's children to prevent config changes on the state
		 */
		protected function lock():void
		{
			if (_parent != null)
			{
				if (!_parent._locked)
					throw new IllegalOperationError("parent state is not locked");
				
				_parents = _parent._parents.concat();
				_parents.push(_parent);
			}
			
			_locked = true;
			
			try
			{
				_initialState = null;
				var hasChildren:Boolean = false;
				
				for each(var cKey:String in _children)
				{
					hasChildren = true;
					var c:State = _children[cKey];
					c._parent = this;
					
					c.lock();
					
					if (c._initial)
						if (_initialState != null)
							throw new IllegalOperationError("more than one initial");
						else
							_initialState = c;
				}
				
				if (hasChildren && _initialState == null)
					throw new IllegalOperationError("no initial child found");
				
				for each (var sKey:String in _from) 
				{
					var s:State = _from[sKey];
					
					if (s == this)
						throw new IllegalOperationError("checking from: " + s._name + " is this");
						
					if (_parent == null)
						throw new IllegalOperationError("checking from: " + s._name + " has no brothers");
					
					if (!brothers[s])
						throw new IllegalOperationError("checking from: " + s._name + " is not a brother");
				}
			}
			catch (err:IllegalOperationError)
			{
				_locked = false;
				throw err;
			}
		}
		
		/**
		 * Dispatch <code>StateMachineEvent.ENTER_CALLBACK</code>
		 */
		public function dispatchEnter():void
		{
			_dispatcher.dispatchEvent(new StateMachineEvent(StateMachineEvent.ENTER_CALLBACK, null, this, this));
		}
		
		/**
		 * Dispatch <code>StateMachineEvent.EXIT_CALLBACK</code>
		 */
		public function dispatchExit():void
		{
			_dispatcher.dispatchEvent(new StateMachineEvent(StateMachineEvent.EXIT_CALLBACK, this, null, this));
		}
		
		public function allowed(signal:String):Boolean
		{
			return _allow.indexOf(signal) != -1;
		}
		
		/**
		 * Listen to enter event
		 * @param	listener	enter handler
		 */
		public function listenEnter(listener:Function):void
		{
			_dispatcher.addEventListener(StateMachineEvent.ENTER_CALLBACK, listener);
		}
		
		/**
		 * Listen to exit event
		 * @param	listener	exit handler
		 */
		public function listenExit(listener:Function):void
		{
			_dispatcher.addEventListener(StateMachineEvent.EXIT_CALLBACK, listener);
		}
		
		public function toString():String
		{
			// DO NOT MODIFY! needed as is for Dynamic Objects mapping purposes
			return _name;
		}
	}
}