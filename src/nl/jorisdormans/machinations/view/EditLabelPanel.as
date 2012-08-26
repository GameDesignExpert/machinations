package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
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
	public class EditLabelPanel extends EditElementPanel
	{
		private var label:PhantomEditBox;
		
		
		public function EditLabelPanel(view:MachinationsEditView, parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true)
		{
			super(view, parent, x, y, width, height, showing, enabled, true);

			new PhantomLabel("Label", this, labelX, controlY);
			label = new PhantomEditBox("Label", this, controlX, controlY, controlW); 
			label.onChange = changeValue;
			controlY += 28;

		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is MachinationsNode) label.caption = (value as MachinationsNode).caption;
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == label) {
				view.setValue("label", label.caption, 0);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
	}

}