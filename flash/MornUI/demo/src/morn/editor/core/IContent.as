/**
 * Morn UI Version 2.0.0526 http://code.google.com/p/morn https://github.com/yungzhu/morn
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.editor.core {
	import flash.display.Sprite;
	
	/**面板接口，实现了编辑器遮罩类型*/
	public interface IContent {
		function get content():Sprite;
	}
}