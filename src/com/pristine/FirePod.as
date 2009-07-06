package com.pristine
{
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cylinder;

	public class FirePod extends DisplayObject3D
	{
		private var _firerate:Number;
		private var _velocity:Number;
		private var _maxammo:Number;
		private var _power:Number;
		private var _type:String;
		
		public function FirePod(xoffset:Number, yoffset:Number, zoffset:Number, firerate:Number, velocity:Number, maxammo:Number, power:Number, type:String="bullet")
		{
			super();
			this.x = xoffset;
			this.y = yoffset;
			this.z = zoffset;
			_firerate = firerate;
			_velocity = velocity;
			_maxammo = maxammo;
			_power = power;
			_type = type;
			
			var visible:Cylinder = new Cylinder(new ColorMaterial(0xEEEEEE), 11, 20);
			visible.pitch(90);
			this.addChild(visible);
		}
	}
}