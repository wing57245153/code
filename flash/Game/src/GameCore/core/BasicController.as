package GameCore.core
{
	import GameCore.interfaces.IDepose;
	
	import org.osflash.signals.Signal;

	public class BasicController implements IDepose
	{
		protected var messenger:Signal;// 全局信号传递
		protected var viewSignal:Signal; // 模块内信号传递
		public function BasicController(signal:Signal = null)
		{
			messenger = Interface.gameBus;
			this.viewSignal = signal;
			
			initEvent();
		}
		
		public function depose():void
		{
			
		}
		
		private function initEvent():void
		{
			if(viewSignal)
			{
				viewSignal.add(moduleEventHandler);
			}
		}
		
		protected  function moduleEventHandler(type:String, data:Object = null):void
		{
			
		}
	}
}