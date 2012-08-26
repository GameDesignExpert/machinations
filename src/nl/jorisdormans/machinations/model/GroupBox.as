package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class GroupBox extends TextLabel
	{
		private var _width:Number;
		private var _height:Number;
		public var points:Vector.<Vector3D>;
		
		private static const yPlus:Number = 10;
		private static const yMinus:Number = -10;
		private static const xPlus:Number = 4;
		
		public function GroupBox() 
		{
			_width = 100;
			_height = 100;
			super();
			points = new Vector.<Vector3D>();
			points.push(new Vector3D(0, 0), new Vector3D(_width, 0), new Vector3D(0, _height), new Vector3D(_width, _height));
			points.push(new Vector3D(xPlus, yMinus), new Vector3D(_width * 0.5, yMinus), new Vector3D(_width - xPlus, yMinus));
			points.push(new Vector3D(xPlus, yPlus), new Vector3D(_width * 0.5, yPlus), new Vector3D(_width - xPlus, yPlus));
			points.push(new Vector3D(xPlus, _height + yMinus), new Vector3D(_width * 0.5, _height + yMinus), new Vector3D(_width - xPlus, _height + yMinus));
			points.push(new Vector3D(xPlus, _height + yPlus), new Vector3D(_width * 0.5, _height + yPlus), new Vector3D(_width - xPlus, _height + yPlus));
			captionPosition = 7;
		}
		
		override public function get captionPosition():Number { return super.captionPosition; }
		
		override public function set captionPosition(value:Number):void 
		{
			var i:int = Math.min(15, Math.max(4, Math.floor(value)));
			
			_captionPosition = i;
			if (points) captionCalculatedPosition = points[i].clone();
			else captionCalculatedPosition = new Vector3D();
			
			switch (i) {
				default:
					captionAlign = PhantomFont.ALIGN_CENTER;
					break;
				case 4:
				case 7:
				case 10:
				case 13:
					captionAlign = PhantomFont.ALIGN_LEFT;
					break;
				case 6:
				case 9:
				case 12:
				case 15:
					captionAlign = PhantomFont.ALIGN_RIGHT;
					break;
			}
			
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@width = width;
			xml.@height = height;
			xml.@captionPos = captionPosition;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			width = xml.@width;
			height = xml.@height;
			captionPosition = xml.@captionPos;
		}				
		
		public function get width():Number { return _width; }
		
		public function set width(value:Number):void 
		{
			_width = value;
			points[1].x = _width;
			points[3].x = _width;
			points[5].x = _width * 0.5;
			points[6].x = _width - xPlus;
			points[8].x = _width * 0.5;
			points[9].x = _width - xPlus;
			points[11].x = _width * 0.5;
			points[12].x = _width - xPlus;
			points[14].x = _width * 0.5;
			points[15].x = _width - xPlus;
			captionPosition = captionPosition;
		}
		
		public function get height():Number { return _height; }
		
		public function set height(value:Number):void 
		{
			_height = value;
			points[2].y = _height;
			points[3].y = _height;
			points[10].y = _height + yMinus;
			points[11].y = _height + yMinus;
			points[12].y = _height + yMinus;
			points[13].y = _height + yPlus;
			points[14].y = _height + yPlus;
			points[15].y = _height + yPlus;
			captionPosition = captionPosition;
		}
		
		override public function getConnection(towards:Vector3D):Vector3D 
		{
			var d:Vector3D = position.clone();
			d.x += width * 0.5;
			d.y += height * 0.5;
			var u:Vector3D = towards.subtract(d);
			u.normalize();
			var p:Vector3D = MathUtil.getRectangleOutlinePoint(u, 0.5 * width + thickness + 1, 0.5 * height + thickness + 1);
			d.incrementBy(p);
			//d.x -= width * 0.5;
			//d.y -= height * 0.5;
			return d;			
		}
		
		override public function getPosition():Vector3D 
		{
			var d:Vector3D = position.clone();
			d.x += width * 0.5;
			d.y += height * 0.5;
			return d;
			
			//return super.getPosition();
		}
		
	}

}