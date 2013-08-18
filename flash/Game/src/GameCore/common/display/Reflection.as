package GameCore.common.display
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;

	/**
	 * 反射
	 * @author selon.xu
	 */
	public class Reflection
	{
		/**
		 * 创建一个DisplayObject实例
		 * @param link : String 类链接
		 * @param domain : ApplicationDomain 应用程序域
		 * @return DisplayObject
		 */
		public static function createDisplayObjectInstance(link:String,
			domain:ApplicationDomain = null) : DisplayObject
		{
			return createInstance(link, domain) as DisplayObject;
		}

		/**
		 * 创建一个实例
		 * @param link : String 类链接
		 * @param domain : ApplicationDomain 应用程序域
		 * @return *
		 */
		public static function createInstance(link:String, domain:ApplicationDomain = null) : *
		{
			var assetClass:Class = getClass(link, domain);
			if(assetClass != null)
			{
				var s:* = new assetClass();

				/*缓存位图，这样设置，CPU降了10%，内存增加了30—40M*/
				if(s is Sprite)
				{
					(s as Sprite).cacheAsBitmap = true;
				}

				return s;
			}
			return null;
		}

		/**
		 * 创建一个BitmapData实例
		 * @param link : String 类名
		 * @param domain : ApplicationDomain 应用程序域
		 * @return BitmapData
		 */
		public static function createBitmapDataInstance(link:String,
			domain:ApplicationDomain = null) : BitmapData
		{
			var assetClass:Class = getClass(link, domain);
			if(assetClass != null)
			{
				return new assetClass(0, 0);
			}
			return null;
		}

		/**
		 * 获取类
		 * @param link : String 类名
		 * @param domain : ApplicationDomain 应用程序域
		 * @return BitmapData
		 */
		public static function getClass(link:String, domain:ApplicationDomain = null) : Class
		{
			if(domain == null)
			{
				domain = ApplicationDomain.currentDomain;
			}
			var assetClass:Class = domain.getDefinition(link) as Class;
			return assetClass;
		}

		/**
		 * 获取类全名
		 * @param o : 类链接
		 * @return String
		 */
		public static function getFullClassName(o:*) : String
		{
			return getQualifiedClassName(o);
		}

		/**
		 * 获取类名
		 * @param o : 类链接
		 * @return String
		 */
		public static function getClassName(o:*) : String
		{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf("::");
			if(lastI >= 0)
			{
				name = name.substr(lastI + 2);
			}
			else
			{
				lastI = name.lastIndexOf(".");
				if(lastI >= 0)
				{
					name = name.substr(lastI + 1);
				}
			}
			return name;
		}

		/**
		 * 获取类包名
		 * @param o : 类链接
		 * @return String
		 */
		public static function getPackageName(o:*) : String
		{
			var name:String = getFullClassName(o);
			var lastI:int = name.lastIndexOf(".");
			if(lastI >= 0)
			{
				return name.substring(0, lastI);
			}
			else
			{
				return "";
			}
		}

		/**
		* 获取一个动态Vector.<myclass>
		* @param	myClass
		* @param	appDomain myClass所在的应用程序域,如果null则为当前应用程序域
		* @return 一个动态Vector, null为myClass不存在
		*/
		public static function getVector(cls:Class, appDomain:ApplicationDomain = null) : *
		{
			// 先获取元素类名
			var className:String = getQualifiedClassName(cls);
			// 拼接成Vector类名
			var vectorName:String = "__AS3__.vec.Vector.<" + className + ">";
			appDomain ||= ApplicationDomain.currentDomain;
			if(appDomain.hasDefinition(vectorName))
			{
				var cls1:Class = appDomain.getDefinition(vectorName) as Class;
				return new cls1();
			}
			// 该类不存在
			return null;
		}
	}
}
