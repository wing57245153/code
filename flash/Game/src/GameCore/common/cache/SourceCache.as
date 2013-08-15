package com.zsj.commons.cache
{
    import com.zsj.commons.display.MovieClipData;
    import com.zsj.commons.loader.LocalCacheManager;
    import com.zsj.commons.loader.events.LocalCacheEvent;
    import com.zsj.debug.Logger;
    import com.zsj.util.TimerManager;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    public class SourceCache extends EventDispatcher implements ISourceCache
    {
        public var _cacheDic:Dictionary;
        public var _gcDic:Dictionary;

        private var _loadingDic:Dictionary;
        private var _callbackDic:Dictionary;
        private var _errorDic:Dictionary;
        private var _len:int;

        public function SourceCache()
        {
            _len = 0;
            _cacheDic = new Dictionary();
            _callbackDic = new Dictionary();
            _gcDic = new Dictionary();
            _loadingDic = new Dictionary();
            _errorDic = new Dictionary();

            LocalCacheManager.getInstance().addEventListener(Event.COMPLETE, onCompleteHandler);
            LocalCacheManager.getInstance().addEventListener(IOErrorEvent.IO_ERROR,
                onIoErrorHandler);
//            TimerManager.getInstance().add(60000 * 2, tempGC);
        }

        private static var _instance:SourceCache;

        public static function getInstance() : SourceCache
        {
            if(!_instance)
                _instance = new SourceCache();
            return _instance;
        }

        public function put(str:String, obj:Object, overWrite:Boolean = false,
            canGC:Boolean = false) : void
        {
            _gcDic[str] = canGC;
            if(_cacheDic[str] == undefined)
            {
                _len++;
                _cacheDic[str] = obj;
            }
            else
            {
                if(overWrite)
                {
                    if(_cacheDic[str] is BitmapData)
                    {
                        BitmapData(_cacheDic[str]).dispose();
                    }
                    if(_cacheDic[str] is MovieClipData)
                    {
                        MovieClipData(_cacheDic[str]).depose();
                    }
                    _cacheDic[str] = obj;
                }
            }
            if(_cacheDic[str] is MovieClipData)
            {
                MovieClipData(_cacheDic[str]).url = str;
                MovieClipData(_cacheDic[str]).canGC = canGC;
            }
        }

        public function removeUI(str:String) : void
        {
            remove(str, true);
        }

        /**
         * 从内存中销毁一个资源
         * str:资源路径
         * force:是否强制销毁，默认true，为false时将跳过使用次数未清零的资源
         */
        public function remove(str:String, force:Boolean = false) : void
        {
            var canRemove:Boolean;
            if(_cacheDic[str] is BitmapData)
            {
                canRemove = true;
                BitmapData(_cacheDic[str]).dispose();
            }
            else if(_cacheDic[str] is MovieClipData)
            {
                if(!force)
                {
                    if(MovieClipData(_cacheDic[str]).register <= 0)
                        canRemove = true;
                }
                else
                {
                    canRemove = true;
                }
                if(canRemove)
                    MovieClipData(_cacheDic[str]).depose();
            }
            else
            {
                canRemove = true;
            }
            if(canRemove)
            {
                LocalCacheManager.getInstance().stopLoading(str);
                delete _cacheDic[str];
                delete _gcDic[str];
                delete _loadingDic[str];
                delete _callbackDic[str];
                _len--;
            }
        }

        public function getDefClass(str:String, defStr:String) : Class
        {
            if(_cacheDic[str] && _cacheDic[str] is MovieClipData && defStr)
            {
                return _cacheDic[str].mc.loaderInfo.applicationDomain.getDefinition(defStr);
            }
            return null;
        }

        public function getObject(str:String) : Object
        {
            return _cacheDic[str];
        }

        public function has(str:String) : Boolean
        {
            return _cacheDic[str] != undefined
        }

        public function get count() : int
        {
            return _len;
        }

        public function loadUI(str:String, canGC:Boolean, callback:Function) : void
        {
            load(str, canGC, callback);
        }

        public function load(str:String, canGC:Boolean = true, callback:Function = null,
            ... args) : void
        {
            if(int(_errorDic[str]) > 3)
            {
                if(callback != null)
                    callback.apply(null, args);
                return;
            }
            if(_cacheDic[str])
            {
                if(callback != null)
                    callback.apply(null, args);
                return;
            }
            if(_callbackDic[str] == undefined)
                _callbackDic[str] = [];
            _callbackDic[str].push({arg: args, fuc: callback});
            _gcDic[str] = canGC;
            _loadingDic[str] = true;
            LocalCacheManager.getInstance().loadFile(str);
        }

        private function onCompleteHandler(evt:LocalCacheEvent) : void
        {
            var url:String = evt.url;
            if(_loadingDic[url] != true)
                return;
            if(url.substr(-3, 3) == "swf")
            {
                if(evt.data is MovieClip)
                    changeSwfToMovieClipDate(url, evt.data as MovieClip);
                else
                    SourceCache.getInstance().put(url, evt.data, true);
            }
            else if(url.substr(-2, 2) == "ng" || url.substr(-2, 2) == "pg")
            {
                var myBitmap:BitmapData = Bitmap(evt.data).bitmapData;
                SourceCache.getInstance().put(url, myBitmap, false, _gcDic[url]);
            }
            delete _loadingDic[url];
            if(_callbackDic[url] != undefined)
            {
                var list:Array = _callbackDic[url];
                for(var i:int = 0; i < list.length; i++)
                {
                    var obj:Object = list[i];
                    var fuc:Function = obj.fuc;
                    var arg:Array = obj.arg;
                    if(fuc != null)
                    {
                        fuc.apply(null, arg);
                    }
                }
                delete _callbackDic[url];
            }
        }

        /**
         * 转换SWF 为movieClipData
         */
        public function changeSwfToMovieClipDate(url:String, movie:MovieClip) : MovieClipData
        {
            movie.stop();
            var bitmapData:MovieClipData = new MovieClipData();
            var arr:Array = [];
            for(var i:int = 0; i < movie.totalFrames; i++)
            {
                movie.gotoAndStop(i);
                arr.push(null);
            }
            bitmapData.bitmapFrameList = arr;
            bitmapData.url = url;
            bitmapData.canGC = _gcDic[url];
            bitmapData.mc = movie;
            movie.gotoAndStop(1);
            SourceCache.getInstance().put(url, bitmapData, false, _gcDic[url]);
            return getObject(url) as MovieClipData;
        }

        private function onIoErrorHandler(evt:LocalCacheEvent) : void
        {
            var url:String = evt.url;
            _errorDic[url] = _errorDic[url] ? _errorDic[url]++ : 0;
            delete _loadingDic[url];
            delete _callbackDic[url];
        }

        public function isLoading(str:String) : Boolean
        {
            return _loadingDic[str] == true;
        }

        /**
         * 定时回收位图数据
         */
        public function tempGC() : void
        {
            for(var str:* in _cacheDic)
            {
                if(_gcDic[str] == true && _cacheDic[str] is MovieClipData)
                {
                    ////一分钟没有使用过回收一次
                    if(MovieClipData(_cacheDic[str]).canGC &&
                        MovieClipData(_cacheDic[str]).register <= 0 &&
                        getTimer() - MovieClipData(_cacheDic[str]).lastUserTime > 30000)
                    {
//                        Logger.debug("定时回收资源：" + str);
                        MovieClipData(_cacheDic[str]).depose();
                        delete _cacheDic[str];
                        delete _gcDic[str];
                        delete _loadingDic[str];
                        _len--;
                    }
                }
            }
        }

        public function removeOldSceneRes() : void
        {
            for(var str:* in _cacheDic)
            {
                if(str.indexOf("res/scene") > -1 || str.indexOf("ui/copy") > -1)
                {
                    remove(str, true);
                }
            }
        }
    }
}
