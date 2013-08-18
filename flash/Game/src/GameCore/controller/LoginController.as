package GameCore.controller
{
	import GameCore.core.BasicController;
	import GameCore.events.AppEvent;
	import GameCore.gameconfig.module_config;
	
	import modules.login.event.LoginEvent;
	
	import org.osflash.signals.Signal;
	
	public class LoginController extends BasicController
	{
		public function LoginController(signal:Signal=null)
		{
			super(signal);
			
		}
		
		override public function depose():void
		{
			
		}
		
		override protected function moduleEventHandler(type:String, data:Object = null):void
		{
			switch(type)
			{
				case LoginEvent.HIDE_MODULE:
					hideModule();
					break;
			}
		}
		
		private function hideModule():void
		{
			messenger.dispatch(AppEvent.MODULE_HIDE_WINDOW, module_config.LOGIN_MODULE);
		}
	}
}