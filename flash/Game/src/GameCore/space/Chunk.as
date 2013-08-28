package GameCore.space
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import GameCore.common.cache.SourceCache;
	import GameCore.interfaces.IDepose;

	public class Chunk extends Bitmap implements IDepose
	{
		private var _chunkPos:Point = new Point(0, 0);
		private var _filePath:String = "";
		
		public function Chunk()
		{
		}
		
		public function depose():void
		{
			_chunkPos = null;
			_filePath = null;
		}
		
		public function setData(x:int, y:int, respath:String = "", filetype:String = "jpg") : void
		{
			_chunkPos.x = x ;
			_chunkPos.y = y ;
			_filePath = respath + x + "_" + y + "." + filetype;
		}
		
		public function draw() : void
		{
			SourceCache.getInstance().load(_filePath, true, drawCallback, _filePath);
		}
		
		public function drawCallback(url:String) : void
		{
			this.bitmapData = SourceCache.getInstance().getObject(url) as BitmapData;
		}
	}
}