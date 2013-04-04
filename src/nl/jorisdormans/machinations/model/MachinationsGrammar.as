package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.graph.GraphConnectionType;
	import nl.jorisdormans.graph.GraphGrammar;
	import nl.jorisdormans.graph.GraphSymbol;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsGrammar extends GraphGrammar
	{
		public static var version:String = "v4.04";
		public static var fontSize:Number = 10;
		public static var fontWeight:Number = 2;
		
		
		public function MachinationsGrammar() 
		{
			
		}
		
		override public function createDefaultGrammar():void 
		{
			symbols.push(new GraphSymbol(Pool, "Pool", "p", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Gate, "Gate", "g", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Source, "Source", "s", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Drain, "Drain", "d", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Converter, "Converter", "c", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Trader, "Trader", "t", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(EndCondition, "EndCondition", "ec", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Register, "Register", "r", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Delay, "Delay", "dl", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(ArtificialPlayer, "ArtificialPlayer", "ap", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(TextLabel, "TextLabel", "tl", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(GroupBox, "GroupBox", "gb", 1, 0x000000, 0xffffff, 0x000000));
			symbols.push(new GraphSymbol(Chart, "Chart", "ch", 1, 0x000000, 0xffffff, 0x000000));
			
			connectionTypes.push(new GraphConnectionType(ResourceConnection, "Resource Connection", 0x000000, 1, GraphConnectionType.STYLE_SOLID, GraphConnectionType.ARROW_NONE, GraphConnectionType.ARROW_MEDIUM));
			connectionTypes.push(new GraphConnectionType(StateConnection, "State Connection", 0x000000, 1, GraphConnectionType.STYLE_DOTTED, GraphConnectionType.ARROW_NONE, GraphConnectionType.ARROW_MEDIUM));
		}
		
	}

}