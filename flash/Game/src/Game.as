package
{
	import GameCore.interfaces.Interface;
	import GameCore.manager.AppManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class Game extends Sprite
	{
		public function Game()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddStageHandler);
		}
		
		protected function onAddStageHandler(event:Event):void
		{
			init();
		}
		
		private function init():void
		{
			Interface.gameBus = new Signal();
			
			new AppManager();
		}
	}
}