package asstatemachine 
{
	import flash.errors.IllegalOperationError;
	
	/**
	 * Creates an array of states (nesting it's childs) from a xml structure.
	 * 
	 * @example Using example
	 * 
	 * <listing>
		var xml:XML = 
			&lt;states&gt;
				&lt;state name="disconnected" initial="true" allow="try_connect" /&gt;
				&lt;state name="connecting" from="disconnected" allow="connect_fail,connect_ok" /&gt;
				&lt;state name="connected" from="connecting" allow="disconnect,io_error" &gt;
					&lt;state name="no_room" initial="true" from="owning_room,joining_room,listing_rooms,exiting_room" /&gt;
					&lt;state name="owning_room" from="no_room" /&gt;
					&lt;state name="own_room" from="owning_room" /&gt;
					&lt;state name="listing_rooms" from="no_room" /&gt;
					&lt;state name="joining_room" from="no_room" /&gt;
					&lt;state name="join_room" from="joining_room" /&gt;
					&lt;state name="exiting_room" from="join_room,own_room" /&gt;
				&lt;/state&gt;
			&lt;/states&gt;;
			
		sm = new StateMachine("SM", XMLStateCreator.fromXML(xml));
		sm.goInitialState();
		</listing>
	 */
	public class XMLStateCreator
	{
		/**
		 * Create the chidren array.
		 * @param	xml				the xml structure
		 * @param	stateFactory	a function to create the states. Signature: <code>function(name:String, initial:Boolean, allow:Array, arrChild:Array):State</code>
		 * @return	the children array
		 */
		public static function fromXML(xml:XML, stateFactory:Function = null):Array 
		{
			var sFactory:Function = stateFactory != null ? stateFactory : createState;
			
			var children:Array = iterateStates(xml, sFactory);
			
			// first put the states in a Dynamic Object
			var statesDO:Object = new Object;
			for each(var child:Object in children)
				statesDO[child] = child;
			
			for each(var node:XML in xml.children())
				setFroms(node, statesDO[node.attribute("name")]);
			
			return children;
		}
		
		/**
		 * @private
		 * @param	parent
		 * @param	factory
		 * @return
		 */
		private static function iterateStates(parent:XML, factory:Function):Array
		{
			var children:Array = [];
			
			for each(var node:XML in parent.children())
			{
				var allow:Array = node.attribute("allow").toString() != "" ? 
					node.attribute("allow").toString().split(",") : [];
				
				children.push(factory(
					node.attribute("name"),
					node.attribute("initial") == "true",
					allow,
					iterateStates(node,factory)
					));
			}
			
			return children;
		}
		
		/**
		 * @private
		 * @param	stateNode
		 * @param	s
		 */
		private static function setFroms(stateNode:XML, s:State):void
		{
			var froms:Array = [];
			var sFrom:String = stateNode.attribute("from").toString();
			
			if (sFrom != '')
			{
				for each(var from:String in sFrom.split(','))
				{
					if (s.brothers)
					{
						var b:State = s.brothers[from];
						
						if(!b)
							throw new IllegalOperationError("unknown brother state '" + from + "' in from attribute");
						
						froms.push(b);
					}
				}
			}
			s.setFrom(froms);
			
			for each(var node:XML in stateNode.children())
			{
				setFroms(node, s.children[node.attribute("name")]);
			}
		}
		
		/**
		 * @private
		 * @param	name
		 * @param	initial
		 * @param	arrChild
		 * @param	arrFrom
		 * @return
		 */
		private static function createState(name:String, initial:Boolean, allow:Array, arrChild:Array):State
		{
			return new State(name, initial, allow, arrChild, null);
		}
		
	}

}