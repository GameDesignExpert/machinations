package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.ArtificialPlayer;
	import nl.jorisdormans.machinations.model.Chart;
	import nl.jorisdormans.machinations.model.Converter;
	import nl.jorisdormans.machinations.model.Drain;
	import nl.jorisdormans.machinations.model.EndCondition;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	import nl.jorisdormans.machinations.model.Gate;
	import nl.jorisdormans.machinations.model.GroupBox;
	import nl.jorisdormans.machinations.model.TextLabel;
	import nl.jorisdormans.machinations.model.MachinationsConnection;
	import nl.jorisdormans.machinations.model.MachinationsNode;
	import nl.jorisdormans.machinations.model.Pool;
	import nl.jorisdormans.machinations.model.Source;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.machinations.model.Trader;
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
	public class EditElementPanel extends PhantomPanel
	{
		private var _element:GraphElement;
		//private var label:PhantomEditBox;
		private var color:PhantomEditBox;
		private var thickness:PhantomEditNumberBox;
		private var panelCaption:PhantomLabel;
		protected var view:MachinationsEditView;
		protected var labelX:Number;
		protected var controlX:Number;
		protected var controlY:Number;
		protected var controlW:Number;
		protected var controlNW:Number;
		
		
		public function EditElementPanel(view:MachinationsEditView, parent:DisplayObjectContainer, x:Number, y:Number, width:Number, height:Number, showing:Boolean = true, enabled:Boolean = true, noThickness:Boolean = false)
		{
			this.view = view;
			super(parent, x, y, width, height, showing, enabled);
			labelX = 4;
			controlX = width*0.4;
			controlY = 2;
			controlW = width -controlX - 4;
			controlNW = 60;
			panelCaption = new PhantomLabel("*Element", this, labelX, controlY, 100);
			controlY += 24;
			//new PhantomLabel("Label", this, lx, cy);
			//label = new PhantomEditBox("Label", this, cx, cy, cw); 
			//label.onChange = changeValue;
			//cy += 28;
			new PhantomLabel("Color", this, labelX, controlY);
			color = new PhantomEditBox("Color", this, controlX, controlY, controlW); 
			color.onChange = changeValue;
			controlY += 28;
			
			if (!noThickness) {
				new PhantomLabel("Thickness", this, labelX, controlY);
				thickness = new PhantomEditNumberBox(1, 0, 1, this, controlX, controlY, controlNW); 
				thickness.min = 0;
				thickness.onChange = changeValue;
				controlY += 28;
			}
		}
		
		public function get element():GraphElement { return _element; }
		
		public function set element(value:GraphElement):void 
		{
			_element = value;
			if (_element is Gate) panelCaption.caption = "Gate";
			if (_element is Source) panelCaption.caption = "Source";
			if (_element is Pool) panelCaption.caption = "Pool";
			if (_element is Drain) panelCaption.caption = "Drain";
			if (_element is Converter) panelCaption.caption = "Converter";
			if (_element is Trader) panelCaption.caption = "Trader";
			if (_element is EndCondition) panelCaption.caption = "EndCondition";
			if (_element is TextLabel) panelCaption.caption = "TextLabel";
			if (_element is GroupBox) panelCaption.caption = "GroupBox";
			if (_element is Chart) panelCaption.caption = "Chart";
			if (_element is ArtificialPlayer) panelCaption.caption = "ArtificialPlayer";
			if (_element is ResourceConnection) panelCaption.caption = "Flow";
			if (_element is StateConnection) panelCaption.caption = "State";
			//label.caption = _element.caption;
			if (_element is MachinationsConnection) {
				color.caption = StringUtil.toColorString((_element as MachinationsConnection).color);
				thickness.value = (_element as MachinationsConnection).thickness;
			}
			if (_element is MachinationsNode) {
				color.caption = StringUtil.toColorString((_element as MachinationsNode).color);
				if (thickness) thickness.value = (_element as MachinationsNode).thickness;
			}
		}
		
		protected function changeValue(sender:PhantomControl):void {
			switch (sender) {
				case color:
					view.setValue("color", color.caption, 0);
					break;
				case thickness:
					view.setValue("thickness", null, thickness.value);
					break;
			}
		}
		
	}

}