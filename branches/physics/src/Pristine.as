package
{
	import com.bigroom.input.KeyPoll;
	
	import flash.events.*;
	import flash.utils.ByteArray;
	
	import jiglib.geometry.JCapsule;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.plugin.papervision3d.Papervision3DPhysics;
	import jiglib.plugin.papervision3d.Pv3dMesh;
	
	import org.ascollada.utils.FPS;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.cameras.SpringCamera3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;

	[SWF(width='800', height='600', backgroundColor='#000000', frameRate='31')]
	public class Pristine extends BasicView
	{
		[Embed(source='assets/shipdata/vipermii.xml',mimeType="application/octet-stream")]
		protected var ShipData:Class;
		
		private var _shipDisplay:DisplayObject3D;
		private var _shipPhysics:JCapsule;
		private var _physics:Papervision3DPhysics;
		private var _keys:KeyPoll;
		
		private var _springCamera:SpringCamera3D;
		private var _cameraTarget:DisplayObject3D;
		
		public function Pristine()
		{
			super(stage.stageWidth, stage.stageHeight, true, false, CameraType.TARGET);
			viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
			_physics = new Papervision3DPhysics(scene, 10);
			PhysicsSystem.getInstance().setGravity(new JNumber3D(0,0,0));
			_keys = new KeyPoll(stage);
			
			var fps:FPS = new FPS();
			this.addChild(fps);
			
			setCamera();
			createShip();
			createFloor();
			startRendering();
		}
		private function createShip():void
		{
			var ba:ByteArray = (new ShipData()) as ByteArray;
			var s:String = ba.readUTFBytes(ba.length);
			var x:XML =new XML(s);
			var width:Number = x.physical.width.@value * 10;
			var height:Number = x.physical.height.@value * 10;
			var length:Number = x.physical.length.@value * 10;
			
			var mat:ColorMaterial = new ColorMaterial(0xFFFFFF);
			var mats:MaterialsList = new MaterialsList();
			mats.addMaterial(mat, 'all');
			var body:Cube = new Cube(mats, width, length, height);
			//var body:Cone = new Cone(mat, height, length);
			//body.rotationX = 90;
			
			_shipDisplay = new DisplayObject3D();
			_shipDisplay.addChild(body);
			scene.addChild(_shipDisplay);
			
			_shipPhysics = new JCapsule(new Pv3dMesh(_shipDisplay), height, length);
			_shipPhysics.y = 200;
			_shipPhysics.restitution = 3;
			_shipPhysics.mass = 1;
			_physics.addBody(_shipPhysics);
			
			_cameraTarget = new DisplayObject3D();
			_cameraTarget.copyPosition(_shipDisplay);
			scene.addChild(_cameraTarget);
			
			_springCamera.target = _cameraTarget;
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
            _physics.createGround(new WireframeMaterial(0xFFFFFF, 0), 1800, 0);
            
            var floor:Plane = new Plane(new WireframeMaterial(0xFFFFFF), 10000, 10000, 10000*0.001, 10000*0.001);
            floor.rotationX = 90;
            floor.y = -150
            scene.addChild(floor);
            
        }
		override protected function onRenderTick(event:Event = null):void
        {
         	if(_keys.isDown(KeyPoll.W))
         	{
         		//trace("W");
         		_shipPhysics.pitch(0.1);
         		//_shipPhysics.addWorldForce(new JNumber3D(0, 0, 100), _shipPhysics.currentState.position); 
         	}   
            if(_keys.isDown(KeyPoll.S))
         	{
         		//trace("S");
         		_shipPhysics.pitch(-0.1);
         		//_shipPhysics.addWorldForce(new JNumber3D(0, 0, -100), _shipPhysics.currentState.position); 
         	} 
            if(_keys.isDown(KeyPoll.D))
         	{
         		trace("D");
         		//_shipPhysics.addWorldForce(new JNumber3D(0, 0, 100), _shipPhysics.currentState.position);
         		var pos:JNumber3D = _shipPhysics.currentState.position;
//         		var vec:Number3D = new Number3D(0, 0, 1); // forward?
         		
         		pos.setTo(vec.x, vec.y, vec.z);
         		
         		_shipPhysics.addWorldForce(pos, _shipPhysics.currentState.position);
         		
         		trace(_shipPhysics.currentState.position.toString());
         	}
         	if(_keys.isDown(KeyPoll.A))
         	{
         		trace("A");
         		_shipPhysics.addWorldForce(new JNumber3D(0, 20, 0), _shipPhysics.currentState.position);
         		//_shipPhysics.addBodyForce(new JNumber3D(0, 0, -10), _shipPhysics.currentState.position); 
         	}  
            _cameraTarget.copyPosition(_shipDisplay);
            
            _physics.step();
            renderer.renderScene(scene, _springCamera, viewport);
        }
	}
}