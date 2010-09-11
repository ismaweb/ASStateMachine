package asstatemachine
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * A hirerarchical Finite State Machine
	 * <p>It allows a hirerarchical state tree, enter and exit events for each state and signals too</p>
	 */
	public class StateMachine extends State
	{
		private var _state:State;
		private var _dispatcher:EventDispatcher;
		private var _sigDispatcher:EventDispatcher;
		
		/**
		 * Constructor
		 * @param	name		the machine name
		 * @param	arrChild	the states array
		 */
		public function StateMachine(name:String, arrChild:Array = null)
		{
			super(name, false, null, arrChild);
			_state = null;
			_dispatcher = new EventDispatcher();
			_sigDispatcher = new EventDispatcher();
		}
		
		/**
		 * locks the machine preventing any change at runtime and sets it to the initial state
		 * @param	dispatchEvents	dispatch or not the events caused by the initial state transition
		 */
		public function init(dispatchEvents:Boolean = true):void
		{
			lock();
			
			if (!locked)
				throw new IllegalOperationError("StateMachine not locked");
			
			enterState(this, dispatchEvents);
		}
		
		/**
		 * Spread a signal on current active states (current state and his ascendence)
		 * @param	signal
		 * @param	args
		 */
		protected function signal(signal:String, args:Object = null):void
		{
			if (!locked)
				throw new IllegalOperationError("StateMachine not locked");
				
			for each(var state:State in activeStates())
			{
				if (state.allowed(signal))
				{
					_sigDispatcher.dispatchEvent(new StateMachineSignal(signal, args));
					break;
				}
			}
		}
		
		/**
		 * Listen to <code>StateMachineSignal</code>s
		 * @param	type		
		 * @param	listener
		 */
		protected function addSignalHandler(type:String, listener:Function):void
		{
			_sigDispatcher.addEventListener(type, listener);
		}
		
		/**
		 * Listen to <code>StateMachineEvent.ENTER_CALLBACK</code> and <code>StateMachineEvent.EXIT_CALLBACK</code> 
		 * wich are enter and exit events from any <code>State</code> on the machine. Is intended for debugging, 
		 * for single State events use <code>listenEnter</code> and <code>listenExit</code> on specific state.
		 * @param	type		
		 * @param	listener
		 */
		protected function addEventListener(type:String, listener:Function):void
		{
			_dispatcher.addEventListener(type, listener);
		}
		
		/**
		 * get the deeper active state
		 */
		protected function get state():State
		{
			return _state;
		}
		
		/**
		 * Checks if <code>state</code> is the current state or a parent
		 * @param	state	the state to check
		 * @return	true if it is
		 */
		protected function isActive(state:State):Boolean
		{
			if (!locked)
				throw new IllegalOperationError("StateMachine not locked");
				
			if (_state == null)
				return false;
			
			if (_state == state)
				return true;
			
			return	_state.parents.indexOf(state) >= 0;
		}
		
		/**
		 * Gets a list of active states (the current state and his parents)
		 * @return
		 */
		private function activeStates():Array
		{
			if (!locked)
				throw new IllegalOperationError("StateMachine not locked");
				
			return _state == null ? [] : _state.parents;
		}
		
		/**
		 * lock the machine ans its states to prevent any change at runtime. Is called from <code>goInitialState</code>
		 */
		override protected function lock():void 
		{
			if (locked)
				throw new IllegalOperationError("StateMachine already locked");
				
			if (children == null)
				throw new IllegalOperationError("StateMachine without states");
			
			super.lock();
		}
		
		/**
		 * Enter a state. Dispatching exit and enter events
		 * @param	state	<code>State</code> to go
		 * @param	dispatchEvents	dispatch or not the events caused by the transition
		 */
		private function enterState(state:State, dispatchEvents:Boolean = true):void
		{
			_state = state;
			
			if (dispatchEvents)
			{
				_state.dispatchEnter();
				_dispatcher.dispatchEvent(new StateMachineEvent(
						StateMachineEvent.ENTER_CALLBACK, _state.parent, _state, state));
			}
			
			if(_state.initialState != null)
			{
				enterState(_state.initialState, dispatchEvents);
			}
		}
		
		/**
		 * Checks if can go from current state to <code>state</code>
		 * @param	state
		 * @return
		 */
		private function canGo(state:State):Boolean
		{
			if (!locked)
				throw new IllegalOperationError("StateMachine not locked");
			
			if (!_state)
				throw new IllegalOperationError("StateMachine not in any state, call goInitialState");
				
			var s:State = _state;
			var brother:State;
			
			do
			{
				brother = s.brothers[state]
				
				if (brother)
					return brother.from == null || brother.from[s] != null;
				
				s = s.parent;
				
			} while (s != null) ;
			
			return false;
		}
		
		/**
		 * Go from current state to <code>newState</code>
		 * @param	newState	The state to go to
		 * @return	true if ok
		 */
		protected function go(newState:State):Boolean
		{
			if (!canGo(newState))
			{
				_dispatcher.dispatchEvent(new StateMachineEvent(
					StateMachineEvent.TRANSITION_DENIED, _state, newState, _state));
					
				return false;
			}
			
			var from:State = _state;
			
			do
			{
				if (_state.brothers && _state.brothers[newState])
				{
					if (_state.brothers[newState].acceptFrom(_state))
					{
						_state.dispatchExit();
						_dispatcher.dispatchEvent(new StateMachineEvent(
							StateMachineEvent.EXIT_CALLBACK, _state, newState, _state));
						
						enterState(newState);
						
						_dispatcher.dispatchEvent(new StateMachineEvent(
							StateMachineEvent.TRANSITION_COMPLETE, from, newState, _state));
							
						return true;
					}
					else
					{
						throw new Error("theorically unreachable point");
					}
				}
				
				_state.dispatchExit();
				_dispatcher.dispatchEvent(new StateMachineEvent(
							StateMachineEvent.EXIT_CALLBACK, _state, _state.parent, _state));
				_state = _state.parent;
				
			} while (s != null) ;
			
			throw new Error("theorically unreachable point");
		}
	}
}