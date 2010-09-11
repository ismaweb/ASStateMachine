package asstatemachine
{
	import flash.xml.XMLNode;
	import org.flexunit.Assert;
		
	public class DOStateCreator_Test extends StateMachine
	{
		private var childs:Array;
		
		public function DOStateCreator_Test()
		{
			childs = [
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
			
			super("SM", DOStateCreator.fromDO(childs));
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
		public function initials():void
		{
			Assert.assertTrue(s.disconnected.initial);
			Assert.assertFalse(s.connecting.initial);
			Assert.assertFalse(s.connected.initial);
			Assert.assertTrue(s.connected.s.no_room.initial);
			Assert.assertFalse(s.connected.s.owning_room.initial);
			Assert.assertFalse(s.connected.s.own_room.initial);
			Assert.assertFalse(s.connected.s.listing_rooms.initial);
			Assert.assertFalse(s.connected.s.joining_room.initial);
			Assert.assertFalse(s.connected.s.join_room.initial);
			Assert.assertFalse(s.connected.s.exiting_room.initial);
		}
		
		[Test]
		public function froms():void
		{
			var f:Function = function(definition:Object, state:State, f:Function):void {
				for each(var childDefinition:Object in definition.children)
				{
					var childState:State = state.children[childDefinition.name];
					
					for each (var from:String in childDefinition.from)
						Assert.assertTrue(childState.acceptFrom(state.s[from]));
					
					f(childDefinition, childState, f);
				}
			}
			
			var dynamicObject:Object = {children:new Object()};
			
			for each(var definition:Object in childs)
				dynamicObject.children[definition.name] = definition;
			
			f(dynamicObject, this, f);
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