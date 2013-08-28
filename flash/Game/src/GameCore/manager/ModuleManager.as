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
	import GameCore.gameconfig.module_config;
	import GameCore.layer.LayerBase;
	import GameCore.layer.ModuleLayer;

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
					hideModule(url);
					break;
				default:
					break;
			}
		}
		
		private function showModule(url:String):void
		{
			ModuleLoader.getInstance().load(url);
		}
		
		private function hideModule(url:String):void
		{
			if(modulesGroup[url])
			{
				modulesGroup[url].visible = false;
			}
		}
		
		/**
		 * 模块加载处理
		 */
		private function onModuleLoadHandler(type:String, url:String, content:*):void
		{
			var parent:LayerBase;
			var moduleInfo:Object = module_config.MODUL_INFO["url"];
			if(moduleInfo == null || moduleInfo["layer"] == null)
			{
				parent = ModuleLayer.getInstance();
			}
			else 
			{
				parent = module_config.LAYER_INFO[moduleInfo["layer"]];
			}
			switch(type)
			{
				case ModuleLoader.COMPLETE:
					parent.addChild(content);
					modulesGroup[url] = content;
					break;
			}
		}
		
		private var modulesGroup:Dictionary; //已经加载过的模块
		
	}
}