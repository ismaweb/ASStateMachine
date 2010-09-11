package asstatemachine
{
	/**
	 * ...
	 * @author isma
	 */
	public class XMLStateCreator_Test extends StateMachine
	{
		//import com.flashogf.core.statemachine.XMLStateMachineCreator;
		import flash.xml.XMLNode;
		import org.flexunit.Assert;
		
		private var xml:XML;
		
		public function XMLStateCreator_Test()
		{
			xml = 
				<states>
					<state name="disconnected" initial="true" allow="try_connect" />
					<state name="connecting" from="disconnected" allow="connect_fail,connect_ok" />
					<state name="connected" from="connecting" allow="disconnect,io_error">
						<state name="no_room" initial="true" from="owning_room,joining_room,listing_rooms,exiting_room" />
						<state name="owning_room" from="no_room" />
						<state name="own_room" from="owning_room" />
						<state name="listing_rooms" from="no_room" />
						<state name="joining_room" from="no_room" />
						<state name="join_room" from="joining_room" />
						<state name="exiting_room" from="join_room,own_room" />
					</state>
				</states>;
				
			super("SM", XMLStateCreator.fromXML(xml));
			
			init();
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
			var f:Function = function(x:XML, parent:State, f:Function):void {
				for each(var c:XML in x.children())			
				{
					var froms:String = c.attribute("from");
					var child:State = parent.s[c.attribute("name")];
					
					if (froms != '')
					{
						for each (var from:String in froms.split(",")) 
							Assert.assertNotNull(child.acceptFrom(parent.s[from]));
						
					}
					
					f(c, child, f);
				}
			}
			
			f(xml, this, f);
		}
		
		[Test]
		public function allows():void
		{
			Assert.assertTrue(s.disconnected.allowed("try_connect"));
			Assert.assertFalse(s.disconnected.allowed("io_error"));
			Assert.assertTrue(s.connecting.allowed("connect_ok"));
			Assert.assertTrue(s.connecting.allowed("connect_fail"));
			Assert.assertTrue(s.connected.allowed("disconnect"));
			Assert.assertTrue(s.connected.allowed("io_error"));
		}
		
	}

}