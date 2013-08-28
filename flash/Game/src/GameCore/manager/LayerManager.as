package GameCore.manager
{
	import GameCore.common.display.StageProxy;
	import GameCore.core.BasicManager;
	import GameCore.layer.ModuleLayer;
	import GameCore.layer.WorldLayer;
	
	public class LayerManager extends BasicManager
	{
		public function LayerManager()
		{
			super();
			init();
		}
		
		private function init():void
		{
			StageProxy.stage.addChild(ModuleLayer.getInstance());
			StageProxy.stage.addChild(WorldLayer.getInstance());
		}
	}
}