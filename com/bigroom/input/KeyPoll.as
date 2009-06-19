/*
 * KeyPoll version 1.2 - 10th April 2008
 * 
 * This class is a modified release of version 1.0.3 of the KeyPoll class by Richard Lord
 * Copyright (c) Big Room Ventures Ltd. 2007
 * http://flashgamecode.net/classes/key-polling-class
 * 
 * It was updated by Richard Davey (rich@photonstorm.com) to include the scancode consts,
 * multiple keypress checks and the return code function.
 * http://www.photonstorm.com
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

package com.bigroom.input
{
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	/**
	 * <p>Games often need to get the current state of various keys in order to respond to user input. 
	 * This is not the same as responding to key down and key up events, but is rather a case of discovering 
	 * if a particular key is currently pressed.</p>
	 * 
	 * <p>In Actionscript 2 this was a simple matter of calling Key.isDown() with the appropriate key code. 
	 * But in Actionscript 3 Key.isDown no longer exists and the only intrinsic way to react to the keyboard 
	 * is via the keyUp and keyDown events.</p>
	 * 
	 * <p>The KeyPoll class rectifies this. It has isDown and isUp methods, each taking a key code as a 
	 * parameter and returning a Boolean.</p>
	 */
	public class KeyPoll
	{
		private var states:ByteArray;
		private var dispObj:DisplayObject;
		private var lastKeyCode:uint;
		
		public static const A:uint = 65;
		public static const ALTERNATE:uint = 18;
		public static const B:uint = 66;
		public static const BACKQUOTE:uint = 192;
		public static const BACKSLASH:uint = 220;
		public static const BACKSPACE:uint = 8;
		public static const C:uint = 67;
		public static const CAPS_LOCK:uint = 20;
		public static const COMMA:uint = 188;
		public static const COMMAND:uint = 19;
		public static const CONTROL:uint = 17;
		public static const D:uint = 68;
		public static const DELETE:uint = 46;
		public static const DOWN:uint = 40;
		public static const E:uint = 69;
		public static const END:uint = 35;
		public static const ENTER:uint = 13;
		public static const EQUAL:uint = 187;
		public static const ESCAPE:uint = 27;
		public static const F:uint = 70;
		public static const F1:uint = 112;
		public static const F10:uint = 121;
		public static const F11:uint = 122;
		public static const F12:uint = 123;
		public static const F13:uint = 124;
		public static const F14:uint = 125;
		public static const F15:uint = 126;
		public static const F2:uint = 113;
		public static const F3:uint = 114;
		public static const F4:uint = 115;
		public static const F5:uint = 116;
		public static const F6:uint = 117;
		public static const F7:uint = 118;
		public static const F8:uint = 119;
		public static const F9:uint = 120;
		public static const G:uint = 71;
		public static const H:uint = 72;
		public static const HOME:uint = 36;
		public static const I:uint = 73;
		public static const INSERT:uint = 45;
		public static const J:uint = 74;
		public static const K:uint = 75;
		public static const L:uint = 76;
		public static const LEFT:uint = 37;
		public static const LEFTBRACKET:uint = 219;
		public static const M:uint = 77;
		public static const MINUS:uint = 189;
		public static const N:uint = 78;
		public static const NUMBER_0:uint = 48;
		public static const NUMBER_1:uint = 49;
		public static const NUMBER_2:uint = 50;
		public static const NUMBER_3:uint = 51;
		public static const NUMBER_4:uint = 52;
		public static const NUMBER_5:uint = 53;
		public static const NUMBER_6:uint = 54;
		public static const NUMBER_7:uint = 55;
		public static const NUMBER_8:uint = 56;
		public static const NUMBER_9:uint = 57;
		public static const NUMPAD:uint = 21;
		public static const NUMPAD_0:uint = 96;
		public static const NUMPAD_1:uint = 97;
		public static const NUMPAD_2:uint = 98;
		public static const NUMPAD_3:uint = 99;
		public static const NUMPAD_4:uint = 100;
		public static const NUMPAD_5:uint = 101;
		public static const NUMPAD_6:uint = 102;
		public static const NUMPAD_7:uint = 103;
		public static const NUMPAD_8:uint = 104;
		public static const NUMPAD_9:uint = 105;
		public static const NUMPAD_ADD:uint = 107;
		public static const NUMPAD_DECIMAL:uint = 110;
		public static const NUMPAD_DIVIDE:uint = 111;
		public static const NUMPAD_ENTER:uint = 108;
		public static const NUMPAD_MULTIPLY:uint = 106;
		public static const NUMPAD_SUBTRACT:uint = 109;
		public static const O:uint = 79;
		public static const P:uint = 80;
		public static const PAGE_DOWN:uint = 34;
		public static const PAGE_UP:uint = 33;
		public static const PERIOD:uint = 190;
		public static const Q:uint = 81;
		public static const QUOTE:uint = 222;
		public static const R:uint = 82;
		public static const RIGHT:uint = 39;
		public static const RIGHTBRACKET:uint = 221;
		public static const S:uint = 83;
		public static const SEMICOLON:uint = 186;
		public static const SHIFT:uint = 16;
		public static const SLASH:uint = 191;
		public static const SPACE:uint = 32;
		public static const T:uint = 84;
		public static const TAB:uint = 9;
		public static const U:uint = 85;
		public static const UP:uint = 38;
		public static const V:uint = 86;
		public static const W:uint = 87;
		public static const X:uint = 88;
		public static const Y:uint = 89;
		public static const Z:uint = 90;
		
		/**
		 * Constructor
		 * 
		 * @param displayObj a display object on which to test listen for keyboard events. To catch all key events use the stage.
		 */
		public function KeyPoll(displayObj:DisplayObject)
		{
			states = new ByteArray();
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			states.writeUnsignedInt( 0 );
			
			dispObj = displayObj;
			dispObj.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener, false, 0, true);
			dispObj.addEventListener(KeyboardEvent.KEY_UP, keyUpListener, false, 0, true);
			dispObj.addEventListener(Event.ACTIVATE, resetKeyStates, false, 0, true);
			dispObj.addEventListener(Event.DEACTIVATE, resetKeyStates, false, 0, true);
		}
		
		private function keyDownListener(ev:KeyboardEvent):void
		{
			states[ ev.keyCode >>> 3 ] |= 1 << (ev.keyCode & 7);
			lastKeyCode = ev.keyCode;
		}
		
		private function keyUpListener(ev:KeyboardEvent):void
		{
			states[ ev.keyCode >>> 3 ] &= ~(1 << (ev.keyCode & 7));
			lastKeyCode = 0;
		}
		
		private function resetKeyStates(ev:Event):void
		{
			for (var i:int = 0; i < 32; ++i)
			{
				states[i] = 0;
			}
			
			lastKeyCode = 0;
		}

		/**
		 * Test if the given keys are currently held down or not.
		 * Only one scancode is required.
		 *
		 * @param keyCode1 The scancode for the first key to test.
		 * @param keyCode2 The scancode for the second key to test.
		 * @param keyCode3 The scancode for the third key to test.
		 *
		 * @return true if the key/s are held down, otherwise false
		 *
		 * @see isUp
		 */
		public function isDown(keyCode1:uint, keyCode2:uint = 0, keyCode3:uint = 0):Boolean
		{
			var result:Boolean = (states[ keyCode1 >>> 3 ] & (1 << (keyCode1 & 7))) != 0;
			
			if (keyCode2 > 0 && result == true)
			{
				result = (states[ keyCode2 >>> 3 ] & (1 << (keyCode2 & 7))) != 0;
			}
			
			if (keyCode3 > 0 && result == true)
			{
				result = (states[ keyCode3 >>> 3 ] & (1 << (keyCode3 & 7))) != 0;
			}

			return result;
		}
		
		/**
		 * Test if the given key (or set of keys) are currently up
		 *
		 * @param keyCode1 The scancode for the first key to test.
		 * @param keyCode2 The scancode for the second key to test.
		 * @param keyCode3 The scancode for the third key to test.
		 *
		 * @return true if the key/s are not currently held down, otherwise false
		 *
		 * @see isDown
		 */
		public function isUp(keyCode1:uint, keyCode2:uint = 0, keyCode3:uint = 0):Boolean
		{
			var result:Boolean = ( states[ keyCode1 >>> 3 ] & (1 << (keyCode1 & 7)) ) == 0;
			
			if (keyCode2 > 0 && result == true)
			{
				result = ( states[ keyCode2 >>> 3 ] & (1 << (keyCode2 & 7)) ) == 0;
			}
			
			if (keyCode3 > 0 && result == true)
			{
				result = ( states[ keyCode3 >>> 3 ] & (1 << (keyCode3 & 7)) ) == 0;
			}

			return result;
		}
		
		/**
		 * Returns the keyCode of the most recent key held down
		 *
		 * @return uint of the keyCode, or 0 if none
		 */
		public function get keyCode():uint
		{
			return lastKeyCode;
		}
	}
}