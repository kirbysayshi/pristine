package com.pristine
{
	import flash.utils.ByteArray;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cone;

	public class Ship extends DisplayObject3D
	{
		[Embed(source='assets/shipdata/vipermii.xml',mimeType="application/octet-stream")]
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
		
		private var _firepods:Array;
		
		private var _glideMatrix:Matrix3D;
		private var _isGliding:Boolean;
		private var _betweenGliding:Boolean;
		private var _glideVelocity:Number;
		
		private var _throttleLevel:Number;
		private var _thrustLevel:Number; // how much thrust...
		private var _velocity:Number; // how fast the ship is moving
		
		public function Ship()
		{
			super();
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
			
			_firepods = new Array();
			for (var k:int = 0; k < x.armaments.mainweapon.@count; k++)
			{
				var i:int = _firepods.push(new FirePod(
					x.armaments.mainweapon.firepod[k].@x * 10, 
					x.armaments.mainweapon.firepod[k].@y * 10, 
					x.armaments.mainweapon.firepod[k].@z * 10,
					x.armaments.mainweapon.@firerate, x.armaments.mainweapon.@velocity,
					x.armaments.mainweapon.@maxammo, x.armaments.mainweapon.@power,
					x.armaments.mainweapon.@type)) - 1;
				this.addChild(_firepods[i]);
			}
			
			_glideMatrix = new Matrix3D();
			_isGliding = false;
			_throttleLevel = 0;
			
			var mat:ColorMaterial = new ColorMaterial(0xFFFFFF);
			var mats:MaterialsList = new MaterialsList();
			mats.addMaterial(mat, 'all');
			var body:Cone = new Cone(mat, _height, _length);
			body.pitch(90);
			this.addChild(body);
		}
		public function startGliding():Matrix3D
		{
			if(_isGliding)
			{
				return _glideMatrix;
			}
			else
			{
				trace('gliding activated');
				_isGliding = true;
				_glideMatrix.copy(this.transform);
				return _glideMatrix;
			}
		}
		public function stopGliding():Boolean
		{
			if(_isGliding)
			{
				trace('gliding deactivated');
				_isGliding = false;
				_betweenGliding = true;
				return true;
			}
			else
			{
				return false;
			}
		}
		public function move():void
		{
			_velocity = _throttleLevel * _maxThrust;
			if(!_isGliding && !_betweenGliding)
			{
				this.moveForward(_velocity);			
			}
			else if (_betweenGliding)
			{
				var forwardThrustAxis:Number3D = new Number3D(0, 0, 1);
				var forwardGlideAxis:Number3D = new Number3D(0, 0, 1); // forward
				
				Matrix3D.rotateAxis(_glideMatrix, forwardGlideAxis);
				Matrix3D.rotateAxis(this.transform, forwardThrustAxis);
				
				this.x += _velocity * (forwardGlideAxis.x + forwardThrustAxis.x) / 2;
				this.y += _velocity * (forwardGlideAxis.y + forwardThrustAxis.y) / 2;
				this.z += _velocity * (forwardGlideAxis.z + forwardThrustAxis.z) / 2;
				trace("glide: " + forwardGlideAxis + " thrust: " + forwardThrustAxis);	
				
				var diff:Number3D = new Number3D( 
					Math.abs(forwardGlideAxis.x) - Math.abs(forwardThrustAxis.x),
					Math.abs(forwardGlideAxis.y) - Math.abs(forwardThrustAxis.y),
					Math.abs(forwardGlideAxis.z) - Math.abs(forwardThrustAxis.z));
				
				if( Math.abs(diff.x) < 0.05 && Math.abs(diff.y) < 0.05 && Math.abs(diff.z) < 0.05)
				{
					_betweenGliding = false;
					_glideMatrix.copy(Matrix3D.IDENTITY);
				}
			}
			else // gliding
			{
				var forwardAxis:Number3D = new Number3D(0, 0, 1); // forward
				Matrix3D.rotateAxis(_glideMatrix, forwardAxis);
				this.x += _velocity * forwardAxis.x;
				this.y += _velocity * forwardAxis.y;
				this.z += _velocity * forwardAxis.z;
				
				_glideVelocity = _velocity;
			}
		}
		public function increaseThrottle():void
		{
			_throttleLevel += 0.01;
			if(_throttleLevel > 1) _throttleLevel = 1;
			trace(_throttleLevel);
		}
		public function decreaseThrottle():void
		{
			_throttleLevel -= 0.01;
			if(_throttleLevel < 0) _throttleLevel = 0;
			trace(_throttleLevel);
		}
	}
}