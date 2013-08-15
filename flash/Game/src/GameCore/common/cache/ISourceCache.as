package com.zsj.commons.cache
{

	/**
	 *资源加载器接口
	 * @author wing
	 *
	 */
	public interface ISourceCache
	{
		/**
		 *加载UI
		 * @param str
		 * @param canGC
		 * @param callback
		 *
		 */
		function loadUI(str:String, canGC:Boolean, callback:Function) : void;
		function getObject(str:String) : Object;
		function removeUI(str:String) : void;
	}
}
