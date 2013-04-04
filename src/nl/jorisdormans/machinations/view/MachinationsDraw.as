package nl.jorisdormans.machinations.view 
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphConnectionType;
	import nl.jorisdormans.machinations.model.Delay;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.phantomGraphics.DrawUtil;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.phantomGraphics.PhantomShape;
	import nl.jorisdormans.phantomGraphics.Primitives;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsDraw
	{
		
		public function MachinationsDraw() 
		{
			
		}
		
		/////////////////////////////  DICE  ////////////////////////////////////////
		
		public static function drawDice(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			graphics.beginFill(color);
			graphics.drawRoundRect(x - size * 0.5, y - size * 0.5, size, size, size * 0.5);
			graphics.drawCircle(x - size * 0.25, y - size * 0.25, size * 0.1);
			graphics.drawCircle(x + size * 0.25, y - size * 0.25, size * 0.1);
			graphics.drawCircle(x - size * 0.00, y - size * 0.00, size * 0.1);
			graphics.drawCircle(x - size * 0.25, y + size * 0.25, size * 0.1);
			graphics.drawCircle(x + size * 0.25, y + size * 0.25, size * 0.1);
			graphics.endFill();
		}
		
		public static function drawDiceToSVG(svg:XML, x:Number, y:Number, size:Number, color:uint):void {
			svg.appendChild(DrawUtil.drawRoundRectToSVG(x - size * 0.5, y - size * 0.5, size, size, size *0.2, size*0.2, StringUtil.toColorStringSVG(color), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x - size * 0.25, y - size * 0.25, size * 0.1, StringUtil.toColorStringSVG(0xffffff), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x + size * 0.25, y - size * 0.25, size * 0.1, StringUtil.toColorStringSVG(0xffffff), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x + size * 0.00, y + size * 0.00, size * 0.1, StringUtil.toColorStringSVG(0xffffff), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x - size * 0.25, y + size * 0.25, size * 0.1, StringUtil.toColorStringSVG(0xffffff), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x + size * 0.25, y + size * 0.25, size * 0.1, StringUtil.toColorStringSVG(0xffffff), null, 0));
		}
		
		/////////////////////////////  SKILL  ////////////////////////////////////////
		
		private static var skillShape:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 2, 2, 3, 3, 3, 2, 2, 2, 2, 2), new Array(-20.00, 8.80, -20.00, 22.40, 20.00, 22.40, 20.00, 8.80, 6.60, 8.80, 5.40, -13.80, 11.20, -17.40, 8.00, -24.40, 0.00, -32.00, -7.00, -24.20, -10.00, -17.80, -4.60, -13.80, -6.20, 8.80, -10.00, 8.80, -10.00, 5.80, -16.80, 5.80, -17.00, 8.80), 0);
		public static function drawSkill(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 50;
			graphics.beginFill(color);
			skillShape.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
		}
		public static function drawSkillToSVG(svg:XML, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 50;
			svg.appendChild(skillShape.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(color), null, 0));
		}

		/////////////////////////////  MULTIPLAYER  ////////////////////////////////////////
		
		private static var multiplayerShape:PhantomShape = new PhantomShape(new Array(1, 2, 3, 2, 3, 3, 3, 3, 3, 1, 2, 3, 2, 3, 3, 3, 3, 3), new Array(-22.40, 16.60, -2.40, 16.60, -2.40, 6.60, -8.40, -3.40, -8.40, -3.40, -3.80, -6.20, -3.80, -11.80, -3.80, -20.00, -12.40, -20.40, -20.80, -19.60, -20.40, -11.40, -20.20, -6.40, -16.80, -3.40, -22.40, 6.60, -22.40, 16.60, 2.40, 16.60, 22.20, 16.60, 22.20, 6.60, 16.80, -3.40, 16.70, -3.40, 21.00, -5.80, 21.40, -11.80, 22.00, -20.41, 11.79, -20.61, 3.40, -19.60, 3.39, -11.40, 3.40, -5.40, 6.80, -3.40, 2.20, 6.60, 2.20, 16.60), 0);
		public static function drawMultiplayer(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			graphics.beginFill(color);
			multiplayerShape.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
		}
		
		public static function drawMultiplayerToSVG(svg:XML, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			svg.appendChild(multiplayerShape.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(color), null, 0));
		}
		
		/////////////////////////////  STRATEGY  ////////////////////////////////////////
		
		private static var strategyShape:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2), new Array(-10.00, 0.00, 10.00, 0.00, 7.20, 2.20, 10.00, 5.60, 6.80, 7.40, 10.00, 10.00, 6.80, 12.40, 10.00, 15.00, 7.20, 16.80, 10.00, 20.00, 5.40, 20.00, 0.00, 25.40, -4.40, 20.00, -10.00, 20.00, -6.40, 17.20, -10.00, 15.00, -6.60, 12.40, -10.00, 10.00, -6.40, 7.00, -10.00, 5.00, -6.60, 2.80), 0);
		public static function drawStrategy(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 34;
			graphics.beginFill(color);
			strategyShape.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			graphics.beginFill(color);
			graphics.drawCircle(x, y - size * 0.25, size * 0.4);
			graphics.drawCircle(x, y - size * 0.25, size * 0.3);
			graphics.endFill();
		}
		
		
		public static function drawStrategyToSVG(svg:XML, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 34;
			svg.appendChild(strategyShape.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(color), null, 0));
			svg.appendChild(DrawUtil.drawCircleToSVG(x, y - size * 0.25, size * 0.4, StringUtil.toColorStringSVG(color), null, 0));			
			svg.appendChild(DrawUtil.drawCircleToSVG(x, y - size * 0.25, size * 0.3, StringUtil.toColorStringSVG(0xffffff), null, 0));			
		}
		
		
		/////////////////////////////  TIME  ////////////////////////////////////////
		
		private static var timeShape:PhantomShape = new PhantomShape(new Array(1, 3, 2, 3, 3, 2, 3), new Array(0.00, 0.00, -10.00, -10.00, -10.00, -20.00, 10.00, -20.00, 10.00, -10.00, 0.00, 0.00, -10.00, 10.00, -10.00, 20.00, 10.00, 20.00, 10.00, 10.00, 0.00, 0.00), 0);
		public static function drawTime(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			graphics.lineStyle(2, color);
			timeShape.drawScaled(graphics, x, y, s, s);
			graphics.lineStyle();
		}
		
		public static function drawTimeToSVG(svg:XML, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			svg.appendChild(timeShape.toSVG(x, y, s, s, 0, "none", StringUtil.toColorStringSVG(color), 2));
		}
		
		///////////////////////////// ACTIVATION TYPES /////////////////////////////
		
		public static function drawPassiveGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY, 0);
		}
		
		public static function drawInteractiveGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY, 0);
			drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16-3, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY, 0);
		}
		
		public static function drawAutomaticGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			graphics.lineStyle(2, color);
			PhantomFont.drawText("*", graphics, x, y + size * 0.4, size * 0.8, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
			//drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16, MachinationsNode.MODE_AUTOMATIC);
		}
		
		public static function drawOnStartGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			graphics.lineStyle(2, color);
			PhantomFont.drawText("s", graphics, x, y + size * 0.4, size * 0.8, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
			//drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16, MachinationsNode.MODE_AUTOMATIC);
		}
		
		
		/////////////////////////////  POOL  ////////////////////////////////////////
		
		public static function drawPoolGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawPool(graphics, x, y, 2, color, 0xffffff, (size / 40) * 20, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY, 0);
		}
		public static function drawPool(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String, flowInputCount:int):void {
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			graphics.drawCircle(x, y, size);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) graphics.drawCircle(x, y, size * 0.75);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*1.1, y - size *0.8+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size * 1.1, y - size * 0.8 + 3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawText("&", graphics, x + size*1.1, y + size *0.8+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ANY && flowInputCount > 0 && activationType != MachinationsNode.MODE_PASSIVE) PhantomFont.drawText("p", graphics, x + size*1.1, y + size *0.8+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL && flowInputCount>0 && activationType != MachinationsNode.MODE_PASSIVE) PhantomFont.drawText("p&", graphics, x + size*1.1 + 4, y + size *0.8+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL && (flowInputCount==0 || activationType == MachinationsNode.MODE_PASSIVE)) PhantomFont.drawText("&", graphics, x + size*1.1 + 4, y + size *0.8+3, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		public static function drawPoolToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String, flowInputCount:int):void {
			svg.appendChild(DrawUtil.drawCircleToSVG(x, y, size, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(DrawUtil.drawCircleToSVG(x, y, size * 0.75, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*1.1, y - size*0.8+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*1.1, y - size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*1.1, y + size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ANY && flowInputCount>0 && activationType != MachinationsNode.MODE_PASSIVE) PhantomFont.drawTextToSVG("p", svg, x + size*1.1, y + size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL && flowInputCount>0 && activationType != MachinationsNode.MODE_PASSIVE) PhantomFont.drawTextToSVG("p&", svg, x + size*1.1 + 4, y + size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL && (flowInputCount==0 || activationType == MachinationsNode.MODE_PASSIVE)) PhantomFont.drawTextToSVG("&", svg, x + size*1.1 + 4, y + size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
		}
		
		/////////////////////////////  GATE  ////////////////////////////////////////
		
		public static function drawGateGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawGate(graphics, x, y, 2, color, 0xffffff, (size / 40) * 16, Gate.GATE_DETERMINISTIC, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY);
		}
		
		public static var shapeGate:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 2), new Array( -18.63, 0.00, 0.00, 18.63, 18.63, 0.00, 0.00, -18.63, -18.63, 0.00), 0);
		public static function drawGate(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, gateType:String, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			shapeGate.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) shapeGate.drawScaled(graphics, x, y, s *0.65, s*0.65);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size * 0.9, y - size * 0.7 + 6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size * 0.9, y - size * 0.7+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawText("&", graphics, x + size * 0.9, y + size * 0.7+5, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
			
			if (activationType == MachinationsNode.MODE_INTERACTIVE) size *= 0.6;
			else size *= 0.8;
			
			switch (gateType) {
				case Gate.GATE_DICE:
					drawDice(graphics, x, y, size, colorLine);
					break;
				case Gate.GATE_SKILL:
					drawSkill(graphics, x, y, size, colorLine);
					break;
				case Gate.GATE_MULTIPLAYER:
					drawMultiplayer(graphics, x, y, size, colorLine);
					break;
				case Gate.GATE_STRATEGY:
					drawStrategy(graphics, x, y, size, colorLine);
					break;
			}
		}
		
		public static function drawGateToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, gateType:String, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			svg.appendChild(shapeGate.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(shapeGate.toSVG(x, y, s*0.6, s*0.6, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*0.9, y - size*0.7+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*0.9, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*0.9, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			
			if (activationType == MachinationsNode.MODE_INTERACTIVE) size *= 0.6;
			else size *= 0.8;
			
			switch (gateType) {
				case Gate.GATE_DICE:
					drawDiceToSVG(svg, x, y, size, colorLine);
					break;
				case Gate.GATE_SKILL:
					drawSkillToSVG(svg, x, y, size, colorLine);
					break;
				case Gate.GATE_MULTIPLAYER:
					drawMultiplayerToSVG(svg, x, y, size, colorLine);
					break;
				case Gate.GATE_STRATEGY:
					drawStrategyToSVG(svg, x, y, size, colorLine);
					break;
			}
		}
		
		public static function drawGateValue(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, value:Number):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorLine);
			shapeGate.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			graphics.lineStyle();
			graphics.lineStyle(2, colorFill);
			var v:int = Math.floor(value);
			PhantomFont.drawText(v.toString(), graphics, x, y + 4, 8, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		/////////////////////////////  SOURCE  ////////////////////////////////////////
		
		public static function drawSourceGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawSource(graphics, x, y, 2, color, 0xffffff, (size / 40) * 20, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY);
		}
		
		public static var shapeSource:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2), new Array( -18.63, 12.42, 18.63, 12.42, 0.00, -18.63, -18.63, 12.42), 0);
		public static function drawSource(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			shapeSource.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) shapeSource.drawScaled(graphics, x, y+s, s *0.6, s*0.6);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size * 0.7, y - size * 0.7+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size * 0.7, y - size * 0.7+3, 10, PhantomFont.ALIGN_CENTER);
			//if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL) PhantomFont.drawText("&", graphics, x + size, y + size+6, 12, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		public static function drawSourceToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			svg.appendChild(shapeSource.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(shapeSource.toSVG(x, y+s, s*0.6, s*0.6, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*0.7, y - size*0.7+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*0.7, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			//if (pullMode == MachinationsNode.PULL_MODE_PUSH_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*1.1, y + size*0.8+5, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
		}
		
		
		/////////////////////////////  DRAIN  ////////////////////////////////////////
		
		public static function drawDrainGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawDrain(graphics, x, y, 2, color, 0xffffff, (size / 40) * 20, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY);
		}
		
		public static var shapeDrain:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2), new Array(-18.63, -12.42, 18.63, -12.42, 0.00, 18.63, -18.63, -12.42), 0);
		public static function drawDrain(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			shapeDrain.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) shapeDrain.drawScaled(graphics, x, y-s, s *0.6, s*0.6);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*1.2, y - size*0.3+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size*1.2, y - size*0.3+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawText("&", graphics, x + size*0.6, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		public static function drawDrainToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			svg.appendChild(shapeDrain.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(shapeDrain.toSVG(x, y-s, s*0.6, s*0.6, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*1.2, y - size*0.3+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*1.2, y - size*0.3+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*0.6, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
		}
		
		/////////////////////////////  CONVERTER  ////////////////////////////////////////
		
		public static function drawConverterGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawConverter(graphics, x, y, 2, color, 0xffffff, (size / 40) * 20, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY);
		}

		public static var shapeConverter:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 1, 2), new Array(-12.42, 18.63, -12.42, -18.63, 18.63, 0.00, -12.42, 18.63, 0.00, -18.63, 0.00, 18.63), 0);
		public static function drawConverter(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			shapeConverter.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) shapeConverter.drawScaled(graphics, x, y, s *0.6, s*0.6);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*0.7, y - size*0.7+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size*0.7, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawText("&", graphics, x + size*0.7, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		public static function drawConverterToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			svg.appendChild(shapeConverter.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(shapeConverter.toSVG(x, y, s*0.6, s*0.6, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*0.7, y - size*0.7+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*0.7, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*0.7, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
		}
		
		
		/////////////////////////////  TRADER  ////////////////////////////////////////
		
		public static function drawTraderGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawTrader(graphics, x, y, 2, color, 0xffffff, (size / 40) * 20, MachinationsNode.MODE_PASSIVE, MachinationsNode.PULL_MODE_PULL_ANY);
		}
		
		public static var shapeTrader:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 1, 2, 2, 2, 1, 2), new Array( -15.03, -18.78, 15.03, -7.51, -15.03, 3.76, -15.03, -18.78, 15.03, -3.76, -15.03, 7.51, 15.03, 18.78, 15.03, -3.76, 0.00, -20.00, 0.00, 20.00), 0);
		public static var shapeTrader2:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 1, 2, 2, 2), new Array(-12.03, -13.98, 6.80, -7.51, -12.00, -1.40, -12.00, -14.20, 12.00, 1.20, -6.80, 7.40, 12.00, 13.80, 12.00, 1.20), 0);
		public static function drawTrader(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			shapeTrader.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) shapeTrader2.drawScaled(graphics, x, y, s, s);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*0.8, y - size*0.7+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size*0.8, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawText("&", graphics, x + size*1.1, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
		}
		
		public static function drawTraderToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, pullMode:String):void {
			var s:Number = size / 20;
			svg.appendChild(shapeTrader.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(shapeTrader2.toSVG(x, y, s, s, 0, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*0.8, y - size*0.7+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*0.8, y - size*0.7+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (pullMode == MachinationsNode.PULL_MODE_PULL_ALL) PhantomFont.drawTextToSVG("&", svg, x + size*1.1, y + size*0.7+5, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
		}
		
		/////////////////////////////  SELECT GLYPH  ////////////////////////////////////////
		
		public static var shapeSelect:PhantomShape = new PhantomShape(new Array(1, 2, 2, 2, 2, 2, 2, 2), new Array( -7.72, -19.97, -7.72, 13.84, -0.53, 4.53, 5.32, 20.23, 10.91, 17.57, 3.73, 3.46, 13.84, 3.46, -7.66, -20.04), 0);
		public static function drawSelectGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			graphics.lineStyle(1, color);
			graphics.beginFill(0xffffff, 0.5);
			shapeSelect.drawScaled(graphics, x, y, s, s);
			graphics.endFill();
			graphics.lineStyle();
		}		
		
		/////////////////////////////  FLOW  ////////////////////////////////////////
		
		public static var shapeFlow:PhantomShape = new PhantomShape(new Array(1, 2, 2, 1, 2), new Array( -20.00, 0.00, 20.00, 0.00, 10.00, 10.00, 10.00, -10.00, 20.00, 0.00), 0);
		public static function drawFlowGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			graphics.lineStyle(2, color);
			shapeFlow.drawScaled(graphics, x, y, s, s);
			graphics.lineStyle();
		}
		
		/////////////////////////////  STATE  ////////////////////////////////////////
		
		public static var shapeState:PhantomShape = new PhantomShape(new Array(1, 2, 1, 2, 1, 2, 1, 2, 1, 2), new Array( -20.00, 0.00, -15.00, 0.00, -5.00, 0.00, 0.00, 0.00, 10.00, 0.00, 15.00, 0.00, 20.00, 0.00, 10.00, 10.00, 10.00, -10.00, 20.00, 0.00), 0);
		public static function drawStateGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			var s:Number = size / 40;
			graphics.lineStyle(2, color);
			shapeState.drawScaled(graphics, x, y, s, s);
			graphics.lineStyle();
		}
		
		/////////////////////////////  REGISTER  ////////////////////////////////////////
		public static function drawRegisterGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawRegister(graphics, x, y, 2, color, 0xffffff, size * 0.85, "x", MachinationsNode.MODE_PASSIVE);
		}
		public static function drawRegister(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, value:String, activationType:String):void {
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorLine);
			graphics.drawRect(x - size * 0.45, y - size * 0.45, size * 0.9, size * 0.9);
			graphics.endFill();
			graphics.lineStyle(thickness, colorLine);
			
			if (activationType == MachinationsNode.MODE_INTERACTIVE) {
				graphics.lineStyle();
				graphics.beginFill(colorFill);
				graphics.moveTo(x, y - size * 0.42);
				graphics.lineTo(x - size * 0.3, y - size * 0.25);
				graphics.lineTo(x + size * 0.3, y - size * 0.25);
				graphics.lineTo(x, y - size * 0.42);
				
				graphics.moveTo(x, y + size * 0.42);
				graphics.lineTo(x - size * 0.3, y + size * 0.25);
				graphics.lineTo(x + size * 0.3, y + size * 0.25);
				graphics.lineTo(x, y + size * 0.42);
				graphics.endFill();
			}
			
			graphics.lineStyle(2, colorFill);
			var size:Number = 8;
			PhantomFont.drawText(value, graphics, x, y + size * 0.5, size, PhantomFont.ALIGN_CENTER);
		}
		
		public static function drawRegisterToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, value:String, activationType:String):void {
			svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.45, y - size * 0.45, size * 0.9, size * 0.9, StringUtil.toColorStringSVG(colorLine), StringUtil.toColorStringSVG(colorLine), thickness));
			
			if (activationType == MachinationsNode.MODE_INTERACTIVE) {
				var commands:Vector.<int> = new Vector.<int>();
				var data:Vector.<Number> = new Vector.<Number>();
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				data.push(x, y - size * 0.42);				
				data.push(x - size * 0.3, y - size * 0.25);
				data.push(x + size * 0.3, y - size * 0.25);
				data.push(x, y - size * 0.42);

				data.push(x, y + size * 0.42);				
				data.push(x - size * 0.3, y + size * 0.25);
				data.push(x + size * 0.3, y + size * 0.25);
				data.push(x, y + size * 0.42);
				
				svg.appendChild(DrawUtil.drawPathToSVG(commands, data, StringUtil.toColorStringSVG(colorFill), "none", 0)); 
			}
			
			var size:Number = 8;
			PhantomFont.drawTextToSVG(value, svg, x, y + size * 0.5, size, PhantomFont.ALIGN_CENTER, "none", StringUtil.toColorStringSVG(colorFill), 2);
		}		
		
		/////////////////////////////  DELAY  ////////////////////////////////////////
		public static function drawDelayGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawDelay(graphics, x, y, 2, color, 0xffffff, size * 0.4, MachinationsNode.MODE_PASSIVE, Delay.TYPE_NORMAL);
		}
		
		public static function drawDelay(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, delayType:String):void {
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			graphics.drawCircle(x, y, size);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) graphics.drawCircle(x, y, size * 0.75);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*1.1, y - size *0.8+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size * 1.1, y - size * 0.8 + 3, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle();
			switch (delayType) {
				case Delay.TYPE_NORMAL:
					drawTime(graphics, x, y, size, colorLine);
					break;
				case Delay.TYPE_QUEUE:
					drawTime(graphics, x-size*0.4, y, size*0.9, colorLine);
					drawTime(graphics, x+size*0.4, y, size*0.9, colorLine);
					break;
			}
			
		}
		
		public static function drawDelayToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String, delayType:String):void {
			svg.appendChild(DrawUtil.drawCircleToSVG(x, y, size, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(DrawUtil.drawCircleToSVG(x, y, size * 0.75, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*1.1, y - size*0.8+14, 18, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*1.1, y - size*0.8+3, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			switch (delayType) {
				case Delay.TYPE_NORMAL:
					drawTimeToSVG(svg, x, y, size, colorLine);
					break;
				case Delay.TYPE_QUEUE:
					drawTimeToSVG(svg, x-size*0.4, y, size*0.9, colorLine);
					drawTimeToSVG(svg, x+size*0.4, y, size*0.9, colorLine);
					break;
			}
		}
		
		
		/////////////////////////////  END CONDITION  ////////////////////////////////////////
		public static function drawEndConditionGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawEndCondition(graphics, x, y, 2, color, 0xffffff, size * 0.85, MachinationsNode.MODE_PASSIVE);
		}
		public static function drawEndCondition(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String):void {
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			graphics.drawRect(x - size * 0.45, y - size * 0.45, size * 0.9, size * 0.9);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) graphics.drawRect(x - size * 0.3, y - size * 0.3, size * 0.6, size * 0.6);
			graphics.lineStyle();
			graphics.beginFill(colorLine);
			graphics.drawRect(x - size * 0.25, y - size * 0.25, size * 0.5, size * 0.5);
			graphics.endFill();
		}
		
		public static function drawEndConditionToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String):void {
			svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.45, y - size * 0.45, size * 0.9, size * 0.9, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.3, y - size * 0.3, size * 0.6, size * 0.6, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.25, y - size * 0.25, size * 0.5, size * 0.5, StringUtil.toColorStringSVG(colorLine), StringUtil.toColorStringSVG(colorLine), thickness));
		}
		
		/////////////////////////////  ARTIFICIAL PLAYER  ////////////////////////////////////////
		public static function drawArtificialPlayerGlyph(graphics:Graphics, x:Number, y:Number, size:Number, color:uint):void {
			drawArtificialPlayer(graphics, x, y, 2, color, 0xffffff, size * 0.8, MachinationsNode.MODE_PASSIVE);
		}
		public static function drawArtificialPlayer(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String):void {
			graphics.lineStyle(thickness, colorLine);
			graphics.beginFill(colorFill);
			graphics.drawRect(x - size * 0.5, y - size * 0.5, size * 1.0, size * 1.0);
			graphics.endFill();
			if (activationType == MachinationsNode.MODE_INTERACTIVE) graphics.drawRect(x - size * 0.35, y - size * 0.35, size * 0.7, size * 0.7);
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawText("*", graphics, x + size*0.8, y - size*0.6+6, 12, PhantomFont.ALIGN_CENTER);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawText("s", graphics, x + size*0.8, y - size*0.6 + 6, 10, PhantomFont.ALIGN_CENTER);
			graphics.lineStyle(2, colorLine);
			if (activationType == MachinationsNode.MODE_INTERACTIVE) {
				PhantomFont.drawText("AP", graphics, x, y + size * 0.15, size * 0.30, PhantomFont.ALIGN_CENTER);
			} else {
				PhantomFont.drawText("AP", graphics, x, y + size * 0.22, size * 0.44, PhantomFont.ALIGN_CENTER);
			}
			graphics.lineStyle();
		}
		
		public static function drawArtificialPlayerToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, size:Number, activationType:String):void {
			svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.45, y - size * 0.45, size * 0.9, size * 0.9, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			
			if (activationType == MachinationsNode.MODE_INTERACTIVE) svg.appendChild(DrawUtil.drawRectToSVG(x - size * 0.3, y - size * 0.3, size * 0.6, size * 0.6, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness));
			if (activationType == MachinationsNode.MODE_AUTOMATIC) PhantomFont.drawTextToSVG("*", svg, x + size*0.8, y - size*0.6+6, 12, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_ONSTART) PhantomFont.drawTextToSVG("s", svg, x + size*0.8, y - size*0.6 + 6, 10, PhantomFont.ALIGN_CENTER, StringUtil.toColorStringSVG(colorFill), StringUtil.toColorStringSVG(colorLine), thickness);
			if (activationType == MachinationsNode.MODE_INTERACTIVE) {
				PhantomFont.drawTextToSVG("AP", svg, x, y + size * 0.15, size * 0.30, PhantomFont.ALIGN_CENTER, "none", StringUtil.toColorStringSVG(colorLine), 2);
			} else {
				PhantomFont.drawTextToSVG("AP", svg, x, y + size * 0.22, size * 0.44, PhantomFont.ALIGN_CENTER, "none", StringUtil.toColorStringSVG(colorLine), 2);
			}
		}
		
		
		/////////////////////////////  GROUP BOX  ////////////////////////////////////////
		
		public static function drawGroupBox(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, width:Number, height:Number):void {
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();
			
			for (var cx:Number = 0; cx < width; cx+=16) {
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(x + cx, y);
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(x + Math.min(cx + 7, width), y);
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(x + cx, y + height);
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(x + Math.min(cx + 7, width), y + height);
				
			}
			for (var cy:Number = 0; cy < height; cy+=16) {
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(x, y + cy);
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(x, y  + Math.min(cy + 7, height));
				commands.push(GraphicsPathCommand.MOVE_TO);
				data.push(x + width, y + cy);
				commands.push(GraphicsPathCommand.LINE_TO);
				data.push(x + width, y  + Math.min(cy + 7, height));
			}			
			
			graphics.lineStyle(thickness, colorLine);
			graphics.drawPath(commands, data);
			graphics.lineStyle();
			
		}
		
		public static function drawGroupBoxToSVG(svg:XML, x:Number, y:Number, thickness:Number, colorLine:uint, colorFill:uint, width:Number, height:Number):void {
			var b:XML = DrawUtil.drawRectToSVG(x, y, width, height, "none", StringUtil.toColorStringSVG(colorLine), 1);
			b.@["stroke-dasharray"] = "6,7";
			svg.appendChild(b);
			//svg.appendChild(DrawUtil.drawRectToSVG(x, y, width, height, "none", StringUtil.toColorStringSVG(colorLine), thickness));
			//draw text
		}		
				
		/////////////////////////////  CHART  ////////////////////////////////////////
		
		public static function drawChart(graphics:Graphics, x:Number, y:Number, thickness:Number, colorLine:uint, width:Number, height:Number):void {
		
			
			graphics.lineStyle(thickness, colorLine);
			graphics.drawRect(0, 0, width, height);
			graphics.lineStyle();
			
		}
		
		/////////////////////////////  RESCOURCE  ////////////////////////////////////////
		
		public static function drawResource(graphics:Graphics, x:Number, y:Number, color:uint):void {
			if (DrawUtil.colorToIllumination(color) < 0.15) {
				var c:uint = DrawUtil.lerpColor(color, 0xffffff, 0.5);
				graphics.beginFill(color);
				graphics.drawCircle(x, y, 6);
				graphics.endFill();
				graphics.beginFill(c);
				graphics.drawCircle(x, y, 4);
				graphics.endFill();
				graphics.beginFill(color);
				graphics.drawCircle(x, y, 3);
				graphics.endFill();
			} else {
				c = DrawUtil.lerpColor(color, 0, 0.5);
				graphics.beginFill(c);
				graphics.drawCircle(x, y, 6);
				graphics.endFill();
				graphics.beginFill(color);
				graphics.drawCircle(x, y, 4);
				graphics.endFill();
			}
		}
		
		public static function drawResourceToSVG(svg:XML, x:Number, y:Number, color:uint):void {
			
			var group:XML = <g/>;
			if (DrawUtil.colorToIllumination(color) < 0.15) {
				var c:uint = DrawUtil.lerpColor(color, 0xffffff, 0.5);
				group.appendChild(DrawUtil.drawCircleToSVG(x, y, 6, StringUtil.toColorStringSVG(color), "none", 0));
				group.appendChild(DrawUtil.drawCircleToSVG(x, y, 4, StringUtil.toColorStringSVG(c), "none", 0));
				group.appendChild(DrawUtil.drawCircleToSVG(x, y, 3, StringUtil.toColorStringSVG(color), "none", 0));
			} else {
				c = DrawUtil.lerpColor(color, 0, 0.5);
				group.appendChild(DrawUtil.drawCircleToSVG(x, y, 6, StringUtil.toColorStringSVG(c), "none", 0));
				group.appendChild(DrawUtil.drawCircleToSVG(x, y, 4, StringUtil.toColorStringSVG(color), "none", 0));
			}
			svg.appendChild(group);
		}		
				
				
		public static function generateConnectionData(connection:MachinationsConnection, commands:Vector.<int>, data:Vector.<Number>, offsetX:Number, offsetY:Number, pinsOnly:Boolean):void
		{
			if (connection.points.length < 2) return;
			
			if (pinsOnly) {
				var p:Vector3D = connection.points[connection.points.length - 1].clone();
				var n:Vector3D = p.subtract(connection.points[connection.points.length - 2]);
				p.x += offsetX;
				p.y += offsetY;
				n.normalize();
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				data.push( p.x, p.y
						 , p.x - n.x * 7, p.y - n.y * 7
						 , p.x - n.x * 3 + n.y * 3, p.y - n.y * 3 - n.x * 3
						 , p.x - n.x * 0, p.y - n.y * 0
						 , p.x - n.x * 3 - n.y * 3, p.y - n.y * 3 + n.x *3);
				//Primitives.addRegularPolygon(commands, data, p.x - n.x*1.5, p.y-n.y*1.5, 4, 10, 0);
						 
				p = connection.points[0].clone();
				n = p.subtract(connection.points[1]);
				p.x += offsetX;
				p.y += offsetY;
				n.normalize();
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				data.push( p.x, p.y
						 , p.x - n.x * 7, p.y - n.y * 7
						 , p.x - n.x * 4 + n.y * 3, p.y - n.y * 4 - n.x * 3
						 , p.x - n.x * 7, p.y - n.y * 7
						 , p.x - n.x * 4 - n.y * 3, p.y - n.y * 4 + n.x *3);
						 
				return;
			}
			
			switch (connection.type.lineStyle) {
				default:
				case GraphConnectionType.STYLE_SOLID:
					commands.push(GraphicsPathCommand.MOVE_TO);
					data.push(connection.points[0].x + offsetX, connection.points[0].y + offsetY);
					for (var i:int = 1; i < connection.points.length; i++) {
						commands.push(GraphicsPathCommand.LINE_TO);
						data.push(connection.points[i].x + offsetX, connection.points[i].y + offsetY);
					}
					break;
					
				case GraphConnectionType.STYLE_DOTTED:
					var segment:int = 0;
					var position:Number = 0;
					var penX:Number;
					var penY:Number;
					var penType:int = GraphicsPathCommand.MOVE_TO;
					var step:Number = 5;
					while (segment < connection.points.length - 1) {
						var line:Vector3D = connection.points[segment + 1].subtract(connection.points[segment]);
						var segmentLength:Number = line.normalize();
						penX = connection.points[segment].x;
						penY = connection.points[segment].y;
						penX += line.x * position;
						penY += line.y * position;
						while (position < segmentLength) {
							commands.push(penType);
							data.push(penX + offsetX, penY + offsetY);
							if (penType == GraphicsPathCommand.MOVE_TO) {
								penType = GraphicsPathCommand.LINE_TO;
								step = Math.max(2, connection.thickness);
							} else {
								penType = GraphicsPathCommand.MOVE_TO;
								step = 5 + connection.thickness;
							}
							position += step;
							penX += line.x * step;
							penY += line.y * step;
						}
						penX = connection.points[segment + 1].x;
						penY = connection.points[segment + 1].y;
						commands.push(penType);
						data.push(penX + offsetX, penY + offsetY);
						position -= segmentLength;
						segment++;
					}				
					break;
			}
			
			
			if (connection.type.arrowEnd != GraphConnectionType.ARROW_NONE) {
				p = connection.points[connection.points.length - 1].clone();
				n = p.subtract(connection.points[connection.points.length - 2]);
				p.x += offsetX;
				p.y += offsetY;
				n.normalize();
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				var s:Number;
				switch (connection.type.arrowEnd) {
					default:
					case GraphConnectionType.ARROW_SMALL: s = 3; break;
					case GraphConnectionType.ARROW_MEDIUM: s = 5; break;
					case GraphConnectionType.ARROW_LARGE: s = 7; break;
				}
				n.scaleBy(s);
				data.push( p.x - n.x - n.y, p.y - n.y + n.x
				         , p.x, p.y
						 , p.x - n.x + n.y, p.y - n.y - n.x);
			}
			
			if (connection.type.arrowStart != GraphConnectionType.ARROW_NONE) {
				p = connection.points[0].clone();
				n = p.subtract(connection.points[1]);
				p.x += offsetX;
				p.y += offsetY;
				n.normalize();
				commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
				switch (connection.type.arrowStart) {
					default:
					case GraphConnectionType.ARROW_SMALL: s = 3; break;
					case GraphConnectionType.ARROW_MEDIUM: s = 5; break;
					case GraphConnectionType.ARROW_LARGE: s = 7; break;
				}
				n.scaleBy(s);
				data.push( p.x - n.x - n.y, p.y - n.y + n.x
				         , p.x, p.y
						 , p.x - n.x + n.y, p.y - n.y - n.x);
			}
			
		}				
		
	}

}