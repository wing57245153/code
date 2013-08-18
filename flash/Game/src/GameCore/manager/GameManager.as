package GameCore.manager
{
	import GameCore.core.BasicManager;
	
	import morn.core.handlers.Handler;
	
	public class GameManager extends BasicManager
	{
		public function GameManager()
		{
			super();
			init();
		}
		
		private function init():void
		{
			//App
			App.loader.loadAssets(["assets/comp.swf"], new Handler(loadComplete));
		}
		
		private function loadComplete():void 
		{
			new AppManager();
		}
	}
}