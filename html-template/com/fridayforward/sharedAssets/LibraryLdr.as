package com.fridayforward.sharedAssets {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * http://www.fridayforward.com/2008/04/16/run-time-class-and-asset-sharing-across-multiple-swfs-in-flex-as3/
	 * 
	 **/
    public class LibraryLdr 
    {  
  
        private static var _callback:Function;  
        private static var _assets:LoaderInfo;  
  
        public static function init(callback:Function, url:String="../sharedassets.swf"):void {  
  
            // set callback function  
            _callback = callback;  
  
            // load assets  
            var request:URLRequest = new URLRequest(url);  
            var loader:Loader = new Loader();  
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);  
            loader.load(request);  
        }  
  
        private static function onLoaded(event:Event):void {  
  
            // retrieve assets  
            _assets = LoaderInfo(event.target);  
  
            // callback  
            _callback();  
        }  
  
        public static function getAsset(id:String):MovieClip {  
  
            // return asset class  
            var c:Class = _assets.applicationDomain.getDefinition(id) as Class;  
            return MovieClip(new c());  
        }  
    }  
}  