package com.Flight
{
	import com.fridayforward.sharedAssets.LibraryLdr;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Transform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.KMZ;
	import org.papervision3d.objects.primitives.Cone;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Sphere;

	public class Ship extends DisplayObject3D
	{
		public var type:String;
		public var sWidth:Number;
		public var sHeight:Number;
		public var sLength:Number;
		public var mass:Number;
		public var drag:Number;
		public var topSpeed:Number;
		public var oneThirdSpeed:Number;
		public var noSpeed:Number;
		public var throttleStatus:String;
		public var throttleLevel:Number;
		public var maxTurnRate:Number;
		public var maxThrust:Number;
		public var maxACLThrust:Number; // (this * maxThrust) * 4 should not be more than maxThrust!
		
		public var fireRate:int; // ms between shots: 4 rounds per second = 250
		public var mainWeaponVelocity:Number;
		public var mainWeaponType:String;
		public var mainWeaponPods:Array;
		public var fireMode:String;
		public var nextFirePod:int;
		
		public var thrustingUp:Boolean;
		public var thrustingDown:Boolean;
		public var thrustingLeft:Boolean;
		public var thrustingRight:Boolean;
		
		public var initialPitch:Number;
		public var pitchAdjustment:Number;
		private var body:Cone;
		private var wing1:Cube;
		private var model:KMZ;
		
		private var velocity:Object;
		private var oldVelocity:Object;
		private var sPosition:Object;
		private var oldPosition:Object;
		private var oldAcceleration:Object;
		private var acceleration:Object;
		
		public var shipGlideCopy:DisplayObject3D;
		
		//public var CockpitClass:Class;
		private var cockpit:MovieClip;
		//private var loadedCockpitSWF:DisplayObject;
		//private var LoadedCockpit:Class;
		private var cockpitH:Number;
		private var cockpitW:Number;
		private var missionTimer:Timer;
		private var seconds:int;
		private var minutes:int;
		private var attachObject:Sprite;
		
		/*** Units
		 * 1 mglt = 4 m/s
		 * x-wing top speed == 100 mglt
		*/
		
		public function Ship(shipType:String, posZ:Number, posX:Number, posY:Number, 
			cockpitWidth:Number, cockpitHeight:Number, attachToObject:Sprite)
		{
			super();
			this.z = posZ;
			this.x = posX;
			this.y = posY;
			initialPitch = 0;
			this.yaw(0);
			this.roll(0);
			cockpitW = cockpitWidth;
			cockpitH = cockpitHeight;
			attachObject = attachToObject;
			
			
			pitchAdjustment = 0;

			type = shipType;
			throttleStatus = "noSpeed";
			throttleLevel = 0;
			model = new KMZ();
			
			
			//this.addChild(shipGlideCopy);
			
			
			switch (type)
			{
				case "a-wing":
					topSpeed = 1200;
					maxThrust = 630;
					mass = 10;
					drag = 0.95;
					maxTurnRate = 1.5;
					//cockpit = new XWingCockpit();
					break;
				case "x-wing":
					/*topSpeed = 100.0;
					maxThrust = 52.4;
					maxACLThrust = 0.2 * maxThrust;
					mass = 10;
					drag = 0.95;
					maxTurnRate = 1.2;
					fireRate = 250;
					mainWeaponVelocity = 700;
					mainWeaponType = "blaster";	*/
					loadShipData("x-wing.xml");
					/*model.addEventListener(FileLoadEvent.LOAD_COMPLETE, function onLoad(event:Event):void {
			        	addChild(model);
			      		});*/
					//model.load("assets/models/x_wing.kmz");
					//cockpit = new XWingCockpit();
					break;
				case "viperMKII":
					loadShipData("vipermii.xml");
					/*topSpeed = 300.0;
					maxThrust = 72.4;
					maxACLThrust = 0.2 * maxThrust;
					mass = 10;
					drag = 0.95;
					maxTurnRate = 1.2;
					fireRate = 50; // 50 ms between shots
					mainWeaponVelocity = 1200;
					mainWeaponType = "bullet";*/
					//cockpit = new XWingCockpit();
					break;
			}
			
		}
		private function loadShipData(file:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, prepShipData);
			loader.load( new URLRequest("assets/shipdata/" + file));
		}
		private function prepShipData(e:Event):void
		{
			var xml:XML = new XML(e.target.data);	
			
			topSpeed = xml.engine.topspeed.@value;
			maxThrust = xml.engine.maxthrust.@value;
			maxACLThrust = xml.engine.maxaclthrust.@value * maxThrust;
			
			mass = xml.physical.mass.@value;
			sWidth = xml.physical.width.@value * 10;
			sHeight = xml.physical.height.@value * 10;
			sLength = xml.physical.length.@value * 10;
			
			drag = xml.handling.drag.@value;
			maxTurnRate = xml.handling.turnrate.@value;
			
			oneThirdSpeed = topSpeed / 3;
			noSpeed = 0;
			
			fireRate = xml.armaments.mainweapon.@firerate;
			mainWeaponVelocity = xml.armaments.mainweapon.@velocity;
			mainWeaponType = xml.armaments.mainweapon.@type;
			fireMode = xml.armaments.options.defaultfiremode.@value;
			nextFirePod = 0;
			var podCount:int = xml.armaments.mainweapon.@count;
			mainWeaponPods = [];
			for (var i:int = 0; i < podCount; i++)
			{
				var pod:FirePod = new FirePod(xml.armaments.mainweapon.firepod[i].@visiblename, 
					xml.armaments.mainweapon.firepod[i].@x * 10, xml.armaments.mainweapon.firepod[i].@y * 10,
					xml.armaments.mainweapon.firepod[i].@z * 10, xml.armaments.mainweapon.@power);
				//pod.copyTransform(this.transform);
				pod.placeAccordingToOffset();
				mainWeaponPods.push(pod);
				this.addChild(mainWeaponPods[i], mainWeaponPods[i].givenName);
			}
			var panelSrc:String = xml.visuals.cockpit.panel.@src;
			/*var cockpitLoader:Loader = new Loader();
			cockpitLoader.contentLoaderInfo.addEventListener(Event.INIT, prepCockpit);
			cockpitLoader.load( new URLRequest("assets/cockpits/" + panelSrc) );*/
			LibraryLdr.init(prepCockpit, "assets/cockpits/" + panelSrc);
			prepPhysics();
			
			var cMat:ColorMaterial = new ColorMaterial(0xCCCCCC);
			var tempShip:Sphere = new Sphere(cMat, sWidth / 4);
			this.addChild(tempShip);
			
			// this rectifies the center 
			this.x -= sWidth / 2;
			this.y -= sHeight / 2;
			this.z -= sLength / 2;
			
			shipGlideCopy = new DisplayObject3D();
			shipGlideCopy.transform.copy(this.transform);
			//var glideMat:ColorMaterial = new ColorMaterial(0xCCCCCC);
			//var glideCone:Cone = new Cone(glideMat, sWidth / 5, sLength, 3, 3);
			//glideCone.pitch(90);
			//shipGlideCopy.addChild(glideCone);
			
		}
		private function prepCockpit():void
		{
			cockpit = LibraryLdr.getAsset("Cockpit");
			//trace(e.target.applicationDomain.getDefinition("Cockpit"));
			//CockpitClass:Class = e.target.applicationDomain.getDefinition("Cockpit") as Class;
			//cockpit = new CockpitClass() as MovieClip;
			readyCockpit(attachObject);
			dispatchEvent(new Event("ShipReady"));
		}
		public function prepPhysics():void
		{
			thrustingUp = false;
			thrustingDown = false;
			thrustingLeft = false;
			thrustingRight = false;
			
			velocity = { all: 0, glide: 0, up: 0, down: 0, left: 0, right: 0 };
			oldVelocity = { all: 0, glide: 0, up: 0, down: 0, left: 0, right: 0 };
			sPosition = { x: this.x, y: this.y, z: this.z };
			acceleration = { all: 0, glide: 0, up: 0, down: 0, left: 0, right: 0 };
			oldAcceleration = { all: 0, glide: 0, up: 0, down: 0, left: 0, right: 0 };
		}
		private function prepMissionClock():void
		{
			missionTimer = new Timer(1000);
			missionTimer.addEventListener(TimerEvent.TIMER, updateMissionClock);
			minutes = 0;
			seconds = 0;
			missionTimer.start();
		}
		public function calcVelocity(glide:Boolean=false):void
		{	
			var thrustPool:Number = maxThrust; // all the engines draw on each other
			var uAction:Number = 0;
			var dAction:Number = 0;
			var lAction:Number = 0;
			var rAction:Number = 0;
			
			// REMOVE THRUSTER JUICE FROM POOL
			if (thrustingUp)
			{
				uAction = maxACLThrust;
				thrustPool -= maxACLThrust;
				velocity.up = uAction;
			}
			if (thrustingDown)
			{	
				dAction = maxACLThrust;
				velocity.down = dAction;
				thrustPool -= maxACLThrust;
			}
			if (thrustingLeft)
			{
				lAction = maxACLThrust;
				thrustPool -= maxACLThrust;
				velocity.left = lAction;
			}
			if (thrustingRight)
			{
				rAction = maxACLThrust;
				velocity.right = rAction;
				thrustPool -= maxACLThrust;
			}
			
			// THRUST LEFT
				oldAcceleration.left = acceleration.left;
				oldVelocity.left = velocity.left;
				acceleration.left = lAction / mass; 
				velocity.left = (oldVelocity.left + ((oldAcceleration.left + acceleration.left) / 2)) * drag;
	
			// THRUST RIGHT
				oldAcceleration.right = acceleration.right;
				oldVelocity.right = velocity.right;
				acceleration.right = rAction / mass;
				velocity.right = (oldVelocity.right + ((oldAcceleration.right + acceleration.right) / 2)) * drag;
			
			// THRUST DOWN
				oldAcceleration.down = acceleration.down;
				oldVelocity.down = velocity.down;
				acceleration.down = dAction / mass;
				velocity.down = (oldVelocity.down + ((oldAcceleration.down + acceleration.down) / 2)) * drag;
			
			// THRUST UP
				oldAcceleration.up = acceleration.up;
				oldVelocity.up = velocity.up;
				acceleration.up = uAction / mass;
				velocity.up = (oldVelocity.up + ((oldAcceleration.up + acceleration.up) / 2)) * drag;
					
			// MAIN ENGINES (All)
				var fAction:Number = throttleLevel * thrustPool;
				if ( fAction < 0 )
					fAction = 0;
				oldAcceleration.all = acceleration.all;
				oldVelocity.all = velocity.all;
				//oldVelocity.glide = velocity.all;
				/*if (fAction > 0)
					acceleration.all = (fAction - (mew * mass * accelGravity)) / (mass * accelGravity);
				else
					acceleration.all = 0;*/
				acceleration.all = fAction / mass;
				/*if ( glide || velocity.glide != 0 )
					acceleration.all = 0;*/
				if ( glide && oldVelocity.glide != velocity.glide )
				{
					velocity.glide = velocity.all;
					oldVelocity.glide = velocity.glide;
					//throttleLevel = 0;
				}
				velocity.all = (oldVelocity.all + ((oldAcceleration.all + acceleration.all) / 2)) * drag;
			
			if ( velocity.all < 0 )
				velocity.all = 0;
			if ( velocity.up < 0 )
				velocity.up = 0;
			if ( velocity.down < 0 )
				velocity.down = 0;
			if ( velocity.left < 0 )
				velocity.left = 0;
			if ( velocity.right < 0 )
				velocity.right = 0;
			
			//velocity.glide = velocity.all;
		}
		public function activateGlide(activate:Boolean=true):void
		{
			if (activate)
				oldVelocity.glide = velocity.all;
			else
				oldVelocity.glide = 0;
		}
		public function updatePosition(glide:Boolean=false):void
		{
			//calcAndSetHorVelocity(throttleLevel * topSpeed);
			calcVelocity(glide);
			
			//calcVelocity("v", throttleLevel * topSpeed);
			
			//oldVelocity.f = 
			//velocity.f = throttleLevel * topSpeed;
			//this.z = calcVelocity("f") + this.z;
			
			//this.x += velocity.h;
			//this.z += velocity.f;
			//this.y -= velocity.v;
			
			//velocity.h *= drag;
			//velocity.v *= drag;
			//velocity.f *= drag;
			/*if ( !glide && this.rotationX != shipGlideCopy.rotationX && 
				this.rotationY != shipGlideCopy.rotationY &&
				this.rotationZ != shipGlideCopy.rotationZ)*/
				
			if ( !glide && velocity.glide != 0 )
			{
				shipGlideCopy.moveForward(velocity.glide);
				
				this.copyPosition(shipGlideCopy);
				
				this.moveForward(velocity.all - velocity.glide);
				//trace("glide v: " + velocity.glide + " combined v: " + (velocity.all - velocity.glide));
				applyThrusters(this);
				shipGlideCopy.copyPosition(this);
				//this.rotationX = shipGlideCopy.rotationX;
				//shipGlideCopy.transform.
				//trace( shipGlideCopy.transform.toString() );
				//trace("glide v: " + velocity.glide + " combined v: " + (velocity.glide - velocity.all));
				velocity.glide *= drag;
				if (velocity.glide < 10)
					velocity.glide = 0;
			}
			else if (!glide)
			{
				
				applyThrusters(this);
				this.moveForward(velocity.all);	
				shipGlideCopy.copyTransform(this.transform);
				//trace(velocity.all);		
			}
			else if (glide)
			{
				shipGlideCopy.moveForward(velocity.glide);
				applyThrusters(shipGlideCopy);
				this.copyPosition(shipGlideCopy);
				
				//shipGlideCopy.copyPosition(this);
				//trace("rotX: " + this.rotationX + " rotY: " + this.rotationY + " rotZ: " + this.rotationZ);
				//trace(velocity.glide);
			}
			
			if ( velocity.all > topSpeed )
				velocity.all = topSpeed;
			if ( velocity.glide > topSpeed )
				velocity.glide = topSpeed;
	
			//trace( velocity.all );
			//trace(velocity.f + " | " + oldVelocity.f);
			//this.x = sPosition.x;
			//this.y = sPosition.y;
			//this.z = sPosition.z;
			//trace("Throttle: " + throttleLevel + " | " + "posZ: " + this.z);
		}
		private function applyThrusters(controlObject:DisplayObject3D):void
		{
			//if (thrustingUp)
				controlObject.moveUp(velocity.up);
			//if (thrustingDown)
				controlObject.moveDown(velocity.down);
			//if (thrustingLeft)
				controlObject.moveLeft(velocity.left);
			//if (thrustingRight)
				controlObject.moveRight(velocity.right);
		}
		public function updateCockpitVisuals(showCockpitGraphics:Boolean, playerName:String=null, 
			throttle:Boolean=false, speed:Boolean=false, numWarheads:Boolean=false, 
			shieldLevel:Boolean=false, laserLevel:Boolean=false):void
		{
			if (playerName != null)
				//trace(playerName);
			if (throttle)
				cockpit.throttleValue.text = Math.round( (throttleLevel * 100) ).toString();
				//trace(throttle);
			if (speed)
			{
				cockpit.speedValue.text = Math.round( (velocity.all /*/ 10*/) ).toString();
				//trace(speed);
			}
			if (showCockpitGraphics)
				cockpit.alpha = 1;
			else
				cockpit.alpha = 0;
		}
		public function readyCockpit(attachObj:Sprite):void
		{
			var origSize:Number = cockpit.width;
			var scalePercent:Number = cockpitW / origSize;
			cockpit.scaleX *= scalePercent;
			cockpit.scaleY *= scalePercent;
			trace("origSize: " + origSize);
			trace("cockpitW: " + cockpitW);
			trace("scaleX: " + cockpit.scaleX);
			trace("scaleY: " + cockpit.scaleY);
			attachObj.addChild(cockpit);
			prepMissionClock();
		}
		private function updateMissionClock(e:TimerEvent):void
		{
			
			var tMin:String;
			var tSec:String;
			if (seconds < 59)
			{
				seconds++;
				tSec = seconds.toString();
			}
			else
			{
				seconds = 0;
				minutes++;
				tMin = minutes.toString();
			}
			if (minutes < 10)
				tMin = "0" + minutes.toString();
			if (seconds < 10)
				tSec = "0" + seconds.toString();
			cockpit.missionTime.text = tMin + ":" + tSec;
			//trace(tMin + ":" + tSec);
		}
		public function get currentVelocity():Number
		{
			if ( velocity.glide < velocity.all )
				return velocity.all;
			else
				return oldVelocity.glide;
		}
		/*public function hideCockpit():void
		
		{
			cockpit.alpha = 0;
		}
		public function showCockpit():void
		{
			cockpit.alpha = 1;
		}
		public function setVelocity(xVal:Number, yVal:Number, zVal:Number):void
		{
			velocity.h = xVal;
			velocity.v = yVal;
			velocity.z = zVal;
		}*/
		
	}
}