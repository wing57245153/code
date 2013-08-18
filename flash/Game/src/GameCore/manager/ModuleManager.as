package GameCore.manager
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import GameCore.common.display.StageProxy;
	import GameCore.common.loader.ModuleLoader;
	import GameCore.core.BasicManager;
	import GameCore.events.AppEvent;

	public class ModuleManager extends BasicManager
	{
		public function ModuleManager()
		{
			modulesGroup = new Dictionary();
			ModuleLoader.getInstance().moduleLoaderSignal.add(onModuleLoadHandler);
			messenger.add(onModuleHandler);
		}
		
		private function onModuleHandler(type:String, url:String, data:Object = null):void
		{
			trace(type);
			
			switch(type)
			{
				case AppEvent.MODULE_SHOW_WINDOW:
					showModule(url);
					break;
				case AppEvent.MODULE_HIDE_WINDOW:
					hideModule();
					break;
				default:
					break;
			}
		}
		
		private function showModule(url:String):void
		{
//			var loader:Loader = new Loader();
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
//			loader.load(new URLRequest("modules/login/LoginModule.swf"));
			ModuleLoader.getInstance().load(url);
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
		
		/**
		 * 模块加载处理
		 */
		private function onModuleLoadHandler(type:String, url:String, content:*):void
		{
			switch(type)
			{
				case ModuleLoader.COMPLETE:
					StageProxy.addChild(content);
					modulesGroup[url] = content;
					break;
			}
		}
		
		private var modulesGroup:Dictionary; //已经加载过的模块
		
	}
}