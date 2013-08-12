/**Created by Morn,Do not modify.*/
package game.ui.chat {
	import morn.core.components.*;
	public class ChatUI extends View {
		public var tab:Button;
		protected var uiXML:XML =
			<View>
			  <Image url="png.bg.bg_1" x="-4" y="-3"/>
			  <Button label="label" skin="png.other.btn_tab" x="29" y="65" var="tab"/>
			  <Image url="png.module.chat.bg" x="128" y="197"/>
			</View>;
		override protected function createChildren():void {
			createView(uiXML);
		}
	}
}