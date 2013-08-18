/**Created by Morn,Do not modify.*/
package modules.login {
	import morn.core.components.*;
	public class LoginUI extends View {
		public var enterBtn:Button;
		protected var uiXML:XML =
			<View>
			  <Image url="png.login.clan" x="97" y="15"/>
			  <TextInput text="TextInput" skin="png.comp.textinput" x="110" y="55"/>
			  <TextInput text="TextInput" skin="png.comp.textinput" x="111" y="97"/>
			  <Button label="进入" skin="png.comp.button" x="123" y="161" var="enterBtn"/>
			</View>;
		override protected function createChildren():void {
			createView(uiXML);
		}
	}
}