package GameCore.entity.factory
{
	import GameCore.entity.Player;

	public class EntityFactory
	{
		private static var _instance:EntityFactory
		public static function getInstance() : EntityFactory
		{
			if(!_instance)
				_instance = new EntityFactory();
			return _instance;
		}
		public function EntityFactory()
		{
		}
		
		public function createPlayer():Player
		{
			var player:Player = new Player();
			return player;
		}
	}
}