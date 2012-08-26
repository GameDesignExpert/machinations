package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.utils.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Delay extends MachinationsNode
	{
		private var resources:Vector.<Resource>;
		private var output:ResourceConnection;
		public var delayType:String;
		public var inputStateValue:Number;
		
		
		public static var TYPE_QUEUE:String = "queue";
		public static var TYPE_NORMAL:String = "normal";
		
		public function Delay() 
		{
			super();
			size = 12;
			resources = new Vector.<Resource>();
			delayType = TYPE_NORMAL;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@delayType = delayType;
			return xml;
		}
		
		override public function autoFire():void 
		{
			super.autoFire();
			if ((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
				advanceTime(1);
			}
			
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			delayType = xml.@delayType;
		}		
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			resources.splice(0, resources.length);
			output = null;
			for (var i:int = 0; i < outputs.length; i++) {
				if (outputs[i] is ResourceConnection) {
					output = outputs[i] as ResourceConnection;
				}
			}
			inputStateValue = 0;
			
		}
		
		override public function stop():void 
		{
			super.stop();
			resources.splice(0, resources.length);
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		override public function fire():void 
		{
			super.fire();
			pull();
		}
		
		override public function receiveResource(color:uint, flow:ResourceConnection):void 
		{
			super.receiveResource(color, flow);
			var r:Resource;
			if ((graph as MachinationsGraph).colorCoding == 1) {
				for (var i:int = 0; i < outputs.length; i++) {
					var o:ResourceConnection = (outputs[i] as ResourceConnection);
					if (o && o.color == color) {
						o.label.generateNewValue();
						var d:Number = o.label.value + inputStateValue;
						r = new Resource(color, d);
						r.connection = o;
						break;
					}
				}
				if (!r) {
					for (i = 0; i < outputs.length; i++) {
						o = (outputs[i] as ResourceConnection);
						if (o && o.color == this.color) {
							o.label.generateNewValue();
							d = o.label.value + inputStateValue;
							r = new Resource(color, d);
							r.connection = o;
							break;
						}
					}
				}
			} else if (output) {
				output.label.generateNewValue();
				d = output.label.value + inputStateValue;
				r = new Resource(color, d);
				r.connection = output;
			}
			if (r) {
				resources.push(r);
				changeState(r.color, 1);
			}
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if ((graph as MachinationsGraph).timeMode != MachinationsGraph.TIME_MODE_TURN_BASED) {
				advanceTime(time);
			}
		}
		
		private function advanceTime(time:Number):void {
			var m:int = resources.length;
			if (delayType == TYPE_QUEUE) m = Math.min(m, 1); //queue
			for (var i:int = m - 1; i >= 0; i--) {
				resources[i].position -= time;
				if (resources[i].position <= 0) {
					if (output) {
						changeState(resources[i].color, -1);
						resources[i].position = 0;
						resources[i].connection.resources.push(resources[i]);
						resources[i].connection.requestQueue.push(1);
						resources.splice(i, 1);
						trigger();
						if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
					}
				}
			}
		}
		
		private function trigger():void 
		{
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection && (outputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER) (outputs[i] as StateConnection).fire();
			}
		}
		
		public function get delayed():Boolean {
			return resources.length>0
		}
		
		public function modify(delta:Number):void {
			inputStateValue += delta;
		}
		
		public function changeState(resourceColor:uint, delta:int):void {
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection) {
					if ((outputs[i] as StateConnection).color == this.color || resourceColor == 0x01000000 || (outputs[i] as StateConnection).color == resourceColor || (graph as MachinationsGraph).colorCoding == 0) {
						(outputs[i] as StateConnection).changeState(delta);
					}
				}
				if (outputs[i] is ResourceConnection) (outputs[i] as ResourceConnection).checkInhibition(true);
			}
			if (delta != 0) {
				checkInhibition();
			}
			
		}
		
		
		
	}

}