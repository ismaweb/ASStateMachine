package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import asstatemachine.StateMachineSignal;
	import asstatemachine.StateMachineEvent;
	
	import ExampleSM;
	
	public class Main extends Sprite 
	{
		private var sm:ExampleSM;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			sm = new ExampleSM("your_machine");
			
			sm.addSocketTryConnectHandler(tryConnect);
			
			//many times signals don't need special handling other than 
			//the state logic defined inside the state machine
			//sm.addConnectedHandler();
			//sm.addDisconnectedHandler();
			//sm.addSocketFailHandler();
			//sm.addIOErrorHandler();
			
			
			sm.addConnectingListener(onConnecting);
			sm.addConnectedListener(onConnected);
			sm.addDisconnectedListener(onDisconnected);
			
			// tells the machine to lock configuration and put it on the first state
			sm.init();
			
			sm.socketTryConnect({url:"www.example.org",port:1234});
		}
		
		private function tryConnect(sig:StateMachineSignal):void
		{
			//sig.args <- arguments
			
			//launch the socket connection attempt
			// socket connection success will launch asyncronously sm.socketConnected
			// socket connection fail will launch asyncronously sm.socketFail
			// socket io error will launch asyncronously sm.socketIOError
			// socket disconnection will launch asyncronously sm.socketDisconnected
		}
		
		private function onConnecting(sig:StateMachineEvent):void
		{
			trace("Connecting..."); 
		}
		
		private function onConnected(e:StateMachineEvent):void 
		{ 
			trace("Connected!"); 
		}
		
		private function onDisconnected(e:StateMachineEvent):void
		{
			trace("Now is disconnected");
		}
		
		
		
		
	}
	
}