package com.zsj.commons.loader.events
{
    import flash.events.Event;

    public class LocalCacheEvent extends Event
    {
        public static const RES_SIZE:String="res_size";

        public var data:Object;

        public var url:String;

        public function LocalCacheEvent(type:String, url:String,data:Object=null,bubbles:Boolean=false, cancelable:Boolean=false)
        {
            this.data=data;
            this.url=url;
            super(type,bubbles,cancelable);
        }
    }
}
