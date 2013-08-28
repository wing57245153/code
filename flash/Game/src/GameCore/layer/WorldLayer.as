package GameCore.layer
{
	public class WorldLayer extends LayerBase
	{
		private static var m_Instance:WorldLayer;
		public static function getInstance():WorldLayer
		{
			if(m_Instance == null)
				m_Instance = new WorldLayer();
			
			return m_Instance;
			
		}
		public function WorldLayer()
		{
			super();
		}
	}
}