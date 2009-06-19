/**
 * @ClassName	: Starfield 
 * @Author 		: Slavomir Durej
 * @Copyright 	: © 2008 Durej.com 
 * 
 * Generates a box filed with stars to be used in Papervision3D scene.
 */ 

package com.durej.pv3d
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
		
	public class Starfield extends Cube
	{
		private var contentWidth			:Number;
		private var contentHeight			:Number;
		
		private var nuStars					:int;
		private var size					:Number;
		
		/**
		 *  Constructor parameters :
		 * 
		 *  @param: nuStars - Number of the stars to be visible per cube side
		 *  @param: size - width/height/depth of the cube
		 *  @param: contentWidth - width of the texture bitmap used on every side of the cube
		 *  @param: contentHeight - height of the texture bitmap used on every side of the cube
		 */ 
		public function Starfield(nuStars:Number=5000, size:Number=10000,contentWidth:Number=500,contentHeight:Number=500)
		{
			this.nuStars 		= nuStars;
			this.contentWidth 	= contentWidth;
			this.contentHeight 	= contentHeight;
			
			var matFront 	: BitmapMaterial = new BitmapMaterial(getStarField()); 
			var matLeft 	: BitmapMaterial = new BitmapMaterial(getStarField()); 
			var matBack 	: BitmapMaterial = new BitmapMaterial(getStarField()); 
			var matUp 		: BitmapMaterial = new BitmapMaterial(getStarField()); 
			var matRight 	: BitmapMaterial = new BitmapMaterial(getStarField()); 
			var matDown 	: BitmapMaterial = new BitmapMaterial(getStarField()); 

			matFront.doubleSided 	= true; 
			matLeft.doubleSided 	= true; 
			matBack.doubleSided 	= true; 
			matUp.doubleSided 		= true; 
			matRight.doubleSided 	= true; 
			matDown.doubleSided 	= true; 

			var ml : MaterialsList = new MaterialsList(); 
			
			ml.addMaterial(matFront, 	"front"); 
			ml.addMaterial(matLeft, 	"left"); 
			ml.addMaterial(matBack, 	"back"); 
			ml.addMaterial(matUp, 		"top"); 
			ml.addMaterial(matRight, 	"right"); 
			ml.addMaterial(matDown, 	"bottom"); 
			
			super(ml, size, size, size,5,5,5);
		}
		
		private function getStarField():BitmapData
		{
			var bmp:BitmapData=new BitmapData(contentWidth, contentHeight, false,0);
			
			var sprite:Sprite=new Sprite();
			
			for(var i:uint=0; i<nuStars; i++) 
			{
				var shadeOfGray:Number = Math.random()*255; 
				
				sprite.graphics.beginFill(shadeOfGray<<16 | shadeOfGray<<8 | shadeOfGray);
				
				sprite.graphics.drawCircle(Math.random()*contentWidth, Math.random()*contentHeight, Math.random()*1.5);
			}
			sprite.filters=[new BlurFilter(1.3,1.3,4)];
			
			bmp.draw(sprite);

			return bmp;
		}
		
	}
}