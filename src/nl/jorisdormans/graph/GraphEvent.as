package nl.jorisdormans.graph 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphEvent extends Event
	{
		public static const ELEMENT_ADD:String = "element_add";
		public static const ELEMENT_CHANGE:String = "element_change";
		public static const ELEMENT_DISPOSE:String = "element_dispose";
		public static const GRAPH_CHANGE:String = "graph_change";
		public static const GRAPH_RUN:String = "run";
		public static const GRAPH_QUICKRUN:String = "quickrun";
		public static const GRAPH_MULTIPLERUN:String = "multiplerun";
		public static const GRAPH_WARNING:String = "warning";
		public static const GRAPH_ERROR:String = "error";
		
		public var element:GraphElement;
		public var message:String;
		
		public function GraphEvent(type:String, element:GraphElement = null, message:String = "") 
		{
			super(type);
			this.element = element;
			this.message = message;
		}
		
	}

}