package nl.jorisdormans.graph 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Graph extends EventDispatcher
	{
		/**
		 * Contains all elements in the graph
		 */
		public var elements:Vector.<GraphElement>;
		
		public var grammar:GraphGrammar;
		
		public function Graph() 
		{
			elements = new Vector.<GraphElement>();
			clear();
		}
		
		/**
		 * Add an element to the graph
		 * @param	element
		 */
		public function addElement(element:GraphElement):void {
			element.graph = this;
			elements.push(element);
		}
		
		/**
		 * Removes an element from a graph, do not call this function directly call element.dispose() instead
		 * @param	element
		 */
		public function removeElement(element:GraphElement):void {
			var l:int = elements.length;
			for (var i:int = l-1; i >= 0; i--) {
				if (elements[i] == element) {
					elements.splice(i, 1);
				}
			}
		}
		
		private function setIds():void {
			var l:int = elements.length;
			for (var i:int = 0; i < l; i++) {
				elements[i].id = i;
			}
		}
		
		/**
		 * Generate a XML object that represents the graph
		 * @return an XML object representing the graph
		 */
		public function generateXML():XML {
			setIds();
			var xml:XML = <graph/>;
			var l:int = elements.length;
			for (var i:int = 0; i < l; i++) {
				xml.appendChild(elements[i].generateXML());
			}
			return xml;
		}
		
		public function readXML(xml:XML):void {
			clear();
			//iterate over all the xml's children and produce an element for each
			var children:XMLList = xml.children();
			for each (var child:XML in children) {
				if (child.localName() == "node") {
					addNodeXML(child);
				}
				if (child.localName() == "connection") {
					addConnectionXML(child);
				}
			}
			
			//hook up elements, based on the ids
			var l:int = elements.length;
			for (var i:int = 0; i < l; i++) {
				var connection:GraphConnection = elements[i] as GraphConnection;
				if (connection) {
					if (connection.startId >= 0) connection.start = elements[connection.startId];
					if (connection.endId >= 0) connection.end = elements[connection.endId];
				}
			}
		}
		
		public function addXML(xml:XML):void {
			var currentCount:int = elements.length;
			var children:XMLList = xml.children();
			for each (var child:XML in children) {
				trace(child.localName, child.name);
				if (child.localName() == "node") {
					addNodeXML(child);
				}
				if (child.localName() == "connection") {
					addConnectionXML(child);
				}
			}
			
			//hook up elements, based on the ids
			var l:int = elements.length;
			for (var i:int = currentCount; i < l; i++) {
				var connection:GraphConnection = elements[i] as GraphConnection;
				if (connection) {
					if (connection.startId >= 0) connection.start = elements[currentCount+connection.startId];
					if (connection.endId >= 0) connection.end = elements[currentCount+connection.endId];
				}
			}
			
		}
		
		private function addNodeXML(child:XML):void
		{
			var symbol:GraphSymbol = grammar.getSymbol(child.@symbol);
			var node:GraphNode = new symbol.nodeClass();
			node.symbol = symbol;
			node.readXML(child);
			addElement(node);
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD, node));
		}
		
		public function addConnectionXML(child:XML):void {
			var type:GraphConnectionType = grammar.getConnectionType(child.@type);
			var connection:GraphConnection = new type.connectionClass();
			connection.type = type;
			connection.readXML(child);
			addElement(connection);
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD, connection));
		}
		
		
		/**
		 * Disposes all elements
		 */
		public function clear():void
		{
			var l:int = elements.length;
			for (var i:int = l-1; i >= 0; i--) {
				elements[i].dispose();
			}
		}
		
		
		public function addNode(symbolName:String, position:Vector3D):GraphNode {
			var symbol:GraphSymbol = grammar.getSymbol(symbolName);
			var node:GraphNode = new symbol.nodeClass();
			node.symbol = symbol;
			node.position = position.clone();
			addElement(node);
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD, node));
			return node;
		}
		
		public function addConnection(typeName:String, start:Vector3D, end:Vector3D):GraphConnection {
			var type:GraphConnectionType = grammar.getConnectionType(typeName);
			var connection:GraphConnection = new type.connectionClass();
			connection.type = type;
			connection.points[0] = start;
			connection.points[1] = end;
			connection.calculateStartPosition(start);
			connection.calculateEndPosition(end);
			addElement(connection);
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_ADD, connection));
			return connection;
		}
		
	}

}