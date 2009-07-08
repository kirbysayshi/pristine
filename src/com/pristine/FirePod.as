package com.pristine
{
	import flash.events.TimerEvent;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.scenes.Scene3D;

	public class FirePod extends DisplayObject3D
	{
		private var _name:String;
		private var _firerate:Number;
		private var _velocity:Number;
		private var _maxammo:Number;
		private var _power:Number;
		private var _type:String;
		private var _mainWeaponRounds:Vector.<Projectile>;
		private var _nextRoundNum:int;
		
		private var _sceneHolder:Scene3D;
		private var _shipHolder:Ship;
		
		private var _timeTillNextFire:Number;
		
		public function FirePod(ship:Ship, scene:Scene3D, xoffset:Number, yoffset:Number, zoffset:Number, firerate:Number, velocity:Number, maxammo:Number, power:Number, type:String, name:String)
		{
			super();
			
			_name = name;
			
			this.x = xoffset;
			this.y = yoffset;
			this.z = zoffset;
			
			_sceneHolder = scene;
			_shipHolder = ship;
			
			_firerate = firerate;
			_velocity = velocity;
			_maxammo = maxammo;
			_power = power;
			_type = type;
			
			_timeTillNextFire = 0;
			
			var visible:Cylinder = new Cylinder(new ColorMaterial(0xEEEEEE), 11, 20);
			visible.pitch(90);
			this.addChild(visible);
			
			readyRounds();
		}
		private function readyRounds():void
		{
			var totalBullets:Number = 0;
			if(_type == 'bullet')
			{
				totalBullets = Math.round(_firerate * 3 / 2);
			}
			if(_type == 'blaster')
			{
				totalBullets = Math.round(_firerate * 1.8 / 10);
			}
			_mainWeaponRounds = new Vector.<Projectile>(totalBullets, false);
			for(var i:int = 0; i < _mainWeaponRounds.length; i++)
			{
				_mainWeaponRounds[i] = new Projectile(_type);
			}
			_nextRoundNum = 0;
		}
		public function updateProjectilePositions(collisionList:Array):void
		{
			for each( var p:Projectile in _mainWeaponRounds)
			{
				if(p.activated)
				{
					for(var i:int = 0; i < collisionList.length; i++)
					{
						var hit:Boolean = false;
						if(collisionList[i] != null)
							hit = collisionList[i][0].hitTestObject(p); 
						if(hit)
						{
							collisionList[i][1]--;
							trace(collisionList[i][1] + " name: " + collisionList[i][0].name);
							
							_sceneHolder.removeChild(p);
							_sceneHolder.removeChild(collisionList[i][0]);
							collisionList.splice(i, 1);
							//collisionList[i] = null;
							trace(collisionList.length);
							p.deactivate();
							// TODO: make targeting reticle: drawn box that's actually out in front
						}
					}

				}
				p.moveForward(_velocity);
				p.x += p.velocity.x;
				p.y += p.velocity.y;
				p.z += p.velocity.z;

				var dx :Number = p.x - p.originPoint.x;
				var dy :Number = p.y - p.originPoint.y;
				var dz :Number = p.z - p.originPoint.z;
				
				if(Math.sqrt( dx*dx + dy*dy + dz*dz ) > p.destroyDistance)
				{
					_sceneHolder.removeChild(p);
					p.deactivate();
					//this.removeChild(p);
				}
			}
		}
		public function fire(e:TimerEvent):void
		{
			if(_nextRoundNum > _mainWeaponRounds.length - 1)
				_nextRoundNum = 0;
			var p:Projectile = _mainWeaponRounds[_nextRoundNum]; 
			
			//p.position = _shipHolder.position;//this.position;
			p.originPoint = _shipHolder.position;
			_nextRoundNum++;
			_sceneHolder.addChild(p);
			//p.copyTransform(_shipHolder);
			p.fireForget(_shipHolder.transform, this.position, _shipHolder.velocity); // copy orientation and proper pitch (+90)
			trace('shot fired from pod: ' + _name);
			//this.addChild(p);
		}
		public function get fireRate():Number
		{
			return _firerate;
		}
		public function get podName():String
		{
			return _name;
		}
	}
}