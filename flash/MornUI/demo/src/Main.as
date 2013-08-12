package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import game.view.chat.ChatView;
	import morn.core.handlers.Handler;
	
	/**
	 * ...
	 * @author woko
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			App.init(this);
			App.loader.loadAssets(["assets/comp.swf", "assets/other.swf", "assets/bg.swf", "assets/module.swf"], new Handler(loadComplete));
		}
		
		private function loadComplete():void 
		{
			addChild(new ChatView());
		}
		
	}
	
}