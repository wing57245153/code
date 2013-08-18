package GameCore.gameconfig
{
	/**
	 * 定义一些加载常量，未有好方法，暂用
	 * @author selon
	 */
	public class loader_config
	{
		/**
		 * 并行加载数
		 */
		public static const THREAD_NUM:int = 4;
		
		/**
		 * 失败限制次数
		 */
		public static const ERROR_TIMES:int = 3;
		
		/**
		 * 广告图所占加载比例
		 */
		public static const BG_PERCENT:Number = 0.1;
		
		/**
		 * 主Game所占加载比例
		 */
		public static const GAME_PERCENT:Number = 0.4;
		
		/**
		 * 加载优先级队列
		 */
		public static const PRIORITY_QUEUE:Vector.<String> = new <String>["resource/iugld", "gameres/image", "map/", "gameres/model/body", "gameres/model/npc", "gameres/model/effect"];
	}
}