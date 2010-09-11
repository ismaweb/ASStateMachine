package asstatemachine
{
	import flash.events.Event;
	
	/**
	 * Defines a signal that comes from system to the machine.
	 * <p>The state machine will raise the signal on the active states,
	 * each of them will raise it to its listeners, if a state is not 
	 * intended to handle that signal then will be silently ignored</p>
	 */
	public class StateMachineSignal extends Event
	{
		private var _args : Object;
		private var _signal:String;
		
		public function StateMachineSignal(signal:String, args:Object = null)
		{
			super(signal, false, false);
			_args = args;
			_signal = signal;
		}
		
		public function get args():Object
		{
			return _args;
		}
		
		public function get signal():String
		{
			return _signal;
		}
	}
}