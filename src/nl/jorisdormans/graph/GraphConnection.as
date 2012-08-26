package nl.jorisdormans.graph 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.utils.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GraphConnection extends GraphElement
	{
		
		private var _start:GraphElement;
		private var _end:GraphElement;
		public var type:GraphConnectionType;
		public var points:Vector.<Vector3D>;
		private var _startPoint:Vector3D;
		private var _endPoint:Vector3D;
		public var totalLength:Number = 0;
		public var startId:int;
		public var endId:int;
		
		public function GraphConnection() 
		{
			points = new Vector.<Vector3D>();
			points.push(new Vector3D(0, 0), new Vector3D(0, 0));
			_startPoint = new Vector3D();
			_endPoint = new Vector3D();
		}
		
		override public function dispose():void 
		{
			start = null;
			end = null;
			points.splice(0, points.length);
			super.dispose();
		}
		
		public function get start():GraphElement { return _start; }
		
		public function set start(value:GraphElement):void 
		{
			if (_start) _start.removeOutput(this);
			_start = value;
			if (_start) {
				_start.outputs.push(this);
				_startPoint = _start.getPosition();
				calculateStartPosition();
			} else {
				_startPoint = points[0].clone();
			}
		}
		
		public function get end():GraphElement { return _end; }
		
		public function set end(value:GraphElement):void 
		{
			if (_end) _end.removeInput(this);
			_end = value;
			if (_end) {
				_end.inputs.push(this);
				_endPoint = _end.getPosition();
				calculateEndPosition();
			} else {
				_endPoint = points[points.length - 1].clone();
			}
		}
		
		public function calculateStartPosition(startPoint:Vector3D = null):void {
			if (startPoint) _startPoint = startPoint.clone();
			if (_start) {
				_startPoint = _start.getPosition();
				if (points.length == 2) {
					points[0] = _start.getConnection(_endPoint);
					if (_end) points[1] = _end.getConnection(_startPoint);
				} else {
					points[0] = _start.getConnection(points[1]);
				}
			} else {
				if (points.length == 2 && _end) points[1] = _end.getConnection(_startPoint);	
				points[0] = _startPoint.clone();

			}
			calculateTotalLength();
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		public function calculateEndPosition(endPoint:Vector3D = null):void {
			if (endPoint) _endPoint = endPoint.clone();
			if (_end) {
				_endPoint = _end.getPosition();
				if (points.length == 2) {
					points[1] = _end.getConnection(_startPoint);
					if (_start) points[0] = _start.getConnection(_endPoint);
				} else {
					points[points.length - 1] = _end.getConnection(points[points.length - 2]);
				}
			} else {
				if (points.length == 2 && _start)  points[0] = _start.getConnection(_endPoint);	
				points[points.length - 1] = _endPoint.clone();
			}
			calculateTotalLength();
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		public function recalculatePoint(index:int):void {
			if (index == 1 && _start) {
				points[0] = _start.getConnection(points[index]);
			}
			if (index == points.length - 2 && _end) {
				points[index + 1] = _end.getConnection(points[index]);
			}
			calculateTotalLength();
		}
		
		protected function calculateTotalLength():void
		{
			totalLength = 0;
			var l:int = points.length;
			for (var i:int = 1; i < l; i++) {
				var dx:Number = points[i].x - points[i - 1].x;
				var dy:Number = points[i].y - points[i - 1].y;
				totalLength += Math.sqrt(dx * dx + dy * dy);
			}
		}
		
		public function getPositionOnLine(position:Number):Vector3D {
			var targetLength:Number = position * totalLength;
			var i:int = 1;
			var result:Vector3D = points[0].clone();
			while (i<points.length) {
				var d:Vector3D = points[i].subtract(points[i - 1]);
				var l:Number = d.normalize();
				if (l < targetLength) {
					targetLength -= l;
				} else {
					result = points[i - 1].clone();
					result.x += d.x * targetLength;
					result.y += d.y * targetLength;
					break;
				}
				i++;
			}
			return result;
		}
		
		public function getPositionSegment(position:Number):int {
			var targetLength:Number = position * totalLength;
			var i:int = 1;
			var result:Vector3D = points[0].clone();
			while (i<points.length) {
				var d:Vector3D = points[i].subtract(points[i - 1]);
				var l:Number = d.normalize();
				if (l < targetLength) {
					targetLength -= l;
				} else {
					return i - 1;
				}
				i++;
			}
			return 0;
		}		
		
		public function findClosestPointTo(x:Number, y:Number):Number {
			var p:Vector3D = new Vector3D(x, y);
			var dist:Number = 100000;
			var segment:int = -1;
			var position:Number = 0;
			var currentLength:Number = 0;
			var i:int = 1;
			while (i < points.length) {
				var d:Vector3D = points[i].subtract(points[i - 1]);
				var l:Number = d.normalize();
				var closest:Number = MathUtil.closestPointOnLine(points[i - 1], d, l, p);
				var pOnLine:Vector3D = points[i - 1].clone();
				pOnLine.x += closest * d.x - x;
				pOnLine.y += closest * d.y - y;
				var ds:Number = pOnLine.length;
				if (ds < dist) {
					dist = ds;
					position = currentLength + closest;
				}
				i++;
				currentLength += l;
			}
			
			return position / currentLength;
		}
		
		public function addPoint(mouseX:Number, mouseY:Number):void
		{
			var p:Number = findClosestPointTo(mouseX, mouseY);
			var s:int = getPositionSegment(p);
			var pos:Vector3D = getPositionOnLine(p);
			points.splice(s+1, 0, pos);
			calculateTotalLength();
			dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			var min:int = 0;
			var max:int = points.length;
			xml.setName("connection");
			xml.@type = type.name;
			if (_start && _start.id >= 0) {
				xml.@start = _start.id;
				min++;
			} else {
				xml.@start = "-1";
			}
			if (_end && _end.id >= 0) {
				xml.@end = _end.id;
				max--;
			} else {
				xml.@end = "-1";
			}
			
			for (var i:int = min; i < max; i++) {
				var point:XML = <point/>;
				point.@x = Math.round(points[i].x);
				point.@y = Math.round(points[i].y);
				xml.appendChild(point);
			}
			
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			startId = xml.@start;
			endId = xml.@end;
			
			var min:int = 0;
			var max:int = xml.point.length();
			_startPoint = new Vector3D(0, 0);
			_endPoint = new Vector3D(0, 0);
			startId = xml.@start;
			endId = xml.@end;
			if (startId == -1) {
				_startPoint.x = xml.point[0].@x;
				_startPoint.y = xml.point[0].@y;
				min++;
			}
			if (endId == -1) {
				_endPoint.x = xml.point[max-1].@x;
				_endPoint.y = xml.point[max-1].@y;
				max--;
			}
			
			points[0] = _startPoint.clone();
			points[1] = _endPoint.clone();
			
			calculateStartPosition();
			calculateEndPosition();
			
			for (var i:int = min; i < max; i++) {
				var p:Vector3D = new Vector3D(xml.point[i].@x, xml.point[i].@y);
				points.splice(points.length - 1, 0, p);
			}
			recalculatePoint(points.length - 2);
			recalculatePoint(1);			
			
		}
		
	}

}