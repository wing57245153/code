package GameCore.common.loader
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import GameCore.gameconfig.loader_config;
    
    import org.osflash.signals.Signal;

    public class LocalCacheManager 
    {
        private static var _instance:LocalCacheManager;

		public var loaderSignal:Signal;
        private var _urlDic:Dictionary;
        private var _domainDic:Dictionary;
        private var _loadingDic:Dictionary;
        private var _httpUrlList:Array;
        private var _curLoaderCount:int;

        public function LocalCacheManager()
        {
			loaderSignal = new Signal();
            _urlDic = new Dictionary();
            _domainDic = new Dictionary();
            _loadingDic = new Dictionary();
            _httpUrlList = [];
        }

        public static function getInstance() : LocalCacheManager
        {
            if(_instance == null)
                _instance = new LocalCacheManager();
            return _instance;
        }

        public function loadFile(url:String, content:LoaderContext = null) : void
        {
            if(url == null || _loadingDic[url] == true)
                return;
            _loadingDic[url] = true;
            if(content)
                _domainDic[url] = content;
            //插队优化
            var i:int = 0;
            var j:int = 0;
           for(i = 0; i < loader_config.PRIORITY_QUEUE.length; i++)
            {
               if(url.indexOf(loader_config.PRIORITY_QUEUE[i]) > -1)
                   break;
            }
            if(i == 0)
            {
                _httpUrlList.unshift(url);
            }
          else if(i < loader_config.PRIORITY_QUEUE.length)
            {
                for(j = 0; j < _httpUrlList.length; j++)
                {
                    for(var z:int = 0; z < i; z++)
                    {
                       if(_httpUrlList[j].indexOf(loader_config.PRIORITY_QUEUE[z]) > -1)
                           break;
                    }
                    if(z >= i)
                        break;
                }
                if(j >= _httpUrlList.length)
                    _httpUrlList.push(url);
                else
                    _httpUrlList.splice(j, 0, url);
            }
            else
            {
                _httpUrlList.push(url);
            }
            sendHTTPwebRequest();
        }

        /**
         * 控制请求HTTP个数
         */
        private function sendHTTPwebRequest() : void
        {
            if(_curLoaderCount > 0 || _httpUrlList.length < 1)
                return;
            var url:String = _httpUrlList.shift();
            var urlLoader:URLLoader = new URLLoader();
            _urlDic[urlLoader] = url;
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompelteHandler);
            urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.load(new URLRequest(url));
            _curLoaderCount++;
        }

        private function urlLoaderCompelteHandler(evt:Event) : void
        {
            _curLoaderCount--;
            sendHTTPwebRequest();
            var writeByte:ByteArray;
            var url:String = _urlDic[evt.target];
            var byte:ByteArray = URLLoader(evt.target).data as ByteArray;
            var stream:ByteArray = new ByteArray();
            stream.writeBytes(byte);
            stream.position = 0;
//            CONFIG::debug
//            {
//                Logger.debug("load completed: " + url);
//            }
            var a:int = stream.readUnsignedByte();
            var b:int = stream.readUnsignedByte();
            var c:int = stream.readUnsignedByte();
            stream = null;
            if(a == 170 && b == 170 && c == 170) //判断SWF为加密 则解密
            {
                var temp:ByteArray = new ByteArray();
                temp.writeByte(67);
                temp.writeByte(87);
                temp.writeByte(83);

                temp.writeBytes(byte, 3);

                byte = temp;
            }
            writeByte = new ByteArray();
            writeByte.writeBytes(byte);
            removeLoaderEvent(evt.target);
            var loader:Loader;
            var signStr:String = url.substr(-2, 2);
            switch(signStr)
            {
                case "wf":
                    loader = new Loader();
                    _urlDic[loader.contentLoaderInfo] = url;
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
                    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                    loader.loadBytes(byte, LoaderContext(_domainDic[url]));
                    delete _domainDic[url];
                    break;
                case "ng":
                    loader = new Loader();
                    _urlDic[loader.contentLoaderInfo] = url;
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
                    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                    loader.loadBytes(byte);
                    break;
                case "pg":
                    loader = new Loader();
                    _urlDic[loader.contentLoaderInfo] = url;
                    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
                    loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                    loader.loadBytes(byte);
                    break;
            }
            byte = null;
            writeByte = null;
        }

        private var _loadingCXml:Vector.<String> = new Vector.<String>();

        private function onCompressXmlLoaded(e:Event) : void
        {
            e.target.removeEventListener(Event.COMPLETE, onCompressXmlLoaded);
            var dic:Dictionary = new Dictionary();
            var total:int = e.target.getFileCount();
            for(var i:int = 0; i < total; i++)
            {
//                var file:FZipFile = e.target.getFileAt(i);
//                dic[file.filename] = file.getContentAsString();
            }
            var url:String = _loadingCXml.shift();
            delete _loadingDic[url];
           // dispatchEvent(new LocalCacheEvent(Event.COMPLETE, url, dic));
			loaderSignal.dispatch(Event.COMPLETE, url, dic);
        }

        private function onProgressHandler(evt:ProgressEvent) : void
        {
			loaderSignal.dispatch(ProgressEvent.PROGRESS, _urlDic[evt.target], {bytesLoaded: evt.bytesLoaded, bytesTotal: evt.bytesTotal});
        }

        private function onCompleteHandler(evt:Event) : void
        {
            var content:Object;
            if(evt.target is LoaderInfo)
            {
                content = LoaderInfo(evt.target).content;
            }
            if(evt.target is URLLoader)
            {
                content = URLLoader(evt.target).data;
            }

			loaderSignal.dispatch(Event.COMPLETE,  _urlDic[evt.target], content);
			
            delete _loadingDic[_urlDic[evt.target]];
            removeLoaderEvent(evt.target);
			
        }

        private function ioErrorHandler(evt:IOErrorEvent) : void
        {
            var url:String = _urlDic[evt.target];
            if(evt.target is URLLoader)
            {
                _curLoaderCount--;
                sendHTTPwebRequest();
            }
			loaderSignal.dispatch(IOErrorEvent.IO_ERROR,  _urlDic[evt.target], null);
			
            delete _loadingDic[_urlDic[evt.target]];
            removeLoaderEvent(evt.target);
			
        }

        private function removeLoaderEvent(obj:Object) : void
        {
            if(obj is LoaderInfo)
            {
                var loaderInfo:LoaderInfo = obj as LoaderInfo;
                loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
                loaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
                loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

                if(loaderInfo.loader.content is MovieClip)
                    MovieClip(loaderInfo.loader.content).stop();
                if(loaderInfo.applicationDomain != ApplicationDomain.currentDomain &&
                    _urlDic[obj] && _urlDic[obj].indexOf("/res/") > -1)
                {
                    loaderInfo.loader.unload();
                }
            }
            else if(obj is URLLoader)
            {
                try
                {
                    URLLoader(obj).close();
                }
                catch(e:Error)
                {

                }
                URLLoader(obj).removeEventListener(Event.COMPLETE, urlLoaderCompelteHandler);
                URLLoader(obj).removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
                URLLoader(obj).removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            }
            delete _loadingDic[_urlDic[obj]];
            delete _urlDic[obj];
        }

        public function stopOldSceneLoading() : void
        {
//            Logger.debug("stop old loadings:");
            var url:String;
            for(var i:int = _httpUrlList.length - 1; i > 0; i--)
            {
                url = _httpUrlList[i];
                if(url.indexOf("res/scene") > -1 || url.indexOf("ui/copy") > -1)
                {
                    stopLoading(url);
//                    Logger.debug("path: " + url);
                }
            }
            url = null;
        }

        public function stopLoading(url:String) : void
        {
            var index:int = _httpUrlList.indexOf(url);
            if(index > -1)
                _httpUrlList.splice(index, 1);
            delete _loadingDic[url];
            try
            {
                for(var i:* in _urlDic)
                {
                    if(_urlDic[i] == url)
                    {
                        if(i is LoaderInfo)
                        {
                            LoaderInfo(i).loader.unloadAndStop();
                        }
                        if(i is URLLoader)
                        {
                            URLLoader(i).close();
                        }
                        _curLoaderCount--;
                        removeLoaderEvent(i);
                        break;
                    }
                }
            }
            catch(e:Error)
            {
                _curLoaderCount--;
//                Logger.error("cannot stop loading: " + url);
            }
            sendHTTPwebRequest();
        }
    }
}
