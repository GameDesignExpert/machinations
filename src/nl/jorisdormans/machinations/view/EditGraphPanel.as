package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.Converter;
	import nl.jorisdormans.machinations.model.Drain;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.TextLabel;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.machinations.model.Trader;
	import nl.jorisdormans.phantomGUI.PhantomCheckButton;
	import nl.jorisdormans.phantomGUI.PhantomComboBox;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomEditBox;
	import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.phantomGUI.PhantomPanel;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditGraphPanel extends PhantomPanel
	{
		private var _graph:MachinationsGraph;
		private var graphName:PhantomEditBox;
		private var author:PhantomEditBox;
		private var actions:PhantomEditNumberBox;
		//private var speed:PhantomEditNumberBox;
		private var dice:PhantomEditBox;
		private var skill:PhantomEditBox;
		private var multiplayer:PhantomEditBox;
		private var strategy:PhantomEditBox;
		private var editWidth:PhantomEditNumberBox;
		private var editHeight:PhantomEditNumberBox;
		private var interval:PhantomEditNumberBox;
		private var intervalLabel:PhantomLabel;
		private var actionsLabel:PhantomLabel;
		private var timeMode:PhantomComboBox;
		private var distributionMode:PhantomComboBox;
		private var colorCoded:PhantomCheckButton;
		protected var labelX:Number;
		protected var controlX:Number;
		protected var controlY:Number;
		protected var controlW:Number;
		protected var controlNW:Number;
		
		private var view:MachinationsEditView;
		
		
		public function EditGraphPanel(parent:DisplayObjectContainer, stage:Stage, view:MachinationsEditView, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true)
		{
			super(parent, x, y, width, height, showing, enabled);
			this.view = view;
			labelX = 4;
			controlX = width*0.4;
			controlY = 2;
			controlW = width -controlX - 4;
			controlNW = 60;
			var ch:int = 27;
			
			new PhantomLabel("*Machinations Diagram", this, labelX, controlY);
			controlY += 24;
			new PhantomLabel("Name", this, labelX, controlY);
			graphName = new PhantomEditBox("Name", this, controlX, controlY, controlW); 
			graphName.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Author", this, labelX, controlY);
			author = new PhantomEditBox("Author", this, controlX, controlY, controlW); 
			author.onChange = changeValue;
			controlY += ch;
			
			new PhantomLabel("Time Mode", this, labelX, controlY);
			timeMode = new PhantomComboBox("timeMode", this, stage, controlX, controlY, controlW);
			timeMode.addOption(MachinationsGraph.TIME_MODE_ASYNCHRONOUS);
			timeMode.addOption(MachinationsGraph.TIME_MODE_SYNCHRONOUS);
			timeMode.addOption(MachinationsGraph.TIME_MODE_TURN_BASED);
			timeMode.onChange = changeValue;
			controlY += ch;
			
			
			
			intervalLabel = new PhantomLabel("Interval", this, labelX, controlY);
			interval = new PhantomEditNumberBox(100, 1, 0.1, this, controlX, controlY, controlNW); 
			interval.min = 0.1;
			interval.onChange = changeValue;
			//controlY += ch;
			actionsLabel = new PhantomLabel("Actions/Turn", this, labelX, controlY, 100);
			actionsLabel.visible = false;
			actions = new PhantomEditNumberBox(1, 0, 1, this, controlX, controlY, controlNW); 
			actions.min = 1;
			actions.onChange = changeValue;
			actions.visible = false;
			controlY += ch;
			
			new PhantomLabel("Distribution", this, labelX, controlY);
			distributionMode = new PhantomComboBox("distribution", this, stage, controlX, controlY, controlW);
			distributionMode.addOption(MachinationsGraph.DISTRIBUTION_MODE_FIXED_SPEED);
			distributionMode.addOption(MachinationsGraph.DISTRIBUTION_MODE_INSTANTANEOUS);
			distributionMode.onChange = changeValue;
			controlY += ch;

			new PhantomLabel("Color Coding", this, labelX, controlY);
			colorCoded = new PhantomCheckButton("Color Coded", changeValue, this, controlX, controlY, controlW, 24); 
			controlY += ch;
			
			/*new PhantomLabel("Res. Speed", this, labelX, controlY, 100);
			speed = new PhantomEditNumberBox(100, 0, 100, this, controlX, controlY, controlNW); 
			speed.min = 0;
			speed.onChange = changeValue;
			controlY += ch;*/
			
			new PhantomLabel("Dice", this, labelX, controlY);
			dice = new PhantomEditBox("Dice", this, controlX, controlY, controlW); 
			dice.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Skill", this, labelX, controlY);
			skill = new PhantomEditBox("Skill", this, controlX, controlY, controlW); 
			skill.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Multiplayer", this, labelX, controlY);
			multiplayer = new PhantomEditBox("Multiplayer", this, controlX, controlY, controlW); 
			multiplayer.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Strategy", this, labelX, controlY);
			strategy = new PhantomEditBox("Strategy", this, controlX, controlY, controlW); 
			strategy.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Width", this, labelX, controlY);
			editWidth = new PhantomEditNumberBox(100, 0, 100, this, controlX, controlY, controlNW); 
			editWidth.min = 0;
			editWidth.onChange = changeValue;
			controlY += ch;
			new PhantomLabel("Height", this, labelX, controlY);
			editHeight = new PhantomEditNumberBox(100, 0, 100, this, controlX, controlY, controlNW); 
			editHeight.min = 0;
			editHeight.onChange = changeValue;
			controlY += ch;
		}
		
		public function get graph():MachinationsGraph { return _graph; }
		
		public function set graph(value:MachinationsGraph):void 
		{
			_graph = value;
			if (_graph) {
				graphName.caption = _graph.name;
				author.caption = _graph.author;
				dice.caption = _graph.dice;
				skill.caption = _graph.skill;
				strategy.caption = _graph.strategy;
				multiplayer.caption = _graph.multiplayer;
				interval.value = _graph.fireInterval;
				timeMode.findOption(_graph.timeMode);
				distributionMode.findOption(_graph.distributionMode);
				//speed.value = _graph.resourceSpeed;
				actions.value = _graph.actionsPerTurn;
				editWidth.value = _graph.width;
				editHeight.value = _graph.height;
				colorCoded.checked = graph.colorCoding == 1;
				
				var vis:Boolean = (_graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED);
				actions.visible = vis;
				actionsLabel.visible = vis;
				interval.visible = !vis;
				intervalLabel.visible = !vis;
			}
			
		}
		
		protected function changeValue(sender:PhantomControl):void {
			if (_graph) {
				_graph.name = graphName.caption;
				_graph.author = author.caption;
				_graph.dice = dice.caption;
				_graph.skill = skill.caption;
				_graph.strategy = strategy.caption;
				_graph.multiplayer = multiplayer.caption;
				_graph.fireInterval = interval.value;
				_graph.timeMode = timeMode.caption;
				_graph.distributionMode = distributionMode.caption;
				_graph.actionsPerTurn = actions.value;
				_graph.width = editWidth.value;
				_graph.height = editHeight.value;
				_graph.colorCoding = colorCoded.checked?1:0;
				if (sender == editWidth || sender == editHeight) view.changeSize();
				
				var vis:Boolean = (_graph.timeMode == MachinationsGraph.TIME_MODE_TURN_BASED);
				actions.visible = vis;
				actionsLabel.visible = vis;
				interval.visible = !vis;
				intervalLabel.visible = !vis;
				
			}
		}
		
	}

}