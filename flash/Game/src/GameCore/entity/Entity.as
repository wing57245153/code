package GameCore.entity
{
	import flash.display.Sprite;
	
	import GameCore.entity.body.BaseBody;

	public class Entity extends Sprite
	{
		protected var body:BaseBody;
		protected var m_type:String;
		protected var m_id:String;
		protected var m_state:String;
		
		public function Entity()
		{
			
		}
		
		public function set config(config:Object):void
		{
			m_type = config.type;
			m_id = config.id;
			m_state = config.state;
			
			if(body == null) 
			    addBody();
		}
		
		protected function addBody():void
		{
			body = new BaseBody(m_type, m_id, m_state);
			this.addChild(body);
		}
		
		
	}
}