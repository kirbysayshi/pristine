package com.pristine
{
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;

	public class SpaceDebrisGenerator extends DisplayObject3D
	{
		private var _sceneref:Scene3D;
		private var _vels:Vector.<Number>;
		private var _particles:Vector.<Particle>;
		private var _parts:Particles;
		
		private var _width:Number;
		private var _sign:Number;
		
		public function SpaceDebrisGenerator(sceneref:Scene3D, density:Number, width:Number, debrisSize:int)
		{
			super();
			_sceneref = sceneref;
			_width = width;
				
			_vels = new Vector.<Number>(density);
			_particles = new Vector.<Particle>(density);
			
			_parts = new Particles('starfield');
			
			var mat:ParticleMaterial = new ParticleMaterial(0xFFFFFF, 1, 1);
			
			_sign = 1;
			
			for(var i:int = 0; i < _vels.length; i++)
			{
				var ranx:Number = Math.random()*_width*2 - Math.random()*_width*2;
				var rany:Number = Math.random()*_width*2 - Math.random()*_width*2;
				var ranz:Number = Math.random()*_width*2 - Math.random()*_width*2;
				
				_sign *= -1;
				
				_particles[i] = new Particle(mat, debrisSize, ranx, rany, ranz);
				
				_parts.addParticle( _particles[i] );	
			}
			_sceneref.addChild(_parts);
		}
		public function renderDebris(shipFutureVel:Number3D, shipPos:Number3D, shipVelMag:Number, shipSpeedLimit:Number):void
		{	
			for(var i:int = 0; i < _particles.length; i++)
			{
				var p:Particle = _particles[i];
				var dx :Number = p.x - shipPos.x;
				var dy :Number = p.y - shipPos.y;
				var dz :Number = p.z - shipPos.z;
				var d:Number = Math.sqrt( dx*dx + dy*dy + dz*dz );
				
				if(d > shipVelMag*18 && shipVelMag > 30) // this should be topspeed * 10
				{
					p.x = shipFutureVel.x + Math.random()*_width - Math.random()*_width;
					p.y = shipFutureVel.y + Math.random()*_width - Math.random()*_width;
					p.z = shipFutureVel.z + Math.random()*_width - Math.random()*_width;
				} 
			}
		}
	}
}