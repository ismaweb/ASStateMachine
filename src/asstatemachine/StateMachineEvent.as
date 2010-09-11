package asstatemachine
{
	import flash.events.Event;
	
	/**
	 * Defines state transition events like enter, exit, transition complete or transition denied
	 */
	public class StateMachineEvent extends Event
	{
		public static const EXIT_CALLBACK:String = "exit";
		public static const ENTER_CALLBACK:String = "enter";
		public static const TRANSITION_COMPLETE:String = "transition complete";
		public static const TRANSITION_DENIED:String = "transition denied";
		
		private var _fromState : State;
		private var _toState : State;
		private var _currentState : State;
		
		public function StateMachineEvent(type:String, from:State = null, to:State = null, current:State = null)
		{
			super(type, false, false);
			_fromState = from;
			_toState = to;
			_currentState = current;
		}
		
		public function get from():State
		{
			return _fromState;
		}
		
		public function get to():State
		{
			return _toState;
		}
		
		public function get current():State
		{
			return _currentState;
		}
	}
}