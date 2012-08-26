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
	import nl.jorisdormans.phantomGUI.PhantomToolButton;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditNodePanel extends EditElementPanel
	{
		private var label:PhantomEditBox;
		//private var interactive:PhantomCheckButton;
		private var actions:PhantomEditNumberBox;
		private var actionsLabel:PhantomLabel;
		private var passive:PhantomToolButton;
		private var interactive:PhantomToolButton;
		private var automatic:PhantomToolButton;
		private var onStart:PhantomToolButton;
		//private var pmAny:PhantomToolButton;
		//private var pmAll:PhantomToolButton;
		private var pullMode:PhantomComboBox;
		private var pullModeLabel:PhantomLabel;
		
		
		
		public function EditNodePanel(view:MachinationsEditView, parent:DisplayObjectContainer, stage:Stage, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true, hasActivationMode:Boolean = true, hasActions:Boolean = true, hasPullMode:Boolean = true)
		{
			super(view, parent, x, y, width, height, showing, enabled);

			new PhantomLabel("Label", this, labelX, controlY);
			label = new PhantomEditBox("Label", this, controlX, controlY, controlW); 
			label.onChange = changeValue;
			controlY += 28;
			
			if (hasActivationMode) {
				new PhantomLabel("Activation", this, labelX, controlY);
				passive = new PhantomToolButton("Passive", changeValue, this, controlX, controlY, 24, 24, false);
				passive.drawImage = MachinationsDraw.drawPassiveGlyph;
				passive.group = 1;
				interactive = new PhantomToolButton("Interactive", changeValue, this, controlX + 28, controlY, 24, 24, false);
				interactive.drawImage = MachinationsDraw.drawInteractiveGlyph;
				interactive.group = 1;
				automatic = new PhantomToolButton("Automatic", changeValue, this, controlX + 28 * 2, controlY, 24, 24, false);
				automatic.drawImage = MachinationsDraw.drawAutomaticGlyph;
				automatic.group = 1;
				onStart = new PhantomToolButton("OnStart", changeValue, this, controlX + 28 * 3, controlY, 24, 24, false);
				onStart.drawImage = MachinationsDraw.drawOnStartGlyph;
				onStart.group = 1;
				//interactive = new PhantomCheckButton("Interactive", changeValue, this, controlX, controlY, controlW, 24); 
				controlY += 28;
				
			} 
			
			if (hasActions) {
				actionsLabel = new PhantomLabel("Actions", this, labelX, controlY);
				actions = new PhantomEditNumberBox(1, 0, 1, this, controlX, controlY, controlNW); 
				actions.min = 0;
				actions.onChange = changeValue;
				controlY += 28;
			} 
			
			if (hasPullMode) {
				pullModeLabel = new PhantomLabel("Pull Mode", this, labelX, controlY);
				pullMode = new PhantomComboBox("pullMode", this, stage, controlX, controlY, controlW);
				pullMode.addOption(MachinationsNode.PULL_MODE_PULL_ANY);
				pullMode.addOption(MachinationsNode.PULL_MODE_PULL_ALL);
				pullMode.addOption(MachinationsNode.PULL_MODE_PUSH_ANY);
				pullMode.addOption(MachinationsNode.PULL_MODE_PUSH_ALL);
				pullMode.onChange = changeValue;
				//pmAny = new PhantomToolButton("Any", changeValue, this, controlX + 28 * 0, controlY, 24+28, 24, false);
				//pmAny.group = 2;
				//pmAll = new PhantomToolButton("All", changeValue, this, controlX + 28 * 2, controlY, 24+28, 24, false);
				//pmAll.group = 2;
				controlY += 28;
				
			}
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is MachinationsNode) label.caption = (value as MachinationsNode).caption;
			if (value is MachinationsNode && passive) passive.selected = (value as MachinationsNode).activationMode == MachinationsNode.MODE_PASSIVE;
			if (value is MachinationsNode && interactive) interactive.selected = (value as MachinationsNode).activationMode == MachinationsNode.MODE_INTERACTIVE;
			if (value is MachinationsNode && automatic) automatic.selected = (value as MachinationsNode).activationMode == MachinationsNode.MODE_AUTOMATIC;
			if (value is MachinationsNode && onStart) onStart.selected = (value as MachinationsNode).activationMode == MachinationsNode.MODE_ONSTART;
			if (value is MachinationsNode && pullMode) pullMode.findOption((value as MachinationsNode).pullMode);
			//if (value is MachinationsNode && pmAny) pmAny.selected = (value as MachinationsNode).pullMode == MachinationsNode.PULL_MODE_ANY;
			//if (value is MachinationsNode && pmAll) pmAll.selected = (value as MachinationsNode).pullMode == MachinationsNode.PULL_MODE_ALL;
			if (value is MachinationsNode && actions) {
				actions.value = (value as MachinationsNode).actions;
				if (((value as MachinationsNode).graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED && interactive) {
					actions.enabled = interactive.selected;
					actionsLabel.enabled = interactive.selected;
				} else {
					actions.enabled = false;
					actionsLabel.enabled = false;
				}
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == label) {
				view.setValue("label", label.caption, 0);
			} else if (sender == pullMode) {
				view.setValue("pullMode", pullMode.caption, 0);
			} else if (sender == passive || sender == automatic || sender == interactive || sender == onStart) {
				view.setValue("activationMode", sender.caption.toLowerCase(), 0);
				if (actions) {
					if (((element as MachinationsNode).graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
						actions.enabled = (sender == interactive);
						actionsLabel.enabled = (sender == interactive);
					} else {
						actions.enabled = false;
						actionsLabel.enabled = false;
					}
				}
				
			} else if (sender == actions) {
				view.setValue("actions", null, actions.value);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
	}

}