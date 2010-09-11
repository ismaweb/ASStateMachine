package
{
	import asstatemachine.StateMachine;
	import asstatemachine.DOStateCreator;
	import asstatemachine.StateMachineSignal;
	
	
	public class ExampleSM extends StateMachine
	{
		private const SIG_SOCKET_TRY_CONNECT:String = "socket_try";
		private const SIG_SOCKET_CONNECTED:String = "socket_connected";
		private const SIG_SOCKET_FAIL:String = "socket_fail";
		private const SIG_SOCKET_DISCONNECTED:String = "socket_disconnected";
		private const SIG_SOCKET_IO_ERROR:String = "socket_io_error";
		
		
		public function ExampleSM(name:String) 
		{
			var childs:Array = [
				{name:"disconnected", initial:true, allow:[SIG_SOCKET_TRY_CONNECT] },
				{name:"connecting", from:["disconnected"], allow:[SIG_SOCKET_CONNECTED, SIG_SOCKET_FAIL] },
				{name:"connected", from:["connecting"], allow:[SIG_SOCKET_DISCONNECTED, SIG_SOCKET_IO_ERROR], children:[
					{name:"no_room", initial:true, from:["owning_room", "joining_room", "listing_rooms", "exiting_room"] },
					{name:"owning_room", from:["no_room"] },
					{name:"own_room", from:["owning_room"] },
					{name:"listing_rooms", from:["no_room"] },
					{name:"joining_room", from:["no_room"] },
					{name:"join_room", from:["joining_room"] },
					{name:"exiting_room", from:["join_room","own_room"] }
				]}
			];
			
			// create from a Dynamic Object array
			super(name, DOStateCreator.fromDO(childs));
			
		}
		
		//signal state logic
		public function socketTryConnect(args:Object):void
		{ 
			if(go(s.connecting))
				signal(SIG_SOCKET_TRY_CONNECT, args);
		}
		
		//signal state logic
		public function socketConnected(args:Object):void
		{ 
			if(go(s.connected))
				signal(SIG_SOCKET_CONNECTED , args);
		}
		
		//signal state logic
		public function socketFail(args:Object):void
		{ 
			if(go(s.disconnected))
				signal(SIG_SOCKET_FAIL, args); 
		}
		
		//signal state logic
		public function socketIOError(args:Object):void
		{
			if(go(s.disconnected))
				signal(SIG_SOCKET_IO_ERROR , args);
		}
		
		//signal state logic
		public function socketDisconnected(args:Object):void
		{ 
			if(go(s.disconnected))
				signal(SIG_SOCKET_DISCONNECTED , args); 
		}
		
		// map signal handlig
		public function addSocketTryConnectHandler(handler:Function):void { addSignalHandler(SIG_SOCKET_TRY_CONNECT, handler); }
		public function addConnectedHandler(handler:Function):void { addSignalHandler(SIG_SOCKET_CONNECTED, handler); }
		public function addSocketFailHandler(handler:Function):void { addSignalHandler(SIG_SOCKET_FAIL, handler); }
		public function addIOErrorHandler(handler:Function):void { addSignalHandler(SIG_SOCKET_IO_ERROR, handler); }
		public function addDisconnectedHandler(handler:Function):void { addSignalHandler(SIG_SOCKET_DISCONNECTED, handler); }
		
		// map output events (state change events) into listeners
		public function addDisconnectedListener(listener:Function):void { s.disconnected.listenEnter(listener); }
		public function addConnectedListener(listener:Function):void { s.connected.listenEnter(listener); }
		public function addConnectingListener(listener:Function):void { s.connecting.listenEnter(listener); }
		
	}

}