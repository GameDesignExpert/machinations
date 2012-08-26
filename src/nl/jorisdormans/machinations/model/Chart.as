package nl.jorisdormans.machinations.model 
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.phantomGraphics.DrawUtil;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.FileIO;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Chart extends GroupBox
	{
		private var _defaultScaleX:int = 0;
		private var _defaultScaleY:int = 0;
		
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _negScaleY:Number;
		private var _data:Vector.<ChartData>;
		private var _time:Number;
		private var _tick:int;
		private var _stopped:Boolean;
		
		private var _highLighted:int = 0;
		private var _runs:int;
		
		private var fileIO:FileIO;
		
		
		public function Chart() 
		{
			_data = new Vector.<ChartData>();
			_scaleY = 12;
			_scaleX = 20;
			_negScaleY = 0;
			
			fileIO = new FileIO();
			super();
			captionPosition = 5;
			activationMode = MODE_AUTOMATIC;
			//toDO:Keep track of and display end condition as well
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@scaleX = defaultScaleX;
			xml.@scaleY = defaultScaleY;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			defaultScaleX = xml.@scaleX;
			defaultScaleY = xml.@scaleY;
			super.readXML(xml);
		}		
		
		public function draw(graphics:Graphics, x:Number, y:Number):void 
		{
			var d:Vector3D = new Vector3D(x, y);
			
			if (defaultScaleX > 0) _scaleX = defaultScaleX;
			if (defaultScaleY > 0) _scaleY = defaultScaleY;
			if (defaultScaleY < 0) {
				_scaleY = -defaultScaleY;
				_negScaleY = defaultScaleY;
			}

			graphics.lineStyle(thickness, color);
			graphics.beginFill(0xffffff);
			graphics.drawRect(d.x, d.y, width, height); 
			graphics.endFill();
			graphics.lineStyle();
			
			
			
			//draw scale
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();	
			var f:Number = _scaleY / (_scaleY - _negScaleY);
			var p:Number = f*0.25;
			while (p < 1) {
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO);
				data.push(d.x+2, d.y + height * p);
				data.push(d.x + width - 3, d.y + height * p);
				p += f * 0.25;
			}
			
			var step:int = 10;
			while (step * (width / _scaleX) < 10) {
				step *= 10;
			}

			for (var x:Number = step; x < _scaleX; x += step) {
				var dx:Number = x * (width / _scaleX);
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO);
				data.push(d.x+dx, d.y + 2);
				data.push(d.x+dx, d.y + height - 3);
			}
			
			graphics.lineStyle(1, 0xcccccc);
			graphics.drawPath(commands, data);
			graphics.lineStyle();
			
			
			//var factorWidth:Number = (graph as MachinationsGraph).fireInterval;
			var factorWidth:Number = 1;
			
			var visibleData:int = 0;
			if (_defaultScaleX > 0) visibleData = _defaultScaleX;
			else visibleData = width;
			
			
			//draw data
			//first pass non-highlighted
			for (var i:int = 0; i < _data.length; i++) {
				if (_data[i].data.length > 0 && _data[i].run > _runs-(graph as MachinationsGraph).visibleRuns && _data[i].run != _highLighted) {
					commands = new Vector.<int>();
					data = new Vector.<Number>();			
					commands.push(GraphicsPathCommand.MOVE_TO);
					data.push(d.x, d.y + f * (height - _data[i].data[0] * (height / _scaleY)));
					for (var j:int = 1; j < Math.min(_data[i].data.length, visibleData); j++) {
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(d.x + j * (width / _scaleX) * factorWidth, d.y + f * (height - _data[i].data[j] * (height / _scaleY)));
					}
					graphics.lineStyle(_data[i].thickness, _data[i].color2);
					graphics.drawPath(commands, data);
					graphics.lineStyle();
				}
			}
			
			//second pass highlighted
			for (i = 0; i < _data.length; i++) {
				if (_data[i].data.length > 0 && _data[i].run == _highLighted) {
					commands = new Vector.<int>();
					data = new Vector.<Number>();			
					commands.push(GraphicsPathCommand.MOVE_TO);
					data.push(d.x, d.y + f *(height - _data[i].data[0] * (height / _scaleY)));
					for (j = 1; j < Math.min(_data[i].data.length, visibleData); j++) {
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(d.x + j * (width / _scaleX) * factorWidth, d.y + f *(height - _data[i].data[j] * (height / _scaleY)));
					}
					
					graphics.lineStyle(_data[i].thickness, _data[i].color);
					graphics.drawPath(commands, data);
					graphics.lineStyle();
				}
			}
			
			//draw texts
			graphics.lineStyle(1, 0xaaaaaa);
			PhantomFont.drawText((_scaleY*0.25).toString(), graphics, d.x+5, d.y+height*0.75 *f+MachinationsGrammar.fontSize*1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT);
			PhantomFont.drawText((_scaleY*0.5).toString(), graphics, d.x+5, d.y+height*0.5 * f+MachinationsGrammar.fontSize*1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT);
			PhantomFont.drawText((_scaleY * 0.75).toString(), graphics, d.x + 5, d.y + height * 0.25 * f + MachinationsGrammar.fontSize * 1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT);
			if (_negScaleY < 0) {
				PhantomFont.drawText("0", graphics, d.x + 5, d.y + height * f + MachinationsGrammar.fontSize * 1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT);
			}
			graphics.lineStyle();
			
			graphics.lineStyle(1, 0xaaaaaa);
			PhantomFont.drawText((_scaleY*1.00).toString()+"", graphics, d.x+5, d.y+height*0.0+MachinationsGrammar.fontSize*1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT);
			graphics.lineStyle();
			
			var sx:String = (_scaleX).toString();
			if (graph && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) sx += " turns";
			else sx += " s";
			
			graphics.lineStyle(1, 0xaaaaaa);
			PhantomFont.drawText(sx, graphics, d.x + (_scaleX) * (width / _scaleX) - 4, d.y+height-4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_RIGHT);
			graphics.lineStyle();
			
			
			
			
			if (graph || !(graph as MachinationsGraph).running) {
				graphics.lineStyle(2, color);
				if (_runs>=1) {
					PhantomFont.drawText("clear", graphics, d.x + width - 5, d.y + MachinationsGrammar.fontSize + 5, MachinationsGrammar.fontSize, PhantomFont.ALIGN_RIGHT);
					PhantomFont.drawText("export", graphics, d.x + width - 5, d.y + height + MachinationsGrammar.fontSize + 5, MachinationsGrammar.fontSize, PhantomFont.ALIGN_RIGHT);
				}
				
				if (_runs>=2) {
					PhantomFont.drawText("<<", graphics, d.x+10, d.y + height + MachinationsGrammar.fontSize + 5, MachinationsGrammar.fontSize, PhantomFont.ALIGN_CENTER);
					PhantomFont.drawText((_highLighted+1).toString(), graphics, d.x+35, d.y + height + MachinationsGrammar.fontSize + 5, MachinationsGrammar.fontSize, PhantomFont.ALIGN_CENTER);
					PhantomFont.drawText(">>", graphics, d.x + 60, d.y + height + MachinationsGrammar.fontSize + 5, MachinationsGrammar.fontSize, PhantomFont.ALIGN_CENTER);
				}
				graphics.lineStyle();
			}
		}
		
		public function toSVG(svg:XML):void 
		{
			var d:Vector3D = position.clone();
			var s:Number = size * 0.5;
			
			var b:XML = DrawUtil.drawRectToSVG(d.x, d.y, width, height, "none", StringUtil.toColorStringSVG(color), 1);
			svg.appendChild(b);
			
			
			//draw scale
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();		
			var f:Number = _scaleY / (_scaleY - _negScaleY);
			var p:Number = f*0.25;
			while (p < 1) {
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO);
				data.push(d.x+2, d.y + height * p);
				data.push(d.x + width - 3, d.y + height * p);
				p += f * 0.25;
			}
			
			var step:int = 10;
			while (step * (width / _scaleX) < 10) {
				step *= 10;
			}

			for (var x:Number = step; x < _scaleX; x += step) {
				var dx:Number = x * (width / _scaleX)
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO);
				data.push(d.x+dx, d.y + 2);
				data.push(d.x+dx, d.y + height - 3);
			}
			
			var l:XML = DrawUtil.drawPathToSVG(commands, data, "none", StringUtil.toColorStringSVG(0x000000), 1);
			l.@["stroke-dasharray"] = "1,2";
			svg.appendChild(l);
			
			
			//draw data
			
			//var factorWidth:Number = (graph as MachinationsGraph).fireInterval;
			var factorWidth:Number = 1;
			
			var visibleData:int = 0;
			if (_defaultScaleX > 0) visibleData = _defaultScaleX;
			else visibleData = width;
			
			
			//first pass non-highlighted
			d = position.clone();
			for (var i:int = 0; i < _data.length; i++) {
				if (_data[i].data.length > 0 && _data[i].run > _runs-(graph as MachinationsGraph).visibleRuns && _data[i].run != _highLighted) {
					commands = new Vector.<int>();
					data = new Vector.<Number>();			
					commands.push(GraphicsPathCommand.MOVE_TO);
					data.push(d.x, d.y + f *(height - _data[i].data[0] * (height / _scaleY)));
					for (var j:int = 1; j < Math.min(_data[i].data.length, visibleData); j++) {
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(d.x + j * (width / _scaleX) * factorWidth, d.y + f *(height - _data[i].data[j] * (height / _scaleY)));
					}
					
					svg.appendChild(DrawUtil.drawPathToSVG(commands, data, "none", StringUtil.toColorStringSVG(_data[i].color2), _data[i].thickness));
				}
			}
			
			//second pass highlighted
			for (i = 0; i < _data.length; i++) {
				if (_data[i].data.length > 0 && _data[i].run == _highLighted) {
					commands = new Vector.<int>();
					data = new Vector.<Number>();			
					commands.push(GraphicsPathCommand.MOVE_TO);
					data.push(d.x, d.y + f *(height - _data[i].data[0] * (height / _scaleY)));
					for (j = 1; j < Math.min(_data[i].data.length, visibleData); j++) {
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(d.x + j * (width / _scaleX) * factorWidth, d.y + f *(height - _data[i].data[j] * (height / _scaleY)));
					}
					
					svg.appendChild(DrawUtil.drawPathToSVG(commands, data, "none", StringUtil.toColorStringSVG(_data[i].color), _data[i].thickness));
				}
			}	
			
			//draw texts
			PhantomFont.drawTextToSVG((_scaleY*0.25).toString(), svg, d.x+5, d.y+height*0.75*f+MachinationsGrammar.fontSize*1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			PhantomFont.drawTextToSVG((_scaleY*0.5).toString(), svg, d.x+5, d.y+height*0.5*f+MachinationsGrammar.fontSize*1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			PhantomFont.drawTextToSVG((_scaleY * 0.75).toString(), svg, d.x + 5, d.y + height * 0.25*f + MachinationsGrammar.fontSize * 1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			if (_negScaleY < 0) {
				PhantomFont.drawTextToSVG("0", svg, d.x + 5, d.y + height * f + MachinationsGrammar.fontSize * 1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			}
			PhantomFont.drawTextToSVG((_scaleY * 1.00).toString() + "", svg, d.x + 5, d.y + height * 0.00 + MachinationsGrammar.fontSize * 1.4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_LEFT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			
			
			var sx:String = (_scaleX).toString();
			if (graph && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) sx += " turns";
			else sx += " s";
			
			PhantomFont.drawTextToSVG(sx, svg, d.x + (_scaleX) * (width / _scaleX) - 4, d.y+height-4, MachinationsGrammar.fontSize, PhantomFont.ALIGN_RIGHT, "none", StringUtil.toColorStringSVG(0x000000), 1);
			
		}			
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			_time = 0;
			_tick = 0;
			_stopped = false;
			_runs++;
			_highLighted = _runs - 1;
			
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection) {
					_data.push(new ChartData(inputs[i] as StateConnection, _highLighted));
				}
			}			
		}
		
		public function clickClear(x:Number, y:Number):Boolean {
			if (_runs < 1) return false;
			if (x > position.x + width - 35 && x < position.x + width && y > position.y + 5 && y < position.y + 5 + MachinationsGrammar.fontSize * 1.2) return true;
			else return false;
		}
		
		
		public function clickExport(x:Number, y:Number):Boolean {
			if (_runs < 1) return false;
			if (x > position.x + width - 45 && x < position.x + width && y > position.y + height && y < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2) return true;
			else return false;
		}
		
		public function clickPrevious(x:Number, y:Number):Boolean {
			if (_runs < 2) return false;
			if (x > position.x + 0 && x < position.x + 20 && y > position.y + height && y < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2) return true;
			else return false;
		}
		
		public function clickNext(x:Number, y:Number):Boolean {
			if (_runs < 2) return false;
			if (x > position.x + 50 && x < position.x + 70 && y > position.y + height && y < position.y + height + 5 + MachinationsGrammar.fontSize * 1.2) return true;
			else return false;
		}
		
		public function doPrevious():void {
			if (_highLighted > 0) _highLighted--;
		}
		
		public function doNext():void {
			if (_highLighted < _runs-1) _highLighted++;
		}
		
		
		
		public function clear(): void {
			_data = new Vector.<ChartData>();
			_scaleX = 20;
			_runs = 0;
			_highLighted = 0;
		}
		
		public function export(): void {
			fileIO.textData = "";
			var maxData:int = 0;
			for (var i:int = 0; i < _data.length; i++) {
				if (_data[i].data.length > maxData) {
					maxData = _data[i].data.length;
				}
			}
			
			//add names
			var s:String  = "";
			var names:Boolean = false;
			for (i = 0; i < _data.length; i++) {
				if (_data[i].name != "") {
					names = true;
				}
				if (i > 0) {
					s += ",";
				}
				s += _data[i].name;
			}
			if (names) {
				fileIO.textData += s + "\r";
			}
			
			//add thickness
			s = "";
			for (i = 0; i < _data.length; i++) {
				if (i > 0) {
					s += ",";
				}
				s += StringUtil.floatToStringMaxPrecision(_data[i].thickness, 1);
			}
			fileIO.textData += s + "\r";
			
			//add color
			s = "";
			for (i = 0; i < _data.length; i++) {
				if (i > 0) {
					s += ",";
				}
				s += StringUtil.toColorString(_data[i].color);
			}
			fileIO.textData += s + "\r";

			//add data
			for (var j:int = 0; j < maxData; j++) {
				s = "";
				for (i = 0; i < _data.length; i++) {
					if (j<_data[i].data.length) { 
						if (i > 0) {
							s += ",";
						}
						s += StringUtil.floatToStringMaxPrecision(_data[i].data[j],3);
					}
				}
				fileIO.textData += s + "\r";
			}
			
			if (fileIO.fileName == "") fileIO.saveFile("data.csv");
			else fileIO.saveFile(fileIO.fileName);
		}	
		
		
		
		override public function fire():void 
		{
			_tick++;
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection) addData(inputs[i] as StateConnection);
			}
		}
		
		public function addData(connection:StateConnection):void {
			if (/*_tick > width ||*/ (_tick > 0 && graph && !(graph as MachinationsGraph).running)) return;
			if (defaultScaleX > 0 && _tick * (graph as MachinationsGraph).fireInterval > defaultScaleX) return;
			var v:Number = connection.state * connection.label.value;
			if (isNaN(v)) v = 0;
			if (defaultScaleY > 0 && v > defaultScaleY) return;
			for (var i:int = _data.length - 1; i >= 0; i--) {
				if (_data[i].run == _highLighted && _data[i].connection == connection) {
					_data[i].data.push(v);
					break;
				}
			}
			while (defaultScaleY==0 && _scaleY < v*1.2) {
				if (_scaleY == 12) _scaleY = 20;
				else if (_scaleY == 20) _scaleY = 40;
				else if (_scaleY == 40) _scaleY = 100;
				else if (_scaleY == 100) _scaleY = 200;
				else if (_scaleY == 200) _scaleY = 500;
				else if (_scaleY == 500) _scaleY = 1000;
				else if (_scaleY == 1000) _scaleY = 2000;
				else if (_scaleY == 2000) _scaleY = 5000;
				else break;
			}
			
			while (defaultScaleY>=0 && _negScaleY > v*1.2) {
				if (_negScaleY == 0) _negScaleY = -12;
				else if (_negScaleY == -12) _negScaleY = -20;
				else if (_negScaleY == -20) _negScaleY = -40;
				else if (_negScaleY == -40) _negScaleY = -100;
				else if (_negScaleY == -100) _negScaleY = -200;
				else if (_negScaleY == -200) _negScaleY = -500;
				else if (_negScaleY == -500) _negScaleY = -1000;
				else if (_negScaleY == -1000) _negScaleY = -2000;
				else if (_negScaleY == -2000) _negScaleY = -5000;
				else break;
			}
			
			if (defaultScaleX <= 0 && _scaleX < _tick && _scaleX<=width-10) _scaleX += 10;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		public function hasData():Boolean {
			return (_data.length > 0);
		}		
		
		override public function stop():void 
		{
			super.stop();
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		public function get defaultScaleX():int { return _defaultScaleX; }
		
		public function set defaultScaleX(value:int):void 
		{
			_defaultScaleX = value;
			_scaleX = Math.max(value, 10);
		}
		
		public function get defaultScaleY():int { return _defaultScaleY; }
		
		public function set defaultScaleY(value:int):void 
		{
			_defaultScaleY = value;
			_scaleY = Math.max(value, 12);
		}
		
	}

}