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
            // mouse-based pitch
            /*if ( mouseY < (stage.height / 2) - 10 )
                    tPitch = ( -(80 / mouseY) > -ship.maxTurnRate)
                            ? -(80 / mouseY) 
                            : -ship.maxTurnRate;
            else if ( mouseY > (stage.height / 2) + 10 ) //&& mouseY < stage.height - 30)
                    tPitch = (80 / (stage.height - mouseY) < ship.maxTurnRate) 
                            ? 80 / (stage.height - mouseY) 
                            : ship.maxTurnRate;
            
            tPitch *= (inverted == true) ? -1 : 1; // if inverted is true, multiply by -1
            
            // mouse-based yaw
            if ( mouseX < (stage.width / 2) - 10) //&& mouseY > 30)
                    tYaw = ( -(80 / mouseX) > -ship.maxTurnRate) 
                            ? -(80 / mouseX) 
                            : -ship.maxTurnRate;
            else if ( mouseX > (stage.width / 2) + 10) //&& mouseY < stage.height - 30)
                    tYaw = (80 / (stage.width - mouseX) < ship.maxTurnRate )
                            ? 80 / (stage.width - mouseX) 
                            : ship.maxTurnRate;
                    
            tYaw *= (inverted == true) ? -1 : 1; // if inverted is true, multiply by -1
            
            // this makes the normal turn rate = 75% of max, 
            // and then 100% of max at 30% throttle
            if ( ship.throttleLevel > 0.31 && ship.throttleLevel < 0.35){
                    tPitch *= 1;
                    tYaw *= 1;
            }
            else if ( ship.throttleLevel <= 0.28 ){
                    tPitch *= 0.2;
                    tYaw *= 0.2;
            }
            else{
                    tPitch *= 0.65;
                    tYaw *= 0.65;
            }
            return {"pitch": tPitch, "yaw": tYaw };*/
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
			if(throttleLevel < 0.28)
			{
				rate *= 0.2;
			}
			if(throttleLevel > 0.35)
			{
				rate *= 0.65;
			}
			return rate;
		}
	}
}