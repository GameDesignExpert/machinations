package nl.jorisdormans.graph 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphConnectionType
	{
		public var name:String;
		public var color:uint;
		public var thickness:Number;
		public var lineStyle:String;
		public var arrowStart:String;
		public var arrowEnd:String;
		public var connectionClass:Class;
		
		public static var STYLE_SOLID:String = "solid";
		public static var STYLE_DOTTED:String = "dotted";
		
		public static var ARROW_NONE:String = "none";
		public static var ARROW_SMALL:String = "small";
		public static var ARROW_MEDIUM:String = "medium";
		public static var ARROW_LARGE:String = "large";
		
		public function GraphConnectionType(connectionClass:Class, name:String, color:uint, thickness:Number = 1, lineStyle:String = "solid", arrowStart:String = "none", arrowEnd:String = "medium") 
		{
			this.connectionClass = connectionClass;
			this.name = name;
			this.color = color;
			this.thickness = thickness;
			this.lineStyle = lineStyle;
			this.arrowStart = arrowStart;
			this.arrowEnd = arrowEnd;
		}
		
	}

}