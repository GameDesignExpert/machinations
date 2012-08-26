package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.Label;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.StateConnection;
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
	public class EditConnectionPanel extends EditElementPanel
	{
		private var label:PhantomEditBox;
		private var min:PhantomEditNumberBox;
		private var max:PhantomEditNumberBox;
		
		
		public function EditConnectionPanel(view:MachinationsEditView, parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true)
		{
			super(view, parent, x, y, width, height, showing, enabled);
			
			new PhantomLabel("Label", this, labelX, controlY);
			label = new PhantomEditBox("Label", this, controlX, controlY, controlW); 
			label.onChange = changeValue;
			controlY += 28;
			
			new PhantomLabel("Min. Value", this, labelX, controlY);
			min = new PhantomEditNumberBox( -Label.LIMIT, 2, 100, this, controlX, controlY, controlNW); 
			min.min = -Label.LIMIT;
			min.max = Label.LIMIT;
			min.onChange = changeValue;
			controlY += 28;
			
			new PhantomLabel("Max. Value", this, labelX, controlY);
			max = new PhantomEditNumberBox(Label.LIMIT, 2, 100, this, controlX, controlY, controlNW); 
			max.onChange = changeValue;
			max.min = -Label.LIMIT;
			max.max = Label.LIMIT;
			controlY += 28;
			
			//new PhantomLabel("Press INSERT to add control points", this, labelX, controlY, 180);
			new PhantomLabel("Press W to add way points", this, labelX, controlY, 180);
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is MachinationsConnection) {
				label.caption = (value as MachinationsConnection).label.getRealText();
				min.value = (value as MachinationsConnection).label.min;
				max.value = (value as MachinationsConnection).label.max;
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
			} else {
				super.changeValue(sender);
			}
		}
		
	}

}