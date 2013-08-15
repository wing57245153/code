package com.zsj.commons.display
{
    import flash.display.BitmapData;

    public class BitmapFrame
    {
        public var rx:Number;
        public var ry:Number;
        public var bitmapData:BitmapData;
        public var label:String;

        public function BitmapFrame()
        {

        }

        public function dispose() : void
        {
            if(bitmapData != null)
            {
                bitmapData.dispose();
                bitmapData = null;
            }
        }
    }
}
