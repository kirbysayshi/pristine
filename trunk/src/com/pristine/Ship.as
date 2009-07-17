package com.pristine
{
	import com.pristine.hud.SimpleHUD;
	
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cone;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.scenes.Scene3D;

	public class Ship extends DisplayObject3D
	{
		[Embed(source='assets/shipdata/a-wing.xml',mimeType="application/octet-stream")]
		protected var ViperData:Class;
		
		private var _thrustPool:Number;
		private var _height:Number;
		private var _width:Number;
		private var _length:Number;
		private var _mass:Number;
		private var _topSpeed:Number;
		private var _maxThrust:Number;
		private var _maxRCSThrust:Number;
		private var _drag:Number;
		private var _turnRate:Number;
		
		private var _firepods:Vector.<FirePod>;
		private var _nextPodToFire:int;
		private var _isFiring:Boolean;
		private var _masterFiringTimer:Timer;
		
		private var _sceneHolder:Scene3D;
		private var _stageRef:Stage;
		
		private var _isGliding:Boolean;
		private var _speedRestricted:Boolean;
		
		private var _throttleLevel:Number;
		private var _thrustLevel:Number; // how much thrust...
		private var _prevThrustLevel:Number; // last thrust value before glide
		private var _velocity:Number3D; // how much per time step the ship should move in all directions
		private var _velocityMagnitude:Number; // "airspeed"
		
		private var _velocityFutureSteps:Vector.<Number3D>;
		
		private var _controls:FlightControl;
		
		private var _tempReticule:Plane;
		
		private var _hud:SimpleHUD;
		
		public function Ship(scene:Scene3D, stageRef:Stage, hud:SimpleHUD)
		{
			super();
			
			_sceneHolder = scene;
			_stageRef = stageRef;
			_hud = hud;
			
			var ba:ByteArray= (new ViperData()) as ByteArray;
			var s:String = ba.readUTFBytes(ba.length);
			var x:XML = new XML(s);
			_width = x.physical.width.@value * 10;
			_height = x.physical.height.@value * 10;
			_length = x.physical.length.@value * 10;
			_mass = x.physical.mass.@value * 10;
			
			_maxThrust = x.engine.maxthrust.@value;
			_maxRCSThrust = x.engine.maxrcsthrust.@value;
			_topSpeed = x.engine.topspeed.@value;
			
			_drag = x.handling.drag.@value;
			_turnRate = x.handling.turnrate.@value;
			
			_masterFiringTimer = new Timer(x.armaments.mainweapon.@firerate);
			_masterFiringTimer.addEventListener(TimerEvent.TIMER, fireSingleShot);
			
			_firepods = new Vector.<FirePod>(x.armaments.mainweapon.@count);
			for (var k:int = 0; k < x.armaments.mainweapon.@count; k++)
			{
				_firepods[k] = new FirePod(
					this, _sceneHolder,
					x.armaments.mainweapon.firepod[k].@x * 10, 
					x.armaments.mainweapon.firepod[k].@y * 10, 
					x.armaments.mainweapon.firepod[k].@z * 10,
					x.armaments.mainweapon.@firerate, x.armaments.mainweapon.@velocity,
					x.armaments.mainweapon.@maxammo, x.armaments.mainweapon.@power,
					x.armaments.mainweapon.@type, x.armaments.mainweapon.firepod[k].@visiblename);
				this.addChild(_firepods[k]);
			}
			
			_nextPodToFire = 0;
			_isFiring = false;
			
			_isGliding = false;
			_speedRestricted = true;
			_throttleLevel = 0;
			// update initial throttle level
			_hud.updateThrottle(Math.round(_throttleLevel * 100));
			
			_thrustLevel = 0;
			_velocity = new Number3D();
			
			_velocityFutureSteps = new Vector.<Number3D>(30);
			for(var i:int = 0; i < _velocityFutureSteps.length; i++)
			{
				_velocityFutureSteps[i] = new Number3D();
			}
			
			var mat:ColorMaterial = new ColorMaterial(0xFFFFFF);
			var mats:MaterialsList = new MaterialsList();
			mats.addMaterial(mat, 'all');
			var body:Cone = new Cone(mat, _height, _length);
			body.pitch(90);
			this.addChild(body);
			
			_controls = new FlightControl(_stageRef, 10, 10, _turnRate);
			createTargetingReticule();
		}
		public function startGliding():Boolean
		{
			if(_isGliding)
			{
				return true;
			}
			else
			{
				trace('gliding activated');
				_isGliding = true;
				_prevThrustLevel = _thrustLevel;
				_thrustLevel = 0;
				return false;
			}
			
		}
		public function stopGliding():Boolean
		{
			if(_isGliding)
			{
				trace('gliding deactivated');
				_isGliding = false;
				_thrustLevel = _prevThrustLevel;
				_prevThrustLevel = 0;
				return false
			}
			else
			{
				return true;
			}
		}
		public function update(collisionList:Array, worldFriction:Number):void
		{
        	this.yaw(_controls.getYawRate(_throttleLevel));
        	this.pitch(_controls.getPitchRate(_throttleLevel));
        	this.roll(_controls.getRollRate(_throttleLevel));
        	
        	calculateVelocity(_drag * worldFriction);
        	move();
        	updateTargetReticule();
        	updateMainWeapons(collisionList);
		}
		
		public function move():void
		{			
			this.x += _velocity.x;
			this.y += _velocity.y;
			this.z += _velocity.z;
		}
		public function calculateVelocity(friction:Number):void
		{
			var forwardAxis:Number3D = new Number3D(0, 0, 1); // forward
			Matrix3D.rotateAxis(this.transform, forwardAxis);
			_velocity.x += _thrustLevel * forwardAxis.x;
			_velocity.y += _thrustLevel * forwardAxis.y;
			_velocity.z += _thrustLevel * forwardAxis.z;
			
			/*if(_velocity.x > _topSpeed)
				_velocity.x = _topSpeed;
			if(_velocity.y > _topSpeed)
				_velocity.y = _topSpeed;
			if(_velocity.z > _topSpeed)
				_velocity.z = _topSpeed;
				
			if(_velocity.x < _topSpeed * -1)
				_velocity.x = _topSpeed * -1;
			if(_velocity.y < _topSpeed * -1)
				_velocity.y = _topSpeed * -1;
			if(_velocity.z < _topSpeed  * -1)
				_velocity.z = _topSpeed * -1;*/
			
			if(!_isGliding)
			{
				_velocity.x *= friction;
				_velocity.y *= friction;
				_velocity.z *= friction;
			}	
			
			_velocityMagnitude = Math.sqrt( _velocity.x*_velocity.x +
											_velocity.y*_velocity.y +
											_velocity.z*_velocity.z);
			
			if(_velocityMagnitude > _topSpeed && _speedRestricted)
			{
				// reset velocity here?
			}
			
			_velocityFutureSteps[0].x = this.x + _velocity.x;
			_velocityFutureSteps[0].y = this.y + _velocity.y;
			_velocityFutureSteps[0].z = this.z + _velocity.z;								
			
			for(var i:int = 1; i < _velocityFutureSteps.length; i++)
			{
				_velocityFutureSteps[i].x = _velocityFutureSteps[i-1].x + (_velocity.x + _thrustLevel * forwardAxis.x);
				_velocityFutureSteps[i].y = _velocityFutureSteps[i-1].y + (_velocity.y + _thrustLevel * forwardAxis.y);
				_velocityFutureSteps[i].z = _velocityFutureSteps[i-1].z + (_velocity.z + _thrustLevel * forwardAxis.z);
			}
			//trace(_velocity);
		}
		public function increaseThrottle():void
		{
			_throttleLevel += 0.01;
			if(_throttleLevel > 1) _throttleLevel = 1;
			_thrustLevel = _throttleLevel * _maxThrust;
			_hud.updateThrottle(Math.round(_throttleLevel * 100));
			//trace(_throttleLevel);
		}
		public function decreaseThrottle():void
		{
			_throttleLevel -= 0.01;
			if(_throttleLevel < 0) _throttleLevel = 0;
			_thrustLevel = _throttleLevel * _maxThrust;
			_hud.updateThrottle(Math.round(_throttleLevel * 100));
			//trace(_throttleLevel);
		}
		public function startFiring():void
		{
			if(!_isFiring)
			{
				_masterFiringTimer.reset();
				_masterFiringTimer.start();
			}
			_isFiring = true;
		}
		public function stopFiring():void
		{
			_isFiring = false;
			_masterFiringTimer.stop();
			_masterFiringTimer.reset();
			_nextPodToFire = 0;
		}
		public function updateMainWeapons(collisionList:Array):void
		{
			// update positions of all projectiles of all firepods
			for each(var pod:FirePod in _firepods)
			{
				pod.updateProjectilePositions(collisionList);	
			}
		}
		public function get velocity():Number3D
		{
			return new Number3D(_velocity.x, _velocity.y, _velocity.z);
		}
		public function get velocityMagnitude():Number
		{
			return _velocityMagnitude;
		}
		public function get speedLimit():Number
		{
			return _topSpeed;
		}
		public function getVelocityFutureStep(step:int):Number3D
		{
			return _velocityFutureSteps[step];
		}
		private function fireSingleShot(e:TimerEvent):void
		{
			if(_nextPodToFire > _firepods.length - 1)
				_nextPodToFire = 0;
			_firepods[_nextPodToFire].fire(e);
			_nextPodToFire++;
		}
		private function createTargetingReticule():void
		{
			_tempReticule = new Plane( new WireframeMaterial(0x333399), 40, 40, 1, 1);
			_tempReticule.copyTransform(this);
			_tempReticule.moveForward(400);
			_sceneHolder.addChild(_tempReticule);
		}
		private function updateTargetReticule():void
		{
			_tempReticule.copyTransform(this);
			_tempReticule.moveForward(500);
		}
	}
}