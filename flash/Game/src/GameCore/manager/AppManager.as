package GameCore.manager
{
	import GameCore.core.BasicManager;
	import GameCore.events.AppEvent;
	import GameCore.gameconfig.module_config;

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
			
			messenger.dispatch(AppEvent.MODULE_SHOW_WINDOW, module_config.LOGIN_MODULE);
		}
	}
}