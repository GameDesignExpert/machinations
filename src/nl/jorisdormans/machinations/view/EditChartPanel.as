package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.Chart;
	import nl.jorisdormans.machinations.model.Converter;
	import nl.jorisdormans.machinations.model.Drain;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.machinations.model.Trader;
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
	public class EditChartPanel extends EditLabelPanel
	{
		private var defaultScaleX:PhantomEditNumberBox;
		private var defaultScaleY:PhantomEditNumberBox;
		
		
		public function EditChartPanel(view:MachinationsEditView, parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true)
		{
			super(view, parent, x, y, width, height, showing, enabled);

			new PhantomLabel("Scale X", this, labelX, controlY);
			defaultScaleX = new PhantomEditNumberBox(0, 0, 10, this, controlX, controlY, controlNW); 
			defaultScaleX.min = 0;
			defaultScaleX.onChange = changeValue;
			controlY += 28;
			new PhantomLabel("Scale Y", this, labelX, controlY);
			defaultScaleY = new PhantomEditNumberBox(0, 0, 12, this, controlX, controlY, controlNW); 
			defaultScaleY.onChange = changeValue;
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is Chart) {
				defaultScaleX.value = (value as Chart).defaultScaleX;
				defaultScaleY.value = (value as Chart).defaultScaleY;
			}
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == defaultScaleX) {
				view.setValue("defaultScaleX", null, defaultScaleX.value);
			} else if (sender == defaultScaleY) {
				view.setValue("defaultScaleY", null, defaultScaleY.value);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
	}

}