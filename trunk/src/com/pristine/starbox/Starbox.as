package com.pristine.starbox
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	
	import com.pristine.Ship;
	
	import flash.events.*;
	import flash.utils.ByteArray;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	public class Starbox extends DisplayObject3D
	{
		[Embed(source='assets/starboxes/starboxes.xml',mimeType="application/octet-stream")]
		private var StarboxData:Class;
		
		private var _x:XML;
		private var _list:Array;
		
		private var _top:BitmapMaterial;
		private var _bottom:BitmapMaterial;
		private var _left:BitmapMaterial;
		private var _right:BitmapMaterial;
		private var _front:BitmapMaterial;
		private var _back:BitmapMaterial;	
		
		private var _starboxname:String;
		private var _url:String;
		
		private var _box:Cube;
		
		private var _loader:BulkLoader;
		private var _sceneRef:Scene3D;
		
		public function Starbox(sceneRef:Scene3D)
		{
			super();
			_sceneRef = sceneRef;
			parseStarfields();
			
			_loader = new BulkLoader('starbox');
			_loader.addEventListener(BulkLoader.COMPLETE, onComplete);
			_loader.addEventListener(BulkLoader.ERROR, onError);
			
			displayStarbox('hotnebula');
		}
		private function parseStarfields():void
		{
			_list = new Array();
			
			var ba:ByteArray = (new StarboxData()) as ByteArray;
			var s:String = ba.readUTFBytes(ba.length);
			_x = new XML(s);
			for each(var box:XML in _x.starbox)
			{
				_list[box.@folder] = new Object();
				_list[box.@folder].front = box.front.@src;
				
				_list[box.@folder].back = box.back.@src;
				
				_list[box.@folder].left = box.left.@src;
				
				_list[box.@folder].top = box.top.@src;
				_list[box.@folder].right = box.right.@src;
				_list[box.@folder].bottom = box.bottom.@src;
				_list[box.@folder].displayname = box.@displayname;
				_list[box.@folder].folder = box.@folder;
			} 
		}
		public function getStarboxList():Array
		{
			var a:Array = new Array();
			for each(var data:* in _list)
			{
				a.push(data.folder);
			}
			return a;
		}
		public function displayStarbox(nameOfBoxToGet:String):void
		{
			_starboxname = nameOfBoxToGet;
			_url = './assets/starboxes/' + _list[_starboxname].folder + "/";
			_loader.add(_url + _list[_starboxname].top);
			_loader.add(_url + _list[_starboxname].bottom);
			_loader.add(_url + _list[_starboxname].front);
			_loader.add(_url + _list[_starboxname].back);
			_loader.add(_url + _list[_starboxname].left);
			_loader.add(_url + _list[_starboxname].right);
			_loader.start();
		}
		public function sendToBack(vp:Viewport3D):void
		{
			vp.getChildLayer(_box, false).forceDepth = true;
			vp.getChildLayer(_box, false).layerIndex = 999999;
		}
		public function syncPosition(obj:Ship):void
		{
			//trace("pos: " + obj.position + " sky: " + _box.position);
			_box.copyPosition(obj);
			//trace("pos: " + obj.position + " sky: " + _box.position);
		}
		private function onError(e:*):void
		{		
			
		}
		private function onComplete(e:BulkProgressEvent):void
		{
			trace('starbox loaded');
			_top = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].top));
			_bottom = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].bottom));
			_left = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].left));
			_right = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].right));
			_front = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].front));
			_back = new BitmapMaterial(
				_loader.getBitmapData(_url + _list[_starboxname].back));
			
			_top.doubleSided = true;
			_bottom.doubleSided = true;
			_left.doubleSided = true;
			_right.doubleSided = true;
			_front.doubleSided = true;
			_back.doubleSided = true;
			
			var skyBoxMats:MaterialsList = new MaterialsList(); 
			
			skyBoxMats.addMaterial(_front, "front"); 
			skyBoxMats.addMaterial(_left, "left"); 
			skyBoxMats.addMaterial(_back, "back"); 
			skyBoxMats.addMaterial(_top, "top"); 
			skyBoxMats.addMaterial(_right, "right"); 
			skyBoxMats.addMaterial(_bottom, "bottom");
			//skyBoxMats.addMaterial(new WireframeMaterial(), 'all'); 
			
			_box = new Cube(skyBoxMats, 100000000, 100000000, 100000000, 4,4,4); // originally 4
			//_box = new Cube(skyBoxMats, 512, 512, 512, 4, 4, 4);
			_sceneRef.addChild(_box);
			var evt:StarboxEvent = new StarboxEvent(this, StarboxEvent.LOADED);
			this.dispatchEvent(evt);
		}
	}
}