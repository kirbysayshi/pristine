package com.pristine
{
	import com.pristine.hud.SimpleHUD;
	
	import flash.display.Stage;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;

	public class Player extends DisplayObject3D
	{
		private var _ship:Ship;
		private var _simpleHud:SimpleHUD;
		private var _sceneref:Scene3D;
		private var _stage:Stage
		
		private var _shipOptions:Array = ['awing', 'xwing', 'vipermii'];
		
		public function Player(scene:Scene3D, stageRef:Stage)
		{
			super();
			readyHUD(stageRef);
			_ship = new Ship(scene, 'vipermii', stageRef, _simpleHud);
			_sceneref = scene;
			_stage = stageRef;
		}
		public function getShip():Ship
		{
			return _ship;
		}
		public function swapShips():void
		{
			_sceneref.removeChild(_ship);
			var next:String = _shipOptions.shift();
			trace(next);
			_ship = new Ship(_sceneref, next, _stage, _simpleHud);
			_shipOptions.push(next); 
			trace(_shipOptions);
			_sceneref.addChild(_ship);
			
		}
		private function readyHUD(stageRef:Stage):void
		{
			_simpleHud = new SimpleHUD();
			stageRef.addChild(_simpleHud);
		}
	}
}