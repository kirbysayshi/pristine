package com.pristine
{
	import flash.display.Sprite;
	import flash.display.Stage;

	public class FlightControl extends Sprite
	{
		private var _stageRef:Stage;
		private var _deadzoneHeight:Number;
		private var _deadzoneWidth:Number;
		private var _shipThrottle:Number;
		private var _shipMaxTurnRate:Number;
		
		private var _deadzoneDisplay:Sprite;
		
		public function FlightControl(stageRef:Stage, deadzoneHeight:Number, deadzoneWidth:Number, shipMaxTurnRate:Number)
		{
			var tPitch:Number = 0;
            var tYaw:Number = 0;
            
            _stageRef = stageRef;
            
            _deadzoneHeight = deadzoneHeight;
            _deadzoneWidth = deadzoneWidth;
            //_shipThrottle = shipThrottle;
            _shipMaxTurnRate = shipMaxTurnRate;
            
            _deadzoneDisplay = new Sprite();
			_deadzoneDisplay.graphics.beginFill(0x000099, 0.7);
			_deadzoneDisplay.graphics.drawRect(0, 0, _deadzoneWidth, _deadzoneHeight);
			_deadzoneDisplay.graphics.endFill();
			
			var startX:Number = (_stageRef.stageWidth / 2) - _deadzoneWidth / 2;
			var startY:Number = (_stageRef.stageHeight / 2) - _deadzoneHeight / 2; 
			
			_deadzoneDisplay.x = startX;
			_deadzoneDisplay.y = startY;
			_deadzoneDisplay.alpha = 0;
            
            _stageRef.addChild(_deadzoneDisplay);
		}
		public function showDeadzone():void
		{
			_deadzoneDisplay.alpha = 1;
		}
		public function hideDeadzone():void
		{
			_deadzoneDisplay.alpha = 0;
		}
		public function getYawRate(throttleLevel:Number):Number
		{
			return calculatePitchRollYawRate(_stageRef.stageWidth, mouseX, throttleLevel);
		}
		public function getPitchRate(throttleLevel:Number):Number
		{
			return calculatePitchRollYawRate(_stageRef.stageHeight, mouseY, throttleLevel);
		}
		public function getRollRate(throttleLevel:Number):Number
		{
			// this should probably be based off of RCS thrust levels
			return 0;
		}
		private function calculatePitchRollYawRate(widthHeight:Number, mouseXY:Number, throttleLevel:Number):Number
		{
			var rate:Number = 0;
			if(mouseXY / widthHeight > 0.5 + (_deadzoneHeight / widthHeight / 2))
			{
				rate = _shipMaxTurnRate * (1 - (widthHeight - mouseXY) / (widthHeight / 2));
				if( mouseXY / (widthHeight - (0.1 * widthHeight)) >= 1)
				{
					rate = _shipMaxTurnRate;
				}
			}
			if(mouseXY / widthHeight < 0.5 - (_deadzoneHeight / widthHeight / 2))
			{
				rate = _shipMaxTurnRate * (-1 + (mouseXY / (widthHeight / 2)));
				if( (widthHeight * 0.1) / mouseXY >= 1)
				{
					rate = -_shipMaxTurnRate;
				}
			}
			rate *= (-2.05 * (throttleLevel - 0.66) * (throttleLevel - 0.66) + 1); 
			return rate;
		}
	}
}