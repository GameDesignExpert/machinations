package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.Label;
	import nl.jorisdormans.machinations.model.Register;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.phantomGUI.PhantomCheckButton;
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
	public class EditRegisterPanel extends EditElementPanel
	{
		private var formulaLabel:PhantomLabel;
		private var label:PhantomEditBox;
		private var start:PhantomEditNumberBox;
		private var step:PhantomEditNumberBox;
		private var startLabel:PhantomLabel;
		private var stepLabel:PhantomLabel;
		private var interactive:PhantomCheckButton;
		private var min:PhantomEditNumberBox;
		private var max:PhantomEditNumberBox;
		
		
		public function EditRegisterPanel(view:MachinationsEditView, parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true)
		{
			super(view, parent, x, y, width, height, showing, enabled);
			
			formulaLabel = new PhantomLabel("Formula", this, labelX, controlY);
			label = new PhantomEditBox("Label", this, controlX, controlY, controlW); 
			label.onChange = changeValue;
			controlY += 28;
			
			new PhantomLabel("Min. Value", this, labelX, controlY);
			min = new PhantomEditNumberBox( -Register.LIMIT, 0, 100, this, controlX, controlY, controlNW); 
			min.min = -Label.LIMIT;
			min.max = Label.LIMIT;
			min.onChange = changeValue;
			controlY += 28;
			
			new PhantomLabel("Max. Value", this, labelX, controlY);
			max = new PhantomEditNumberBox(Register.LIMIT, 0, 100, this, controlX, controlY, controlNW); 
			max.onChange = changeValue;
			max.min = -Label.LIMIT;
			max.max = Label.LIMIT;
			controlY += 28;
			
			interactive = new PhantomCheckButton("Interactive", changeValue, this, controlX, controlY, controlW, 24);
			controlY += 28;
			
			startLabel = new PhantomLabel("Starting Value", this, labelX, controlY);
			start = new PhantomEditNumberBox( 0, 0, 1, this, controlX, controlY, controlNW); 
			start.min = -Label.LIMIT;
			start.max = Label.LIMIT;
			start.onChange = changeValue;
			controlY += 28;
			
			stepLabel = new PhantomLabel("Step", this, labelX, controlY);
			step = new PhantomEditNumberBox( 1, 0, 1, this, controlX, controlY, controlNW); 
			step.min = -Label.LIMIT;
			step.max = Label.LIMIT;
			step.onChange = changeValue;
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is Register) {
				label.caption = (value as Register).caption;
				min.value = (value as Register).minValue;
				max.value = (value as Register).maxValue;
				start.value = (value as Register).startValue;
				step.value = (value as Register).valueStep;
				interactive.checked = (value as Register).activationMode == MachinationsNode.MODE_INTERACTIVE;
				start.enabled = interactive.checked;
				step.enabled = interactive.checked;
				startLabel.enabled = interactive.checked;
				stepLabel.enabled = interactive.checked;
				if ((value as Register).activationMode == MachinationsNode.MODE_INTERACTIVE) {
					formulaLabel.caption = "Label";
				} else {
					formulaLabel.caption = "Formula";
				}
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == label) {
				view.setValue("label", label.caption, 0);
			} else if (sender == min) {
				view.setValue("min", "", min.value);
			} else if (sender == max) {
				view.setValue("max", "", max.value);
			} else if (sender == start) {
				view.setValue("start", "", start.value);
			} else if (sender == step) {
				view.setValue("step", "", step.value);
			} else if (sender == interactive) {
				if (interactive.checked) {
					view.setValue("activationMode", MachinationsNode.MODE_INTERACTIVE, 0);
					formulaLabel.caption = "Label";
				} else {
					view.setValue("activationMode", MachinationsNode.MODE_PASSIVE, 0);
					formulaLabel.caption = "Formula";
				}
				start.enabled = interactive.checked;
				step.enabled = interactive.checked;
				startLabel.enabled = interactive.checked;
				stepLabel.enabled = interactive.checked;
			} else {
				super.changeValue(sender);
			}
		}
		
	}

}