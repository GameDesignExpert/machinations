package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphConnection;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.MathUtil;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsConnection extends GraphConnection
	{
		public var color:uint;
		public var thickness:Number;
		public var label:Label;
		public var doEvents:Boolean;
		public var firing:Number;
		public var blocked:Number;
		private var _inhibited:Boolean;
		protected var communicateInhibition:Boolean = true;
		
		
		public function MachinationsConnection() 
		{
			super();
			thickness = 2;
			color = 0x000000;
			label = new Label(this, 0.5, "");
		}
		
		override protected function calculateTotalLength():void 
		{
			super.calculateTotalLength();
			calculateModifierPosition();
		}
		
		public function calculateModifierPosition(x:Number = -1, y:Number = -1):void {
			var targetLength:Number = label.position * totalLength;
			var i:int = 1;
			label.calculatedNormal = new Vector3D(1, 0);
			label.calculatedPosition = points[0].clone();
			while (i<points.length) {
				var d:Vector3D = points[i].subtract(points[i - 1]);
				var l:Number = d.normalize();
				if (l < targetLength) {
					targetLength -= l;
				} else {
					label.calculatedNormal = d;
					label.calculatedPosition = points[i - 1].clone();
					label.calculatedPosition.x += d.x * targetLength;
					label.calculatedPosition.y += d.y * targetLength;
					
					if (x>-1) {
						var dif:Vector3D = label.calculatedPosition.clone();
						dif.x -= x;
						dif.y -= y;
						dif.z = dif.x;
						dif.x = -dif.y
						dif.y = dif.z;
						var dot:Number = dif.dotProduct(d);
						if (dot > 0) label.side = 1;
						else label.side = -1;
					}
					
					var s:Number = 10 * label.side;
					if (d.x>0.94 || d.x<-0.94) {
						label.align = PhantomFont.ALIGN_CENTER;
					} else if (d.y * label.side < 0) {
						label.align = PhantomFont.ALIGN_LEFT;
					} else {
						label.align = PhantomFont.ALIGN_RIGHT;
					}
					label.calculatedPosition.x -= d.y * s;
					label.calculatedPosition.y += d.x * s;
					break;
				}
				i++;
			}
			
			var li:int = inputs.length;
			for (i = 0; i < li; i++) {
				if (inputs[i] != this) inputs[i].calculateEndPosition();
			}
			li = outputs.length;
			for (i = 0; i < li; i++) {
				if (outputs[i] != this) outputs[i].calculateStartPosition();
			}
			
			
		}
		
		override public function getPosition():Vector3D 
		{
			return label.calculatedPosition.clone();
		}
		
		override public function getConnection(towards:Vector3D):Vector3D 
		{
			var d:Vector3D = label.calculatedPosition.clone();
			switch (label.align) {
				case PhantomFont.ALIGN_LEFT:
					d.x += label.size.x * 0.5;
					break;
				case PhantomFont.ALIGN_RIGHT:
					d.x -= label.size.x *0.5;
					break;
			}
			var u:Vector3D = towards.subtract(d);
			u.normalize();
			var p:Vector3D = MathUtil.getRectangleOutlinePoint(u, 0.5 * label.size.x + 3, 0.5 * label.size.y + 3);
			d.incrementBy(p);
			//d.x -= width * 0.5;
			//d.y -= height * 0.5;
			return d;					}	
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@label = label.getRealText();
			xml.@position = Math.round(label.position * 100) * 0.01 * label.side;
			xml.@color = StringUtil.toColorString(color);
			xml.@thickness = thickness;
			if (label.min > -Label.LIMIT) xml.@min = label.min.toFixed(2);
			if (label.max < Label.LIMIT) xml.@max = label.max.toFixed(2);
			return xml;
		}	
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			label.text = xml.@label;
			label.position = xml.@position;
			if (label.position < 0) {
				label.position *= -1;
				label.side = -1;
			} else {
				label.side = 1;
			}
			color = StringUtil.toColor(xml.@color);
			if (xml.@min.length() > 0) label.min = parseFloat(xml.@min);
			if (xml.@max.length() > 0) label.max = parseFloat(xml.@max);
			thickness = xml.@thickness;
		}
		
		public function prepare(doEvents:Boolean):void {
			this.doEvents = doEvents;
			firing = 0;
			blocked = 0;
			label.prepare();
			_inhibited = false;
			if (start is MachinationsNode) {
				_inhibited = (start as MachinationsNode).inhibited;
				(start as MachinationsNode).checkInhibition();
			}
		}
		
		public function stop():void {
			firing = 0;
			blocked = 0;
			label.stop();
			inhibited = false;
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		public function update(time:Number):void
		{
			if (firing > 0) {
				firing -= time;
				if (firing <= 0) {
					firing = 0;
					if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				}
			}			
			if (blocked > 0) {
				blocked -= time;
				if (blocked <= 0) {
					blocked = 0;
				}
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}			
		}	
		
		public function get inhibited():Boolean { return _inhibited; }
		
		public function set inhibited(value:Boolean):void 
		{
			if (_inhibited == value) return;
			_inhibited = value;
			if (end is MachinationsNode && communicateInhibition) (end as MachinationsNode).checkInhibition();
			if (end is ResourceConnection && communicateInhibition) (end as ResourceConnection).checkInhibition();
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		
		
		
	}

}