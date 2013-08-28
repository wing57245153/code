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
			LocalCacheManager.getInstance().loaderSignal.add(onCompleteHandler);
        }

        public function load(url:String) : void
        {
            _loadingDic[url] = true;
            LocalCacheManager.getInstance().loadFile(url);
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
        }
    }
}
