package nl.jorisdormans.graph 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphGrammar
	{
		public var symbols:Vector.<GraphSymbol>;
		public var connectionTypes:Vector.<GraphConnectionType>
		public var name:String;
		
		public function GraphGrammar() 
		{
			symbols = new Vector.<GraphSymbol>();
			connectionTypes = new Vector.<GraphConnectionType>();
			clear();
			
			createDefaultGrammar();
		}
		
		/**
		 * clears symbols and connectionTypes and the grammar's name
		 */
		public function clear():void {
			symbols.splice(0, symbols.length);
			connectionTypes.splice(0, connectionTypes.length);
			name = "";
		}
		
		/**
		 * creates a basic grammar, called by the constructor
		 */
		public function createDefaultGrammar():void {
			//default symbols
			symbols.push(new GraphSymbol(GraphNode, "node", "n", 1, 0x000000, 0xffffff, 0x000000));
			
			//default connections
			connectionTypes.push(new GraphConnectionType(GraphConnection, "connection", 0x000000, 1, GraphConnectionType.STYLE_SOLID, GraphConnectionType.ARROW_NONE, GraphConnectionType.ARROW_MEDIUM));
		}
		
		public function getSymbol(name:String):GraphSymbol {
			for (var i:int = 0; i < symbols.length; i++) {
				if (symbols[i].name == name) return symbols[i];
			}
			if (symbols.length > 0) return symbols[0];
			return null;
		}
		
		public function getConnectionType(name:String):GraphConnectionType
		{
			for (var i:int = 0; i < connectionTypes.length; i++) {
				if (connectionTypes[i].name == name) return connectionTypes[i];
			}
			if (connectionTypes.length > 0) return connectionTypes[0];
			return null;
			
		}
		
	}

}