package game.view.chat 
{
	import flash.events.MouseEvent;
	import game.ui.chat.ChatUI;
	
	/**
	 * ...
	 * @author woko
	 */
	public class ChatView extends ChatUI 
	{
		
		public function ChatView() 
		{
			tab.addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		private function onClickHandler(e:MouseEvent):void 
		{
			trace("hhahah");
		}
		
	}

}