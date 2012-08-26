package nl.jorisdormans.graph 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphSymbol
	{
		public var name:String;
		public var abbrivation:String;
		public var terminal:Number;
		public var colorLine:uint;
		public var colorFill:uint;
		public var colorText:uint;
		public var nodeClass:Class;
		
		public function GraphSymbol(nodeClass:Class, name:String, abbrivation:String, terminal:Number, colorLine:uint, colorFill:uint, colorText:uint) 
		{
			this.nodeClass = nodeClass;
			this.name = name;
			this.abbrivation = abbrivation;
			this.terminal = terminal;
			this.colorLine = colorLine;
			this.colorFill = colorFill;
			this.colorText = colorText;
		}
		
	}

}