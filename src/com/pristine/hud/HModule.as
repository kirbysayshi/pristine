package com.pristine.hud
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class HModule extends Sprite
	{
		private var _box:Sprite;
		private var _label:TextField;
		private var _content:TextField;
		private var _contentfmt:TextFormat;
		private var _labelfmt:TextFormat;
		private var _color:uint;
		private var _alpha:Number;

		public function HModule(color:uint, alpha:Number=0.5)
		{
			_color = color;
			_alpha = alpha;
			
			_contentfmt = new TextFormat('Eurostile');
			_contentfmt.color = 0xFFFFFF;
			_contentfmt.size = 20;
			
			_labelfmt = new TextFormat('Eurostile');
			_labelfmt.color = 0xFFFFFF;
			_labelfmt.size = 14;
			_labelfmt.bold = true;		
		}
		public function addLabel(label:String):void
		{
			_label = new TextField();
			_label.defaultTextFormat = _labelfmt;
			_label.text = label;
			_label.x = 5;
			_label.y = 5;
			this.addChild(_label);
		}
		public function addContent(content:String):void
		{
			_content = new TextField();
			_content.defaultTextFormat = _contentfmt;
			_content.text = content;
			_content.x = 5;
			_content.y = 25;
			this.addChild(_content);
		}
		public function updateContent(content:String):void
		{
			_content.text = content;
		}
		public function drawBox():void
		{
			var width:Number = _label.textWidth + _content.textWidth + 10;
			var height:Number = _label.textHeight + _content.textHeight + 20;
			
			_box = new Sprite();
			_box.graphics.beginFill(_color, _alpha);
			_box.graphics.lineStyle(3, _color, _alpha+0.2);
			_box.graphics.drawRoundRect(0, 0, width, height, width/10, height/10);
			_box.graphics.endFill();
			this.addChild(_box);
		}	
		public function get defaultFormatting():TextFormat
		{
			return _contentfmt;
		}
	}
}