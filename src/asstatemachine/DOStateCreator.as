package asstatemachine
{
	import flash.errors.IllegalOperationError;
	
	/**
	 * Creates a children array from a Dynamic Object structure
	 */
	public class DOStateCreator
	{
		/**
		 * Creates a children array from a Dynamic Object structure
		 * @example
		 * <listing>
		 * var childs:Array = [
				{name:"disconnected", initial:true, allow:["try_connect"] },
				{name:"connecting", from:["disconnected"], allow:["connect_fail","connect_ok"] },
				{name:"connected", from:["connecting"], allow:["disconnect","io_error"], children:[
					{name:"no_room", initial:true, from:["owning_room", "joining_room", "listing_rooms", "exiting_room"] },
					{name:"owning_room", from:["no_room"] },
					{name:"own_room", from:["owning_room"] },
					{name:"listing_rooms", from:["no_room"] },
					{name:"joining_room", from:["no_room"] },
					{name:"join_room", from:["joining_room"] },
					{name:"exiting_room", from:["join_room","own_room"] }
				]}
			];
			
			sm = new StateMachine("SM", DOStateCreator.fromDO(childs));
			sm.goInitialState();
		 * </listing>
		 * 
		 * @param	definitions		the definition structure
		 * @param	stateFactory	a function to create the states. Signature: <code>function(name:String, initial:Boolean, allow:Array, arrChild:Array):State</code>
		 * @return the children array
		 */
		public static function fromDO(definitions:Array, stateFactory:Function = null):Array
		{
			var sFactory:Function = stateFactory != null ? stateFactory : createState;
			var states:Array = iterateStates(definitions, sFactory);
			
			// first put the states in a Dynamic Object
			var statesDO:Object = new Object;
			for each(var definition:Object in states)
				statesDO[definition] = definition;
				
			setFroms(definitions, statesDO);
			return states;
		}
		
		
		private static function iterateStates(definitions:Array, factory:Function):Array
		{
			var children:Array = [];
			
			if(definitions)
			{
				for each(var definition:Object in definitions)
				{
					children.push(factory(
						definition.name,
						definition.initial == true,
						definition.allow,
						iterateStates(definition.children, factory)
						));
				}
			}
			
			return children;
		}
		
		private static function setFroms(definitions:Array, brothers:Object):void
		{
			
			
			for each(var definition:Object in definitions)
			{
				var froms:Array = [];
				
				if (definition.from)
				{
					// Check if every from is a brother (exist in brosDO)
					for each(var from:String in definition.from)
					{						
						var b:State = brothers[from];
						
						if(!b)
							throw new IllegalOperationError("unknown brother state '" + from + "' in from attribute");
						
						froms.push(b);
					}
				}
			
				var state:State = brothers[definition.name];
				state.setFrom(froms);
			
				setFroms(definition.children, state.children);
			}
		}
		
		private static function createState(name:String, initial:Boolean, allow:Array, arrChild:Array):State
		{
			return new State(name, initial, allow, arrChild);
		}
		
	}

}