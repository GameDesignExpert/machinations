package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.phantomGUI.PhantomButton;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomEditBox;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.phantomGUI.PhantomToolButton;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditGatePanel extends EditNodePanel
	{
		private var deterministic:PhantomToolButton;
		private var dice:PhantomToolButton;
		private var skill:PhantomToolButton;
		private var multiplayer:PhantomToolButton;
		private var strategy:PhantomToolButton;
		
		public function EditGatePanel(view:MachinationsEditView, parent:DisplayObjectContainer, stage:Stage, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true) 
		{
			super(view, parent, stage, x, y, width, height, showing, enabled);
			
			new PhantomLabel("Type", this, labelX, controlY);
			
			deterministic = new PhantomToolButton("Deterministic", changeValue, this, controlX, controlY, 24, 24, false);
			deterministic.drawImage = MachinationsDraw.drawGateGlyph;
			dice = new PhantomToolButton("Dice", changeValue, this, controlX + 28, controlY, 24, 24, false);
			dice.drawImage = MachinationsDraw.drawDice;
			skill = new PhantomToolButton("Skill", changeValue, this, controlX + 28 * 2, controlY, 24, 24, false);
			skill.drawImage = MachinationsDraw.drawSkill;
			controlY += 28;
			multiplayer = new PhantomToolButton("Multiplayer", changeValue, this, controlX, controlY, 24, 24, false);
			multiplayer.drawImage = MachinationsDraw.drawMultiplayer;
			strategy = new PhantomToolButton("Strategy", changeValue, this, controlX + 28 * 1, controlY, 24, 24, false);
			strategy.drawImage = MachinationsDraw.drawStrategy;
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is Gate) {
				deterministic.selected = ((value as Gate).gateType == Gate.GATE_DETERMINISTIC);
				dice.selected = ((value as Gate).gateType == Gate.GATE_DICE);
				skill.selected = ((value as Gate).gateType == Gate.GATE_SKILL);
				strategy.selected = ((value as Gate).gateType == Gate.GATE_STRATEGY);
				multiplayer.selected = ((value as Gate).gateType == Gate.GATE_MULTIPLAYER);
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == deterministic) {
				view.setValue("gateType", Gate.GATE_DETERMINISTIC, 0);
			} else if (sender == dice) {
				view.setValue("gateType", Gate.GATE_DICE, 0);
			} else if (sender == skill) {
				view.setValue("gateType", Gate.GATE_SKILL, 0);
			} else if (sender == strategy) {
				view.setValue("gateType", Gate.GATE_STRATEGY, 0);
			} else if (sender == multiplayer) {
				view.setValue("gateType", Gate.GATE_MULTIPLAYER, 0);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
		
		
		
		
	}

}