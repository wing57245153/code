package modules.login.view
{
	import flash.events.MouseEvent;
	
	import modules.login.LoginUI;
	import modules.login.event.LoginEvent;
	
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.signals.natives.sets.NativeSignalSet;
	
	public class LoginView extends LoginUI
	{
		protected var viewSignal:Signal;
		
		private var nativeSignal:NativeSignal;
		public function LoginView(signal:Signal)
		{
			super();
			this.viewSignal = signal;
			
			nativeSignal = new NativeSignal(enterBtn, MouseEvent.CLICK,MouseEvent);
			nativeSignal.add(onClickHandler);
			
//			nativeSignal.
			
//			var signalSet:NativeSignalSet = new NativeSignalSet(null);
//			signalSet.
			//enterBtn.addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		protected function onClickHandler(event:MouseEvent):void
		{
			trace("enter");
			viewSignal.dispatch(LoginEvent.HIDE_MODULE);
		}
	}
}