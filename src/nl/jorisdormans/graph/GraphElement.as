package nl.jorisdormans.graph 
{
	import flash.display.Graphics;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphElement extends EventDispatcher
	{
		/**
		 * Identification when saved to XML format
		 */
		public var id:int;
		public var graph:Graph;
		
		public var inputs:Vector.<GraphConnection>;
		public var outputs:Vector.<GraphConnection>;
		
		
		public function GraphElement() 
		{
			id = -1;
			inputs = new Vector.<GraphConnection>();
			outputs = new Vector.<GraphConnection>();
		}
		
		public function dispose():void {
			
			//remove inputs
			var l:int = inputs.length;
			for (var i:int = l-1; i > 0; i--) {
				inputs[i].end = null;
			}
			inputs.splice(0, l);
			inputs = null;
			
			//remove outputs
			l = outputs.length;
			for (i = l-1; i >= 0; i--) {
				outputs[i].start = null;
			}
			outputs.splice(0, l);
			outputs = null;
			
			if (graph) {
				graph.removeElement(this);
				graph = null;
			}
			
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_DISPOSE));
		}
		
		public function generateXML():XML {
			var xml:XML = <element/>;
			return xml;
		}
		
		public function readXML(xml:XML):void {
			//should be overriden
		}
		
		public function removeInput(connection:GraphConnection):void {
			if (!inputs) return;
			var l:int = inputs.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if (inputs[i] == connection) {
					inputs.splice(i, 1);
				}
			}
		}
		
		public function removeOutput(connection:GraphConnection):void {
			if (!outputs) return;
			var l:int = outputs.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if (outputs[i] == connection) {
					outputs.splice(i, 1);
				}
			}
		}	
		
		public function getPosition():Vector3D {
			return new Vector3D();
		}
		
		public function getConnection(towards:Vector3D):Vector3D {
			return new Vector3D();
		}
		
		public function moveBy(dx:Number, dy:Number, dz:Number = 0):void {
			//to be overriden
		}
		
		public function moveTo(x:Number, y:Number, z:Number = 0):void {
			//to be overriden
		}
		
		
		
		
	}

}