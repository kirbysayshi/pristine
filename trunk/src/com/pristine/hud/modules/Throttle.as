package com.pristine.hud.modules
{
	import com.pristine.hud.HModule;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Throttle extends HModule
	{
		private var _t:TextField;
		
		public function Throttle(color:uint=0x003399, alpha:Number=0.5)
		{
			super(color, alpha);
			this.addLabel("THROTTLE");
			this.addContent("0%");
			this.drawBox();
		}
		public function update(level:Number):void
		{
			this.updateContent(level + "%");
		}
	}
}