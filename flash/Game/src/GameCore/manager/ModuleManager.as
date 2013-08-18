package GameCore.manager
{
	import GameCore.common.display.StageProxy;
	import GameCore.core.BasicManager;
	import GameCore.events.AppEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class ModuleManager extends BasicManager
	{
		public function ModuleManager()
		{
			modulesGroup = new Dictionary();
			
			messenger.add(onModuleHandler);
		}
		
		private function onModuleHandler(type:String, data:Object = null):void
		{
			trace(type);
			
			switch(type)
			{
				case AppEvent.MODULE_SHOW_WINDOW:
					showModule();
					break;
				case AppEvent.MODULE_HIDE_WINDOW:
					hideModule();
					break;
				default:
					break;
			}
		}
		
		private function showModule():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			loader.load(new URLRequest("modules/login/LoginModule.swf"));
		}
		
		private function hideModule():void
		{
			if(modulesGroup[1])
			{
				modulesGroup[1].visible = false;
			}
		}
		
		protected function onCompleteHandler(event:Event):void
		{
			var content:DisplayObject = (event.target as LoaderInfo).content;
			StageProxy.addChild(content);
			
			modulesGroup[1] = content;
		}
		
		private var modulesGroup:Dictionary; //已经加载过的模块
		
	}
}