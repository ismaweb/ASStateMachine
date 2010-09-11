package asstatemachine
{
	/**
	 * ...
	 * @author isma
	 */
	public class StateMachine_Test extends StateMachine
	{
		import org.flexunit.Assert;
		
		private var xml:XML;
		
		private var disconnected_entered:Boolean = false;
		private var disconnected_exited:Boolean = false;
		private var connecting_entered:Boolean = false;
		private var connecting_exited:Boolean = false;
		private var connected_entered:Boolean = false;
		private var connected_exited:Boolean = false;
		private var no_room_entered:Boolean = false;
		private var no_room_exited:Boolean = false;
		private var listing_rooms_entered:Boolean = false;
		private var listing_rooms_exited:Boolean = false;
		private var transition_denied:Boolean = false;
		private var transition_complete:Boolean = false;
		
		private var test_signal:String = "test_signal";
		private var signal_recieved:Boolean = false;
		private var recieved_args:Object = null;
		private var recieved_signal:String = null;
		
		public function StateMachine_Test()
		{
			super("SM", [
				new State("disconnected", true),
				new State("connecting"),
				new State("connected", false, [test_signal], [
					new State("no_room", true),
					new State("owning_room"),
					new State("own_room"),
					new State("listing_rooms"),
					new State("joining_room"),
					new State("join_room"),
					new State("exiting_room")
				])
			]);
			
			s.connecting.setFrom([ s.disconnected ]);
			
			s.connected.setFrom([ s.connecting ]);
			
			s.connected.s.no_room.setFrom([
				s.connected.s.owning_room,
				s.connected.s.joining_room,
				s.connected.s.listing_rooms,
				s.connected.s.exiting_room
			]);
			
			s.connected.s.listing_rooms.setFrom([ s.connected.s.no_room ]);
			
			s.connected.s.owning_room.setFrom([ s.connected.s.no_room ]);
			s.connected.s.own_room.setFrom([ s.connected.s.owning_room ]);
			
			s.connected.s.joining_room.setFrom([ s.connected.s.no_room ]);
			s.connected.s.join_room.setFrom([ s.connected.s.joining_room ]);
			
			s.connected.s.exiting_room.setFrom([ 
				s.connected.s.join_room,
				s.connected.s.own_room
			]);
			
			s.disconnected.listenEnter( 
				function(e:StateMachineEvent):void { disconnected_entered = true; } );
				
			s.disconnected.listenExit( 
				function(e:StateMachineEvent):void { disconnected_exited = true; } );
				
			s.connecting.listenEnter(    
				function(e:StateMachineEvent):void { connecting_entered = true; } );
				
			s.connecting.listenExit(   
				function(e:StateMachineEvent):void { connecting_exited = true; } );
				
			s.connected.listenEnter(  
				function(e:StateMachineEvent):void { connected_entered = true; } );
				
			s.connected.listenExit(   
				function(e:StateMachineEvent):void { connected_exited = true; } );
				
			addSignalHandler(test_signal,
				function(e:StateMachineSignal): void { 
					signal_recieved = true; 
					recieved_signal = e.signal
					recieved_args = e.args; 
				});
				
			s.connected.s.no_room.listenEnter(  
				function(e:StateMachineEvent):void { no_room_entered = true; } );
				
			s.connected.s.no_room.listenExit(   
				function(e:StateMachineEvent):void { no_room_exited = true; } );
				
			s.connected.s.listing_rooms.listenEnter(  
				function(e:StateMachineEvent):void { listing_rooms_entered = true; } );
				
			s.connected.s.listing_rooms.listenExit(   
				function(e:StateMachineEvent):void { listing_rooms_exited = true; } );
			
			addEventListener(StateMachineEvent.TRANSITION_DENIED,  
				function(e:StateMachineEvent):void { transition_denied = true; } );
				
			addEventListener(StateMachineEvent.TRANSITION_COMPLETE,  
				function(e:StateMachineEvent):void { transition_complete = true; } );
			
			init();
		}
		
		[Before]
		public function before():void
		{
			go(s.disconnected);
			
			disconnected_entered = false;
			disconnected_exited = false;
			connecting_entered = false;
			connecting_exited = false;
			connected_entered = false;
			connected_exited = false;
			transition_denied = false;
			transition_complete = false;
			signal_recieved = false;
			recieved_args = null;
			recieved_signal = null;
		}
		
		[Test]
		public function creation():void
		{
			Assert.assertEquals(name, "SM");
			Assert.assertNotNull(s.disconnected);
			Assert.assertNotNull(s.connecting);
			Assert.assertNotNull(s.connected);
			Assert.assertNotNull(s.connected.s.no_room);
			Assert.assertNotNull(s.connected.s.owning_room);
			Assert.assertNotNull(s.connected.s.own_room);
			Assert.assertNotNull(s.connected.s.listing_rooms);
			Assert.assertNotNull(s.connected.s.joining_room);
			Assert.assertNotNull(s.connected.s.join_room);
			Assert.assertNotNull(s.connected.s.exiting_room);
		}
		
		[Test]
		public function froms():void
		{
			Assert.assertNotNull(s.connecting.acceptFrom(s.disconnected));
			Assert.assertNotNull(s.connected.acceptFrom(s.connecting));
			Assert.assertNotNull(s.connected.s.no_room.acceptFrom(s.connected.s.owning_room));
			Assert.assertNotNull(s.connected.s.no_room.acceptFrom(s.connected.s.joining_room));
			Assert.assertNotNull(s.connected.s.no_room.acceptFrom(s.connected.s.listing_rooms));
			Assert.assertNotNull(s.connected.s.no_room.acceptFrom(s.connected.s.exiting_room));
			Assert.assertNotNull(s.connected.s.listing_rooms.acceptFrom(s.connected.s.no_room));
			Assert.assertNotNull(s.connected.s.owning_room.acceptFrom(s.connected.s.no_room));
			Assert.assertNotNull(s.connected.s.own_room.acceptFrom(s.connected.s.owning_room));
			Assert.assertNotNull(s.connected.s.joining_room.acceptFrom(s.connected.s.no_room));
			Assert.assertNotNull(s.connected.s.join_room.acceptFrom(s.connected.s.joining_room));
			Assert.assertNotNull(s.connected.s.exiting_room.acceptFrom(s.connected.s.join_room));
			Assert.assertNotNull(s.connected.s.exiting_room.acceptFrom(s.connected.s.own_room));
		}
		
		[Test]
		public function denied_go_3():void
		{	
			go(s.connected);
			Assert.assertTrue(transition_denied);
			Assert.assertFalse(disconnected_exited);
			Assert.assertFalse(connected_entered);
			Assert.assertEquals(state, s.disconnected);
		}
		
		[Test]
		public function go_2():void
		{	
			go(s.connecting);
			Assert.assertTrue(disconnected_exited);
			Assert.assertTrue(connecting_entered);
			Assert.assertEquals(state, s.connecting);
		}
		
		[Test]
		public function go_3():void
		{
			go(s.connecting);
			Assert.assertFalse(connecting_exited);
			Assert.assertFalse(no_room_entered);
			
			go(s.connected);
			Assert.assertTrue(connecting_exited);
			Assert.assertTrue(connected_entered);
			Assert.assertTrue(no_room_entered);
			Assert.assertFalse(connected_exited);
			
			Assert.assertEquals(state, s.connected.s.no_room);
			
			Assert.assertTrue(isActive(this));
			Assert.assertTrue(isActive(s.connected));
			Assert.assertTrue(isActive(s.connected.s.no_room));
		}
		
		[Test]
		public function go_3_2():void
		{
			go(s.connecting);
			go(s.connected);
			
			Assert.assertTrue(no_room_entered);
			
			go(s.connected.s.listing_rooms);
			Assert.assertFalse(transition_denied);
			Assert.assertFalse(connected_exited);
			Assert.assertTrue(no_room_exited);
			
			Assert.assertTrue(isActive(this));
			Assert.assertTrue(isActive(s.connected));
			Assert.assertFalse(isActive(s.connected.s.no_room));
			Assert.assertTrue(isActive(s.connected.s.listing_rooms));
		}
		
		[Test]
		public function return_1_1():void
		{
			go(s.connecting);
			go(s.connected);
			go(s.connected.s.listing_rooms);
			
			transition_complete = false;
			disconnected_entered = false;
			listing_rooms_exited = false;
			connected_exited = false;
			go(s.disconnected);
			
			Assert.assertTrue(transition_complete);
			Assert.assertTrue(listing_rooms_exited);
			Assert.assertTrue(connected_exited);
			Assert.assertTrue(disconnected_entered);
			Assert.assertEquals(state, s.disconnected);
			Assert.assertTrue(isActive(this));
			Assert.assertTrue(isActive(s.disconnected));
		}
		
		[Test]
		public function return_1_2():void
		{
			go(s.connecting);
			go(s.connected);
			go(s.connected.s.listing_rooms);
			
			transition_denied = false;
			transition_complete = false;
			disconnected_entered = false;
			listing_rooms_exited = false;
			connected_exited = false;
			go(s.connecting); // not allowed
			
			Assert.assertTrue(transition_denied);
			Assert.assertFalse(transition_complete);
			Assert.assertFalse(listing_rooms_exited);
			Assert.assertFalse(connected_exited);
			Assert.assertEquals(state, s.connected.s.listing_rooms);
			Assert.assertTrue(isActive(this));
			Assert.assertTrue(isActive(s.connected));
			Assert.assertTrue(isActive(s.connected.s.listing_rooms));
		}
		
		[Test]
		public function listenedSignal():void
		{
			go(s.connecting);
			go(s.connected);
			
			var args:Object = { arg1:"test" };
			
			signal(test_signal, args);
			
			Assert.assertTrue(signal_recieved);
			Assert.assertEquals(test_signal, recieved_signal);
			Assert.assertEquals(args, recieved_args);
		}
		
		[Test]
		public function unlistenedSignal():void
		{
			var args:Object = { arg1:"test" };
			
			//is in disconnected who isn't listening for test_signal
			signal(test_signal, args);
			
			Assert.assertFalse(signal_recieved);
			Assert.assertNull(recieved_signal);
			Assert.assertNull(recieved_args);
		}
		
	}

}