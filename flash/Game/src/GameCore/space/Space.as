package GameCore.space
{
	import flash.geom.Point;
	
	import GameCore.entity.Player;
	import GameCore.entity.factory.EntityFactory;
	
	public class Space
	{
		private var m_parent:*;
		private var m_path:String = "gameres/maps/1000/";
		public function Space()
		{
			super();
		}
		
		public function set parent(val:*):void
		{
			m_parent = val;
		}
		
		public function draw(camPos:Point):void
		{
			var ck:Chunk;
			
			ck  = getChunkPool();
			ck.setData(1, 1, this.m_path);
			ck.draw();
			if(m_parent)
			{
				m_parent.addChild(ck);
			}
		}
		
		private var _chunkPool:Vector.<Chunk> = new Vector.<Chunk>();
		private function getChunkPool():Chunk
		{
			if(_chunkPool.length > 0)
				return _chunkPool.pop();
			return new Chunk();
		}
	}
}