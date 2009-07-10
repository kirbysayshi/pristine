package com.pristine
{
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.scenes.Scene3D;

	public class StarfieldGenerator extends DisplayObject3D
	{
		private var _starCount:Number;	
		private var _starSize:int;
		private var _drawDistance:Number;
		private var _deleteDistance:Number;
		private var _depth:Number;
		private var _height:Number;
		private var _width:Number;
		
		private var _currentField:int;
		private var _fields:Vector.<ParticleField>;
		
		private var _positionCounter:Number;
		private var _lastSwapPos:Number3D; // the position at which the last swap occurred
		private var _lastSwap:ParticleField;
		
		public function StarfieldGenerator(scene:Scene3D, start:Number3D, count:int=100, 
		size:int=4, drawDistance:int=3000, deleteDistance:int=5, depth:int=1000, 
		height:int=5000, width:int=5000)
		{
			super();
			
			_starCount = count;
			_starSize = size;
			_drawDistance = drawDistance;
			_deleteDistance = deleteDistance;
			_depth = depth;
			_height = height;
			_width = width;
			
			_positionCounter = 0;
			_lastSwapPos = new Number3D();
			_lastSwapPos.copyFrom(start);	
			
			var starMat:ParticleMaterial = new ParticleMaterial(0xFFFFFF, 1, 1);
			
			var max:int = Math.round(_deleteDistance / 2);
			_currentField = 0;
			
			_fields = new Vector.<ParticleField>(max * 2, false);
			
			trace("Starfield count (+=): " + max);
			for (var f:int = 0; f < max * 2; f++)
			{
				_fields[f] = new ParticleField(starMat, _starCount, 
					_starSize, _width, _height, _depth);
				_fields[f].x = start.x;
				_fields[f].y = start.y;
				_fields[f].z = start.z;
				if(f <= max)
				{
					_fields[f].moveBackward((max - f) * _drawDistance);
				}
				if(f > max)
				{
					_fields[f].moveForward((f - max) * _drawDistance);
				}
				scene.addChild(_fields[f]);
			}
			_lastSwap = _fields[0];
		}
		public function checkFields(shipRef:Ship):void
		{
			_positionCounter += Math.abs(shipRef.velocity.x) + Math.abs(shipRef.velocity.y) + Math.abs(shipRef.velocity.z);
			if(_positionCounter > shipRef.velocityMagnitude*18)
			{
				trace(_positionCounter);
				_positionCounter = 0;
				
				_fields[_currentField].copyTransform(shipRef);
				
				_fields[_currentField].x +=  shipRef.velocity.x * 30;
				_fields[_currentField].y +=  shipRef.velocity.y * 30;
				_fields[_currentField].z +=  shipRef.velocity.z * 30;

				_currentField++;
				if(_currentField >= _fields.length)
					_currentField = 0;
			}
			
		}
	}
}