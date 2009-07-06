package
{
	import com.bigroom.input.KeyPoll;
	import com.pristine.Player;
	
	import flash.events.*;
	
	import org.ascollada.utils.FPS;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.cameras.SpringCamera3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	[SWF(width='800', height='600', backgroundColor='#000000', frameRate='31')]
	public class Pristine extends BasicView
	{
		private var _player:Player;
		private var _keys:KeyPoll;
		
		private var _springCamera:SpringCamera3D;
		
		public function Pristine()
		{
			super(stage.stageWidth, stage.stageHeight, true, false, CameraType.SPRING);
			viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
			
			_keys = new KeyPoll(stage);
			
			var fps:FPS = new FPS();
			this.addChild(fps);
			
			setCamera();
			createPlayer();
			createFloor();
			startRendering();
		}
		private function createPlayer():void
		{
			_player = new Player();
			scene.addChild(_player.getShip());
			_springCamera.target = _player.getShip();
		}
		private function setCamera():void
		{
			_springCamera = new SpringCamera3D();
			_springCamera.mass = 10;
            _springCamera.damping = 10;
            _springCamera.stiffness = 1;
                
            _springCamera.lookOffset = new Number3D(0, 20, 30);
            _springCamera.positionOffset = new Number3D(0, 100, -1500);
            
            _springCamera.focus = 100;
            _springCamera.zoom = 10;
            
		}
		private function createFloor():void
        {
            var floor:Plane = new Plane(new WireframeMaterial(0xFFFFFF), 100000, 100000, 10000*0.001, 10000*0.001);
            floor.rotationX = 90;
            floor.y = -10000;
            floor.z = 10000;
            scene.addChild(floor);
        }
        private function checkKeys():void
        {
        	if(_keys.isDown(KeyPoll.W))
         	{
         		_player.getShip().pitch(0.3);
         		//trace("W");
         	}   
            if(_keys.isDown(KeyPoll.S))
         	{
         		_player.getShip().pitch(-0.3);
         		//trace("S"); 
         	} 
            if(_keys.isDown(KeyPoll.D))
         	{
         		_player.getShip().roll(0.3);
         		trace("D");
         	}
         	if(_keys.isDown(KeyPoll.A))
         	{
         		_player.getShip().roll(-0.3);
         		trace("A");
         	}
         	if(_keys.isDown(KeyPoll.EQUAL))
         	{
         		_player.getShip().increaseThrottle();
         	}
         	if(_keys.isDown(KeyPoll.MINUS))
         	{
         		_player.getShip().decreaseThrottle();
         	} 
         	if(_keys.isDown(KeyPoll.SPACE))
         	{
         		_player.getShip().startGliding();
         	}
         	else
         	{
         		_player.getShip().stopGliding();
         	}
        }
		override protected function onRenderTick(event:Event = null):void
        {
        	
        	checkKeys();
        	_player.getShip().move();
            renderer.renderScene(scene, _springCamera, viewport);
        }
	}
}