package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.machinations.model.ArtificialPlayer;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.phantomGUI.PhantomCheckButton;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomEditBox;
	import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.phantomGUI.PhantomTextArea;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditAPPanel extends EditNodePanel
	{
		private var actionsPerTurn:PhantomEditNumberBox;
		private var actionsPerTurnLabel:PhantomLabel;
		private var script:PhantomTextArea;
		//private var active:PhantomCheckButton;
		
		public function EditAPPanel(view:MachinationsEditView, parent:DisplayObjectContainer, stage:Stage, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true) 
		{
			super(view, parent, stage, x, y, width, height, showing, enabled, true, false, false);
			
			//active = new PhantomCheckButton("Active", changeValue, this, controlX, controlY, controlW, 24);
			
			actionsPerTurnLabel = new PhantomLabel("Actions/turn", this, labelX, controlY);
			actionsPerTurn = new PhantomEditNumberBox(1, 0, 1, this, controlX, controlY, controlNW); 
			actionsPerTurn.min = 1;
			actionsPerTurn.onChange = changeValue;
			controlY += 18;

			new PhantomLabel("Script:", this, labelX, controlY);
			controlY += 20;
			script = new PhantomTextArea("script", this, labelX, controlY, controlWidth - 8, controlHeight - 4 - controlY);
			script.setFont("Courier New", 10);
			script.onChange = changeValue;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is ArtificialPlayer) {
				//active.checked = (value as ArtificialPlayer).active;
				actionsPerTurn.value = (value as ArtificialPlayer).actionsPerTurn;
				script.caption = (value as ArtificialPlayer).script;
				if ((value.graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
					actionsPerTurnLabel.enabled = true;
					actionsPerTurn.enabled = true;
				} else {
					actionsPerTurnLabel.enabled = false;
					actionsPerTurn.enabled = false;
				}
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == actionsPerTurn) {
				view.setValue("actionsPerTurn", null, actionsPerTurn.value);
			} else if (sender == script) {
				view.setValue("script", script.caption, 0);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
		
		
		
		
	}

}