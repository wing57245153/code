package GameCore.core
{
	
	import org.osflash.signals.Signal;

	public class BasicManager
	{
		protected var messenger:Signal;//
		public function BasicManager()
		{
			messenger = Interface.gameBus;
		}
	}
}