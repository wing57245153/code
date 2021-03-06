package GameCore.common.display
{
    import GameCore.interfaces.IDepose;
    
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    dynamic public class BitmapMovieClip extends Sprite implements IDepose
    {
        public static var END:String = "end";

        public var totalFrames:int; //总帧数
        public var currentFrame:int = 1; //当前帧
        public var interval:int = 1; //间隔
        public var intervalDic:Dictionary; //间隔字典
        public var isRunning:Boolean = false; //是否运行中

        private var _endFunction:Function;
        private var _startFrame:int;
        private var _endFrame:int;
        private var _isLoop:Boolean;
        private var _bitmap:Bitmap = new Bitmap(null, "auto", true);
        private var _movieClipDataContainer:MovieClipDataContainer;
        private var _listenFrameDic:Dictionary = new Dictionary();
        private var _listenFrameArgsDic:Dictionary = new Dictionary();

        public function BitmapMovieClip()
        {
            super();
            _bitmap = new Bitmap(null, "auto", true);
            this.addChild(_bitmap);
            this.mouseChildren = false;
            this.mouseEnabled = false;
        }

        public function set movieClipDataContainer(value:MovieClipDataContainer) : void
        {
            if(value == null)
                return;

            if(_movieClipDataContainer != null)
            {
                _movieClipDataContainer.depose();
                _movieClipDataContainer = null;
            }
            _movieClipDataContainer = value;
            totalFrames = _movieClipDataContainer.length;
            _startFrame = 1;
            _endFrame = totalFrames;
            this.gotoAndStop(currentFrame);
        }

        public function get movieClipDataContainer() : MovieClipDataContainer
        {
            return _movieClipDataContainer;
        }

        public function get bitmap() : Bitmap
        {
            return _bitmap;
        }

        public function get bitmapData() : BitmapData
        {
            return _bitmap.bitmapData;
        }

        public function set bitmapData(bit:BitmapData) : void
        {
            _bitmap.bitmapData = bit;
        }

        public function set scale(val:Number) : void
        {
            this.scaleX = val;
            this.scaleY = val;
        }

        protected var count:int = 0;

        public function step(e:Event = null) : void
        {
            if(!_bitmap)
            {
                stop();
                return;
            }

            if(++count < interval)
                return;

            count = 0;

            if(intervalDic && intervalDic[currentFrame])
            {
                interval = intervalDic[currentFrame];
            }

            if(currentFrame >= _endFrame)
            {
                if(_isLoop == false)
                {
                    stop();
                    if(_endFunction != null)
                    {
                        _endFunction();
                    }
                    this.dispatchEvent(new Event(END));
                    return;
                }
                currentFrame = _startFrame;
            }
            else
            {
                currentFrame++;
            }

            setCurrentFrame(currentFrame);

            if(_listenFrameDic && _listenFrameDic[currentFrame])
                _listenFrameDic[currentFrame].apply(null, _listenFrameArgsDic[currentFrame]);
        }

        protected function setCurrentFrame(frameIndex:int) : void
        {
            if(_movieClipDataContainer == null)
                return;
            if(frameIndex > _movieClipDataContainer.length)
            {
                frameIndex = _movieClipDataContainer.length;
            }

            if(frameIndex < 1)
                return;

            currentFrame = frameIndex;

            var bitmapFrame:BitmapFrame =
                _movieClipDataContainer.getbitmapFrame(currentFrame) as BitmapFrame;
            if(bitmapFrame == null)
            {
                return;
            }
            if(!_bitmap)
            {
                stop();
                return;
            }
            _bitmap.bitmapData = null;
            _bitmap.bitmapData = bitmapFrame.bitmapData;
            _bitmap.x = bitmapFrame.rx;
            _bitmap.y = bitmapFrame.ry;
        }

        public function addFrameListener(frame:int, callback:Function, ... args) : void
        {
            if(!_listenFrameDic)
            {
                _listenFrameDic = new Dictionary();
                _listenFrameArgsDic = new Dictionary();
            }
            _listenFrameDic[frame] = callback;
            _listenFrameArgsDic[frame] = args ? args : null;
        }

        public function gotoAndPlay(frame:Object, isLoop:Boolean = true, startFrame:Object = null,
            endFrame:Object = null, endfunc:Function = null) : void
        {
            if(_movieClipDataContainer == null)
                return;
            _isLoop = isLoop;
            if(frame is Number)
            {
                currentFrame = int(frame);
            }
            if(startFrame == null)
            {
                _startFrame = 1;
            }
            else
            {
                if(startFrame is Number)
                {
                    _startFrame = int(startFrame);
                }
            }
            if(endFrame == null)
            {
                _endFrame = totalFrames;
            }
            else
            {
                if(endFrame is Number)
                {
                    _endFrame = int(endFrame);
                }
            }
            _endFunction = endfunc;
            setCurrentFrame(currentFrame);
            play();

            if(_listenFrameDic && _listenFrameDic[currentFrame])
                _listenFrameDic[currentFrame].apply(null, _listenFrameArgsDic[currentFrame]);
        }

        public function gotoAndStop(frame:Object, callback:Function = null) : void
        {
            if(_movieClipDataContainer == null)
                return;
            if(frame is Number)
            {
                currentFrame = int(frame);
            }
            if(callback != null)
                _endFunction = callback;
            setCurrentFrame(currentFrame);
            stop();
        }

        public function prevFrame() : void
        {
            gotoAndStop(Math.max(currentFrame - 1, 1));
        }

        public function nextFrame() : void
        {
            gotoAndStop(Math.min(currentFrame + 1, _movieClipDataContainer.length));
        }

        public function stop() : void
        {
            MovieClipManager.getInstance().remove(this);
            isRunning = false;
        }

        public function play() : void
        {
            MovieClipManager.getInstance().add(this);
            isRunning = true;
        }

        public function getRectangle() : Rectangle
        {
            if(_bitmap)
                return _bitmap.getBounds(this);
            return null;
        }

        public function getPixel32(x:int, y:int) : uint
        {
            if(bitmapData)
            {
                var argb:uint =
                    bitmapData.getPixel32(this.x < 0 ? x - this.x : this.x - x, y - this.y);

                return argb >> 24 & 255;
            }
            return 0;
        }

        public function depose() : void
        {
            MovieClipManager.getInstance().remove(this);
            isRunning = false;
            _endFunction = null;
            _listenFrameDic = null;
            _listenFrameArgsDic = null;
            if(_bitmap)
                _bitmap.bitmapData = null;
            _bitmap = null;
            if(_movieClipDataContainer)
            {
                _movieClipDataContainer.depose();
                _movieClipDataContainer = null;
            }
            if(parent)
            {
                parent.removeChild(this);
            }
//            DisplayObjectManager.clearChildren(this);
        }
    }
}

