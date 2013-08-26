package GameCore.layer
{
	public class ModuleLayer extends LayerBase
	{
		private static var m_Instance:ModuleLayer;
		public static function getInstance():ModuleLayer
		{
			if(m_Instance == null)
				m_Instance = new ModuleLayer();
			
			return m_Instance;
				
		}
		public function ModuleLayer()
		{
			super();
		}
	}
}