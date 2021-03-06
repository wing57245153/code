package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import GameCore.common.display.StageProxy;
	import GameCore.core.Interface;
	import GameCore.manager.GameManager;
	
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
			App.init(this);
			StageProxy.regist(this.stage);
			Interface.gameBus = new Signal();
			Interface.loadAssets = App.loader.loadAssets;
			new GameManager();
		}
	}
}