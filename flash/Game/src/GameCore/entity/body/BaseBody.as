package GameCore.entity.body
{
	import flash.display.Sprite;
	
	import GameCore.common.cache.SourceCache;
	import GameCore.common.display.BitmapMovieClip;
	import GameCore.common.display.MovieClipData;
	import GameCore.common.display.MovieClipDataContainer;

	public class BaseBody extends Sprite
	{
		
		protected var m_type:String;
		protected var m_id:String;
		protected var m_state:String;
		public function BaseBody(type:String, id:String, state:String)
		{
			m_type = type;
			m_id = id;
			m_state = state;
			
			loadBody();
		}
		
		private function loadBody():void
		{
			 var url:String = "gameres/body/" + m_type + "/" + m_id + "/" + m_state + ".swf";
			 SourceCache.getInstance().load(url, true, onLoadBodyComplete, url);
		}
		
		private function onLoadBodyComplete(url:String):void
		{
			var mcd:MovieClipData = SourceCache.getInstance().getObject(url) as MovieClipData;
			var container:MovieClipDataContainer = new MovieClipDataContainer(mcd);
			var bmc:BitmapMovieClip = new BitmapMovieClip();
			bmc.movieClipDataContainer = container;
			bmc.gotoAndPlay(1);
			this.addChild(bmc);
		}
	}
}