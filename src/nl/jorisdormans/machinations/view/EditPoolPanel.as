package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomEditNumberBox;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditPoolPanel extends EditSourcePanel
	{
		private var number:PhantomEditNumberBox;
		private var max:PhantomEditNumberBox;
		private var tokenLimit:PhantomEditNumberBox;
		
		public function EditPoolPanel(view:MachinationsEditView, parent:DisplayObjectContainer, stage:Stage, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true) 
		{
			super(view, parent, stage, x, y, width, height, showing, enabled);
			
			new PhantomLabel("Number", this, labelX, controlY);
			number = new PhantomEditNumberBox(0, 0, 1, this, controlX, controlY, controlNW); 
			number.min = 0;
			number.max = 9999;
			number.onChange = changeValue;
			controlY += 28;
			new PhantomLabel("Capacity", this, labelX, controlY);
			max = new PhantomEditNumberBox(0, 0, 1, this, controlX, controlY, controlNW); 
			max.min = -1;
			max.max = 9999;
			max.onChange = changeValue;
			controlY += 28;
			new PhantomLabel("Display Cap.", this, labelX, controlY);
			tokenLimit = new PhantomEditNumberBox(0, 0, 5, this, controlX, controlY, controlNW); 
			tokenLimit.min = -1;
			tokenLimit.max = 25;
			tokenLimit.onChange = changeValue;
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is Pool) {
				number.value = (value as Pool).startingResources;
				max.value = (value as Pool).capacity;
				tokenLimit.value = (value as Pool).displayCapacity;
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == number) {
				view.setValue("startingResources", null, number.value);
			} else if (sender == max) {
				view.setValue("capacity", null, max.value);
			} else if (sender == tokenLimit) {
				view.setValue("displayCapacity", null, tokenLimit.value);
			} else {
				super.changeValue(sender);
			}
		}			
		
	}

}