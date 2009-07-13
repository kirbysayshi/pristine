package com.pristine
{
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cylinder;

	public class Projectile extends DisplayObject3D
	{
		private var _destroyDistance:Number;
		private var _radius:Number;
		private var _length:Number;
		private var _topRadius:Number;
		private var _type:String;
		private var _mat:ColorMaterial;
		private var _visible:Cylinder;
		
		private var _originPoint:Number3D;
		
		private var _shipVelocity:Number3D;
		
		private var _isBeingShot:Boolean;
		
		private var _lastPos:Number3D;
		
		public function Projectile(type:String="bullet")
		{
			_type = type;
			_originPoint = new Number3D();
			_shipVelocity = new Number3D();
			_lastPos = new Number3D();
			_isBeingShot = false;
			
			if ( _type == "bullet" )
			{
				// viper = 800 max, 20 rounds per second
				_mat = new ColorMaterial(0xFFFF99);
				_radius = 1;
				_length = 500;
				_topRadius = 3;
				_destroyDistance = 7500;
			}
			else if ( _type == "blaster" )
			{
				_mat = new ColorMaterial(0xFF0000);
				_radius = 2;
				_length = 1000;
				_topRadius = 5;
				_destroyDistance = _length * 18;
			}
			
			_visible = new Cylinder(_mat, _radius, _length, 8, 6, _topRadius);
			this.addChild(_visible);
			_visible.pitch(90);
		}
		public function fireForget(orientation:Matrix3D, offset:Number3D, shipVel:Number3D):void
		{
			this.copyTransform(orientation);
			_shipVelocity.copyFrom(shipVel);
			_lastPos.copyFrom(_originPoint);
			moveRight(offset.x);
			moveUp(offset.y);
			moveForward(offset.z);
			_isBeingShot = true;
		}
		public function set lastPosition(pos:Number3D):void
		{
			_lastPos.copyFrom(pos);
		}
		public function get lastPosition():Number3D
		{
			return _lastPos;
		}
		public function set originPoint(origin:Number3D):void
		{
			_originPoint = origin;
		}
		public function get originPoint():Number3D
		{
			return _originPoint;
		}
		public function get destroyDistance():Number
		{
			return _destroyDistance;
		}
		public function get velocity():Number3D
		{
			return _shipVelocity;
		}
		public function deactivate():void
		{
			_isBeingShot = false;
		}
		public function get activated():Boolean
		{
			return _isBeingShot;
		}
		public function get visibleGeometry():DisplayObject3D
		{
			return _visible;
		}
	}
}