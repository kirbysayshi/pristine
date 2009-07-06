package com.pristine
{
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Player extends DisplayObject3D
	{
		private var _ship:Ship;
		
		public function Player()
		{
			super();
			_ship = new Ship();
		}
		public function getShip():Ship
		{
			return _ship;
		}
	}
}