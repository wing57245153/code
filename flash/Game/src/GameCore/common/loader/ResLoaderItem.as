package com.zsj.commons.loader
{
	import GameCore.interfaces.IDepose;

	public class ResLoaderItem implements IDepose
	{
		public var isNewPlayerRes:Boolean;
		public var url:String;
		public var title:String;
		public var data:*;

		public function ResLoaderItem()
		{

		}

		public function depose() : void
		{
			url = null;
			title = null;
			data = null;
		}
	}
}

