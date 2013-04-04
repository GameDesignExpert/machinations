package nl.jorisdormans.machinations.view 
{
	import adobe.utils.CustomActions;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import nl.jorisdormans.graph.GraphConnection;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.graph.GraphNode;
	import nl.jorisdormans.machinations.model.ArtificialPlayer;
	import nl.jorisdormans.machinations.model.Chart;
	import nl.jorisdormans.machinations.model.Delay;
	import nl.jorisdormans.machinations.model.EndCondition;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.Label;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsGrammar;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.machinations.model.Register;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.machinations.model.TextLabel;
	import nl.jorisdormans.machinations.view.MachinationsViewElement;
	import nl.jorisdormans.phantomGraphics.PhantomShape;
	import nl.jorisdormans.phantomGUI.PhantomBorder;
	import nl.jorisdormans.phantomGUI.PhantomButton;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomDrawPanel;
	import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
	import nl.jorisdormans.phantomGUI.PhantomGlyph;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.phantomGUI.PhantomPanel;
	import nl.jorisdormans.phantomGUI.PhantomTabButton;
	import nl.jorisdormans.phantomGUI.PhantomToolButton;
	import nl.jorisdormans.utils.FileIO;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsEditView extends MachinationsView
	{
		private var lastElement:GraphElement;
		private var _lastSelected:MachinationsViewElement;
		private var mouseDownX:Number;
		private var mouseDownY:Number;
		
		private var editPanel:PhantomBorder;
		private var panelGraph:PhantomPanel;
		private var panelEdit:PhantomPanel;
		private var panelFile:PhantomPanel;
		private var panelRun:PhantomPanel;
		
		private static const editPanelWidth:Number = 194;
		private static const editPanelHeight:Number = 182;
		private static const topPanelHeight:Number = 34;
		private var _selectTool:PhantomToolButton;
		private var tool:String;
		
		private var undoList:Vector.<XML>;
		private var undoPosition:int;
		
		private var copiedData:XML;
		private var copyShift:int;
		
		private var addingConnection:Boolean = false;
		
		private var fileIOImport:FileIO;
		private var fileIOSVG:FileIO;
		private var multiSelector:MultiSelector;
		private var dragging:Boolean = false;
		
		private var _activePanel:PhantomPanel;
		private var editElement:EditElementPanel;
		private var editConnection:EditConnectionPanel;
		private var editNode:EditNodePanel;
		private var editRegister:EditRegisterPanel;
		private var editDelay:EditDelayPanel;
		private var editEnd:EditNodePanel;
		private var editSource:EditSourcePanel;
		private var editPool:EditSourcePanel;
		private var editGate:EditGatePanel;
		private var editLabel:EditLabelPanel;
		private var editChart:EditChartPanel;
		private var editAP:EditAPPanel;
		private var editGraph:EditGraphPanel;
		private var editNumberOfRuns:PhantomEditNumberBox;
		private var editVisibleRuns:PhantomEditNumberBox;
		
		public function MachinationsEditView(parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number) 
		{
			super(parent, x, y + topPanelHeight + 2, width - editPanelWidth - 2, height /*- topPanelHeight - 2*/);
			
			undoList = new Vector.<XML>();
			
			fileIOImport = new FileIO();
			fileIOSVG = new FileIO();
		}
		
		override protected function createControls():void 
		{
			drawContainer = new PhantomPanel(this, 2, 2, this._controlWidth - 4, this._controlHeight - 4);
			drawPanel = new PhantomDrawPanel(drawContainer, 0, 0, this._controlWidth - 4, this._controlHeight - 4);
			//drawPanel = new PhantomDrawPanel(this, 2, 2, this._controlWidth - 4, this._controlHeight - 4);
			drawPanel.background = 0xffffff;
			drawPanel.foreground = 0xbbbbdd;
			drawPanel.draw();
			drawPanel.mouseChildren = false;
			
			
			topBorder = new PhantomBorder(parent, x, y - topPanelHeight - 2, _controlWidth + editPanelWidth + 2, topPanelHeight + 2);
			topPanel = new PhantomPanel(topBorder, 2, 2, _controlWidth + editPanelWidth - 2, topPanelHeight);
			runButton = new PhantomButton("Run (R)", run, topPanel, 4, 4);
			runButton.glyph = PhantomGlyph.PLAY;
			new PhantomLabel("Machinations "+MachinationsGrammar.version+" by Joris Dormans (2009-2013), www.jorisdormans.nl/machinations", topPanel, 100, 6, 450);
			
			editPanel = new PhantomBorder(parent, _controlWidth + x, y, editPanelWidth + 2, _controlHeight);
			var px:int = 0;
			var py:int = 2;
			
			//tabs
			panelGraph = new PhantomPanel(editPanel, px, py+20, editPanelWidth, editPanelHeight, true);
			panelEdit = new PhantomPanel(editPanel, px, py+20, editPanelWidth, editPanelHeight, false);
			panelFile = new PhantomPanel(editPanel, px, py+20, editPanelWidth, editPanelHeight, false);
			panelRun = new PhantomPanel(editPanel, px, py + 20, editPanelWidth, editPanelHeight, false);
			
			new PhantomTabButton("*Graph", changeTab, editPanel, px, py, 50, 20, true).tab = panelGraph;
			new PhantomTabButton("*Edit", changeTab, editPanel, px+50, py, 50, 20, false).tab = panelEdit;
			new PhantomTabButton("*File", changeTab, editPanel, px+100, py, 50, 20, false).tab = panelFile;
			new PhantomTabButton("*Run", changeTab, editPanel, px + 150, py, 44, 20, false).tab = panelRun;
			
			//graphPanel
			var buttonSize:int = 40;
			var buttonSpace:int = 44;
			var tbx:int = 10;
			var tby:int = 6;
			
			_selectTool = new PhantomToolButton("Select", selectTool, panelGraph, tbx + 0 * buttonSpace, tby + 0 * buttonSpace, buttonSize, buttonSize, false);
			_selectTool.drawImage = MachinationsDraw.drawSelectGlyph;

			new PhantomToolButton("TextL", selectTool, panelGraph,            tbx + 1 * buttonSpace, tby + 0 * buttonSpace, buttonSize, buttonSize, false);
			new PhantomToolButton("GroupBox", selectTool, panelGraph,             tbx + 2 * buttonSpace, tby + 0 * buttonSpace, buttonSize, buttonSize, false);
			new PhantomToolButton("Chart", selectTool, panelGraph,                tbx + 3 * buttonSpace, tby + 0 * buttonSpace, buttonSize, buttonSize, false);
			
			new PhantomToolButton("Pool", selectTool, panelGraph,                 tbx + 0 * buttonSpace, tby + 1 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawPoolGlyph;
			new PhantomToolButton("Gate", selectTool, panelGraph,                 tbx + 1 * buttonSpace, tby + 1 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawGateGlyph;
			new PhantomToolButton("Resource Connection", selectTool, panelGraph,  tbx + 2 * buttonSpace, tby + 1 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawFlowGlyph;
			new PhantomToolButton("State Connection", selectTool, panelGraph,     tbx + 3 * buttonSpace, tby + 1 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawStateGlyph;
			//
			new PhantomToolButton("Source", selectTool, panelGraph,               tbx + 0 * buttonSpace, tby + 2 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawSourceGlyph;
			new PhantomToolButton("Drain", selectTool, panelGraph,                tbx + 1 * buttonSpace, tby + 2 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawDrainGlyph;
			new PhantomToolButton("Converter", selectTool, panelGraph,            tbx + 2 * buttonSpace, tby + 2 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawConverterGlyph;
			new PhantomToolButton("Trader", selectTool, panelGraph,               tbx + 3 * buttonSpace, tby + 2 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawTraderGlyph;
			
			new PhantomToolButton("Delay", selectTool, panelGraph,         	  tbx + 0 * buttonSpace, tby + 3 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawDelayGlyph;
			new PhantomToolButton("Register", selectTool, panelGraph,         	  tbx + 1 * buttonSpace, tby + 3 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawRegisterGlyph;
			new PhantomToolButton("EndCondition", selectTool, panelGraph,         tbx + 2 * buttonSpace, tby + 3 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawEndConditionGlyph;
			new PhantomToolButton("ArtificialPlayer", selectTool, panelGraph,     tbx + 3 * buttonSpace, tby + 3 * buttonSpace, buttonSize, buttonSize, false).drawImage = MachinationsDraw.drawArtificialPlayerGlyph;
			
			panelGraph.redraw();
			activateSelect();
			
			
			//filePanel
			//tbx = (editPanelWidth - 88) * 0.5;
			tbx = editPanelWidth * 0.4;
			var controlW:Number  = editPanelWidth -tbx - 4;			
			tby = 4;
			new PhantomButton("New (N)", newGraph, panelFile, tbx, tby, controlW); tby += 28;
			new PhantomButton("Open (O)", openGraph, panelFile, tbx, tby, controlW); tby += 28;
			new PhantomButton("Import (I)", importGraph, panelFile, tbx, tby, controlW); tby += 28;
			//new PhantomButton("Library (L)", openLibary, panelFile, tbx, tby, controlW); tby += 28;
			new PhantomButton("Save (S)", saveGraph, panelFile, tbx, tby, controlW); tby += 28;
			new PhantomButton("Export Selection (E)", saveSelection, panelFile, tbx, tby, controlW); tby += 28;
			new PhantomButton("Save as SVG (G)", saveAsSVG, panelFile, tbx, tby, controlW); tby += 28;

			//editPanel
			//tbx = (editPanelWidth - 88) * 0.5;
			tby = 4;
			new PhantomButton("Select All (A)", selectAll, panelEdit, tbx, tby, controlW); tby += 28;
			new PhantomButton("Copy (C)", copySelected, panelEdit, tbx, tby, controlW); tby += 28;
			new PhantomButton("Paste (V)", pasteSelected, panelEdit, tbx, tby, controlW); tby += 28;
			new PhantomButton("Undo (Z)", doUndo, panelEdit, tbx, tby, controlW); tby += 28;
			new PhantomButton("Redo (Y)", doRedo, panelEdit, tbx, tby, controlW); tby += 28;
			new PhantomButton("Zoom (M)", zoom, panelEdit, tbx, tby, controlW); tby += 28;
			
			//editPanel
			//tbx = (editPanelWidth - 88) * 0.5;
			tby = 4;
			quickRun = new PhantomButton("Quick Run", startQuickRun, panelRun, tbx, tby, controlW); tby += 28;
			multipleRuns = new PhantomButton("Multiple Runs", startMultipleRuns, panelRun, tbx, tby, controlW); tby += 28;
			new PhantomLabel("Runs", panelRun, 4, tby);
			editNumberOfRuns = new PhantomEditNumberBox(10, 0, 10, panelRun, tbx, tby, 60); tby += 28;
			editNumberOfRuns.min = 1;
			editNumberOfRuns.onChange = changeNumberOfRuns;
			new PhantomLabel("Visible Runs", panelRun, 4, tby);
			editVisibleRuns = new PhantomEditNumberBox(10, 0, 10, panelRun, tbx, tby, 60); tby += 28;
			editVisibleRuns.min = 1;
			editVisibleRuns.onChange = changeVisibleRuns;
			
			py = py + 20 + 2 + editPanelHeight + topPanelHeight + 2;
			var h:Number = _controlHeight - py + topPanelHeight;
			
			editElement = new EditElementPanel(this, parent, _controlWidth + x, py, editPanelWidth, h, false);
			editConnection = new EditConnectionPanel(this, parent, _controlWidth + x, py, editPanelWidth, h, false);
			editNode = new EditNodePanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editRegister = new EditRegisterPanel(this, parent, _controlWidth + x, py, editPanelWidth, h, false);
			editDelay = new EditDelayPanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editEnd = new EditNodePanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false, true, false);
			editSource = new EditSourcePanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editPool = new EditPoolPanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editGate = new EditGatePanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editLabel = new EditLabelPanel(this, parent, _controlWidth + x, py, editPanelWidth, h, false);
			editChart = new EditChartPanel(this, parent, _controlWidth + x, py, editPanelWidth, h, false);
			editAP = new EditAPPanel(this, parent, stage, _controlWidth + x, py, editPanelWidth, h, false);
			editGraph = new EditGraphPanel(parent, stage, this, _controlWidth + x, py, editPanelWidth, h, true);
			editGraph.graph = graph;
			
			setInteraction(true);
		}
		
		private function changeTab(sender:PhantomControl):void
		{
			activateSelect();
		}
		
		private function changeVisibleRuns(sender:PhantomEditNumberBox):void
		{
			graph.visibleRuns = sender.value;
		}
		
		private function changeNumberOfRuns(sender:PhantomEditNumberBox):void
		{
			graph.numberOfRuns = sender.value;
		}
		
		
		override public function setControls(enable:Boolean):void
		{
			super.setControls(enable);
			if (!enable) {
				deselectAll();
				lastSelected = null;
			} 
			editPanel.enabled = enable;
		}
		
		private function newGraph(sender:PhantomButton):void
		{
			graph.clear();
			_zoomed = false;
			changeSize();
			graph = graph;
			fileIO.fileName = "";
			fileIOSVG.fileName = "";
			
		}
		
		private function openGraph(sender:PhantomButton):void
		{
			fileIO.onLoadComplete = onLoadGraph;
			fileIO.openFileDialog("Open File");
		}
		
		private function importGraph(sender:PhantomButton):void
		{
			fileIOImport.onLoadComplete = onImportGraph;
			fileIOImport.openFileDialog("Import File");
		}
		
		public function onImportGraph():void {
			selectAddedElements = true;
			graph.addXML(fileIOImport.data);
			selectAddedElements = false;
		}
		
		private function openLibary(sender:PhantomButton):void
		{
			//here be code
		}
		
		private function saveGraph(sender:PhantomButton):void
		{
			fileIO.data = graph.generateXML();
			if (fileIO.fileName != "") fileIO.saveFile(fileIO.fileName);
			else fileIO.saveFile("new_diagram.xml");
			
		}
		
		private function saveSelection(sender:PhantomButton):void
		{
			fileIOImport.data = generateSelectionXML();
			fileIOImport.saveFileDialog("Save Selection");
		}
		
		private function saveAsSVG(sender:PhantomButton):void
		{
			var xml:XML = <svg/>;
			xml.@width = (graph.width / 50).toFixed(2) + "cm";
			xml.@height = (graph.height / 50).toFixed(2) + "cm";
			xml.@viewBox = "0 0 " + graph.width.toString() + " " + height.toString();
			xml.@xmlns = "http://www.w3.org/2000/svg";
			xml.@version = "1.1";
			
			var group:XML = <g/>;
			group.@["stroke-linecap"] = "round";
			group.@["stroke-linejoin"] = "round";
			
			//draw all connections
			var l:int = drawPanel.numChildren;
			for (var i:int = 0; i < l; i++) {
				var el:MachinationsViewElement = drawPanel.getChildAt(i) as MachinationsViewElement;
				if (el) {
					xml.appendChild(el.drawToSVG(group));
				}
			}	
			
			xml.appendChild(group);
			//trace(xml.toXMLString());
			
			fileIOSVG.data = xml;
			if (fileIOSVG.fileName != "") fileIOSVG.saveFile(fileIOSVG.fileName);
			else if (fileIO.fileName != "") fileIOSVG.saveFile(StringUtil.setFileExtention(fileIO.fileName, "svg"));
			else fileIOSVG.saveFile("new_diagram.svg");
			
		}
		
		private function selectAll(sender:PhantomButton):void
		{
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				if (!_elements[i].selected) {
					_elements[i].selected = true;	
				}
			}
		}
		
		private function copySelected(sender:PhantomButton):void
		{
			copiedData = generateSelectionXML();
			copyShift = 0;
		}
		
		private function pasteSelected(sender:PhantomButton):void
		{
			if (copiedData != null) {
				copyShift += 20;
				deselectAll();
				selectAddedElements = true;
				graph.addXML(copiedData);
				selectAddedElements = false;
				var l:int = _elements.length;
				for (var i:int = 0; i < l; i++) {
					if (_elements[i].selected) _elements[i].moveBy(copyShift, copyShift);
				}
				
			}
		}
		
		public function addUndo():void {
			var xml:XML = graph.generateXML();
			undoList.splice(undoPosition, undoList.length - undoPosition);
			undoList.push(xml);
			//keep the list to sixteen
			if (undoList.length > 16) undoList.splice(0, 1);
			undoPosition = undoList.length;
		}

		private function doUndo(sender:PhantomControl):void {
			if (undoPosition == 0) return;
			if (undoPosition == undoList.length) {
				addUndo();
				undoPosition--;
			}
			undoPosition--;
			graph.readXML(undoList[undoPosition]);
			activateSelect();
		}

		private function doRedo(sender:PhantomControl):void {
			if (undoPosition > undoList.length-2) return;
			undoPosition++;
			graph.readXML(undoList[undoPosition]);
			activateSelect();
		}		
		
		private function selectTool(sender:PhantomToolButton):void
		{
			tool = sender.caption;	
			deselectAll();
		}
		
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.target is TextField) return;
			
			if (e.keyCode == Keyboard.INSERT || e.keyCode == 87) {
				if (lastSelected && lastSelected.unique && lastSelected.element is GraphConnection) {
					addUndo();
					(lastSelected.element as GraphConnection).addPoint(drawPanel.mouseX, drawPanel.mouseY);
				}
			}
			if (e.keyCode == Keyboard.SHIFT || e.keyCode == Keyboard.ESCAPE) {
				if (addingConnection) {
					deleteSelected();
				}
				activateSelect();
			}
			
			if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) {
				deleteSelected();
			}
			
			if (e.keyCode == 65) selectAll(null);
			if (e.keyCode == 67) copySelected(null);
			if (e.keyCode == 69) saveSelection(null);
			if (e.keyCode == 71) saveAsSVG(null);
			if (e.keyCode == 73) importGraph(null);
			if (e.keyCode == 76) openLibary(null);
			if (e.keyCode == 77) zoom(null);
			if (e.keyCode == 78) newGraph(null);
			if (e.keyCode == 79) openGraph(null);
			if (e.keyCode == 82) run(null);
			if (e.keyCode == 83) saveGraph(null);
			if (e.keyCode == 86) pasteSelected(null);
			if (e.keyCode == 89) doRedo(null);
			if (e.keyCode == 90) doUndo(null);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			var mx:Number = e.localX;
			var my:Number = e.localY;
			var element:MachinationsViewElement = getElementAt(mx, my);
			if (element && element == lastSelected && element.unique) {
				element.hoveringControl = element.pointOnControl(mx, my); 
			}
			element = getElementAt(mx, my, lastSelected);
			if (!element || !element.selected) {
				hover = element;
			}
			if (addingConnection) {
				(lastSelected.element as GraphConnection).calculateEndPosition(new Vector3D(mx, my));
			}
		}
		
		public function get selectedCount():int {
			var l:int = _elements.length;
			var r:int = 0;
			for (var i:int = 0; i < l; i++) {
				if (_elements[i].selected) r++;
			}
			return r;
		}
		
		public function get activePanel():PhantomPanel{ return _activePanel; }
		
		public function set activePanel(value:PhantomPanel):void 
		{
			if (_activePanel) _activePanel.showing = false;
			_activePanel = value;
			if (_activePanel) {
				_activePanel.showing = true;
				if (_lastSelected && _activePanel is EditElementPanel) (_activePanel as EditElementPanel).element = _lastSelected.element;
				if (_activePanel is EditGraphPanel) {
					(_activePanel as EditGraphPanel).graph = graph;
				}
			}
		}
		
		public function get lastSelected():MachinationsViewElement { return _lastSelected; }
		
		public function set lastSelected(value:MachinationsViewElement):void 
		{
			_lastSelected = value;
			activePanel = null;
			if (_lastSelected) {
				lastElement = _lastSelected.element;
			}
			if (_lastSelected && selectedCount == 1) {
				_lastSelected.unique = true;
				determinePanel();
			} else if (_lastSelected) {
				determinePanel();
			} else {
				activePanel = editGraph;
			}
		}
		
		private function determinePanel():void
		{
			var c:String = _lastSelected.element.toString();
			var l:int = _elements.length;
			for (var i:int = 0; i < _elements.length; i++) {
				if (_elements[i].selected) {
					switch (c) {
						case "[object Pool]":
							if (_elements[i].element is MachinationsConnection) c = "multi";
							else if (_elements[i].element is TextLabel) c = "multi";
							else if (_elements[i].element is Pool) c = "[object Pool]";
							else if (_elements[i].element is Source) c = "[object Source]";
							else if (_elements[i].element is MachinationsNode) c = "[object MachinationsNode]";
							break;
						case "[object Source]":
						case "[object Trader]":
						case "[object Converter]":
							if (_elements[i].element is MachinationsConnection) c = "multi";
							else if (_elements[i].element is TextLabel) c = "multi";
							else if ((_elements[i].element is EndCondition)) c = "multi";
							else if (!(_elements[i].element is Source)) c = "[object MachinationsNode]";
							break;
						case "[object ResourceConnection]":
						case "[object StateConnection]":
							if (_elements[i].element is MachinationsNode) c = "multi";
							break;
						case "[object Gate]":
							if (_elements[i].element is MachinationsConnection) c = "multi";
							else if ((_elements[i].element is EndCondition)) c = "multi";
							else if (_elements[i].element is TextLabel) c = "multi";
							else if (!(_elements[i].element is Gate)) c = "[object MachinationsNode]";
							break;
						case "[object Chart]":	
							if (_elements[i].element is Chart) c = "[object Chart]";
							else if (_elements[i].element is TextLabel) c = "[object TextLabel]";
							else c = "multi";
							break;
						case "[object GroupBox]":	
						case "[object TextLabel]":	
							if (!(_elements[i].element is TextLabel)) c = "multi";
							break;
						case "[object Drain]":	
						case "[object MachinationsNode]":
							if ((_elements[i].element is EndCondition)) c = "multi";
							else if (_elements[i].element is MachinationsConnection) c = "multi";
							break;
						case "[object Register]":
							if (!(_elements[i].element is Register)) c = "multi";
							break;
						case "[object Delay]":
							if (!(_elements[i].element is Delay)) c = "multi";
							break;
						case "[object EndCondition]":
							if (!(_elements[i].element is EndCondition)) c = "multi";
							break;
						case "[object ArtificialPlayer]":
							if (_elements[i].element is MachinationsConnection) c = "multi";
							else if (_elements[i].element is TextLabel) c = "multi";
							else if (_elements[i].element is ArtificialPlayer) c = "[object ArtificialPlayer]";
							else if (_elements[i].element is MachinationsNode) c = "[object MachinationsNode]";
							break;
							
					}
				}
			}
			switch (c) {
				default:
				case "multi":
					activePanel = editElement;
					break;
				case "[object ResourceConnection]":
				case "[object StateConnection]":
					activePanel = editConnection;
					break;
				case "[object Gate]":
					activePanel = editGate;
					break;
				case "[object Chart]":
					activePanel = editChart;
					break;
				case "[object GroupBox]":
				case "[object TextLabel]":
					activePanel = editLabel;
					break;
				case "[object Register]":
					activePanel = editRegister;
					break;
				case "[object Delay]":
					activePanel = editDelay;
					break;
				case "[object EndCondition]":
					activePanel = editEnd;
					break;
				case "[object Drain]":
				case "[object MachinationsNode]":
					activePanel = editNode;
					break;
				case "[object ArtificialPlayer]":
					activePanel = editAP;
					break;
				case "[object Source]":
				case "[object Trader]":
				case "[object Converter]":
					activePanel = editSource;
					break;
				case "[object Pool]":
					activePanel = editPool;
					break;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if (addingConnection) {
				addConnectionPoint(e);
			} else {
				switch (tool) {
					default:
					case "Select":
						doSelect(e);
						break;
					case "Pool":
					case "Gate":
					case "Source":
					case "Drain":
					case "Converter":
					case "Trader":
					case "Delay":
					case "Register":
					case "EndCondition":
					case "ArtificialPlayer":
					case "TextL":
					case "GroupBox":
					case "Chart":
						addNode(e);
						break;
					case "State Connection":
					case "Resource Connection":
						addConnection(e);
						break;
				}
			}
		}
		
		private function addConnection(e:MouseEvent):void {
			var element:MachinationsViewElement = getElementAt(e.localX, e.localY);
			if (element && element.selected && element.element is GraphConnection) {
				//selecting previously created connection
				activateSelect();
				doSelect(e);
				return;
			}
			deselectAll();
			var sn:Point = drawPanel.trySnap(e.localX, e.localY);
			var connection:MachinationsConnection = graph.addConnection(tool, new Vector3D(e.localX+sn.x, e.localY+sn.y), new Vector3D(e.localX, e.localY)) as MachinationsConnection;
			_elements[_elements.length - 1].selected = true;
		
			if (connection && element) {
				connection.start = element.element;
				if (element.element is MachinationsNode) {
					connection.color = (element.element as MachinationsNode).color;
					connection.thickness = (element.element as MachinationsNode).thickness;
				} else if (element.element is MachinationsConnection) {
					connection.color = (element.element as MachinationsConnection).color;
					connection.thickness = (element.element as MachinationsConnection).thickness;
				} 
			} else if (connection && lastElement is MachinationsNode) {
				connection.color = (lastElement as MachinationsNode).color;
				connection.thickness = (lastElement as MachinationsNode).thickness;
			}else if (connection && lastElement is MachinationsConnection) {
				connection.color = (lastElement as MachinationsConnection).color;
				connection.thickness = (lastElement as MachinationsConnection).thickness;
			}
			
			lastSelected = _elements[_elements.length - 1];
			
			addingConnection = true;
		}
		
		private function addConnectionPoint(e:MouseEvent):void {
			addUndo();
			var connection:GraphConnection = (lastSelected.element as GraphConnection);
			var element:MachinationsViewElement = getElementAt(e.localX, e.localY, lastSelected);
			if (element) {
				connection.end = element.element;
				setDefaultModifier(connection as MachinationsConnection);
				addingConnection = false;
			} else {
				//determine distance to last point
				var dx:Number = e.localX - connection.points[connection.points.length - 2].x;
				var dy:Number = e.localY - connection.points[connection.points.length - 2].y;
				var ds:Number = dx * dx + dy * dy;
				if (ds < MachinationsViewElement.CONTROL_SIZE * MachinationsViewElement.CONTROL_SIZE) {
					connection.points.splice(connection.points.length-1, 1);
					connection.calculateEndPosition();
					addingConnection = false;
					setDefaultModifier(connection as MachinationsConnection);
				} else {
					var sn:Point = drawPanel.trySnap(e.localX, e.localY);
					connection.points[connection.points.length - 1].x = e.localX + sn.x;
					connection.points[connection.points.length - 1].y = e.localY + sn.y;
					connection.points.push(new Vector3D(e.localX, e.localY));
					connection.calculateEndPosition();
				}
			}
		}
		
		private function setDefaultModifier(connection:MachinationsConnection):void
		{
			if (connection is StateConnection) {
				if (connection.end is Pool || connection.end is MachinationsConnection) {
					connection.label.text = "+1";
					editConnection.element = connection;
					connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
					if (connection.end is MachinationsConnection && (connection.end as MachinationsConnection).label.getRealText() == "") {
						(connection.end as MachinationsConnection).label.text = "1";
					}
				} else if (connection.end is Register) {
					var c:int = 97;
					var l:int = connection.end.inputs.length;
					while (c < 97+26 && l>0) {
						var found:Boolean = false;
						for (var i:int = 0; i < l; i++) {
							if ((connection.end.inputs[i] is StateConnection) && (connection.end.inputs[i] as StateConnection).label.text.charCodeAt(0) == c) {
								found = true;
								break;
							}
						}
						if (!found) break;
						c++;
					}
					connection.label.text = String.fromCharCode(c);
					editConnection.element = connection;
					connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
					
				} else if (connection.end is TextLabel) {
					
				} else if (connection.end is MachinationsNode) {
					if (connection.start is Pool || connection.start is Register) {
						connection.label.text = ">0";
					} else if (connection.start is Gate) {
						connection.label.text = "";
					} else {
						connection.label.text = "*";
					}
					editConnection.element = connection;
					connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
				}
			}
		}
		
		private function addNode(e:MouseEvent):void {
			addUndo();
			deselectAll();
			var element:MachinationsViewElement = getElementAt(e.localX, e.localY);
			if (element) {
				//select an element instead
				activateSelect();
				doSelect(e);
				return;
			}
			
			var sn:Point = drawPanel.trySnap(e.localX, e.localY);
			
			var s:String = tool;
			if (s == "TextL") s = "TextLabel"

			var node:MachinationsNode = graph.addNode(s, new Vector3D(e.localX+sn.x, e.localY+sn.y)) as MachinationsNode;
			if (node && lastElement is MachinationsNode) {
				node.color = (lastElement as MachinationsNode).color;
				node.thickness = (lastElement as MachinationsNode).thickness;
			}
			if (node && lastElement is MachinationsConnection) {
				node.color = (lastElement as MachinationsConnection).color;
				node.thickness = (lastElement as MachinationsConnection).thickness;
			}
			
			_elements[_elements.length - 1].selected = true;
			lastSelected = _elements[_elements.length - 1];
			
		}
		
		private function activateSelect():void
		{
			if (tool == "Select") return;
			tool = "Select";
			_selectTool.selected = true;
		}
		
		private function doSelect(e:MouseEvent):void {
			var mx:Number = e.localX;
			var my:Number = e.localY;
			
			mouseDownX = mx;
			mouseDownY = my;
			var element:MachinationsViewElement = getElementAt(mx, my);
			if (lastSelected && lastSelected.unique && lastSelected != element) lastSelected.unique = false;
			if (!e.shiftKey && !(element && element.selected)) {
				deselectAll();
			}
			if (element != null) {
				if (element.element is Chart) {
					if (clickChartButtons(element.element as Chart, e)) return;
				}
				
				element.selected = true;
				if (selectedCount == 1) {
					element.unique = true;
					element.control = element.pointOnControl(mx, my);
				}
				dragging = false;
				if (element.control < 0) {
					addEventListener(MouseEvent.MOUSE_MOVE, dragElements);
					addEventListener(MouseEvent.MOUSE_UP, endDragElements);
				} else {
					addEventListener(MouseEvent.MOUSE_MOVE, dragControl);
					addEventListener(MouseEvent.MOUSE_UP, endDragControl);
				}
			} else if (e.target is PhantomDrawPanel) {
				addEventListener(MouseEvent.MOUSE_MOVE, multiSelect);
				addEventListener(MouseEvent.MOUSE_UP, endMultiSelect);
				if (multiSelector == null) {
					multiSelector = new MultiSelector();
				}
				multiSelector.setPosition(drawPanel, e.localX, e.localY);
				
			}
			
			lastSelected = element;
			
			if (lastSelected) {
				pushToTop(_lastSelected);
				graph.pushToTop(_lastSelected.element);
				drawPanel.setChildIndex(_lastSelected, drawPanel.numChildren - 1);
			}
		}
		
		private function multiSelect(e:MouseEvent):void {
			multiSelector.setSize(e.localX - multiSelector.x, e.localY - multiSelector.y);
		}
		
		private function endMultiSelect(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, multiSelect);
			removeEventListener(MouseEvent.MOUSE_UP, endMultiSelect);
			multiSelector.parent.removeChild(multiSelector);
			if (!e.shiftKey) deselectAll();
			var r:Rectangle = multiSelector.getRectangle();
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				if (_elements[i].elementInRectangle(r)) {
					_elements[i].selected = true;
					lastSelected = _elements[i];
				}
			}
		}
		
		
		private function dragControl(e:MouseEvent):void 
		{
			var mx:Number = e.localX;
			var my:Number = e.localY;
			
			var dx:int = mx - mouseDownX;
			var dy:int = my - mouseDownY;
			if (dragging || dx * dx + dy * dy > 25) {
				if (!dragging) {
					dragging = true;
					addUndo();
				}
				lastSelected.moveControl(dx, dy, e.localX, e.localY);
				mouseDownX += dx;
				mouseDownY += dy;
			}
			
		}
		
		private function endDragControl(e:MouseEvent):void 
		{
			var mx:Number = e.localX;
			var my:Number = e.localY;
			if (dragging) {
				var d:Point = drawPanel.trySnap(mx, my);
				if (d.x != 0 && d.y != 0) {
					lastSelected.moveControl(d.x, d.y, mx+d.x, my+d.y);
					lastSelected.draw();
				}
			}

			
			var connection:MachinationsConnection = (lastSelected.element as MachinationsConnection);
			if (connection) {
				if (lastSelected.control == 0 && dragging) {
					if (hover) connection.start = hover.element;
					else connection.start = null;
				}
				if (lastSelected.control == connection.points.length - 1 && dragging) {
					if (hover) connection.end = hover.element;
					else connection.end = null;
				}
				lastSelected.draw();
			}
			removeEventListener(MouseEvent.MOUSE_MOVE, dragControl);
			removeEventListener(MouseEvent.MOUSE_UP, endDragControl);
		}
		
		private function deselectAll():void
		{
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				if (_elements[i].selected) {
					_elements[i].selected = false;
					if (_elements[i].unique) _elements[i].unique = false;
				}
			}
			
		}
		
		private function endDragElements(e:MouseEvent):void 
		{
			//snap to grid
			if (lastSelected.element is MachinationsNode && dragging) {
				var d:Point = lastSelected.getSnap();
				if (d.x != 0 && d.y != 0) {
					var l:int = _elements.length;
					for (var i:int = 0; i < l; i++) {
						if (_elements[i].selected) _elements[i].moveBy(d.x, d.y);
					}
					
				}
			}
			removeEventListener(MouseEvent.MOUSE_MOVE, dragElements);
			removeEventListener(MouseEvent.MOUSE_UP, endDragElements);
		}
		
		private function dragElements(e:MouseEvent):void 
		{
			var mx:Number = e.localX;
			var my:Number = e.localY;
			var dx:int = mx - mouseDownX;
			var dy:int = my - mouseDownY;
			if (dragging || dx * dx + dy * dy > 25) {
				if (!dragging) {
					dragging = true;
					addUndo();
				}
				
				var l:int = _elements.length;
				for (var i:int = 0; i < l; i++) {
					if (_elements[i].selected) _elements[i].moveBy(dx, dy);
				}
				mouseDownX += dx;
				mouseDownY += dy;
			}
			
		}
		
		private function deleteSelected():void 
		{
			if (lastSelected && lastSelected.unique && lastSelected.control >= 0) {
				addUndo();
				lastSelected.deleteControl();
			} else {
				addUndo();
				var l:int = _elements.length;
				for (var i:int = l - 1; i >= 0; i--) {
					if (_elements[i].selected) _elements[i].element.dispose();
				}
				activateSelect();
			}
			if (addingConnection) addingConnection = false;
		}
		
		override public function removeElement(element:MachinationsViewElement):void 
		{
			if (element == lastSelected) lastSelected = null;
			if (element == _hover) _hover = null;
			super.removeElement(element);
		}
		
		public function generateSelectionXML():XML {
			//generate the ids
			var id:int = 0;
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				if (_elements[i].selected) {
					_elements[i].element.id = id;
					id++;
				} else {
					_elements[i].element.id = -1;
				}
			}
			
			//generate xml
			var xml:XML = <graph/>;
			
			xml.@version = MachinationsGrammar.version;
			xml.@name = graph.name;
			xml.@author = graph.author;
			xml.@interval = graph.fireInterval;
			xml.@timeMode = graph.timeMode;
			xml.@distributionMode = graph.distributionMode;
			xml.@speed = graph.resourceSpeed;
			xml.@actions = graph.actionsPerTurn;
			xml.@dice = graph.dice;
			xml.@skill = graph.skill;
			xml.@strategy = graph.strategy;
			xml.@multiplayer = graph.multiplayer;
			xml.@width = graph.width;
			xml.@height = graph.height;
			xml.@numberOfRuns = graph.numberOfRuns;
			xml.@visibleRuns = graph.visibleRuns;
			xml.@colorCoding = graph.colorCoding;
			
			for (i = 0; i < l; i++) {
				if (_elements[i].selected) {
					xml.appendChild(_elements[i].element.generateXML());
				}
			}
			
			return xml;
		}
		
		public function setValue(attribute:String, string:String, value:Number):void
		{
			var l:int = _elements.length;
			for (var i:int = 0; i < l; i++) {
				if (_elements[i].selected) {
					switch (attribute) {
						case "color":
							if (_elements[i].element is MachinationsConnection) (_elements[i].element as MachinationsConnection).color = StringUtil.toColor(string);
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).color = StringUtil.toColor(string);
							break;
						case "thickness":
							if (_elements[i].element is MachinationsConnection) (_elements[i].element as MachinationsConnection).thickness = value;
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).thickness = value;
							break;
						case "label":
							if (_elements[i].element is MachinationsConnection) (_elements[i].element as MachinationsConnection).label.text = string;
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).caption = string;
							break;
						case "min":
							if (_elements[i].element is MachinationsConnection) (_elements[i].element as MachinationsConnection).label.min = Math.max(value, -Label.LIMIT);
							if (_elements[i].element is Register) (_elements[i].element as Register).minValue = Math.max(value, -Register.LIMIT);
							break
						case "max":
							if (_elements[i].element is MachinationsConnection) (_elements[i].element as MachinationsConnection).label.max = Math.min(value, Label.LIMIT);
							if (_elements[i].element is Register) (_elements[i].element as Register).maxValue = Math.min(value, Register.LIMIT);
							break
						case "start":
							if (_elements[i].element is Register) (_elements[i].element as Register).startValue = Math.max(Math.min(value, Register.LIMIT), -Register.LIMIT);
							break
						case "step":
							if (_elements[i].element is Register) (_elements[i].element as Register).valueStep = Math.max(Math.min(value, Register.LIMIT), -Register.LIMIT);
							break
						case "pullMode":
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).pullMode = string;
							break;
						case "activationMode":
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).activationMode = string;
							break;
						case "actions":
							if (_elements[i].element is MachinationsNode) (_elements[i].element as MachinationsNode).actions = value;
							break;
						case "resourceColor":
							if (_elements[i].element is Source) (_elements[i].element as Source).resourceColor = StringUtil.toColor(string);
							break;
						case "startingResources":
							if (_elements[i].element is Pool) (_elements[i].element as Pool).startingResources = value;
							break;
						case "capacity":
							if (_elements[i].element is Pool) (_elements[i].element as Pool).capacity = value;
							break;
						case "displayCapacity":
							if (_elements[i].element is Pool) (_elements[i].element as Pool).displayCapacity = value;
							break;
						case "gateType":
							if (_elements[i].element is Gate) (_elements[i].element as Gate).gateType = string;
							break;
						case "defaultScaleX":
							if (_elements[i].element is Chart) (_elements[i].element as Chart).defaultScaleX = value;
							break;
						case "defaultScaleY":
							if (_elements[i].element is Chart) (_elements[i].element as Chart).defaultScaleY = value;
							break;
						case "delayType":
							if (_elements[i].element is Delay) (_elements[i].element as Delay).delayType = string;
							break;
						case "actionsPerTurn":
							if (_elements[i].element is ArtificialPlayer) (_elements[i].element as ArtificialPlayer).actionsPerTurn = value;
							break;
						case "script":
							if (_elements[i].element is ArtificialPlayer) (_elements[i].element as ArtificialPlayer).script = string;
							break;
					}
					_elements[i].draw();
				}
			}
		}
		
		override public function setInteraction(enable:Boolean):void 
		{
			//drawPanel.mouseChildren = !enable;
			super.setInteraction(enable);
			if (enable) {
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownView);
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveView);
			} else {
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownView);
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveView);
			}
			
			
			if (enable) {
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				editGraph.enabled = true;
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				editGraph.enabled = false;
			}
		}
		
		
		override public function get graph():MachinationsGraph { return super.graph; }
		
		override public function set graph(value:MachinationsGraph):void 
		{
			super.graph = value;
			if (editGraph) editGraph.graph = value;
			editVisibleRuns.value = graph.visibleRuns;
			editNumberOfRuns.value = graph.numberOfRuns;
		}
		
		override protected function zoom(sender:PhantomControl):void
		{
			if (!_zoomed) {
				var s:Number = Math.min(drawContainer.controlWidth / drawPanel.controlWidth, drawContainer.controlHeight / drawPanel.controlHeight);
				drawPanel.scaleX = s;
				drawPanel.scaleY = s;
				_zoomed = true;
			} else {
				drawPanel.scaleX = 1;
				drawPanel.scaleY = 1;
				_zoomed = false;
			}
			drawContainer.scrollTo(0, 0);
			drawContainer.checkSize();
			drawPanel.redraw();
		}		
		
		override public function onLoadGraph():void 
		{
			super.onLoadGraph();
			fileIOSVG.fileName = "";
		}
		
	}

}