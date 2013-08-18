package modules.login
{
	import GameCore.controller.LoginController;
	import GameCore.core.BasicModule;
	
	import modules.login.view.LoginView;
	
	public class LoginModule extends BasicModule
	{
		public function LoginModule()
		{
			resUrl = "assets/login.swf";
			super();
		}
		
		override protected function loadUIComplete():void
		{
			super.loadUIComplete();
			addChild(new LoginView(signal));
			new LoginController(signal);
		}
	}
}