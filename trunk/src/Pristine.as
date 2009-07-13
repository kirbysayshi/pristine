package
{
	import br.com.stimuli.loading.BulkLoader;
	
	import com.bigroom.input.KeyPoll;
	import com.pristine.Player;
	import com.pristine.SpaceDebrisGenerator;
	import com.pristine.StarfieldGenerator;
	import com.pristine.starbox.Starbox;
	import com.pristine.starbox.StarboxEvent;
	
	import flash.display.StageDisplayState;
	import flash.events.*;
	import flash.utils.*;
	
	import org.ascollada.utils.FPS;
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.cameras.SpringCamera3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	[SWF(width='800', height='600', backgroundColor='#000000', frameRate='31')]
	public class Pristine extends BasicView
	{
		private var _player:Player;
		private var _keys:KeyPoll;
		
		private var _worldFriction:Number;
		
		private var _starfields:StarfieldGenerator;
		private var _spacedebris:SpaceDebrisGenerator;
		
		private var _springCamera:SpringCamera3D;
		private var _cam:Camera3D;
		
		private var _collisionList:Array;
		
		private var _floorHP:Number;
		
		private var _masterLoader:BulkLoader;
		
		private var _starbox:Starbox;
		
		private var _stuffToLoad:Dictionary;
		
		public function Pristine()
		{
			super(stage.stageWidth, stage.stageHeight, true, false, CameraType.FREE);
			
			_stuffToLoad = new Dictionary();
			
			viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
			
			_masterLoader = new BulkLoader('master');
			
			_keys = new KeyPoll(stage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, clickHandler);
			
			var fps:FPS = new FPS();
			this.addChild(fps);
			
			_worldFriction = 1; // if we were underwater or something, this would be smaller
			_collisionList = new Array();
			
			setCamera();
			createPlayer();
			//createStarfields();
			_spacedebris = new SpaceDebrisGenerator(scene, 100, 600, 1);
			createTempStation();
			//createFloor();
			createTargets();
			_starbox = new Starbox(scene);
			_stuffToLoad[_starbox] = false;
			_starbox.addEventListener(StarboxEvent.LOADED, checkIfLoaded);
		}
		private function checkIfLoaded(e:*):void
        {
        	_stuffToLoad[e.self] == true;
        	
        	var ready:Boolean = true;
        	for each (var o:* in _stuffToLoad)
        	{
        		if( _stuffToLoad[o] == false )
        			ready = false;
        	}
        	
        	if(ready)
        		startRendering();
        }
		private function createPlayer():void
		{
			_player = new Player(scene, stage);
			scene.addChild(_player.getShip());
			//_player.getShip().pitch(90);
			//_cam.target = _player.getShip();
			//_springCamera.target = _player.getShip();
		}
		private function setCamera():void
		{
			_cam = new Camera3D();
			_cam.fov = 120;
			_cam.focus = 50;
			_cam.zoom = 12;
			/*_springCamera = new SpringCamera3D();
			_springCamera.mass = 50;
            _springCamera.damping = 15;
            _springCamera.stiffness = 1;
                
            _springCamera.lookOffset = new Number3D(0, 0, 30);
            _springCamera.positionOffset = new Number3D(0, 100, -1500);
            
            _springCamera.focus = 100;
            _springCamera.zoom = 10;*/
            
		}
		private function createStarfields():void
		{
			_starfields = new StarfieldGenerator(scene, _player.getShip().position);
			
		}
		private function createFloor():void
        {
            var floor:Plane = new Plane(new WireframeMaterial(0xFFFFFF), 100000, 100000, 10000*0.001, 10000*0.001);
            floor.rotationX = 90;
            floor.y = -10000;
            floor.z = 100000;
            scene.addChild(floor);
            _floorHP = 1000;
            _collisionList.push( new Array(floor, _floorHP));
        }
        private function createTargets():void
        {
        	var mat:ColorMaterial = new ColorMaterial();
        	for(var i:int = 0; i < 5; i++)
        	{
        		var mats:MaterialsList = new MaterialsList();
				mats.addMaterial(mat, 'all');
        		var b:Cube = new Cube(mats, i * 40, i * 40, i * 40);
        		b.position = new Number3D(i * 400, 0, 400);
        		_collisionList.push( new Array(b, i * 40));
        		scene.addChild(b); 
        	}
        }
        private function createTempStation():void
        {
        	var stationMat:ColorMaterial = new ColorMaterial(0x666666);
			var stationSaucer:Cylinder = new Cylinder(stationMat, 6000, 500);
			stationSaucer.copyTransform(_player.getShip());
			
			var stationMat2:ColorMaterial = new ColorMaterial(0x3366CC);
			var stationCenter:Cylinder = new Cylinder(stationMat2, 500, 8000);
			stationCenter.copyTransform(_player.getShip());
			stationSaucer.moveUp(2000);
			
			stationCenter.moveForward(600000);
			stationSaucer.moveForward(600000);
			
			scene.addChild(stationCenter);
			scene.addChild(stationSaucer);
        }
        private function checkKeys():void
        {
        	if(_keys.isDown(KeyPoll.W))
         	{
         		_player.getShip().pitch(1);
         		//trace("W");
         	}   
            if(_keys.isDown(KeyPoll.S))
         	{
         		_player.getShip().pitch(-1);
         		//trace("S"); 
         	} 
            if(_keys.isDown(KeyPoll.D))
         	{
         		_player.getShip().roll(-1);
         		//trace("D");
         	}
         	if(_keys.isDown(KeyPoll.A))
         	{
         		_player.getShip().roll(1);
         		//trace("A");
         	}
         	if(_keys.isDown(KeyPoll.EQUAL))
         	{
         		_player.getShip().increaseThrottle();
         	}
         	if(_keys.isDown(KeyPoll.MINUS))
         	{
         		_player.getShip().decreaseThrottle();
         	}
         	if(_keys.isDown(KeyPoll.RIGHTBRACKET))
         	{
         		_cam.focus += 1;
         		trace(_cam.focus);
         	}
         	if(_keys.isDown(KeyPoll.LEFTBRACKET))
         	{
         		_cam.focus -= 1;
         		trace(_cam.focus);
         	}
         	 
         	if(_keys.isDown(KeyPoll.V))
         	{
         		trace(_player.getShip().velocityMagnitude);
         	}
         	 
         	if(_keys.isDown(KeyPoll.SPACE))
         	{
         		_player.getShip().startGliding();
         	}
         	else
         	{
         		_player.getShip().stopGliding();
         	}
         	
         	if(_keys.isDown(KeyPoll.V))
         	{
         		//_player.getShip().controls.showDeadzone();
         	}
         	else
         	{
         		//_player.getShip().controls.hideDeadzone();
         	}
        }
        private function clickHandler(e:MouseEvent):void
        {
        	if(e.type == MouseEvent.MOUSE_DOWN)
        	{
        		_player.getShip().startFiring();	
        		trace('start firing');
        	}
        	else if(e.type == MouseEvent.MOUSE_UP)
        	{
        		_player.getShip().stopFiring();
        		trace('stop firing');
        	}
        }
		override protected function onRenderTick(event:Event = null):void
        {
        	checkKeys();
        	//_starfields.checkFields(_player.getShip());
        	
        	_spacedebris.renderDebris(_player.getShip().getVelocityFutureStep(15), _player.getShip().position, _player.getShip().velocityMagnitude, _player.getShip().speedLimit);
        	
        	_player.getShip().update(_collisionList, _worldFriction);
        	
        	//_starbox.syncPosition(_player.getShip());
        	//_starbox.sendToBack(viewport);
        	_cam.copyTransform(_player.getShip());
        	//_cam.moveBackward(1000);
        	//_cam.moveUp(400);
        	
            renderer.renderScene(scene, _cam, viewport);
            //renderer.renderScene(scene, _springCamera, viewport);
        }
	}
}