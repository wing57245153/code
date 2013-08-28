package GameCore.gameconfig
{
	import GameCore.layer.ModuleLayer;
	import GameCore.layer.WorldLayer;

	public class module_config
	{
		public function module_config()
		{
		}
		
		public static var LOGIN_MODULE:String = "modules/login/LoginModule.swf";
		public static var WORLD_MODULE:String = "modules/world/WorldModule.swf";
		
		public static var MODUL_INFO:Object = 
			{
			    LOGIN_MODULE : {layer : "ModuleLayer"},
				WORLD_MODULE : {layer : "WorldLayer"}
		    };
		
		public static var LAYER_INFO:Object = 
			{
				"ModuleLayer" : ModuleLayer.getInstance(),
				"WorldLayer" : WorldLayer.getInstance() 
			};
			
			
	}
}