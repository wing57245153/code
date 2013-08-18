package GameCore.layer
{
	import flash.display.Sprite;
	
	public class LayerBase extends Sprite
	{
		public function LayerBase()
		{
			super();
		}
		
		public function Hide():void
		{
			visible = false;
		}
		
		public function Show():void
		{
			visible = true;
		}
	}
}