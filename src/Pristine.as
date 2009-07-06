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
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.special.ParticleField;
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
		
		private var _velocity:Number;
		private var _glideMatrix:JMatrix3D;
		private var _glideMatrixPaper:Matrix3D;
		
		private var _springCamera:SpringCamera3D;
		private var _cameraTarget:DisplayObject3D;
		
		private var starMat:ParticleMaterial;
		private var fieldArray:Array;
		private var currField:int;
		private var starDistanceCounter:Number;
		private var lastShipPosOfLastStarfieldJump:Number3D;
		
		private var starfieldStarCount:int;
		private var starfieldDrawDistance:int;
		private var starfieldDeleteDistance:int;
		private var starfieldStarSize:int;
		private var starfieldWidth:int;
		private var starfieldHeight:int;
		private var starfieldDepth:int;
		
		public function Pristine()
		{
			super(stage.stageWidth, stage.stageHeight, true, false, CameraType.TARGET);
			viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
			_physics = new Papervision3DPhysics(scene, 10);
			PhysicsSystem.getInstance().setGravity(new JNumber3D(0,0,0));
			_keys = new KeyPoll(stage);
			
			var fps:FPS = new FPS();
			this.addChild(fps);
			
			_velocity = 0;
			
			setCamera();
			createShip();
			readyStarfieldProps();
			checkParticleFields(true);
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
			
			_glideMatrixPaper = new Matrix3D();
			_glideMatrixPaper.copy(_shipDisplay.transform);
			
			_springCamera.target = _shipDisplay;
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
            //_physics.createGround(new WireframeMaterial(0xFFFFFF, 0), 1800, 0);
            
            var floor:Plane = new Plane(new WireframeMaterial(0xFFFFFF), 100000, 100000, 10000*0.001, 10000*0.001);
            floor.rotationX = 90;
            floor.y = -150
            scene.addChild(floor);
            
        }
        private function readyStarfieldProps():void
		{
			lastShipPosOfLastStarfieldJump = _shipDisplay.position;
			starfieldStarCount = 100;
			//starfieldStarCount = 1000;
			starfieldStarSize = 1;
			//starfieldStarSize = 4;
			starfieldDrawDistance = 100;
			starfieldDeleteDistance = 13;
			//starfieldDepth = 1000;
			//starfieldHeight = 8000;
			//starfieldWidth = 8000;	
			starfieldDepth = 1000;
			starfieldHeight = 3000;
			starfieldWidth = 3000;
		}
		private function checkParticleFields(firstLoad:Boolean=false):void
		{	
			if (firstLoad)
			{
				currField = 0;
				starDistanceCounter = 0;
				starMat = new ParticleMaterial(0xFFFFFF, 1, 1);
				fieldArray = [];
				var max:int = starfieldDeleteDistance;
				trace("Starfield count (+=): " + Math.round(max / 2));
				for (var f:int = -1 * Math.round(max / 2); f <= Math.round(max / 2); f++)
				{
					var i:int = fieldArray.push( new ParticleField(starMat, starfieldStarCount, 
						starfieldStarSize, starfieldWidth, starfieldHeight, starfieldDepth) );
					fieldArray[i-1].copyTransform(_shipDisplay);
					fieldArray[i-1].moveForward(f * 1000);
					scene.addChild( fieldArray[i-1] );
				}
			}
			else
			{
				if ( starDistanceCounter < starfieldDrawDistance / 8 )
				{
					var x :Number = _shipDisplay.x - lastShipPosOfLastStarfieldJump.x;
					var y :Number = _shipDisplay.y - lastShipPosOfLastStarfieldJump.y;
					var z :Number = _shipDisplay.z - lastShipPosOfLastStarfieldJump.z;
					
					starDistanceCounter += Math.sqrt( x*x + y*y + z*z );
				}
				else
				{
					lastShipPosOfLastStarfieldJump = _shipDisplay.position;
					var k:int = fieldArray.push( scene.removeChild(fieldArray.shift()) );
					//var d:DisplayObject3D = new DisplayObject3D();
					
					//d.transform
					fieldArray[k-1].copyTransform(_glideMatrixPaper);
					fieldArray[k-1].moveForward( starfieldDrawDistance );
					scene.addChild( fieldArray[k-1] );
					starDistanceCounter = 0;
				}
			}
		}
		override protected function onRenderTick(event:Event = null):void
        {
        	if(_keys.isDown(KeyPoll.EQUAL)){
        		_velocity += 0.1;
        		trace(_velocity);
        	}
        	if(_keys.isDown(KeyPoll.MINUS)){
        		_velocity -= 0.1;
        	}
        	
        	if(!_keys.isDown(KeyPoll.SPACE)){
	        	var forwardAxis:JNumber3D = new JNumber3D(0, 0, 1);
	        	JMatrix3D.rotateAxis(_shipPhysics.currentState.orientation, forwardAxis);
	        	
	        	var posJ:JNumber3D = new JNumber3D();
	        	posJ.x = _velocity * forwardAxis.x + posJ.x;
	        	posJ.y = _velocity * forwardAxis.y + posJ.y;
	        	posJ.z = _velocity * forwardAxis.z + posJ.z;
	
	        	_glideMatrix = _shipPhysics.currentState.orientation;
	        	
	        	_glideMatrixPaper.n11 = _glideMatrix.n11;
	        	_glideMatrixPaper.n12 = _glideMatrix.n12;
	        	_glideMatrixPaper.n13 = _glideMatrix.n13;
	        	_glideMatrixPaper.n14 = _glideMatrix.n14;
	        	_glideMatrixPaper.n21 = _glideMatrix.n21;
	        	_glideMatrixPaper.n22 = _glideMatrix.n22;
	        	_glideMatrixPaper.n23 = _glideMatrix.n23;
	        	_glideMatrixPaper.n24 = _glideMatrix.n24;
	        	_glideMatrixPaper.n31 = _glideMatrix.n31;
	        	_glideMatrixPaper.n32 = _glideMatrix.n32;
	        	_glideMatrixPaper.n33 = _glideMatrix.n33;
	        	_glideMatrixPaper.n34 = _glideMatrix.n34;
	        	_glideMatrixPaper.n41 = _glideMatrix.n41;
	        	_glideMatrixPaper.n42 = _glideMatrix.n42;
	        	_glideMatrixPaper.n43 = _glideMatrix.n43;
	        	_glideMatrixPaper.n44 = _glideMatrix.n44;
	        	
	        	//_glideMatrix = null;
        	}
        	else
        	{
        		
        		var forwardAxis:JNumber3D = new JNumber3D(0, 0, 1);
	        	JMatrix3D.rotateAxis(_glideMatrix, forwardAxis);
	        	
	        	var posJ:JNumber3D = new JNumber3D();//_shipPhysics.currentState.position;
	        	posJ.x = _velocity * forwardAxis.x + posJ.x;
	        	posJ.y = _velocity * forwardAxis.y + posJ.y;
	        	posJ.z = _velocity * forwardAxis.z + posJ.z;
        	}
        	_shipPhysics.addWorldForce(posJ, _shipPhysics.currentState.position);
        	trace(_shipPhysics.currentState.position);
        	
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
         		_shipPhysics.addWorldForce(new JNumber3D(0, 0, 100), _shipPhysics.currentState.position);
         		//var pos:JNumber3D = _shipPhysics.currentState.position;
         		//var vec:Number3D = new Number3D(0, 0, 1); // forward?
         		
         		//pos.setTo(vec.x, vec.y, vec.z);
         		
         		//_shipPhysics.addWorldForce(pos, _shipPhysics.currentState.position);
         		
         		trace(_shipPhysics.currentState.position.toString());
         	}
         	if(_keys.isDown(KeyPoll.A))
         	{
         		trace("A");
         		_shipPhysics.addWorldForce(new JNumber3D(0, 20, 0), _shipPhysics.currentState.position);
         		//_shipPhysics.addBodyForce(new JNumber3D(0, 0, -10), _shipPhysics.currentState.position); 
         	}  
            //_springCamera.copyPosition(_shipDisplay);
            
            checkParticleFields();
            _physics.step();
            renderer.renderScene(scene, _springCamera, viewport);
        }
	}
}