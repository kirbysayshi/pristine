package com.pristine
{
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;

	public class Player extends DisplayObject3D
	{
		private var _ship:Ship;
		
		public function Player(scene:Scene3D)
		{
			super();
			_ship = new Ship(scene);
		}
		public function getShip():Ship
		{
			return _ship;
		}
	}
}