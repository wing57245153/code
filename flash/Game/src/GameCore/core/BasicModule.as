package GameCore.core
{
	import GameCore.interfaces.IDepose;
	
	import flash.display.Sprite;
	
	import morn.core.handlers.Handler;
	
	import org.osflash.signals.Signal;

	public class BasicModule extends Sprite implements IDepose
	{
		protected var messenger:Signal;//
		protected var resUrl:String;
		protected var signal:Signal;
		public function BasicModule()
		{
			messenger = Interface.gameBus;
			signal = new Signal();
			loadUI();
		}
		
		public function depose():void
		{
			
		}
		
		protected function loadUI():void
		{
			if(resUrl == null)
				loadUIComplete();
			else
				Interface.loadAssets([resUrl], new Handler(loadUIComplete));
			
		}
		
		protected function loadUIComplete():void
		{
			
		}
	}
}