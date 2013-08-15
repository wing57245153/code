package com.zsj.commons.loader
{
    import GameCore.interfaces.IDepose;
    
    import com.zsj.commons.loader.events.LoaderEvent;
    import com.zsj.commons.loader.events.LocalCacheEvent;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

    /**
     * 加载队列
     * @author Selon
     */
    public class ResLoaderList extends EventDispatcher implements IDepose
    {
        public static const ITEM_COMPLETE:String = "item_complete";
        public static const ITEM_START:String = "item_start";
        public static const COMPLETE:String = "complete";

        public var totalNum:int;
        public var loadedNum:int;

        private var _loadList:Array; ////加载队列
        private var isLoading:Boolean; /////当前正在加载
        private var curItem:ResLoaderItem;

        public function ResLoaderList()
        {
            _loadList = [];
//            for(var i:int = 0; i < URL.preLoadFiles.length; i++)
//            {
//                var item:ResLoaderItem = new ResLoaderItem();
////                item.url = URL.preLoadFiles[i].url;
////                item.title = URL.preLoadFiles[i].title;
//                _loadList.push(item);
//                totalNum++;
//            }
            LocalCacheManager.getInstance().addEventListener(Event.COMPLETE, onCompleteHandler);
            LocalCacheManager.getInstance().addEventListener(ProgressEvent.PROGRESS,
                onProgressHandler);
        }

        public function depose() : void
        {
            LocalCacheManager.getInstance().removeEventListener(Event.COMPLETE, onCompleteHandler);
            LocalCacheManager.getInstance().removeEventListener(ProgressEvent.PROGRESS,
                onProgressHandler);
            for each(var item:ResLoaderItem in _loadList)
            {
                item.depose();
            }
            if(curItem)
            {
                curItem.depose();
                curItem = null;
            }
            _loadList = null;
        }

        public function load() : void
        {
            if(_isStopped)
                return;
            if(_loadList.length == 0)
            {
                dispatchEvent(new LoaderEvent(ResLoaderList.COMPLETE));
                isLoading = false;
                return;
            }
            if(isLoading == false)
            {
                isLoading = true;
                curItem = _loadList.shift();
                if(curItem.url.substr(-3, 3) == "swf")
                {
                    if(curItem.isNewPlayerRes)
                    {
                        LocalCacheManager.getInstance().loadFile(curItem.url,
                            new LoaderContext(false, new ApplicationDomain()));
                    }
                    else
                    {
                        LocalCacheManager.getInstance().loadFile(curItem.url,
                            new LoaderContext(false, ApplicationDomain.currentDomain));
                    }
                }
                else
                {
                    LocalCacheManager.getInstance().loadFile(curItem.url);
                }
                dispatchEvent(new LoaderEvent(ResLoaderList.ITEM_START, curItem));
            }
        }

        private var _isStopped:Boolean;

        public function stop() : void
        {
            _isStopped = true;
        }

        public function start() : void
        {
            _isStopped = false;
            load();
        }

        private function onCompleteHandler(evt:LocalCacheEvent) : void
        {
            if(curItem && evt.url == curItem.url)
            {
                curItem.data = evt.data;
                loadedNum++;
                dispatchEvent(new LoaderEvent(ResLoaderList.ITEM_COMPLETE, curItem));
                curItem = null;
                isLoading = false;
                load();
            }
        }

        private function onProgressHandler(evt:LocalCacheEvent) : void
        {
            if(curItem && evt.url == curItem.url)
                dispatchEvent(new LoaderEvent(ProgressEvent.PROGRESS, evt.data));
        }
    }
}
