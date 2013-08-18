package GameCore.common.display
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import GameCore.common.cache.SourceCache;

	public class MovieClipDataContainer extends EventDispatcher
	{
		private var _movieClipDataList:Array;
		private var curMovieClipData:MovieClipData;

		public function MovieClipDataContainer(mc:MovieClipData=null)
		{
			_movieClipDataList=[];
			if (mc)
			{
				for (var i:int=0; i < mc.length; i++)
				{
					_movieClipDataList[i]={key: mc.url, index: i + 1};
				}
			}
		}

		public function setFrameList(movieKey:String, toStartIndex:int, fromStartIndex:int, fromEndIndex:int):void
		{
			var i:int=0;
			var arr:Array=[];
			for (i=fromStartIndex; i <= fromEndIndex; i++)
			{
				arr.push({key: movieKey, index: i});
			}
			_movieClipDataList.splice.apply(null, [toStartIndex - 1, 0].concat(arr));
		}

		public function getbitmapFrame(index:int):BitmapFrame
		{
			var bitmapFrame:BitmapFrame;
			var obj:Object=_movieClipDataList[index - 1];
			if (obj == null)
				return null;
			if (!curMovieClipData || curMovieClipData.url != obj.key)
			{
				if (curMovieClipData)
					curMovieClipData.register--;

				curMovieClipData=SourceCache.getInstance().getObject(obj.key) as MovieClipData;
				if (curMovieClipData)
				{
					dispatchEvent(new Event(Event.CHANGE));
					curMovieClipData.register++;
				}
			}
			if (curMovieClipData)
			{
				bitmapFrame=curMovieClipData.bitmapFrameList[obj.index - 1];
				if (bitmapFrame == null)
				{
					bitmapFrame=curMovieClipData.getbitmapFrame(obj.index);
					if (curMovieClipData && curMovieClipData.bitmapFrameList)
						curMovieClipData.bitmapFrameList[obj.index - 1]=bitmapFrame;
				}
				if (curMovieClipData)
					curMovieClipData.lastUserTime=getTimer();
				return bitmapFrame;
			}
			return null;
		}

		public function get length():int
		{
			return _movieClipDataList ? _movieClipDataList.length : 0;
		}

		public function depose():void
		{
			_movieClipDataList=null;
			if (curMovieClipData)
			{
				curMovieClipData.register--;
				curMovieClipData=null;
			}
		}
	}
}
