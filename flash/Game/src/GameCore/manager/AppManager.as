package GameCore.manager
{
	import GameCore.core.BasicManager;
	import GameCore.events.AppEvent;

	public class AppManager extends BasicManager
	{
		public function AppManager()
		{
			super();
			init();
		}
		
		private function init():void
		{
			new ModuleManager();
			
			messenger.dispatch(AppEvent.MODULE_SHOW_WINDOW, "modules/login/LoginModule.swf");
		}
	}
}