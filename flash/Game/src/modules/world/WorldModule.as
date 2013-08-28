package modules.world
{
	import flash.geom.Point;
	
	import GameCore.core.BasicModule;
	import GameCore.entity.Player;
	import GameCore.entity.factory.EntityFactory;
	import GameCore.space.Space;
	
	public class WorldModule extends BasicModule
	{
		public function WorldModule()
		{
			super();
		}
		
		private var m_space:Space;
		override protected function loadUIComplete():void
		{
			m_space = new Space();
			m_space.parent = this;
		
			m_space.draw( new Point(1,1));
			
			addPlayer();
		}
		
		private function addPlayer():void
		{
			var player:Player = EntityFactory.getInstance().createPlayer();
			var config:Object = {};
			config.type = "player";
			config.id = "0220002";
			config.state = "run";
			player.config = config;
			
			this.addChild(player);
		}
		
		
	}
}