package com.pristine.starbox
{
	import flash.events.Event;
	
	public class StarboxEvent extends Event
	{
		public static const LOADED:String = 'starbox';
		public var self:Starbox;
		
		public function StarboxEvent(starbox:Starbox, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			self = starbox;
		}
	}
}