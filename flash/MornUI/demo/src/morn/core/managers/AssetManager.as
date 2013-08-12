/**
 * Morn UI Version 2.1.0623 http://code.google.com/p/morn https://github.com/yungzhu/morn
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package morn.core.managers {
	import flash.display.BitmapData;
	import flash.system.ApplicationDomain;
	import morn.core.utils.BitmapUtils;
	
	/**资源管理器*/
	public class AssetManager {
		private var _bmdMap:Object = {};
		private var _clipsMap:Object = {};
		private var _domain:ApplicationDomain = ApplicationDomain.currentDomain;
		
		/**判断是否有类的定义*/
		public function hasClass(name:String):Boolean {
			return _domain.hasDefinition(name);
		}
		
		/**获取类*/
		public function getClass(name:String):Class {
			if (hasClass(name)) {
				return _domain.getDefinition(name) as Class;
			}
			App.log.error("Miss Asset:", name);
			return null;
		}
		
		/**获取资源*/
		public function getAsset(name:String):* {
			var assetClass:Class = getClass(name);
			if (assetClass != null) {
				return new assetClass();
			}
			return null;
		}
		
		/**获取位图数据*/
		public function getBitmapData(name:String, cache:Boolean = true):BitmapData {
			var bmd:BitmapData = _bmdMap[name];
			if (bmd == null) {
				var bmdClass:Class = getClass(name);
				if (bmdClass == null) {
					return null;
				}
				bmd = new bmdClass(1, 1);
				if (cache) {
					_bmdMap[name] = bmd;
				}
			}
			return bmd;
		}
		
		/**获取切片资源*/
		public function getClips(name:String, xNum:int, yNum:int, cache:Boolean = true):Vector.<BitmapData> {
			var clips:Vector.<BitmapData> = _clipsMap[name];
			if (clips == null) {
				var bmd:BitmapData = getBitmapData(name, false);
				if (bmd == null) {
					return null;
				}
				clips = BitmapUtils.createClips(bmd, xNum, yNum);
				if (cache) {
					_clipsMap[name] = clips;
				}
			}
			return clips;
		}
		
		/**缓存位图数据*/
		public function cacheBitmapData(name:String, bmd:BitmapData):void {
			if (bmd) {
				_bmdMap[name] = bmd;
			}
		}
		
		/**销毁位图数据*/
		public function disposeBitmapData(name:String):void {
			var bmd:BitmapData = _bmdMap[name];
			if (bmd) {
				delete _bmdMap[name];
				bmd.dispose();
			}
		}
		
		/**缓存切片资源*/
		public function cacheClips(name:String, clips:Vector.<BitmapData>):void {
			if (clips) {
				_clipsMap[name] = clips;
			}
		}
		
		/**销毁切片位图数据*/
		public function destroyClips(name:String):void {
			var clips:Vector.<BitmapData> = _clipsMap[name];
			if (clips) {
				for each (var item:BitmapData in clips) {
					item.dispose();
				}
				clips.length = 0;
				delete _clipsMap[name];
			}
		}
	}
}