package com.Flight
{
	import flash.display.Sprite;
	
	public class Physics extends Sprite
	{
		/***
		 * h: horizontal
		 * v: vertical
		 * f: forward
		 * r: roll
		 * p: pitch
		 * */
		private var velocity:Object;
		private var oldVelocity:Object;
		private var position:Object;
		private var oldPosition:Object;
		private var oldAcceleration:Object;
		private var acceleration:Object;
		
		private var ship:Ship;
		private var mass:Number;
		
		public function Physics(physObj:Ship)
		{
			ship = physObj;
			mass = ship.mass;
			velocity = { h: 0, v: 0, f: 0, r: 0, p:0 };
			oldVelocity = { h: 0, v: 0, f: 0, r: 0, p:0 };
			position = { x: ship.x, y: ship.y, z: ship.z };
			//setPosition();
			acceleration = { h: 0, v: 0, f: 0, r: 0, p:0 };
			oldAcceleration = { h: 0, v: 0, f: 0, r: 0, p:0 };
		}
		public function calcAndSetHorVelocity(fAction:Number=0, mew:Number=1, accelGravity:Number=1):void
		{
			acceleration.h = (fAction - (mew * mass * accelGravity)) / (mass * accelGravity);
			velocity.h = oldVelocity.h + ( (oldAcceleration.h + acceleration.h) /2 ) * (1/30);
			if (velocity.h > ship.topSpeed)
				velocity.h = ship.topSpeed;
			else if (velocity.h < -ship.topSpeed)
				velocity.h = -ship.topSpeed;
			//trace("acceleration: " + acceleration.h + " :: velocity: " + velocity.h);
		}
		
		public function calcAndSetVertVelocity(fAction:Number=0, mew:Number=1, accelGravity:Number=1):void
		{
			acceleration.v = (fAction - (mew * mass * accelGravity)) / (mass * accelGravity);
			velocity.v = oldVelocity.v + ( (oldAcceleration.v + acceleration.v) /2 ) * (1/30);
			if (velocity.v > ship.topSpeed)
				velocity.v = ship.topSpeed;
			else if (velocity.v < -ship.topSpeed)
				velocity.v = -ship.topSpeed;
			//trace("acceleration: " + acceleration.v + " :: velocity: " + velocity.v);	
		}
		
		// Accessors!
		public function getHorVelocity():Number
		{
			return velocity.h;
		}
		public function getVertVelocity():Number
		{
			return velocity.v;
		}
		//public function get
		// Mutators!
		public function setPosition(xVal:Number, yVal:Number, zVal:Number):void
		{
			position.x = xVal;
			position.y = yVal
			position.z = zVal
			ship.x = position.x;
			ship.y = position.y;
			ship.z = position.z;
		}
		public function setVelocity(xVal:Number, yVal:Number, zVal:Number):void
		{
			velocity.h = xVal;
			velocity.v = yVal;
			velocity.z = zVal;
		}

	}
}