package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Source extends MachinationsNode
	{
		private var _resourceColor:uint;
		
		public function Source() 
		{
			resourceColor = StringUtil.toColor("Black");
			activationMode = MODE_AUTOMATIC;
		}

		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@resourceColor = StringUtil.toColorString(resourceColor);
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			resourceColor = StringUtil.toColor(xml.@resourceColor);
		}		
		
		public function get resourceColor():uint { return _resourceColor; }
		
		public function set resourceColor(value:uint):void 
		{
			_resourceColor = value;
		}
		
		override public function fire():void 
		{
			super.fire();
			satisfy();
		}
		
		override public function satisfy():void 
		{
			super.satisfy();
			var l:int = outputs.length; 
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is ResourceConnection && !(outputs[i] as ResourceConnection).inhibited) (outputs[i] as ResourceConnection).produce(this);
				if (outputs[i] is StateConnection) (outputs[i] as StateConnection).fire();
			}
		}
		
	}

}