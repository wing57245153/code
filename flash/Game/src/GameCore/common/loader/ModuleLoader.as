package GameCore.common.loader
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    import org.osflash.signals.Signal;

    /**
     * Module 加载器
     * @author Selon
     */
    public class ModuleLoader 
    {
        public static const COMPLETE:String = "module_complete";
		private static var _instance:ModuleLoader;
		public var moduleLoaderSignal:Signal;
        private var _loadingDic:Dictionary;

		public static function getInstance() : ModuleLoader
		{
			if(_instance == null)
				_instance = new ModuleLoader();
			return _instance;
		}
		
        public function ModuleLoader()
        { 
			moduleLoaderSignal = new Signal();
            _loadingDic = new Dictionary();
           // LocalCacheManager.getInstance().addEventListener(Event.COMPLETE, onCompleteHandler);
			LocalCacheManager.getInstance().loaderSignal.add(onCompleteHandler);
        }

        public function load(url:String) : void
        {
            _loadingDic[url] = true;
            LocalCacheManager.getInstance().loadFile(url);
//            var isFrame:Boolean;
////            for each(var path:String in Config.frameList)
//            {
////                if(url.indexOf(path) > -1)
//                {
//                    isFrame = true;
////                    break;
//                }
//            }
//            if(!isFrame)
//                Interface.gameBus.dispatchEvent(new iEvent(AppEvent.LOADING_MODULE_BEGIN,
//                    {name: "模块"}));
        }

        private function onCompleteHandler(type:String, url:String, content:*) : void
        {
			if(_loadingDic[url])
			{
				switch(type)
				{
					case Event.COMPLETE:
						moduleLoaderSignal.dispatch(ModuleLoader.COMPLETE, url, content);
						delete _loadingDic[url];
						break;
				}
				
			}
//            if(_loadingDic[evt.url])
//            {
////                Interface.gameBus.dispatchEvent(new iEvent(AppEvent.LOADING_MODULE_END));
//                var item:ResLoaderItem = new ResLoaderItem();
//                item.data = evt.data;
//                item.url = evt.url;
//                dispatchEvent(new LoaderEvent(ModuleLoader.COMPLETE, item));
//                delete _loadingDic[evt.url];
//            }
        }
    }
}
