package modules.login.view
{
	import flash.events.MouseEvent;
	
	import modules.login.LoginUI;
	
	public class LoginView extends LoginUI
	{
		public function LoginView()
		{
			super();
			enterBtn.addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		protected function onClickHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			trace("enter");
		}
	}
}