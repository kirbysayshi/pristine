package com.Flight
{
	import com.bigroom.input.KeyPoll;
	import com.kirbySaysHi.input.KeyDelayedToggle;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.papervision3d.cameras.SpringCamera3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;

	public class ThreeDee extends Sprite
	{
		private var scene:Scene3D;					
		//private var camera:Camera3D;
		private var camera:SpringCamera3D;
		private var render:BasicRenderEngine;		
		private var viewport:Viewport3D;
		
		//private var cameraZMod:Number;
		private var keyPoll:KeyPoll;
		private var mainStage:Stage;
		
		// TOGGLE BOOLEANS
		private var inverted:Boolean;
		private var viewToggle:KeyDelayedToggle;
		private var deadZoneToggle:KeyDelayedToggle;
		private var glideToggle:KeyDelayedToggle;
		private var clickFireToggle:KeyDelayedToggle;
		
		private var view:String;
		//private var isTweening:Boolean;
		
		private var ship:Ship;
		
		//private var calcs:Physics;
		
		//private var stars:Starfield;
		private var tempPlane:Plane;
		private var deadZone:Sprite;
		
		[Embed (source="../assets/images/hot_nebula_0.jpg")]
		private var BitmapFront : Class; 
		[Embed (source="../assets/images/hot_nebula_270.jpg")]
		private var BitmapRight : Class; 
		[Embed (source="../assets/images/hot_nebula_180.jpg")]
		private var BitmapBack : Class; 
		[Embed (source="../assets/images/hot_nebula_90.jpg")]
		private var BitmapLeft : Class; 
		[Embed (source="../assets/images/hot_nebula_bottom.jpg")]
		private var BitmapDown : Class; 
		[Embed (source="../assets/images/hot_nebula_top.jpg")]
		private var BitmapUp : Class; 
		
		private var skybox:Cube;
		private var starMat:ParticleMaterial;
		private var fieldArray:Array;
		private var currField:int;
		private var shipPos:Object;
		private var posLock:Matrix3D; // used to hold the ship transform for particle placement
		//private var particleFieldHolder:ParticleField; // holds the field as it gets moved around
		
		private var starfieldStarCount:int;
		private var starfieldDrawDistance:int;
		private var starfieldDeleteDistance:int;
		private var starfieldStarSize:int;
		private var starfieldWidth:int;
		private var starfieldHeight:int;
		private var starfieldDepth:int;
		
		[Embed (source="../assets/models/textures/xwingskin.jpg")]
		private var XWingSkin:Class;
		private var xWingMaterial:BitmapMaterial;
		
		//private var mouseIsDown:Boolean;
		private var localMainWeaponArray:Array;
		private var localFireRateTimer:Timer;
		private var currentBulletSlot:int;
			
		public function ThreeDee(stageRef:Stage)
		{
			super();
			mainStage = stageRef;
			
			//mainStage.quality = StageQuality.LOW;
			viewport = new Viewport3D(800,600);
			addChild(viewport);
				//build instances of the other 3 mandatories
			scene = new Scene3D();
			render = new BasicRenderEngine();
			//camera = new Camera3D();
			camera = new SpringCamera3D();
			camera.mass = 10;
			camera.stiffness = 5;
			camera.positionOffset = new Number3D(0, 0, 0);
			
			ship = new Ship("viperMKII", 0, 0, 0, mainStage.stageWidth, mainStage.stageHeight, this);
			ship.addEventListener("ShipReady", init);
			
		}
		private function init(e:Event):void
		{
			createSkyBox();
			readyStarfieldProps();
			shipPos = {"cur": ship.shipGlideCopy.clone(), 
						"old": ship.shipGlideCopy.clone(), 
						"counter": 0};
			scene.addChild(ship);
			
			// WTF DOES THIS DO???
			ship.shipGlideCopy.addChildren(ship);
			
			scene.addChild(ship.shipGlideCopy);
			
			view = "cockpit";	
		
			keyPoll = new KeyPoll(mainStage);
			
			camera.fov = 120;
			camera.zoom = 12;
			camera.focus = 100;
			camera.target = ship; // spring3d camera
			camera.lookOffset = new Number3D(0, 0, 100);
			
			
			inverted = false;
			readyDeadZoneGraphic();
			setToggles();
			glideToggle.readyToHit(); // to set .yes to FALSE initially
			
			checkParticleFields(true);
			
			loadModels();
			localMainWeaponArray = [];
			localFireRateTimer = new Timer(ship.fireRate);
			prepBullets();
			mainStage.addEventListener(MouseEvent.MOUSE_DOWN, toggleLocalWeaponFire); // start firing
			mainStage.addEventListener(MouseEvent.MOUSE_UP, toggleLocalWeaponFire); // stop firing
			localFireRateTimer.addEventListener(TimerEvent.TIMER, createBullet);
			addEventListener(Event.ENTER_FRAME, mainLoop);
		}
		private function readyStarfieldProps():void
		{
			starfieldStarCount = 100;
			//starfieldStarCount = 1000;
			starfieldStarSize = 1;
			//starfieldStarSize = 4;
			starfieldDrawDistance = 3000;
			starfieldDeleteDistance = 13;
			//starfieldDepth = 1000;
			//starfieldHeight = 8000;
			//starfieldWidth = 8000;	
			starfieldDepth = 1000;
			starfieldHeight = 3000;
			starfieldWidth = 3000;
		}
		private function createSkyBox():void
		{
			var skyboxFront:BitmapMaterial = new BitmapMaterial(new BitmapFront().bitmapData); 
			var skyboxLeft : BitmapMaterial = new BitmapMaterial(new BitmapLeft().bitmapData); 
			var skyboxBack : BitmapMaterial = new BitmapMaterial(new BitmapBack().bitmapData); 
			var skyboxTop : BitmapMaterial = new BitmapMaterial(new BitmapUp().bitmapData); 
			var skyboxRight : BitmapMaterial = new BitmapMaterial(new BitmapRight().bitmapData); 
			var skyboxBottom : BitmapMaterial = new BitmapMaterial(new BitmapDown().bitmapData); 

			skyboxFront.doubleSided = true; 
			skyboxLeft.doubleSided = true; 
			skyboxBack.doubleSided = true; 
			skyboxTop.doubleSided = true; 
			skyboxRight.doubleSided = true; 
			skyboxBottom.doubleSided = true; 
		
			var skyBoxMats:MaterialsList = new MaterialsList(); 
			
			skyBoxMats.addMaterial(skyboxFront, "front"); 
			skyBoxMats.addMaterial(skyboxLeft, "left"); 
			skyBoxMats.addMaterial(skyboxBack, "back"); 
			skyBoxMats.addMaterial(skyboxTop, "top"); 
			skyBoxMats.addMaterial(skyboxRight, "right"); 
			skyBoxMats.addMaterial(skyboxBottom, "bottom"); 
			
			skybox = new Cube(skyBoxMats, 100000000, 100000000, 100000000, 4, 4, 4); // originally 4
			scene.addChild(skybox);
		}
		private function mainLoop(e:Event):void
		{	
			updateBulletPositions();
 			ship.updatePosition(glideToggle.yes);
 			
 			checkParticleFields();
 			//shipPos.cur;
 			checkKeyInput();
 			
 			if (view == "external")
 			{
 				camera.transform.copy(ship.transform);
 				//camera.moveBackward(800);
 				camera.positionOffset = new Number3D(0, 0, -200);
 				ship.updateCockpitVisuals(false);
 			}
 			else if (view == "cockpit")
 			{
 				camera.transform.copy(ship.transform);
 				camera.positionOffset = new Number3D(0, 0, 0);
 				//camera.moveForward(100);
 				ship.updateCockpitVisuals(true, "Rookie 1", true, true);
 			}
 			
 			var pY:Object = getPitchAndYaw();
 			ship.pitch( pY.pitch );
 			ship.yaw( pY.yaw );
			
 			shipPos.old.copyTransform(ship);
 			render.renderScene(scene, camera, viewport);
 			
		}
		private function loadModels():void
		{
			//var model:KMZ = new KMZ();
			/*model.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {
	        	model.copyTransform(ship);
	        	model.moveForward(8000);
	        	scene.addChild(model);
	      		});
				model.load("assets/models/viper_simple.kmz");*/
			/*var xWingBM:Bitmap = Bitmap(new XWingSkin());
			var xWingTexture:BitmapData = new BitmapData(xWingBM.width, xWingBM.height, true,0x00ffff);
			xWingTexture.draw(xWingBM, new Matrix);
			xWingMaterial = new BitmapMaterial(xWingTexture);
			xWingMaterial.oneSide = true;
			var xwing:Ase = new Ase(xWingMaterial, "assets/models/ase/xwing.ASE", 0.008);
			xwing.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(e:Event):void {
				xwing.copyTransform(ship);
				xwing.moveForward(6000);
				//scene.addChild(xwing);
			});*/
			
			var stationMat:ColorMaterial = new ColorMaterial(0x666666);
			var stationSaucer:Cylinder = new Cylinder(stationMat, 6000, 500);
			stationSaucer.copyTransform(ship);
			
			var stationMat2:ColorMaterial = new ColorMaterial(0x3366CC);
			var stationCenter:Cylinder = new Cylinder(stationMat2, 500, 8000);
			stationCenter.copyTransform(ship);
			stationSaucer.moveUp(2000);
			
			stationCenter.moveForward(600000);
			stationSaucer.moveForward(600000);
			
			scene.addChild(stationCenter);
			scene.addChild(stationSaucer);
		}
		private function setToggles():void
		{
			deadZoneToggle = new KeyDelayedToggle(100);
			viewToggle = new KeyDelayedToggle(100);
			glideToggle = new KeyDelayedToggle(100);
			clickFireToggle = new KeyDelayedToggle(ship.fireRate);
		}
		private function checkKeyInput():void
		{
			// THROTTLE INCREMENT CONTROLS
			if (keyPoll.isDown( KeyPoll.MINUS ))
 			{
 				if (ship.throttleLevel > 0)
 					ship.throttleLevel -= 0.01;
 				
 			}
 			if (keyPoll.isDown( KeyPoll.EQUAL))
 			{
 				if (ship.throttleLevel < 1)
 					ship.throttleLevel += 0.01;
 				//trace(ship.throttleLevel);
 			}
 			// THROTTLE AUTO SET CONTROLS
			if (keyPoll.isDown(KeyPoll.NUMBER_1))
 			{
 				ship.throttleLevel = 0;
 				ship.throttleStatus = "noSpeed";
 			}
 			else if (keyPoll.isDown(KeyPoll.NUMBER_2))
 			{
 				ship.throttleLevel = 0.33;
 				ship.throttleStatus = "oneThird";
 			}
 			else if (keyPoll.isDown(KeyPoll.NUMBER_3))
 			{
 				ship.throttleLevel = 1;
 				ship.throttleStatus = "topSpeed";
 			}
			// VIEW TOGGLE
 			if (keyPoll.isDown( KeyPoll.SLASH ) && viewToggle.readyToHit())
 			{
 				if (viewToggle.yes)
 					view = "cockpit";
 				else 
 					view = "external";
 			}
 			// DEADZONE VIEW TOGGLE
 			if ( keyPoll.isDown(KeyPoll.QUOTE) && deadZoneToggle.readyToHit())
 			{
 				if (deadZoneToggle.yes)
 					deadZone.alpha = 0.3;
 				else 
 					deadZone.alpha = 0;
 			}	
 			// GLIDE TOGGLE
 			if ( keyPoll.isDown(KeyPoll.SPACE) && glideToggle.readyToHit())
 			{
 				if ( glideToggle.yes ) 
 					ship.activateGlide(true);
 				else
 					ship.activateGlide(false);
 				// this forces a toggle
 				//trace("ship v: " + ship
 			}
			// TRANSLATE THRUSTERS
			if ( keyPoll.isDown(KeyPoll.W) )
				ship.thrustingUp = true;
			if ( keyPoll.isDown(KeyPoll.S) )
				ship.thrustingDown = true;
			if ( keyPoll.isDown(KeyPoll.A) )
				ship.thrustingLeft = true;
			if ( keyPoll.isDown(KeyPoll.D) )
				ship.thrustingRight = true;
			
			if ( !keyPoll.isDown(KeyPoll.W) )
				ship.thrustingUp = false;
			if ( !keyPoll.isDown(KeyPoll.S) )
				ship.thrustingDown = false;
			if ( !keyPoll.isDown(KeyPoll.A) )
				ship.thrustingLeft = false;
			if ( !keyPoll.isDown(KeyPoll.D) )
				ship.thrustingRight = false;
			// TEMP
			if ( keyPoll.isDown(KeyPoll.P) )
				localMainWeaponArray[0].pitch(1);
			if ( keyPoll.isDown(KeyPoll.O) )
				localMainWeaponArray[0].pitch(-1);
		}
		private function readyDeadZoneGraphic():void
		{
			deadZone = new Sprite();
			deadZone.graphics.beginFill(0xFFFF00, 1);
			deadZone.graphics.drawRect(0, 0, 20, 20);
			deadZone.graphics.endFill();
			deadZone.x = mainStage.stageWidth / 2 - deadZone.width / 2;
			deadZone.y = mainStage.stageHeight / 2 - deadZone.height / 2;
			deadZone.alpha = 0.3;
			trace("deadZoneAlpha: " + deadZone.alpha);
			this.addChild(deadZone);
		}
		private function getPitchAndYaw():Object
		{
			var tPitch:Number = 0;
 			var tYaw:Number = 0;
 			
 			// mouse-based pitch
 			if ( mouseY < (stage.height / 2) - 10 )
 				tPitch = ( -(80 / mouseY) > -ship.maxTurnRate)
	 				? -(80 / mouseY) 
	 				: -ship.maxTurnRate;
 			else if ( mouseY > (stage.height / 2) + 10 ) //&& mouseY < stage.height - 30)
 				tPitch = (80 / (stage.height - mouseY) < ship.maxTurnRate) 
	 				? 80 / (stage.height - mouseY) 
	 				: ship.maxTurnRate;
 			
 			tPitch *= (inverted == true) ? -1 : 1; // if inverted is true, multiply by -1
 			
 			// mouse-based yaw
 			if ( mouseX < (stage.width / 2) - 10) //&& mouseY > 30)
 				tYaw = ( -(80 / mouseX) > -ship.maxTurnRate) 
	 				? -(80 / mouseX) 
	 				: -ship.maxTurnRate;
 			else if ( mouseX > (stage.width / 2) + 10) //&& mouseY < stage.height - 30)
 				tYaw = (80 / (stage.width - mouseX) < ship.maxTurnRate )
	 				? 80 / (stage.width - mouseX) 
	 				: ship.maxTurnRate;
 				
 			tYaw *= (inverted == true) ? -1 : 1; // if inverted is true, multiply by -1
 			
 			// this makes the normal turn rate = 75% of max, 
 			// and then 100% of max at 30% throttle
 			if ( ship.throttleLevel > 0.31 && ship.throttleLevel < 0.35){
 				tPitch *= 1;
 				tYaw *= 1;
 			}
 			else if ( ship.throttleLevel <= 0.28 ){
 				tPitch *= 0.2;
 				tYaw *= 0.2;
 			}
 			else{
 				tPitch *= 0.65;
 				tYaw *= 0.65;
 			}
 			return {"pitch": tPitch, "yaw": tYaw };
		}
		private function checkParticleFields(firstLoad:Boolean=false):void
		{
			//var tempMat:Matrix3D = ship.shipGlideCopy.transform;
			if ( glideToggle.yes )
				posLock = ship.shipGlideCopy.transform;
			else
				posLock = ship.transform;
			
			/*if (firstLoad)
			{
				var bfx:BitmapEffectLayer = new BitmapEffectLayer(viewport, mainStage.stageWidth, mainStage.stageHeight);
				
				var pixels:Pixels = new Pixels(null);
				
				var width2  :Number = starfieldWidth /2;
				var height2 :Number = starfieldHeight /2;
				var depth2  :Number = starfieldDepth /2;
				
				for(var i:int = 0; i < starfieldStarCount; i++)
				{
					var sX:int = Math.random() * starfieldWidth  - width2;
					var sY:int = Math.random() * starfieldHeight - height2;
					var sZ:int = Math.random() * starfieldDepth  - depth2;
					pixels.addPixel3D( new Pixel3D(0xFFFFFF, sX, sY, sZ) );
					trace( "x: " + sX + " y: " + sY + " z: " + sZ);
				}
				viewport.containerSprite.addLayer(bfx);
				scene.addChild(pixels);
			}*/
			
			if (firstLoad)
			{
				currField = 0;
				shipPos.counter = 0;
				starMat = new ParticleMaterial(0xFFFFFF, 1, 1);
				fieldArray = [];
				var max:int = starfieldDeleteDistance;
				trace("Starfield count (+=): " + Math.round(max / 2));
				for (var f:int = -1 * Math.round(max / 2); f <= Math.round(max / 2); f++)
				{
					var i:int = fieldArray.push( new ParticleField(starMat, starfieldStarCount, 
						starfieldStarSize, starfieldWidth, starfieldHeight, starfieldDepth) );
					fieldArray[i-1].copyTransform(posLock);
					fieldArray[i-1].moveForward(f * 1000);
					scene.addChild( fieldArray[i-1] );
				}
			}
			else
			{
				if ( shipPos.counter < starfieldDrawDistance / 8 )
				{
					shipPos.counter += shipPos.old.distanceTo(ship.shipGlideCopy);
				}
				else
				{
					var k:int = fieldArray.push( scene.removeChild(fieldArray.shift()) );
					fieldArray[k-1].copyTransform(posLock);
					fieldArray[k-1].moveForward( starfieldDrawDistance );
					scene.addChild( fieldArray[k-1] );
					shipPos.counter = 0;
				}
			}
		}
		private function toggleLocalWeaponFire(e:MouseEvent):void
		{	
			if ( e.type == MouseEvent.MOUSE_UP)
			{
				localFireRateTimer.stop();
				localFireRateTimer.reset();	
			}
			else if ( !localFireRateTimer.running && e.type == MouseEvent.MOUSE_DOWN )
			{
				if (clickFireToggle.readyToHit())
					createBullet( new TimerEvent(TimerEvent.TIMER) ); // for an instant first shot
				localFireRateTimer.start();
				
			}

		}
		private function prepBullets():void
		{
			var totalBullets:Number = 0;
			if ( ship.mainWeaponType == "blaster" )
				totalBullets = Math.round(ship.fireRate * 1.8 / 10);
			else if (ship.mainWeaponType == "bullet")
				totalBullets = Math.round(ship.fireRate * 3 / 2);
			for (var i:int = 0; i < totalBullets; i++)
			{
				var b:Projectile = new Projectile(ship.mainWeaponType);
				//b.visible = false;
				b.saveVectorSnapshot(ship, ship.currentVelocity);
				//b.pitch(90);
				localMainWeaponArray.push(b);
			}
		}
		private function createBullet(e:TimerEvent):void
		{
			currentBulletSlot ++;
			if ( currentBulletSlot >= localMainWeaponArray.length)
				currentBulletSlot = 0;
			var p:Projectile = localMainWeaponArray[currentBulletSlot];
			
			var fPos:Number3D = ship.mainWeaponPods[ship.nextFirePod].position;
			p.forwardVelocity = ship.mainWeaponVelocity + ship.currentVelocity;
			//trace(ship.currentVelocity);
			//p.visible = true;
			//if ( ship.rotationY < 0 && ship.rotationX )
				//trace(ship.currentVelocity * Math.cos( ship.rotationX * Math.PI / 180));
			/*var b:Projectile = new Projectile(ship.mainWeaponType, 
				);*/
			if ( ship.fireMode == "single" )
			{
				// Number3D(ship.transform.n11 * shipVelocity, ship.transform.n21 * shipVelocity, ship.transform.n31 * shipVelocity)
				// p.position.plusEq(n3d);
				//p.position.plusEq(
				
				p.copyTransform( ship );
				//p.localRotationX = ship.localRotationX;
				//p.localRotationY = ship.localRotationY;
				//p.localRotationZ = ship.localRotationZ;
				//p.copyPosition(ship.shipGlideCopy);
				p.saveVectorSnapshot(ship, ship.currentVelocity);
				
				//p.pitch(90);
				//p.x += fPos.x;
				//p.y += fPos.y;
				//p.z += fPos.z;
				
				p.pitch(90);
				
				//p.moveLeft(fPos.x);
				//p.moveBackward(fPos.y);
				p.position = Number3D.add(ship.position, fPos);
				//p.moveUp(ship.sLength * 10);
				//p.moveUp(ship.sLength / 2);
				
				//p.position.plusEq(fPos);
				//trace("podNum: " + ship.nextFirePod + " pos: " + p.position.plusEq(fPos));
				//trace("pPos: " + p.position);
				//trace("fPos: " + fPos);
				//trace("zBlastPoint: " + ship.mainWeaponPods[ship.nextFirePod].zBlastPoint);
				ship.nextFirePod++;
				//ship.copyTransform(
				if (ship.nextFirePod >= ship.mainWeaponPods.length)
					ship.nextFirePod = 0;
			}
			//b.copyPosition(ship);
			
			//b.moveForward(1000);
			//b.moveUp(300);
			scene.addChild(p);
			//p.lookAt(ship);
			//p.pitch(90);
			//localMainWeaponArray.push(b);
			//trace( localMainWeaponArray[localMainWeaponArray.length-1].velocity );
			//localMainWeaponArray.splice(
			//trace("round fired");
		}
		public function updateBulletPositions():void
		{	
			var p:Projectile;
			//trace(localMainWeaponArray.length);
			for (var i:int = 0; i < localMainWeaponArray.length; i++)
			{	
				p = localMainWeaponArray[i];
				p.moveUp(p.forwardVelocity);
				//TODO: This isn't working
				//p.updateFireForget();

				if (p.distanceTo(ship) > p.destroyDistance)
				{
					//trace("ship: " + p.distanceTo(ship) + " destroy: " + p.destroyDistance);
					scene.removeChild(p);
				}
			}
			/*if ( localMainWeaponArray.length > 15 && localFireRateTimer.running )
			{
				scene.removeChild( localMainWeaponArray.shift() );
			}*/
			/*var last:Projectile = localMainWeaponArray[localMainWeaponArray.length-1];
			if ( !localFireRateTimer.running && 
				last.distanceTo(ship) > last.velocity * 10 )
			{
				for (var k:int = 0; k < localMainWeaponArray.length; k++)
				{
					scene.removeChild( localMainWeaponArray.shift() );
				}
			}*/
		}
	}
}