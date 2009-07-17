package com.pristine.hud
{
	import com.pristine.hud.modules.Throttle;
	
	import flash.display.Sprite;

	public class SimpleHUD extends Sprite
	{
		private var _throttle:Throttle;
		
		public function SimpleHUD()
		{
			super();
			_throttle = new Throttle();
			_throttle.x = 650;
			_throttle.y = 530;
			this.addChild(_throttle);
		}
		public function updateThrottle(level:Number):void
		{
			_throttle.update(level);
		}
	}
}