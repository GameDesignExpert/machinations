package nl.jorisdormans.utils 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MathUtil
	{
		
		public function MathUtil() 
		{
			
		}
		
		public static const TO_DEGREES:Number = 180 / Math.PI;
		public static const RO_RADIANS:Number = Math.PI / 180;
		public static const TWO_PI:Number = Math.PI * 2;
		
		
		public static function normalizeAngle(a:Number):Number {
			a = a % TWO_PI;
			if (a > Math.PI) a -= TWO_PI;
			if (a <= -Math.PI) a += TWO_PI;
			return a;
		}
		
		public static function angleDifference(target:Number, current:Number):Number {
			target -= current;
			return (normalizeAngle(target));
		}
		
		private static var _sin:Number = 0;
		private static var _cos:Number = 1;
		private static var _angle:Number = 0;
		public static function rotateVector3D(v:Vector3D, angle:Number):Vector3D {
			if (angle != _angle) {
				_sin = Math.sin(angle);
				_cos = Math.cos(angle);
				_angle = angle;
			}
			return new Vector3D(_cos * v.x - _sin * v.y, _sin * v.x + _cos * v.y, v.z);
		}
		
		//a second version of the same function to boost performance (collision detection often needs two 'matrices' at the same time)
		private static var _sinb:Number = 0;
		private static var _cosb:Number = 1;
		private static var _angleb:Number = 0;
		public static function rotateVector3Db(v:Vector3D, angle:Number):Vector3D {
			if (angle != _angleb) {
				_sinb = Math.sin(angle);
				_cosb = Math.cos(angle);
				_angleb = angle;
			}
			return new Vector3D(_cosb * v.x - _sinb * v.y, _sinb * v.x + _cosb * v.y, v.z);
		}		
		
		public static function getNormal2D(v:Vector3D):Vector3D {
			var r:Vector3D = v.clone();
			r.normalize();
			var y:Number = r.y;
			r.y = -r.x;
			r.x = y;
			return r;
		}	
		
		public static function intersection(line1Start:Vector3D, line1Direction:Vector3D, line1Length:Number, line2Start:Vector3D, line2Direction:Vector3D, line2Length:Number):Number {
			var v3bx:Number = line2Start.x - line1Start.x;
			var v3by:Number = line2Start.y - line1Start.y;
			var perP1:Number = v3bx * line2Direction.y - v3by * line2Direction.x;
			var perP2:Number = line1Direction.x * line2Direction.y - line1Direction.y * line2Direction.x;
			if (perP2 == 0) return -1;
			var t:Number = perP1 / perP2;
			if (t <= 0 || t>=line1Length) return -1; //in the wrong direction
			var cx:Number = line1Start.x + line1Direction.x * t;
			var cy:Number = line1Start.y + line1Direction.y * t;
			var lx:Number = cx - line2Start.x;
			var ly:Number = cy - line2Start.y;
			var dot:Number = lx * line2Direction.x + ly * line2Direction.y;
			
			if (dot > 0 && dot < line2Length) {
				return dot;
			}
			return -1;
		}		
		
		public static function closestPointOnLine(lineStart:Vector3D, lineDirection:Vector3D, lineLength:Number, point:Vector3D):Number {
			var v3bx:Number = point.x - lineStart.x;
			var v3by:Number = point.y - lineStart.y;
			var p:Number = v3bx * lineDirection.x + v3by * lineDirection.y;
			if (p < 0) p = 0;
			if (p > lineLength) p = lineLength;
			return p;
		}	
		
		public static function distanceToLine(lineStart:Vector3D, lineDirection:Vector3D, lineLength:Number, point:Vector3D):Number {
			var p:Number = closestPointOnLine(lineStart, lineDirection, lineLength, point);
			var cp:Vector3D = lineStart.clone();
			cp.x += lineDirection.x * p;
			cp.y += lineDirection.y * p;
			return Vector3D.distance(cp, point);
		}
		
		public static function pointOnRightSide(point:Vector3D, lineStart:Vector3D, lineUnit:Vector3D):Boolean {
			var n:Vector3D = new Vector3D(lineUnit.y, -lineUnit.x, 0);
			return n.dotProduct(lineStart.subtract(point))>0;
		}	
		
		public static function getSquareOutlinePoint(d:Vector3D, size:Number):Vector3D {
			d.normalize();
			if (Math.abs(d.x) > Math.abs(d.y)) {
				if (d.x < 0) return new Vector3D( -size, -size * d.y / d.x, 0);
				else return new Vector3D( size, size * d.y / d.x, 0);
			} else {
				if (d.y < 0) return new Vector3D( -size * d.x / d.y, -size, 0);
				else return new Vector3D( size * d.x / d.y, size, 0);
			}
		}
		
		public static function getRectangleOutlinePoint(d:Vector3D, width:Number, height:Number):Vector3D {
			var f:Number = height / width;
			d.x *= f;
			d = getSquareOutlinePoint(d, width);
			d.y *= f;
			return d;
		}
		
		public static function distanceSquared(a:Vector3D, b:Vector3D):Number {
			var dx:Number = a.x - b.x;
			var dy:Number = a.y - b.y;
			return dx * dx + dy * dy;
		}
		
		
		
	}

}