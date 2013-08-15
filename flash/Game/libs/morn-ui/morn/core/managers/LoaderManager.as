/**
 * Morn UI Version 2.1.0623 http://code.google.com/p/morn https://github.com/yungzhu/morn
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.managers {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import morn.core.handlers.Handler;
	
	/**队列全部加载后触发*/
	[Event(name="complete",type="flash.events.Event")]
	
	/**加载管理器(单队列顺序加载)*/
	public class LoaderManager extends EventDispatcher {
		private var _resInfos:Array = [];
		private var _resLoader:ResLoader = new ResLoader();
		private var _isLoading:Boolean;
		private var _failRes:Object = {};
		
		/** 加载
		 * @param	url 地址
		 * @param	type 类型
		 * @param	complete 结束回调，并返回加载内容
		 * @param	progress 进度回调，返回进度百分率
		 * @param	error 错误回调，返回url
		 * @param	isCacheContent 是否缓存加载内容*/
		public function load(url:String, type:uint, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			var resInfo:ResInfo = new ResInfo();
			resInfo.url = url;
			resInfo.type = type;
			resInfo.complete = complete;
			resInfo.progress = progress;
			resInfo.error = error;
			
			var content:* = ResLoader.getResLoaded(resInfo.url);
			if (content != null) {
				endLoad(resInfo, content);
			} else {
				_resInfos.push(resInfo);
				checkNext();
			}
		}
		
		private function checkNext():void {
			if (_isLoading) {
				return;
			}
			_isLoading = true;
			while (_resInfos.length > 0) {
				var resInfo:ResInfo = _resInfos.shift();
				var content:* = ResLoader.getResLoaded(resInfo.url);
				if (content != null) {
					endLoad(resInfo, content);
				} else {
					_resLoader.load(resInfo.url, resInfo.type, new Handler(loadComplete, [resInfo]), resInfo.progress);
					return;
				}
			}
			_isLoading = false;
			if (hasEventListener(Event.COMPLETE)) {
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function loadComplete(resInfo:ResInfo, content:*):void {
			endLoad(resInfo, content);
			_isLoading = false;
			checkNext();
		}
		
		private function endLoad(resInfo:ResInfo, content:*):void {
			//如果加载后为空，放入队列末尾重试一次
			if (content == null) {
				if (_failRes[resInfo.url] == null) {
					_failRes[resInfo.url] = 1;
					_resInfos.push(resInfo);
					return;
				} else {
					App.log.warn("load error:", resInfo.url);
					if (resInfo.error != null) {
						resInfo.error.executeWith([resInfo.url]);
					}
				}
			}
			if (resInfo.complete != null) {
				resInfo.complete.executeWith([content]);
			}
		}
		
		/**加载SWF，返回1*/
		public function loadSWF(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.SWF, complete, progress, error, isCacheContent);
		}
		
		/**加载位图，返回Bitmapdata*/
		public function loadBMD(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.BMD, complete, progress, error, isCacheContent);
		}
		
		/**加载AMF，返回Object*/
		public function loadAMF(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.AMF, complete, progress, error, isCacheContent);
		}
		
		/**加载TXT，返回String*/
		public function loadTXT(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.TXT, complete, progress, error, isCacheContent);
		}
		
		/**加载二进制数据，返回Object*/
		public function loadDB(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.DB, complete, progress, error, isCacheContent);
		}
		
		/**加载BYTE，返回ByteArray*/
		public function loadBYTE(url:String, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			load(url, ResLoader.BYTE, complete, progress, error, isCacheContent);
		}
		
		/**加载数组里面的资源
		 * @param arr 简单：["a.swf","b.swf"]，复杂[{url:"a.swf",type:ResLoader.SWF,size:100},{url:"a.png",type:ResLoader.BMD,size:50}]*/
		public function loadAssets(arr:Array, complete:Handler = null, progress:Handler = null, error:Handler = null, isCacheContent:Boolean = true):void {
			var itemCount:int = arr.length;
			var itemloaded:int = 0;
			var totalSize:int = 0;
			var totalLoaded:int = 0;
			for (var i:int = 0; i < itemCount; i++) {
				var item:Object = arr[i];
				if (item is String) {
					item = {url: item, type: ResLoader.SWF, size: 1};
				}
				totalSize += item.size;
				load(item.url, item.type, new Handler(loadAssetsComplete, [item.size]), new Handler(loadAssetsProgress, [item.size]), error, isCacheContent);
			}
			
			function loadAssetsComplete(size:int, content:*):void {
				itemloaded++;
				totalLoaded += size;
				if (itemloaded == itemCount) {
					if (complete != null) {
						complete.execute();
					}
				}
			}
			
			function loadAssetsProgress(size:int, value:Number):void {
				if (progress != null) {
					value = (totalLoaded + size * value) / totalSize;
					progress.executeWith([value]);
				}
			}
		}
		
		/**获得已加载的资源*/
		public function getResLoaded(url:String):* {
			ResLoader.getResLoaded(url);
		}
		
		/**删除已加载的资源*/
		public function clearResLoaded(url:String):void {
			ResLoader.clearResLoaded(url);
		}
		
		/**尝试关闭加载*/
		public function tryToCloseLoad(url:String):void {
			if (_resLoader.url == url) {
				_resLoader.tryToCloseLoad();
				App.log.warn("Try to close load:", url);
				_isLoading = false;
				checkNext();
			}
		}
	}
}
import morn.core.handlers.Handler;

class ResInfo {
	public var url:String;
	public var type:int;
	public var complete:Handler;
	public var progress:Handler;
	public var error:Handler;
}