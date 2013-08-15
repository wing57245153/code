package GameCore.manager
{
	import GameCore.core.BasicManager;
	import GameCore.interfaces.Interface;
	
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
			
			messenger.dispatch("signal");
		}
	}
}