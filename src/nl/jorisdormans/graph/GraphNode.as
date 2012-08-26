package nl.jorisdormans.graph 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphNode extends GraphElement
	{
		public var position:Vector3D;
		public var symbol:GraphSymbol;
		
		
		public function GraphNode() 
		{
			position = new Vector3D();
			symbol = null;
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
		
		override public function getPosition():Vector3D 
		{
			return position.clone();
		}
		
		override public function getConnection(towards:Vector3D):Vector3D 
		{
			return position.clone();
		}
		
		override public function moveBy(dx:Number, dy:Number, dz:Number = 0):void 
		{
			moveTo(position.x + dx, position.y + dy, position.z + dz);
		}
		
		override public function moveTo(x:Number, y:Number, z:Number = 0):void 
		{
			position.x = x;
			position.y = y;
			position.z = z;
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				inputs[i].calculateEndPosition();
			}
			l = outputs.length;
			for (i = 0; i < l; i++) {
				outputs[i].calculateStartPosition();
			}
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.setName("node");
			xml.@symbol = symbol.name;
			xml.@x = Math.round(position.x);
			xml.@y = Math.round(position.y);
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			position.x = xml.@x;
			position.y = xml.@y;
		}
		

		
		
	}

}