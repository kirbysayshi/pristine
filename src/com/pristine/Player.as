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
		
		public function Player(scene:Scene3D, stageRef:Stage)
		{
			super();
			readyHUD(stageRef);
			_ship = new Ship(scene, stageRef, _simpleHud);
		}
		public function getShip():Ship
		{
			return _ship;
		}
		private function readyHUD(stageRef:Stage):void
		{
			_simpleHud = new SimpleHUD();
			stageRef.addChild(_simpleHud);
		}
	}
}