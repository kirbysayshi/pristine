package com.pristine
{
	import flash.display.Stage;
	
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;

	public class Player extends DisplayObject3D
	{
		private var _ship:Ship;
		
		public function Player(scene:Scene3D, stageRef:Stage)
		{
			super();
			_ship = new Ship(scene, stageRef);
		}
		public function getShip():Ship
		{
			return _ship;
		}
	}
}