package com.zsj.commons.loader.events
{
    import flash.events.Event;

    public class LoaderEvent extends Event
    {
        public var data:*;

        public function LoaderEvent(type:String,$data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            data=$data;
            super(type, bubbles, cancelable);
        }
    }
}

