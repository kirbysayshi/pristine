package com.Flight
{
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Cylinder;

	public class Projectile extends Cylinder
	{
		public var destroyDistance:Number;
		
		private var mat:ColorMaterial;
		private var r:int;
		private var h:int;
		private var tR:int;
		
		private var fVel:Number;
		private var snapshot:Number3D;
		
		public function Projectile(type:String="bullet")
		{
			if ( type == "bullet" )
			{
				// viper = 800 max, 20 rounds per second
				mat = new ColorMaterial(0xFFFF99);
				r = 1;
				h = 500;
				tR = 3;
				destroyDistance = 7500;
			}
			else if ( type == "blaster" )
			{
				mat = new ColorMaterial(0xFFF000);
				r = 2;
				h = 500;
				tR = 5;
				destroyDistance = h * 18;
			}
			super( mat, r, h, 8, 6, tR);
		}
		public function saveVectorSnapshot(ship:Ship, shipVel:Number):void
		{
			snapshot = new Number3D(
				//ship.transform.n11 * shipVel, ship.transform.n21 * shipVel, ship.transform.n31 * shipVel);
				ship.transform.n14 * shipVel, ship.transform.n24 * shipVel, ship.transform.n34 * shipVel);
				//ship.x + shipVel, ship.y + shipVel, ship.z + shipVel);
			//trace("snapshot: " + snapshot);
			//trace("ship: " + ship.position);
		}
		public function updateFireForget():void
		{
			//trace("snap: " + snapshot + " plus: " + Number3D.add(snapshot, this.position));
			this.position.plusEq(snapshot);
			//this.z += snapshot.z;
			//this.y += snapshot.y;
			//this.x += snapshot.z;
			
		}
		public function set forwardVelocity(velocity:Number):void
		{
			fVel = velocity;
		}
		
		public function get forwardVelocity():Number
		{
			return fVel;
		}
		public function get snapshotVector():Number3D
		{
			return snapshot;
		}
	}
}