package res
{
	
	import GameCore.gameconfig.loader_config;
	import GameCore.gameconfig.swfres_config;
	import GameCore.util.PathUtil;
	
	import debug.Debug;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * 资源统一加载
	 * @author yangxr
	 * @modify by selon
	 */
	public class DataRes
	{
		private static var _instance:DataRes;
		private var _urlDic:Dictionary;
		private var _loaderDic:Dictionary;
		private var _loadingDic:Dictionary;
		private var _paramsDic:Dictionary;
		private var _defBmdDic:Dictionary;//位图缓存
		private var _defMcDic:Dictionary;//mc缓存，人物Mcbody的放这里
		private var _httpUrlList:Array;
		private var _curLoaderCount:int;
		
		private var _loaderPool:Array;
		private var _decoderPool:Array;
		private var _decodelist:Array;
		private var _dataDic:Dictionary;
		
		public function DataRes()
		{
			_urlDic = new Dictionary();
			_loadingDic = new Dictionary();
			_loaderDic = new Dictionary();
			_paramsDic = new Dictionary();
			_defBmdDic = new Dictionary();
			_httpUrlList = [];
			
			_loaderPool = [];
			_decoderPool= [];
			_decodelist = [];
			_dataDic = new Dictionary();
			init();
		}
		
		public static function getInstance():DataRes
		{
			if (_instance == null)
				_instance = new DataRes();
			return _instance;
		}
		
		
		private  function init():void
		{
			for (var i:int = 0; i < loader_config.THREAD_NUM; i++)
			{
				var loader:SourceLoader = new SourceLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, urlLoaderCompelteHandler);
				loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);				
				_loaderPool.push(loader);
				var decoder:DecodeLoader = new DecodeLoader();
				decoder.contentLoaderInfo.addEventListener(Event.COMPLETE, onDecodeComplete);
				decoder.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDecodeErrorHandler);
				_decoderPool.push(decoder);
			}
		}
		
		//        public function isLoading(url:String):Boolean
		//        {
		//            return _loadingDic[url];
		//        }
		
		public function isLoaded(url:String):Boolean
		{
			// return _loaderDic[url] && !_loadingDic[url];
			return _dataDic[url];
		}
		
		/**
		 * @param url : 资源相对路径
		 * @param completeFunc : 带url参数的回调方法
		 * @param progressFunc : 带bytesLoaded和bytesTotal参数的回调方法
		 * @param errorFunc : 带url参数的回调方法
		 */
		public function loadRes(url:String,  onComplete:Function = null, onProgress:Function = null, onError:Function = null, isMapFile:Boolean = false):void
		{
			if (!url)
				return;
			if (_paramsDic[url] != null)
			{
				if (onComplete != null && _paramsDic[url].onComplete.indexOf(onComplete) < 0)
					_paramsDic[url].onComplete.push(onComplete);
				if (onProgress != null && _paramsDic[url].onProgress.indexOf(onProgress) < 0)
					_paramsDic[url].onProgress.push(onProgress);
				if (onError != null && _paramsDic[url].onError.indexOf(onError) < 0)
					_paramsDic[url].onError.push(onError);
				return;
			}
			//            if (_loaderDic[url])
			//            {
			//                if (onProgress != null)
			//                    onProgress(100, 100);
			//                if (onComplete != null)
			//                    onComplete(url);
			//                return;
			//            }
			trace(url);
			if(_dataDic[url] != null)
			{
				if (onProgress != null)
					onProgress(100, 100);
				if (onComplete != null)
					onComplete(url);
				return;
			}
			//_loadingDic[url] = true;
			//插队优化
			if(!isMapFile)
			{
				var i:int = 0;
				var j:int = 0;
				var z:int = 0;
				for (i = 0; i < loader_config.PRIORITY_QUEUE.length; i++)
				{
					if (url.indexOf(loader_config.PRIORITY_QUEUE[i]) > -1)
						break;
				}
				if (i < loader_config.PRIORITY_QUEUE.length)
				{
					for (j = 0; j < _httpUrlList.length; j++)
					{
						for (z = 0; z < i; z++)
						{
							if (_httpUrlList[j].indexOf(loader_config.PRIORITY_QUEUE[z]) > -1)
								break;
						}
						if (z >= i)
							break;
					}
					if (j >= _httpUrlList.length)
						_httpUrlList.push(url);
					else
						_httpUrlList.splice(j, 0, url);
				}
				else
				{
					_httpUrlList.push(url);
				}
			}
			else
			{
				_httpUrlList.unshift(url);
			}
			_paramsDic[url] = {
				onComplete: onComplete != null ? [onComplete] : [], 
					onError: onError != null ? [onError] : [], 
					onProgress: onProgress != null ? [onProgress] : [], 
					errorTimes: 0,
					url:url
			};
			sendHTTPwebRequest();
		}
		
		/**
		 * 控制请求HTTP个数
		 */
		private function sendHTTPwebRequest():void
		{
			if (_loaderPool.length == 0|| _httpUrlList.length < 1)
				return;
			var url:String = _httpUrlList.shift();
			//            var urlLoader:URLLoader = new URLLoader();
			//            _urlDic[urlLoader] = url;
			//            _curLoaderCount++;
			//            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			//            urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompelteHandler);
			//            urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			//            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			//            urlLoader.load(new URLRequest(PathUtil.getFullPath(url)));
			
			var loader:SourceLoader = _loaderPool.pop();
			loader.info = _paramsDic[url];
			loader.load(new URLRequest(PathUtil.getFullPath(url)));
		}
		
		private function urlLoaderCompelteHandler(evt:Event):void
		{
			var loader:SourceLoader = evt.target as SourceLoader;
			_loaderPool.push(loader);
			var info:Object = loader.info;
			info.data = loader.data;
			_decodelist.push(info);
			decode();
			sendHTTPwebRequest();
			
			//            _curLoaderCount--;
			//            sendHTTPwebRequest();
			//            var url:String = _urlDic[evt.target];
			//            var byte:ByteArray = URLLoader(evt.target).data as ByteArray;
			//            removeLoaderEvent(evt.target);
			//            var loader:Loader = new Loader();
			//            _urlDic[loader.contentLoaderInfo] = url;
			//            _loaderDic[url] = loader;
			//            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			//            var lc:LoaderContext = new LoaderContext();
			//            lc.allowCodeImport = true;
			//            loader.loadBytes(byte,lc);
		}
		
		private function onProgressHandler(evt:ProgressEvent):void
		{
			var loader:SourceLoader = evt.target as SourceLoader;
			var info:Object = loader.info;
			//            var url:String = _urlDic[evt.target];
			//            var params:Object = _paramsDic[url];
			for each (var func:Function in info.onProgress)
			{
				func(URLLoader(evt.target).bytesLoaded, URLLoader(evt.target).bytesTotal);
			}
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			var loader:SourceLoader = evt.target as SourceLoader;
			var info:Object = loader.info;
			if (++info.errorTimes < loader_config.ERROR_TIMES)
			{
				_httpUrlList.unshift(info.url);
			}
			else
			{
				Debug.Trace("load failed(" + info.errorTimes + "): " + info);
				delete _paramsDic[info.url];
				for each (var func:Function in info.onError)
				{
					func(info);
				}
			}
			_loaderPool.push(loader);
			sendHTTPwebRequest();
			
			//			var url:String = _urlDic[evt.target];
			//			var params:Object = _paramsDic[url];
			//			delete _loaderDic[url];
			//			removeLoaderEvent(evt.target);
			//			if (++params.errorTimes < loader_config.ERROR_TIMES)
			//			{
			//				_httpUrlList.unshift(url);
			//			}
			//			else
			//			{
			//				Debug.Trace("load failed(" + params.errorTimes + "): " + url);
			//				for each (var func:Function in params.onError)
			//				{
			//					func(url);
			//				}
			//			}
			//			_curLoaderCount--;
			//			sendHTTPwebRequest();
		}
		
		private function decode():void
		{
			if (!_decoderPool.length || !_decodelist.length)
				return;
			var decoder:DecodeLoader = _decoderPool.pop();
			decoder.info = _decodelist.shift();
			var lc:LoaderContext = new LoaderContext();
			lc.allowCodeImport = true;
			decoder.loadBytes(decoder.info.data, lc);
		}
		
		private function onDecodeErrorHandler(evt:Event):void
		{
			var decoder:DecodeLoader = evt.target as DecodeLoader;
			var info:Object = decoder.info;
			if (++info.errorTimes < loader_config.ERROR_TIMES)
			{
				_decodelist.push(info);
			}
			_decoderPool.push(decoder);
			decode();
		}
		
		private function onDecodeComplete(evt:Event):void
		{
			var decoder:DecodeLoader = evt.target.loader as DecodeLoader;
			var info:Object = decoder.info;
			delete _paramsDic[info.url];
			_dataDic[info.url] = {url:info.url, content:decoder.content, domain:decoder.contentLoaderInfo.applicationDomain};
			for each (var func:Function in info.onComplete)
			{
				func(info.url);
			}
			_decoderPool.push(decoder);
			decode();
		}
		
		//        private function onCompleteHandler(evt:Event):void
		//        {
		//            var url:String = _urlDic[evt.target];
		//            var params:Object = _paramsDic[url];
		//            removeLoaderEvent(evt.target);
		//			delete _paramsDic[url];
		//			delete _loadingDic[url];
		//            for each (var func:Function in params.onComplete)
		//            {
		//                func(url);
		//            }
		//        }
		
		
		
		private function removeLoaderEvent(obj:Object):void
		{
			return;
			if (obj is LoaderInfo)
			{
				// LoaderInfo(obj).removeEventListener(Event.COMPLETE, onCompleteHandler);
				
				if (LoaderInfo(obj).loader.content is MovieClip)
					MovieClip(LoaderInfo(obj).loader.content).stop();
			}
			else if (obj is URLLoader)
			{
				URLLoader(obj).removeEventListener(Event.COMPLETE, urlLoaderCompelteHandler);
				URLLoader(obj).removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
				URLLoader(obj).removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				try
				{
					URLLoader(obj).close();
				}
				catch (e:Error)
				{
					
				}
			}
			delete _urlDic[obj];
		}
		
		public function clearNotify(url:String, notify:Function):void
		{
			if (_paramsDic[url] != null)
			{
				var ary:Array = _paramsDic[url].onComplete;
				var index:int = ary.indexOf(notify);
				if (index > -1)
					ary.splice(index, 1);
			}
		}
		
		public function clearMapRes():void
		{
			var needDelUrls:Vector.<String> = new <String>[];
			var url:String;
			for(url in _paramsDic)
			{
				if(url.indexOf("map/") > -1)
					needDelUrls.push(url);
			}
			//			for each(url in needDelUrls)
			//			{
			//				clearRes(url);
			//			}
			needDelUrls = new <String>[];
			for(url in _dataDic)
			{
				if(url.indexOf("map/") > -1)
					needDelUrls.push(url);
			}
			for each(url in needDelUrls)
			{
				clearRes(url);
			}
		}
		
		public function clearRes(url:String):void
		{
			var data:Object = _dataDic[url];
			if(data != null)
			{
				if ((data.content is Bitmap) && (data.content as Bitmap).bitmapData != null)
				{
					(data.content as Bitmap).bitmapData.dispose();
				}
				data.content = null;
				data.domain = null;
				delete _paramsDic[url];
				delete _dataDic[url];
			}
			sendHTTPwebRequest();
			return;
			//			var loader:*;
			//            if (isLoading(url))
			//            {
			//                for (loader in _urlDic)
			//                {
			//                    if (_urlDic[loader] == url)
			//					{
			//						removeLoaderEvent(loader);
			//						delete _urlDic[loader];
			//						delete _paramsDic[url];
			//						delete _loadingDic[url];
			//						_curLoaderCount--;
			//						sendHTTPwebRequest();
			//                        break;
			//					}
			//                }
			//            }
			//            else if(isLoaded(url))
			//            {
			//                loader = _loaderDic[url];
			//				loader.unloadAndStop(true);
			//				if (loader.content)
			//				{
			//					if (loader.content is Bitmap)
			//					{
			//						if (Bitmap(loader.content).bitmapData)
			//						{
			//							Bitmap(loader.content).bitmapData.dispose();
			//							Bitmap(loader.content).bitmapData = null;
			//						}
			//					}
			//				}
			//				delete _loaderDic[url];
			//            }
			
		}
		
		public function getImg(url: String):BitmapData
		{
			var bitmap:Bitmap = getContent(url);
			return bitmap ? bitmap.bitmapData : null;
		}
		
		public function getContent(url:String):*
		{
			return _dataDic[url] ? _dataDic[url].content : null;
			//return _loaderDic[url] ? Loader(_loaderDic[url]).content : null;
		}
		
		public function getDomain(url: String):ApplicationDomain
		{
			//			var loader:Loader = _loaderDic[url];
			//			if (loader)
			//				return ApplicationDomain(loader.contentLoaderInfo.applicationDomain);
			var data:Object = _dataDic[url];
			if(data != null)
			{
				return data.domain as ApplicationDomain;
			}
			return null;
		}
		
		/**
		 * @param url  资源路径
		 * @param link 链接名字
		 */
		public function getDefClass(url:String = null, link:String = null):Class
		{
			var domain:ApplicationDomain = url ? getDomain(url) : ApplicationDomain.currentDomain;
			if (domain && domain.hasDefinition(link))
				return domain.getDefinition(link) as Class;
			return null;
		}
		
		public function getDefMc(url:String, link:String):MovieClip
		{
			var domain:ApplicationDomain = url ? getDomain(url) : ApplicationDomain.currentDomain;
			var c:Class = domain.getDefinition(link)  as Class;
			return (new c()) as MovieClip;
			//m_MCList[resName] = (new c()) as MovieClip;
			
		}
		
		/**
		 * @param url  资源路径
		 * @param link 链接名字
		 */
		public function getDefInstance(url:String, link:String):*
		{
			var cls:Class = getDefClass(url, link);
			if (cls != null)
			{
				var s:* = new cls();
				/*缓存位图，这样设置，CPU降了10%，内存增加了30—40M*/
				//                if (s is Sprite)
				//                    (s as Sprite).cacheAsBitmap = true;
				return s;
			}
			return null;
		}
		
		/**
		 * @param url  资源路径
		 * @param link 链接名字
		 */
		public function getDefBitmapData(url:String, link:String):BitmapData
		{
			if(_defBmdDic[url + "-" + link])
				return _defBmdDic[url + "-" + link];
			var cls:Class = getDefClass(url, link);
			if (cls)
			{
				_defBmdDic[url] = new cls(0, 0);
				return _defBmdDic[url];
			}
			return null;
		}
		
		/**
		 * @param url  资源路径
		 * @param link 链接名字
		 */
		public function getDefBitmap(url:String, link:String):Bitmap
		{
			var bmd:BitmapData = getDefBitmapData(url, link);
			return bmd ? new Bitmap(bmd) : null;
		}
		
		private function getSettingData(url:String, path:String):Object
		{
			var domain:ApplicationDomain = this.getDomain(url);
			if (domain)
			{
				while (path.indexOf("/") >= 0)
				{
					path = path.replace("/", "___");
				}
				path = path.replace(".", "__");
				if (domain.hasDefinition(path))
				{
					var cl:Class = domain.getDefinition(path) as Class;
					return new cl();
				}
			}
			return null;
		}
		
		public function getXMLData(path:String):XML
		{
			return XML(this.getSettingData(swfres_config.CONFIG_DATA, path));
		}
		
		public function getNotXMLData(path:String):ByteArray
		{
			return ByteArray(this.getSettingData(swfres_config.CONFIG_DATA, path));
		}
		
		public function getImgNew(url: String):  BitmapData
		{
			
			return getImg(url);
			var loader:Loader = _loaderDic[url];
			
			if(!loader)
			{
				//trace("【警告: getImg以下文件不存在" + url + "】" );
				return null;
			}
			return (loader.content as Bitmap).bitmapData;
		}			
	}
}


import flash.display.Loader;
import flash.net.URLLoader;

class SourceLoader extends URLLoader
{
	public var info:Object;
}

class DecodeLoader extends Loader
{
	
	public var info:Object;
}
