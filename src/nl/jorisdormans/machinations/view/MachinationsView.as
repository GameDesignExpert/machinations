package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.ArtificialPlayer;
	import nl.jorisdormans.machinations.model.Chart;
	import nl.jorisdormans.machinations.model.MachinationsGrammar;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Register;
	import nl.jorisdormans.machinations.view.MachinationsViewElement;
	import nl.jorisdormans.phantomGUI.PhantomBorder;
	import nl.jorisdormans.phantomGUI.PhantomButton;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
	import nl.jorisdormans.phantomGUI.PhantomGlyph;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.phantomGUI.PhantomPanel;
	import nl.jorisdormans.phantomGUI.PhantomToolTip;
	import nl.jorisdormans.utils.FileIO;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsView extends PhantomBorder
	{
		private var title:PhantomLabel;
		private var data:PhantomLabel;
		public var drawPanel:PhantomDrawPanel;
		public var drawContainer:PhantomPanel;
		protected var _graph:MachinationsGraph;
		protected var _elements:Vector.<MachinationsViewElement>;
		protected var selectAddedElements:Boolean = false;

		protected var topBorder:PhantomBorder;
		protected var topPanel:PhantomPanel;

		public var runButton:PhantomButton;
		public var quickRun:PhantomButton;
		public var multipleRuns:PhantomButton;
		public var runAfterLoad:Boolean;
		
		protected static const topPanelHeight:Number = 34;
		
		protected var _zoomed:Boolean = false;
		
		protected var _hover:MachinationsViewElement = null;
		
		
		protected var fileIO:FileIO;
		private var toolTip:PhantomToolTip;
		
		private var popup:PopUp;
		
		public function MachinationsView(parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number) 
		{
			super(parent, x, y /*+ topPanelHeight + 2*/, width - 2, height - topPanelHeight - 2);
			//super(parent, x, y, width, height);
			_elements = new Vector.<MachinationsViewElement>();
			createControls();
			fileIO = new FileIO();
			runAfterLoad = false;
		}
		
		protected function createControls():void
		{
			drawContainer = new PhantomPanel(this, 2, 2, this._controlWidth - 4, this._controlHeight - 4);
			drawPanel = new PhantomDrawPanel(drawContainer, 0, 0, this._controlWidth - 4, this._controlHeight - 4);
			drawPanel.background = 0xffffff;
			drawPanel.foreground = 0xbbbbdd;
			drawPanel.gridX = 0;
			drawPanel.gridY = 0;
			drawPanel.draw();
			drawPanel.mouseChildren = false;
			
			topBorder = new PhantomBorder(parent, x, y +_controlHeight, _controlWidth, topPanelHeight + 2);
			topPanel = new PhantomPanel(topBorder, 2, 0, _controlWidth - 4, topPanelHeight);
			runButton = new PhantomButton("Run (R)", run, topPanel, 4, 4, 88, 24);
			runButton.glyph = PhantomGlyph.PLAY;
			title = new PhantomLabel("*title", topPanel, 92, -2, _controlWidth-100);
			data = new PhantomLabel("data", topPanel, 92, 14, _controlWidth-100);
			title.caption = "Loading file...";
			data.caption = "...";
		
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownView);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveView);

		}
		
		protected function onMouseDownView(e:MouseEvent):void 
		{
			if (hover && hover.element is ArtificialPlayer) {
				//TODO: toggle activation mode
				var ap:ArtificialPlayer = (hover.element as ArtificialPlayer);
				switch (ap.activationMode) {
					case MachinationsNode.MODE_AUTOMATIC:
						ap.activationMode = MachinationsNode.MODE_PASSIVE;
						break;
					case MachinationsNode.MODE_PASSIVE:
						ap.activationMode = MachinationsNode.MODE_AUTOMATIC;
						break;
				}
				hover.draw();
			}
			if (hover && hover.element is Chart) {
				clickChartButtons(hover.element as Chart, e);
			}
			if (hover && hover.element is MachinationsNode && (hover.element as MachinationsNode).activationMode == MachinationsNode.MODE_INTERACTIVE) {
				if ((hover.element as MachinationsNode).inhibited) {
					hover = null;
					return;
				}
				
				if (hover.element is Register) {
					if (e.localY > (hover.element as Register).position.y) {
						(hover.element as Register).interaction -= (hover.element as Register).valueStep;
					} else {
						(hover.element as Register).interaction += (hover.element as Register).valueStep;
					}
				}
				(hover.element as MachinationsNode).click();
			}
		}
		
		protected function onMouseMoveView(e:MouseEvent):void 
		{
			if (toolTip != null) {
				toolTip.dispose();
				toolTip = null;
			}
			var element:MachinationsViewElement = getElementAt(e.localX, e.localY);
			var hovering:MachinationsViewElement = null;
			if (element) {
				if (element.pinsOnly) hovering = element; 
				if (graph.running && !graph.ended) {
					if ((element.element is MachinationsNode) && (element.element as MachinationsNode).activationMode == MachinationsNode.MODE_INTERACTIVE && !(element.element as MachinationsNode).inhibited) hovering = element;
					if (element.element is ArtificialPlayer && ((element.element as ArtificialPlayer).activationMode == MachinationsNode.MODE_PASSIVE || (element.element as ArtificialPlayer).activationMode == MachinationsNode.MODE_AUTOMATIC)) {
						hovering = element;
					}				
				} else {
					if (element.element is ArtificialPlayer) {
						hovering = element;
						toolTip = new PhantomToolTip((element.element as ArtificialPlayer).script, this);
					}				
					
					if (element.element is Chart && checkChartButtons(element.element as Chart, e)) hovering = element;
					
				}
				
			}
			hover = hovering;
			if (hovering && hovering.element is MachinationsNode) buttonMode = true;
			else buttonMode = false;
		}
		
		
		public function createQuickRunControls():void {
			quickRun = new PhantomButton("Quick Run", startQuickRun, topPanel, _controlWidth-200, 4, 88, 24);
			multipleRuns = new PhantomButton("Multiple Runs", startMultipleRuns, topPanel, _controlWidth-100, 4, 88, 24);
		}
		
		public function get hover():MachinationsViewElement { return _hover; }
		
		public function set hover(value:MachinationsViewElement):void 
		{
			if (_hover) _hover.hovering = false;
			_hover = value;
			if (_hover) _hover.hovering = true;
		}		
		
		public function get graph():MachinationsGraph { return _graph; }
		
		public function set graph(value:MachinationsGraph):void 
		{
			if (_graph!=null) {
				//_graph.removeEventListener(GraphEvent.GRAPH_CHANGE, onChangeGraph);
				_graph.removeEventListener(GraphEvent.ELEMENT_ADD, onElementAdd);
				_graph.removeEventListener(GraphEvent.GRAPH_WARNING, onWarning);
				_graph.removeEventListener(GraphEvent.GRAPH_ERROR, onError);
			}
			_graph = value;
			if (_graph != null) {
				//_graph.addEventListener(GraphEvent.GRAPH_CHANGE, onChangeGraph);
				_graph.addEventListener(GraphEvent.ELEMENT_ADD, onElementAdd);
				_graph.addEventListener(GraphEvent.GRAPH_WARNING, onWarning);
				_graph.addEventListener(GraphEvent.GRAPH_ERROR, onError);
			}
			
		}
		
		private function onElementAdd(e:GraphEvent):void 
		{
			_elements.push(new MachinationsViewElement(drawPanel, e.element));
			if (selectAddedElements) {
				_elements[_elements.length - 1].selected = true;
			}
		}
		
		public function getElementAt(x:Number, y:Number, exclude:MachinationsViewElement = null):MachinationsViewElement {
			var l:int = _elements.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if (_elements[i] != exclude && _elements[i].pointInElement(x, y)) return _elements[i];
			}
			return null;
		}
		
		public function removeElement(element:MachinationsViewElement):void
		{
			drawPanel.removeChild(element);
			var l:int = _elements.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if (_elements[i] == element) {
					_elements.splice(i, 1);
				}
			}
		}
		
		public function onLoadGraph():void {
			graph.readXML(fileIO.data);
			graph = graph;
			if (title) title.caption = graph.name;
			if (data) {
			var s:String = "";
				if (graph.author != "") s += "by: " + graph.author;
				if (graph.dice != "" && graph.dice != "D6") s += ", dice: " + graph.dice;
				if (graph.skill != "") s += ", skill: " + graph.skill;
				if (graph.strategy != "") s += ", strategy: " + graph.strategy;
				if (graph.multiplayer != "") s += ", multiplayer: " + graph.multiplayer;
				if (graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
					if (graph.actionsPerTurn > 1) s += ", actions: " + graph.actionsPerTurn.toString() + " per turn";
					if (graph.actionsPerTurn == 1) s += ", actions: 1 per turn";
				}
				
				if (s.charAt(0) == ",") s = s.substr(2);
				data.caption = s;
			}
			
			changeSize();
			
			if (runAfterLoad) run(null);
		}
		
		
		
		public function loadGraph(filename:String):void {
			fileIO.onLoadComplete = onLoadGraph;
			fileIO.openFile(filename);
		}
		
		public function setInteraction(enable:Boolean):void
		{	
			
/*			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				var node:MachinationsNode = _elements[i].element as MachinationsNode;
				if (node && node.interactive) {
					if (!enable) {
						_elements[i].buttonMode = true;
						_elements[i].addEventListener(MouseEvent.CLICK, clickElement);
						_elements[i].addEventListener(MouseEvent.MOUSE_OVER, mouseOverElement);
						_elements[i].addEventListener(MouseEvent.MOUSE_OUT, mouseOutElement);
					} else  {
						_elements[i].buttonMode = false;
						_elements[i].removeEventListener(MouseEvent.CLICK, clickElement);
						_elements[i].removeEventListener(MouseEvent.MOUSE_OVER, mouseOverElement);
						_elements[i].removeEventListener(MouseEvent.MOUSE_OUT, mouseOutElement);
						
					}
				}
			}
*/		}
		
		public function refresh():void
		{
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				_elements[i].draw();
			}
			
		}
		
		/*private function mouseOutElement(e:MouseEvent):void 
		{
			var element:MachinationsViewElement = e.target as MachinationsViewElement;
			if (element) {
				var node:MachinationsNode = element.element as MachinationsNode;
				if (node && node.interactive) {
					if (element.hovering) element.hovering = false;
				}
			}
			
		}
		
		private function mouseOverElement(e:MouseEvent):void 
		{
			var element:MachinationsViewElement = e.target as MachinationsViewElement;
			if (element) {
				var node:MachinationsNode = element.element as MachinationsNode;
				if (node && node.interactive && !node.inhibited) {
					if (!element.hovering) element.hovering = true;
				}
			}
			
		}
		
		private function clickAP(e:MouseEvent):void 
		{
			var element:MachinationsViewElement = e.target as MachinationsViewElement;
			
			if (element && element.element is ArtificialPlayer) {
				(element.element as ArtificialPlayer).active = !(element.element as ArtificialPlayer).active;
				element.draw();
			}
		}
		
		
		
		private function clickElement(e:MouseEvent):void 
		{
			var element:MachinationsViewElement = e.target as MachinationsViewElement;
			if (element) {
				var node:MachinationsNode = element.element as MachinationsNode;
				if (node && node.interactive && !node.inhibited) {
					node.click();
				}
			}
		}
		
		private function clickChart(e:MouseEvent):void 
		{
			trace("CLICK CHART", e);
			var element:MachinationsViewElement = e.target as MachinationsViewElement;
			
			if (element && element.element is Chart) {
				e.localX += (element.element  as Chart).position.x;
				e.localY += (element.element  as Chart).position.y;
				checkChartButtons((element.element  as Chart), e);
			}
			
			
		}	*/	
		
		protected function checkChartButtons(chart:Chart, e:MouseEvent):Boolean
		{
			if (chart.clickClear(e.localX, e.localY)) {
				return true;
			}
			if (chart.clickNext(e.localX, e.localY)) {
				return true;
			}
			if (chart.clickPrevious(e.localX, e.localY)) {
				return true;
			}
			if (chart.clickExport(e.localX, e.localY)) {
				return true;
			}
			return false;
		}
		
		
		protected function clickChartButtons(chart:Chart, e:MouseEvent):Boolean
		{
			if (chart.clickClear(e.localX, e.localY)) {
				chart.clear();
				chart.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, chart));
				return true;
			}
			if (chart.clickNext(e.localX, e.localY)) {
				chart.doNext();
				chart.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, chart));
				return true;
			}
			if (chart.clickPrevious(e.localX, e.localY)) {
				chart.doPrevious();
				chart.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, chart));
				return true;
			}
			if (chart.clickExport(e.localX, e.localY)) {
				chart.export();
				return true;
			}
			return false;
		}
		
		public function setControls(enable:Boolean):void {
			topPanel.enabled = enable;
		}
		
		protected function run(sender:PhantomButton):void
		{
			dispatchEvent(new GraphEvent(GraphEvent.GRAPH_RUN));
			if (graph.running) {
				runButton.caption = "Stop (R)";
				runButton.glyph = PhantomGlyph.STOP;
				setControls(false);
				runButton.enabled = true;
			} else {
				runButton.caption = "Run (R)";
				runButton.glyph = PhantomGlyph.PLAY;
				setControls(true);
			}
		}		
		
		protected function startQuickRun(sender:PhantomButton):void
		{
			dispatchEvent(new GraphEvent(GraphEvent.GRAPH_QUICKRUN));
			if (graph.running) {
				if (graph.ended) quickRun.caption = "Reset";
				else quickRun.caption = "Stop";
				setControls(false);
				quickRun.enabled = true;
			} else {
				quickRun.caption = "Quick Run";
				setControls(true);
			}
			
		}
		
		protected function startMultipleRuns(sender:PhantomButton):void
		{
			dispatchEvent(new GraphEvent(GraphEvent.GRAPH_MULTIPLERUN));
			if (graph.running) {
				if (graph.ended) multipleRuns.caption = "Reset";
				else multipleRuns.caption = "Stop";
				setControls(false);
				multipleRuns.enabled = true;
			} else {
				multipleRuns.caption = "Multiple Runs";
				setControls(true);
			}
			
		}		
		
		
		public function changeSize():void {
			if (graph.width < 600) graph.width = 600;
			if (graph.height < 560) graph.height = 560;
			drawPanel.setSize(graph.width, graph.height);
			_zoomed = false;
			zoom(null);
		}		
		
		protected function zoom(sender:PhantomControl):void
		{
			
		}	
		
		public function pushToTop(element:MachinationsViewElement):void
		{
			var l:int = _elements.length;
			for (var i:int = 0; i < l - 1; i++) {
				if (_elements[i] == element) {
					_elements.splice(i, 1);
					_elements.push(element);
					break;
				}
			}
		}	
		
		private function onWarning(e:GraphEvent):void 
		{
			if (popup && popup.parent) popup.parent.removeChild(popup);
			popup = new PopUp(stage, (600 - 300) * 0.5, 100, "Warning!", e.message);
		}
		
		private function onError(e:GraphEvent):void 
		{
			graph.end("Error");
			if (popup && popup.parent) popup.parent.removeChild(popup);
			popup = new PopUp(stage, (600 - 300) * 0.5, 100, "Error!", e.message);
		}
	}

}