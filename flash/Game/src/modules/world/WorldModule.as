package modules.world
{
	import flash.geom.Point;
	
	import GameCore.core.BasicModule;
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
		}
	}
}