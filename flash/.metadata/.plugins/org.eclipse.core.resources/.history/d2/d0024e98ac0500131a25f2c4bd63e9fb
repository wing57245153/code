package com.zsj.commons.display
{
	import flash.display.*;

	/**
	 * 舞台策略类，保存舞台的公用属性
	 * @author selon.xu
	 */
	public class StageProxy
	{
		public static var stage:Stage;
		public static var isRegisted:Boolean;
		public static var registWidth:Number;
		public static var registHeight:Number;

		/**
		 * 注册舞台
		 * @param registStage Stage : 舞台
		 * @param registWidth Number : 舞台宽度
		 * @param registHeight Number : 舞台高度
		 */
		public static function regist(registStage:Stage, registWidth:Number = 1200,
			registHeight:Number = 650) : void
		{
			StageProxy.isRegisted = true;
			StageProxy.stage = registStage;
			StageProxy.registWidth = registWidth;
			StageProxy.registHeight = registHeight;
		}

		/**
		 * 舞台宽度
		 */
		public static function get width() : Number
		{
			return Math.max(stage.stageWidth, minWidth);
		}

		/**
		 * 舞台高度
		 */
		public static function get height() : Number
		{
			return Math.max(stage.stageHeight, minHeight);
		}

		public static function get minWidth() : Number
		{
			return Math.min(stage.stageWidth, registWidth);
		}

		public static function get minHeight() : Number
		{
			return Math.min(stage.stageHeight, registHeight);
		}

		/**
		 * 当前舞台宽度
		 */
		public static function get stageWidth() : Number
		{
			return stage.stageWidth;
		}

		/**
		 * 当前舞台高度
		 */
		public static function get stageHeight() : Number
		{
			return stage.stageHeight;
		}

		public static function get leftOffset() : Number
		{
			return 0;
		}

		public static function get rightOffset() : Number
		{
			return stage.stageWidth - minWidth;
		}

		public static function get upOffset() : Number
		{
			return 0;
		}

		public static function get downOffset() : Number
		{
			return stage.stageHeight - minHeight;
		}
	}
}
