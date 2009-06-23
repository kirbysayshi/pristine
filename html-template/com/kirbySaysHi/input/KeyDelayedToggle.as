/**
 * KeyDelayedToggle v1.2 - December 30nd, 2008
 *
 * This class is meant to avoid creating multiple booleans and timers 
 * whenever you want a keypress to TOGGLE, and not repeat instantly. 
 * 
 * It is intended for use with an "arcade-style" or "AS2-style" (.isDown())
 * key polling class, like KeyPoll by Richard Lord (http://code.google.com/p/bigroom), 
 * the "enhanced" version by Richard Davey (http://www.photonstorm.com), or your own!
 * 
 * It was created by Andrew Petersen, ajpetersen86@gmail.com.
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.kirbySaysHi.input
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class KeyDelayedToggle
	{
		private var time:Timer;
		private var okToHit:Boolean;
		private var yesBool:Boolean;
		
		/**
		 * With an AS2-style isDown keypoll class, holding down the key produces
		 * an endless supply of repeat keypresses. This is great! However, sometimes
		 * it is necessary to TOGGLE something, like a HUD, or another visual
		 * aspect. In this situation, a series of booleans / timers would need to 
		 * be set up to make sure that the key doesn't repeat endlessly. Otherwise,
		 * even one user keypress can be registered as multiple presses at high
		 * framerates, producing a very difficult situation to control (for the 
		 * user).
		 * 
		 * This class solves that by accepting for how long you wish to delay.
		 *
		 * An example is at the bottom.
		 */ 
		public function KeyDelayedToggle(delay:Number)
		{
			okToHit = true;
			yesBool = true;
			time = new Timer(delay, 1);
			time.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
				okToHit = true;
			});
			
		}
		/**
		 * This function should be called everytime the user pushes the key in question.
		 * It flags the key hit as being unavailable for keypresses, resets the timer so
		 * each new press has the same delay, and starts the timer. It also toggles the 
		 * internal boolean (yesBool) that is used to test the actual toggle.
		 */
		public function readyToHit():Boolean
		{	
			if (okToHit)
			{
				okToHit = false;
				time.reset();
				time.start();
				yesBool = !yesBool;
				return true;
			}
			else
			{
				time.reset();
				time.start();
				return false;
			}
		}
		/**
		 * This is the actual toggle boolean, to be used for whatever you're toggling.
		 */
		public function get yes():Boolean
		{
			return yesBool;	
		}
	}
}
/**
 * EXAMPLE USE:
 * 
 * Let's pretend we were toggling a square to be visible on the screen, which
 * has an instance name of toggleSquare.
 * 
 * Somewhere, create an instance of this class:
 * 
 * public var squareToggleCheck:KeyDelayedToggle 
 * 		= new KeyDelayedToggle(100);
 * 	
 * 100 ms usually works fine, but if you want to have a different delay, do so. 
 * 
 * Next, our keyCheck function, which is called on an enterFrame event listener
 * somewhere else in our application. This example uses the KeyPoll class mentioned above.
 * 
 * private function keyCheck():void
 * {
 * 		if ( keyPoll.isDown(KeyPoll.SPACE) && squareToggleCheck.readyToHit())
 *		{
 *			if (squareToggleCheck.yes)
 *				toggleSquare.alpha = 1;
 *	 		else 
 *				toggleSquare.alpha = 0;
 *		}	
 * }
 * 
 * And that's it. The if statement above checks for both the key being down, and the 
 * key being ready to hit. If so, then it reads the value of the toggle boolean
 * and does different things depending on if it's true or false.
 */