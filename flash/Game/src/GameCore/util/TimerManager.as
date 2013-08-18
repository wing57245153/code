package GameCore.util
{
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	/**
	 * 延时控制器
	 * @author Selon
	 */
	public class TimerManager
	{
		private static var _instance:TimerManager = null;
		
		private var timerDic:Dictionary;
		private var funcToTimerDic:Dictionary;
		private var funcListDic:Dictionary;
		private var paramsDic:Dictionary;
		private var countDic:Dictionary;
		
		public function TimerManager()
		{
			timerDic = new Dictionary(); //存储new的timer  按照延时长短处理
			funcToTimerDic = new Dictionary(); //存储new的timer  按照fun存储
			funcListDic = new Dictionary(); //存储要调用的方法
			paramsDic = new Dictionary();
			countDic = new Dictionary();
		}
		
		public static function getInstance() : TimerManager
		{
			if(!_instance)
				_instance = new TimerManager();
			return _instance;
		}
		
		/**
		 * 判断是否存在某function的定时器
		 * @param fuc : Function
		 * @return Boolean
		 */
		public function hasTimer(func:Function) : Boolean
		{
			return this.funcToTimerDic[func] != undefined;
		}
		
		/**
		 * @param delay 延时ms
		 * @param func  方法
		 * @param count 执行次数，默认-1代表无限次
		 * @param args  参数列表
		 */
		public function add(delay:Number, func:Function, count:int = -1, ... args) : void
		{
			
			if(func == null)
				return;
			remove(func);
			if(count == 0)
				return;
			funcToTimerDic[func] = createTimer(delay);
			paramsDic[func] = args;
			countDic[func] = [0, count];
			funcListDic[delay].push(func); //把此时的dic的此个obj看成数组，，存储方法为每个元素。。。
		}
		
		/**
		 * 移除方法延时
		 */
		public function remove(func:Function) : void
		{
			if(funcToTimerDic[func] == undefined)
				return;
			var timer:Timer = funcToTimerDic[func];
			delete funcToTimerDic[func];
			delete paramsDic[func];
			delete countDic[func];
			var list:Array = funcListDic[timer.delay];
			if(list.indexOf(func) > -1)
			{
				list.splice(list.indexOf(func), 1);
			}
			if(list.length == 0)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				delete funcListDic[timer.delay];
				delete timerDic[timer.delay];
			}
		}
		
		private function createTimer(delay:Number) : Timer
		{
			if(timerDic[delay] == undefined)
			{
				var timer:Timer = new Timer(delay);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
				timerDic[delay] = timer;
				
			}
			if(funcListDic[delay] == undefined)
			{
				funcListDic[delay] = [];
			}
			return timerDic[delay];
		}
		
		
		private function timerHandler(e:TimerEvent) : void
		{
			var curTimer:Number = getTimer();
			var list:Array = funcListDic[Timer(e.target).delay];
			var len:int = list.length;
			for(var i:int = len - 1; i >= 0; i--)
			{
				var func:Function = list[i];
				if (func == null)
					continue;
				var params:Array = paramsDic[func];
				var count:Array = countDic[func];
				func.apply(null, params);
				if(count[1] != -1)
				{
					count[0]++;
					if(count[0] >= count[1])
						remove(func);
				}
			}
		}
		
		private static var m_TimeOutFun:Object = { };
		private static function saveTimeOutFun(now:int, delay:int):void
		{
			var cost:int = getTimer() - now;
			if (cost > 5)
			{
				if (m_TimeOutFun[delay.toString()] == null)
				{
					m_TimeOutFun[delay.toString()] = [cost, 1];
				}
				else
				{
					var arr:Array = m_TimeOutFun[delay.toString()] as Array;
					m_TimeOutFun[delay.toString()] = [int((arr[0] + cost) / 2), arr[1] + 1];
				}			
				
			}
		}			
		
		public  function ShowTimerGroup():void
		{
			var s:String = "";
			for (var gp:String in funcListDic)
			{
				var list:Array = funcListDic[gp];
				var len:int = list.length;				
				//s = s + tmpS + "\n";
				
			}
			
		}			
	}
}