package com.Flight
{
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.Sphere;

	public class FirePod extends DisplayObject3D
	{
		public var power:Number;
		public var givenName:String;
		public var zBlastPoint:Number;
		private var xOff:Number;
		private var yOff:Number;
		private var zOff:Number;
		
		private var visual:Cylinder;
		private var tip:Sphere;
		
		public function FirePod(name:String, xOff:Number, yOff:Number, zOff:Number, power:Number)
		{
			super();
			this.xOff = xOff;
			this.yOff = yOff;
			this.zOff = zOff;
			this.zBlastPoint = zOff;
			this.power = power;
			this.givenName = name;
			visual = new Cylinder(new ColorMaterial(0xFFFFFF), 1, zOff);
			visual.pitch(90);
			visual.x = 0;
			visual.y = 0;
			visual.z = zOff / 2;
			tip = new Sphere(new ColorMaterial(0xAAAAAA), 2);
			tip.z = 0;
			tip.y = 0;
			tip.x = 0;
			this.addChild(visual); 
			this.addChild(tip);
		}
		public function placeAccordingToOffset():Array
		{
			this.x += xOff;
			this.y += yOff;
			//this.z += zOff;
			return ([x, y, z]);
		}
	}
}