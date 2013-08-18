package GameCore.manager
{
	import GameCore.core.BasicManager;
	import GameCore.core.Interface;
	import GameCore.events.AppEvent;
	
	import org.osflash.signals.Signal;

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
			
			messenger.dispatch(AppEvent.MODULE_SHOW_WINDOW);
		}
	}
}