package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphConnection;
	import nl.jorisdormans.graph.GraphConnectionType;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.graph.GraphNode;
	import nl.jorisdormans.machinations.model.ArtificialPlayer;
	import nl.jorisdormans.machinations.model.Chart;
	import nl.jorisdormans.machinations.model.Converter;
	import nl.jorisdormans.machinations.model.Delay;
	import nl.jorisdormans.machinations.model.Drain;
	import nl.jorisdormans.machinations.model.EndCondition;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.GroupBox;
	import nl.jorisdormans.machinations.model.Label;
	import nl.jorisdormans.machinations.model.Register;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.TextLabel;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.machinations.model.Resource;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.machinations.model.TextLabel;
	import nl.jorisdormans.machinations.model.Trader;
	import nl.jorisdormans.phantomGraphics.DrawUtil;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.phantomGraphics.PhantomShape;
	import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
	import nl.jorisdormans.utils.FileIO;
	import nl.jorisdormans.utils.MathUtil;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsViewElement extends Sprite
	{
		public static const SELECTED_COLOR:uint = 0x0088ff;
		private static const SELECTED_COLOR2:uint = 0x88bbff;
		private static const HOVER_COLOR:uint = 0xffbb00;
		private static const CONTROL_COLOR:uint = 0xffffff;
		private static const SELECTED_THICKNESS:Number = 5;
		public static const CONTROL_SIZE:Number = 6;
		
		public static const FIRE_COLOR:uint = 0x0088ff;
		public static const INHIBITED_COLOR:uint = 0xdddddd;
		public static const BLOCKED_COLOR:uint = 0xffffff;
		
		private var _element:GraphElement;
		private var _selected:Boolean = false;
		private var _unique:Boolean = false;
		private var _control:int = -1;
		private var _hovering:Boolean = false;
		private var _hoveringControl:int = -1;
		public var pinsOnly:Boolean;
		
		public function MachinationsViewElement(parent:DisplayObjectContainer, element:GraphElement) 
		{
			this.element = element;
			parent.addChild(this);
			element.addEventListener(GraphEvent.ELEMENT_CHANGE, onElementChanged);
			element.addEventListener(GraphEvent.ELEMENT_DISPOSE, onElementDisposed);
			draw();
		}
		
		private function onElementDisposed(e:GraphEvent):void 
		{
			(parent.parent.parent as MachinationsView).removeElement(this);
		}
		
		private function onElementChanged(e:GraphEvent):void 
		{
			draw();
		}
		
		public function get element():GraphElement { return _element; }
		
		public function set element(value:GraphElement):void 
		{
			_element = value;
			draw();
		}
		
		public function get selected():Boolean { return _selected; }
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			_hoveringControl = -1;
			draw();
		}
		
		public function get unique():Boolean { return _unique; }
		
		public function set unique(value:Boolean):void 
		{
			_unique = value;
			draw();
		}
		
		public function get control():int { return _control; }
		
		public function set control(value:int):void 
		{
			_control = value;
			draw();
		}
		
		public function get hovering():Boolean { return _hovering; }
		
		public function set hovering(value:Boolean):void 
		{
			_hovering = value;
			draw();
		}
		
		public function get hoveringControl():int { return _hoveringControl; }
		
		public function set hoveringControl(value:int):void 
		{
			_hoveringControl = value;
			draw();
		}
		
		public function draw():void {
			if (!parent) return;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			graphics.clear();
			var node:MachinationsNode = (element as MachinationsNode);
			if (node) {
				
				this.x = node.position.x + offsetX;
				this.y = node.position.y + offsetY;
				var th:Number = Math.max(node.thickness, 1);
				
				var c:uint = 0;
				if (_selected) c = SELECTED_COLOR;
				else if (_hovering) c = HOVER_COLOR;
				if (c != 0) {
					if (node is Drain) MachinationsDraw.drawDrain(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, node.pullMode);
					else if (node is Pool) MachinationsDraw.drawPool(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, node.pullMode, node.resourceInputCount);
					else if (node is Delay) MachinationsDraw.drawDelay(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, (node as Delay).delayType);
					else if (node is Converter) MachinationsDraw.drawConverter(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, node.pullMode);
					else if (node is Trader) MachinationsDraw.drawTrader(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, node.pullMode);
					else if (node is Source) MachinationsDraw.drawSource(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode, node.pullMode);
					else if (node is Gate) MachinationsDraw.drawGate(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, (node as Gate).gateType, node.activationMode, node.pullMode);
					else if (node is Register) MachinationsDraw.drawRegister(this.graphics, 0, 0, th + SELECTED_THICKNESS, c, 0xffffff, node.size, "", node.activationMode);
					else if (node is EndCondition) MachinationsDraw.drawEndCondition(this.graphics, 0, 0, th + SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode);
					else if (node is ArtificialPlayer) MachinationsDraw.drawArtificialPlayer(this.graphics, 0, 0, th + SELECTED_THICKNESS, c, 0xffffff, node.size, node.activationMode);
					else if (node is Chart) MachinationsDraw.drawChart(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, (node as Chart).width, (node as Chart).height);
					else if (node is GroupBox) MachinationsDraw.drawGroupBox(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, (node as GroupBox).width, (node as GroupBox).height);
				}
				
				var lc:uint = node.color;
				if (node.inhibited) lc = INHIBITED_COLOR;
				if (node.firing>0 || node.fireFlag) lc = FIRE_COLOR;
				//if ((node is ArtificialPlayer) && !(node as ArtificialPlayer).active) lc = INHIBITED_COLOR;
				
				if (node is Drain) MachinationsDraw.drawDrain(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Pool) MachinationsDraw.drawPool(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode, node.resourceInputCount);
				else if (node is Delay) {
					if ((node as Delay).delayed) {
						MachinationsDraw.drawDelay(this.graphics, 0, 0, th, 0xffffff, lc, node.size, node.activationMode, (node as Delay).delayType);
					} else {
						MachinationsDraw.drawDelay(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, (node as Delay).delayType);
					}
				}
				else if (node is Converter) MachinationsDraw.drawConverter(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Trader) MachinationsDraw.drawTrader(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Source) MachinationsDraw.drawSource(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Gate) {
					if ((element as Gate).displayValue > 0) MachinationsDraw.drawGateValue(this.graphics, 0, 0, th, lc, 0xffffff, node.size, (node as Gate).value);
					else MachinationsDraw.drawGate(this.graphics, 0, 0, th, lc, 0xffffff, node.size, (node as Gate).gateType, node.activationMode, node.pullMode);
				}
				
				else if (node is Register) {
					var v:String = "x";
					if (node.activationMode == MachinationsNode.MODE_INTERACTIVE || (node.graph as MachinationsGraph).running) {
						v = (node as Register).value.toString();
					}
					MachinationsDraw.drawRegister(this.graphics, 0, 0, th, lc, 0xffffff, node.size, v, node.activationMode);
				}
				else if (node is EndCondition) MachinationsDraw.drawEndCondition(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode);
				else if (node is ArtificialPlayer) MachinationsDraw.drawArtificialPlayer(this.graphics, 0, 0, th, lc, 0xffffff, node.size, node.activationMode);
				else if (node is Chart) (node as Chart).draw(this.graphics, 0, 0);
				else if (node is GroupBox) MachinationsDraw.drawGroupBox(this.graphics, 0, 0, th, lc, (node as GroupBox).width, (node as GroupBox).height);
				
				
				//draw caption
				var cap:String = node.caption;
				if (node is TextLabel && !(node is GroupBox)) {
					if (!cap || StringUtil.trim(cap) == "") cap = "TextLabel";
				}
				if (cap && cap != "") {
					if (c == 0) c = 0xffffff;
					if (_hoveringControl == 0) c = HOVER_COLOR;
					graphics.lineStyle(6, c);
					PhantomFont.drawText(cap, graphics, node.captionCalculatedPosition.x, node.captionCalculatedPosition.y + 4.5, 9, node.captionAlign);
					graphics.lineStyle();
					graphics.lineStyle(2, lc);
					node.captionSize = PhantomFont.drawText(cap, graphics, node.captionCalculatedPosition.x, node.captionCalculatedPosition.y + 4.5, 9, node.captionAlign);
					graphics.lineStyle();
				}
				
				//resources
				if (element is Pool) {
					//drawResources((element as Pool).resources, (element as Pool).inhibited, (element as Pool).activationMode);
					drawResources(element as Pool);
				}
				
				if (unique && node is GroupBox) {
					var box:GroupBox = (node as GroupBox);
					var l:int = Math.min(box.points.length, 4);
					for (var i:int = 0; i < l; i++) {
						c = SELECTED_COLOR;
						if (i + 1 == _hoveringControl) c = HOVER_COLOR;
						if (_control >= 0 && _control == i + 1) c = SELECTED_COLOR2;
						graphics.beginFill(c);
						graphics.drawCircle(box.points[i].x, box.points[i].y, CONTROL_SIZE);
						graphics.endFill();
						graphics.beginFill(CONTROL_COLOR);
						graphics.drawCircle(box.points[i].x, box.points[i].y, CONTROL_SIZE - 2);
						graphics.endFill();
					}
				}				
				
				//ready
				return;
			}
			var connection:MachinationsConnection = (element as MachinationsConnection);
			if (connection && connection.points.length>1) {
				//generate command data
				this.x = connection.points[0].x + offsetX;
				this.y = connection.points[0].y + offsetY;
				var commands:Vector.<int> = new Vector.<int>();
				var data:Vector.<Number> = new Vector.<Number>();
				
				pinsOnly = false;
				if (connection.end is Chart) {
					if (parent.parent.parent is MachinationsEditView) {
						pinsOnly = !selected;
					} else {
						pinsOnly = true;
					}
				}
				
				
				th = connection.thickness;
				if (th == 0) {
					if (connection is ResourceConnection) {
						//* minimum thickness = 1
						th = 1;
						//*/
						
						/* when thickness = 0, it becomes dynamic
						if ((connection.graph as MachinationsGraph).running) {
							th = Math.min(connection.label.value * 2, 12);
						} else {
							th = 2;
						}
						//*/
					} else {
						th = 1;
						if (parent.parent.parent is MachinationsEditView) {
							pinsOnly = !selected;
						} else {
							pinsOnly = true;
						}
					}
				}
				
				MachinationsDraw.generateConnectionData(connection, commands, data, -this.x, -this.y, pinsOnly);
				
				
				
				//draw selected outline
				c = 0;
				if (selected) {
					c = SELECTED_COLOR;
				} else if (_hovering) {
					c = HOVER_COLOR;
				}
				if (c!=0) {
					graphics.lineStyle(th+SELECTED_THICKNESS, c);
					graphics.drawPath(commands, data);
					graphics.lineStyle();
				}
				
				//draw the connection
				lc = connection.color;
				if (connection.firing > 0) lc = FIRE_COLOR;
				if (connection.inhibited || th == 0) lc = INHIBITED_COLOR;
				if (connection.blocked > 0 && (connection.blocked % 0.1)<0.05) lc = BLOCKED_COLOR;
				graphics.lineStyle(th, lc);
				graphics.drawPath(commands, data);
				graphics.lineStyle();
				
				if (pinsOnly) return;
				
				//draw modifier
				if (c == 0) c = 0xffffff;
				if (_hoveringControl == connection.points.length) c = HOVER_COLOR;
				graphics.lineStyle(6, c);
				PhantomFont.drawText(connection.label.text, graphics, connection.label.calculatedPosition.x - x, connection.label.calculatedPosition.y - y + 4.5, 9, connection.label.align);
				graphics.lineStyle();
				graphics.lineStyle(2, lc);
				connection.label.size = PhantomFont.drawText(connection.label.text, graphics, connection.label.calculatedPosition.x - x, connection.label.calculatedPosition.y - y + 4.5, 9, connection.label.align);
				graphics.lineStyle();
				
				//determine the place to draw a marker
				var modP:Vector3D = connection.getPosition();
				switch (connection.label.align) {
					case PhantomFont.ALIGN_RIGHT:
						modP.x -= connection.label.size.x;
						break;
					case PhantomFont.ALIGN_CENTER:
						modP.x -= connection.label.size.x *0.5;
						break;
				}
				modP.x -= this.x;
				modP.y -= this.y + 1;
				
				switch (connection.label.type) {
					case Label.TYPE_DICE:
						if (c!=0xffffff) graphics.lineStyle(6, c);
						MachinationsDraw.drawDice(graphics, modP.x, modP.y, 14, lc);
						graphics.lineStyle();
						MachinationsDraw.drawDice(graphics, modP.x, modP.y, 14, lc);
						break;
					case Label.TYPE_SKILL:
						if (c!=0xffffff) graphics.lineStyle(6, c);
						MachinationsDraw.drawSkill(graphics, modP.x, modP.y, 14, lc);
						graphics.lineStyle();
						MachinationsDraw.drawSkill(graphics, modP.x, modP.y, 14, lc);
						break;
					case Label.TYPE_MULTIPLAYER:
						if (c!=0xffffff) graphics.lineStyle(6, c);
						MachinationsDraw.drawMultiplayer(graphics, modP.x, modP.y, 14, lc);
						graphics.lineStyle();
						MachinationsDraw.drawMultiplayer(graphics, modP.x, modP.y, 14, lc);
						break;
					case Label.TYPE_STRATEGY:
						if (c!=0xffffff) graphics.lineStyle(6, c);
						MachinationsDraw.drawStrategy(graphics, modP.x, modP.y, 14, lc);
						graphics.lineStyle();
						MachinationsDraw.drawStrategy(graphics, modP.x, modP.y, 14, lc);
						break;
				}
				
				//draw markers for points
				if (unique) {
					l = connection.points.length;
					for (i = 0; i < l; i++) {
						c = SELECTED_COLOR;
						if (i == _hoveringControl) c = HOVER_COLOR;
						if (_control >= 0 && _control == i) c = SELECTED_COLOR2;
						graphics.beginFill(c);
						graphics.drawCircle(connection.points[i].x - x, connection.points[i].y - y, CONTROL_SIZE);
						graphics.endFill();
						graphics.beginFill(CONTROL_COLOR);
						graphics.drawCircle(connection.points[i].x - x, connection.points[i].y - y, CONTROL_SIZE - 2);
						graphics.endFill();
					}
				}
				
				//draw resources
				var flow:ResourceConnection = connection as ResourceConnection;
				if (flow && !flow.instantaneous) {
					l = flow.resources.length;
					for (i = 0; i < l; i++) {
						if (flow.resources[i].position >= 0) {
							var rp:Vector3D = flow.getPositionOnLine(flow.resources[i].position);
							rp.x -= x;
							rp.y -= y;
							MachinationsDraw.drawResource(graphics, rp.x, rp.y, flow.resources[i].color);
						}
					}
				}
				
				
				
				return;
			}
		}
		
		
		public function drawToSVG(svg:XML):void {
			if (!parent) return;
			var node:MachinationsNode = (element as MachinationsNode);
			if (node) {
				var th:Number = Math.max(node.thickness, 1);
				
				var c:uint = 0;
				/*if (_selected) c = SELECTED_COLOR;
				else if (_hovering) c = HOVER_COLOR;
				if (c != 0) {
					if (node is Drain) MachinationsDraw.drawDrain(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Pool) MachinationsDraw.drawPool(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Converter) MachinationsDraw.drawConverter(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Trader) MachinationsDraw.drawTrader(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Source) MachinationsDraw.drawSource(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Gate) MachinationsDraw.drawGate(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, 0xffffff, node.size, (node as Gate).gateType);
					else if (node is EndCondition) MachinationsDraw.drawEndCondition(this.graphics, 0, 0, th + SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is ArtificialPlayer) MachinationsDraw.drawArtificialPlayer(this.graphics, 0, 0, th + SELECTED_THICKNESS, c, 0xffffff, node.size);
					else if (node is Chart) MachinationsDraw.drawChart(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, (node as Chart).width, (node as Chart).height);
					else if (node is GroupBox) MachinationsDraw.drawGroupBox(this.graphics, 0, 0, th+SELECTED_THICKNESS, c, (node as GroupBox).width, (node as GroupBox).height);
				}*/
				
				var lc:uint = node.color;
				//if (node.inhibited) lc = INHIBITED_COLOR;
				//if (node.firing>0) lc = FIRE_COLOR;
				//if ((node is ArtificialPlayer) && !(node as ArtificialPlayer).active) lc = INHIBITED_COLOR;
				
				
				if (node is Drain) MachinationsDraw.drawDrainToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Pool) MachinationsDraw.drawPoolToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode, node.resourceInputCount);
				else if (node is Delay) MachinationsDraw.drawDelayToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, (node as Delay).delayType);
				else if (node is Converter) MachinationsDraw.drawConverterToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Trader) MachinationsDraw.drawTraderToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				else if (node is Source) MachinationsDraw.drawSourceToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode, node.pullMode);
				//else if (node is Gate && (element as Gate).displayValue > 0) MachinationsDraw.drawGateValue(this.graphics, 0, 0, th, lc, 0xffffff, node.size, (node as Gate).value);
				else if (node is Gate) MachinationsDraw.drawGateToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, (node as Gate).gateType, node.activationMode, node.pullMode);
				else if (node is Register) {
					var v:String = "x";
					if (node.activationMode == MachinationsNode.MODE_INTERACTIVE || (node.graph as MachinationsGraph).running) {
						v = (node as Register).value.toString();
					}
					MachinationsDraw.drawRegisterToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, v, node.activationMode);
				}
				else if (node is EndCondition) MachinationsDraw.drawEndConditionToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode);
				else if (node is ArtificialPlayer) MachinationsDraw.drawArtificialPlayerToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, node.size, node.activationMode);
				else if (node is Chart) (node as Chart).toSVG(svg);
				else if (node is GroupBox) MachinationsDraw.drawGroupBoxToSVG(svg, node.position.x, node.position.y, th, lc, 0xffffff, (node as GroupBox).width, (node as GroupBox).height);
				
				
				//draw caption
				var cap:String = node.caption;
				if (node is TextLabel && !node is GroupBox) {
					if (!cap || StringUtil.trim(cap) == "") cap = "TextLabel";
				}
				if (cap && cap != "") {
					if (c == 0) c = 0xffffff;
					if (_hoveringControl == 0) c = HOVER_COLOR;
					//PhantomFont.drawTextToSVG(cap, svg, node.captionCalculatedPosition.x + x, node.captionCalculatedPosition.y + 4.5 + y, 9, node.captionAlign, "none", StringUtil.toColorStringSVG(c), 6);
					PhantomFont.drawTextToSVG(cap, svg, node.captionCalculatedPosition.x + x, node.captionCalculatedPosition.y + 4.5 + y, 9, node.captionAlign, "none", StringUtil.toColorStringSVG(lc), 2);
				}
				
				//resources
				if (element is Pool) {
					drawResourcesToSVG((element as Pool), svg);
				}
				
				//ready
				return;
			}
			var connection:MachinationsConnection = (element as MachinationsConnection);
			if (connection && connection.points.length>1) {
				//generate command data
				var commands:Vector.<int> = new Vector.<int>();
				var data:Vector.<Number> = new Vector.<Number>();
				
				var pinsOnly:Boolean = false;
				if (connection.end is Chart) {
					pinsOnly = true;
				}
				
				th = connection.thickness;
				if (th == 0) {
					if (connection is ResourceConnection) {
						th = 2;
					} else {
						th = 1;
						pinsOnly = true;
					}
				}
				
				
				
				MachinationsDraw.generateConnectionData(connection, commands, data, 0, 0, pinsOnly);
				
				
				//draw selected outline
				/*c = 0;
				if (selected) {
					c = SELECTED_COLOR;
				} else if (_hovering) {
					c = HOVER_COLOR;
				}
				if (c!=0) {
					graphics.lineStyle(th+SELECTED_THICKNESS, c);
					graphics.drawPath(commands, data);
					graphics.lineStyle();
				}*/
				
				//draw the connection
				lc = connection.color;
				//if (connection.firing > 0) lc = FIRE_COLOR;
				//if (connection.inhibited || th == 0) lc = INHIBITED_COLOR;
				//if (connection.blocked > 0 && (connection.blocked % 0.1)<0.05) lc = BLOCKED_COLOR;
				
				svg.appendChild(DrawUtil.drawPathToSVG(commands, data, "none", StringUtil.toColorStringSVG(lc), th));
				
				if (pinsOnly) return;
				
				//draw modifier
				if (c == 0) c = 0xffffff;
				if (_hoveringControl == connection.points.length) c = HOVER_COLOR;
				PhantomFont.drawTextToSVG(connection.label.text, svg, connection.label.calculatedPosition.x, connection.label.calculatedPosition.y + 4.5, 9, connection.label.align, "none", StringUtil.toColorStringSVG(c), 6);
				PhantomFont.drawTextToSVG(connection.label.text, svg, connection.label.calculatedPosition.x, connection.label.calculatedPosition.y + 4.5, 9, connection.label.align, "none", StringUtil.toColorStringSVG(lc), 2);
				
				//determine the place to draw a marker
				var modP:Vector3D = connection.getPosition();
				switch (connection.label.align) {
					case PhantomFont.ALIGN_RIGHT:
						modP.x -= connection.label.size.x;
						break;
					case PhantomFont.ALIGN_CENTER:
						modP.x -= connection.label.size.x *0.5;
						break;
				}
				modP.x -= this.x;
				modP.y -= this.y + 1;
				
				switch (connection.label.type) {
					case Label.TYPE_DICE:
						MachinationsDraw.drawDiceToSVG(svg, modP.x+x, modP.y+y, 14, lc);
						break;
					case Label.TYPE_SKILL:
						MachinationsDraw.drawSkillToSVG(svg, modP.x+x, modP.y+y, 14, lc);
						break;
					case Label.TYPE_MULTIPLAYER:
						MachinationsDraw.drawMultiplayerToSVG(svg, modP.x+x, modP.y+y, 14, lc);
						break;
					case Label.TYPE_STRATEGY:
						MachinationsDraw.drawStrategyToSVG(svg, modP.x+x, modP.y+y, 14, lc);
						break;
				}
				return;
			}
		}		
		
		//private function drawResources(resources:Vector.<Resource>, inhibited:Boolean, activationMode:String):void
		private function drawResources(pool:Pool):void
		{
			var c:uint;
			var l:int = pool.resourceCount;
			if (l>=0 && l <= pool.tokenLimit) {
				var x:Number = -12;
				var y:Number = -2;
				for (var i:int = 0; i < l; i++) {
					c = pool.resources[i].color;
					if (pool.inhibited) c = INHIBITED_COLOR;
					MachinationsDraw.drawResource(graphics, x, y, c);
					y -= 4;
					if (i % 5 == 4) {
						y += 20;
						x += 12;
					}
					if (i % 15 == 14) {
						y += 10;
						x -= 12*2.5;
					}
				}
				
			} else {
				var s:Number = 12;
				if (pool.activationMode == MachinationsNode.MODE_INTERACTIVE) s = 9;
				
				if (l >= 1000) s *=0.8;
				
				var t:Number = (s / 12) * 3;
				if (l>0) {
					c = pool.resources[l - 1].color;
				} else {
					c = pool.resourceColor;
				}
				if (pool.inhibited) c = INHIBITED_COLOR;
				graphics.lineStyle(t, c);
				PhantomFont.drawText(l.toString(), graphics, 0, s*0.5, s, PhantomFont.ALIGN_CENTER);
				graphics.lineStyle();
			}
		}
		
		private function drawResourcesToSVG(pool:Pool, svg:XML):void
		{
			var l:int = pool.resources.length;
			if (l>=0 && l <= pool.tokenLimit) {
				var x:Number = -12;
				var y:Number = -2;
				for (var i:int = 0; i < l; i++) {
					MachinationsDraw.drawResourceToSVG(svg, x+this.x, y+this.y, pool.resources[i].color);
					y -= 4;
					if (i % 5 == 4) {
						y += 20;
						x += 12;
					}
					if (i % 15 == 14) {
						y += 10;
						x -= 12*2.5;
					}
				}
				
			} else {
				var s:Number = 12;
				if (pool.activationMode == MachinationsNode.MODE_INTERACTIVE) s = 9;
				
				if (l >= 1000) s *=0.8;
				
				var t:Number = (s / 12) * 3;
				
				if (l>0) {
					PhantomFont.drawTextToSVG(l.toString(), svg, this.x, this.y + s * 0.5, s, PhantomFont.ALIGN_CENTER, "none", StringUtil.toColorStringSVG(pool.resources[l - 1].color), t);
				}
			}
		}		
		
		public function pointInElement(x:Number, y:Number):Boolean
		{
			var box:GroupBox = (element as GroupBox);
			if (box) {
				if (box.pointInCaption(x, y)) return true;
				if (box is Chart) {
					return (x > box.position.x - 5 && x < box.position.x + box.width + 5 && y > box.position.y - 5 && y < box.position.y + box.height + 25);
				}
				var dx:Number = x - box.position.x;
				var dy:Number = y - box.position.y;
				if (Math.abs(dx) < 5 && dy > -5 && dy < box.height + 5) return true;
				if (Math.abs(box.width - dx) < 5 && dy > -5 && dy < box.height + 5) return true;
				if (Math.abs(dy) < 5 && dx > -5 && dx < box.width + 5) return true;
				if (Math.abs(box.height - dy) < 5 && dx > -5 && dy < box.width + 5) return true;
				return false;
			}
			
			var node:MachinationsNode = (element as MachinationsNode);
			if (node) {
				dx = x - node.position.x;
				dy = y - node.position.y;
				var ds:Number = dx * dx + dy * dy;
				if (ds < node.size * node.size) return true;
				if (node.pointInCaption(x, y)) return true;
			}
			var connection:MachinationsConnection = (element as MachinationsConnection);
			if (connection) {
				var p:Vector3D = new Vector3D(x, y);
				if (pinsOnly) {
					var d:Vector3D = connection.points[1].subtract(connection.points[0]);
					d.normalize();
					d.scaleBy(7);
					d.incrementBy(connection.points[0]);
					d.decrementBy(p);
					if (d.length < 7) return true;
					d = connection.points[connection.points.length - 1].subtract(connection.points[connection.points.length - 2]);
					d.normalize();
					d.scaleBy(-7);
					d.incrementBy(connection.points[connection.points.length - 1]);
					d.decrementBy(p);
					if (d.length < 7) return true;
					return false;
				}
				if (connection.label.pointInModifier(x, y)) return true;
				var l:int = connection.points.length;
				for (var i:int = 1; i < l; i++) {
					d = connection.points[i].subtract(connection.points[i - 1]);
					var len:Number = d.normalize();
					var dist:Number = MathUtil.distanceToLine(connection.points[i - 1], d, len, p);
					if (dist < SELECTED_THICKNESS) return true;
				}
			}
			return false;
		}
		
		public function pointOnControl(x:Number, y:Number):int
		{
			var box:GroupBox = (element as GroupBox);
			if (box) {
				if (box.pointInCaption(x, y)) return 0;
				var l:int = box.points.length;
				for (var i:int = 0; i < l; i++) {
					var dx:Number = x - box.points[i].x - box.position.x;
					var dy:Number = y - box.points[i].y - box.position.y;
					var ds:Number = dx * dx + dy * dy;
					if (ds < CONTROL_SIZE * CONTROL_SIZE) {
						return i + 1;
					}
				}
				return -1;
			}
			
			var node:MachinationsNode = (element as MachinationsNode);
			if (node is TextLabel) return -1;
			if (node) {
				if (node.pointInCaption(x, y)) return 0;
			}
			var connection:MachinationsConnection = (element as MachinationsConnection);
			if (connection) {
				var p:Vector3D = new Vector3D(x, y);
				l = connection.points.length;
				for (i = 0; i < l; i++) {
					dx = x - connection.points[i].x;
					dy = y - connection.points[i].y;
					ds = dx * dx + dy * dy;
					if (ds < CONTROL_SIZE * CONTROL_SIZE) {
						return i;
					}
				}
				if (connection.label.pointInModifier(x, y)) return connection.points.length;
			}			
			return -1;
		}
		
		
		public function moveBy(dx:int, dy:int):void
		{
			var node:MachinationsNode = element as MachinationsNode;
			if (node) {
				x += dx;
				y += dy;
				node.moveBy(dx, dy);
			}
			var connection:MachinationsConnection = element as MachinationsConnection;
			if (connection) {
				var l:int = connection.points.length;
				for (var i:int = 0; i < l; i++) {
					if (i == 0 && connection.start) {
						connection.calculateStartPosition();
						continue;
					}
					if (i == l - 1 && connection.end) {
						connection.calculateEndPosition();
						continue;
					}
					connection.points[i].x += dx;
					connection.points[i].y += dy;
				}
				connection.calculateModifierPosition();
				draw();
			}
		}
		
		public function moveControl(dx:Number, dy:Number, mouseX:Number, mouseY:Number):void
		{
			var box:GroupBox = (element as GroupBox);
			if (box) {
				switch (_control) {
					case 0:
						var cp:int = 0;
						var minD:Number = 999999;
						var l:int = 15;
						if (box is Chart) l = 6;
						for (var i:int = 4; i <= l; i++) {
							var dx:Number = box.points[i].x + box.position.x - mouseX;
							var dy:Number = box.points[i].y + box.position.y - mouseY;
							var ds:Number = dx * dx + dy * dy;
							if (ds < minD) {
								cp = i;
								minD = ds;
							}
						}
						if (cp > 0) box.captionPosition = cp;
						break;
					case 1:
						box.width = box.width - mouseX + box.position.x;
						box.position.x = mouseX;
						box.height = box.height - mouseY + box.position.y;
						box.position.y = mouseY;
						break;
					case 2:
						box.width = mouseX - box.position.x;
						box.height = box.height - mouseY + box.position.y;
						box.position.y = mouseY;
						break;
					case 3:
						box.width = box.width - mouseX + box.position.x;
						box.position.x = mouseX;
						box.height = mouseY - box.position.y;
						break;
					case 4:
						box.width = mouseX - box.position.x;
						box.height = mouseY - box.position.y;
						break;
				}
				return;
			}
			
			
			var node:MachinationsNode = element as MachinationsNode;
			if (node) {
				if (_control == 0) {
					var a:Number = Math.atan2(mouseY - y, mouseX - x);
					a /= (Math.PI * 2);
					a = a % 1;
					if (a < 0) a += 1;
					node.captionPosition = a;
					draw();
				}
			}
			var connection:MachinationsConnection = element as MachinationsConnection;
			if (connection) {
				if (_control == connection.points.length) {
					connection.label.position = connection.findClosestPointTo(mouseX, mouseY);
					if (Math.abs(connection.label.position - 0.5) < 0.05) connection.label.position = 0.5;
					connection.calculateModifierPosition(mouseX, mouseY);
					draw();
					
				} else {
					connection.points[_control].x = mouseX;
					connection.points[_control].y = mouseY;
					if (_control == 0) {
						connection.start = null;
						connection.calculateStartPosition(connection.points[_control]);
					} else if (_control == connection.points.length-1) {
						connection.end = null;
						connection.calculateEndPosition(connection.points[_control]);
					} else {
						connection.recalculatePoint(_control);
					}
					draw();
				}
			}
		}
		
		public function deleteControl():void
		{
			var connection:MachinationsConnection = element as MachinationsConnection;
			if (connection) {
				if (control > 0 && control < connection.points.length - 1) {
					connection.points.splice(control, 1);
					connection.recalculatePoint(control);
					connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				} else {
					connection.dispose();
				}
			}
		}
		
		public function elementInRectangle(r:Rectangle):Boolean
		{
			var node:MachinationsNode = element as MachinationsNode;
			if (node) {
				return (node.position.x + node.size >= r.x && node.position.x - node.size <= r.right && node.position.y + node.size >= r.y && node.position.y - node.size <= r.bottom);
			}
			var connection:MachinationsConnection = element as MachinationsConnection;
			if (connection) {
				var l:int = connection.points.length;
				for (var i:int = 0; i < l; i++) {
					if (connection.points[i].x >= r.x && connection.points[i].x <= r.right && connection.points[i].y >= r.y && connection.points[i].y <= r.bottom) return true;
				}
			}
			return false;
		}
		
		public function getSnap():Point
		{
			var p:Point = new Point(0, 0);
			if (element is MachinationsNode) {
				var ep:Vector3D = (element as MachinationsNode).getPosition();
				p = (parent as PhantomDrawPanel).trySnap(ep.x, ep.y);
			}
			return p;
		}
	}

}