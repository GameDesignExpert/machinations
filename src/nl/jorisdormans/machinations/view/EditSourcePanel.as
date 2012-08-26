package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.phantomGUI.PhantomControl;
	import nl.jorisdormans.phantomGUI.PhantomEditBox;
	import nl.jorisdormans.phantomGUI.PhantomLabel;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EditSourcePanel extends EditNodePanel
	{
		private var resourceColor:PhantomEditBox;
		
		public function EditSourcePanel(view:MachinationsEditView, parent:DisplayObjectContainer, stage:Stage, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true) 
		{
			super(view, parent, stage, x, y, width, height, showing, enabled);
			
			new PhantomLabel("Resources", this, labelX, controlY);
			resourceColor = new PhantomEditBox("Color", this, controlX, controlY, controlW); 
			resourceColor.onChange = changeValue;
			controlY += 28;
		}
		
		override public function get element():GraphElement { return super.element; }
		
		override public function set element(value:GraphElement):void 
		{
			super.element = value;
			if (value is Source) resourceColor.caption = StringUtil.toColorString((value as Source).resourceColor);
		}
		
		override protected function changeValue(sender:PhantomControl):void 
		{
			if (sender == resourceColor) {
				view.setValue("resourceColor", resourceColor.caption, 0);
			} else {
				super.changeValue(sender);
			}
		}		
		
		
		
		
		
		
	}

}