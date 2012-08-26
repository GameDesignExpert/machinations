package nl.jorisdormans.utils 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class StringUtil
	{
		
		public function StringUtil() 
		{
			
		}
		
		public static function toColor(string:String):uint {
			switch (string.toLowerCase()) {
				case "black": return 0x000000;
				case "white": return 0xffffff;
				case "red": return 0xce0000;
				case "darkred": return 0x8b0000;
				case "orange": return 0xffa500;
				case "orangered": return 0xff4500;
				case "yellow": return 0xffff00;
				case "gold": return 0xffd700;
				case "green": return 0x008000;
				case "lime": return 0x00ff00;
				case "blue": return 0x0000ff;
				case "lightblue": return 0x0080d1;
				case "darkblue": return 0x00008b;
				case "purple": return 0x800080;
				case "violet": return 0xee82ee;
				case "teal": return 0x008080;
				case "gray": return 0xa9a9a9;
				case "darkgray": return 0x808080;
				case "brown": return 0x8b4513;
				default: return parseInt(string);
			}
			
		}
		
		public static function toColorString(c:uint):String {
			switch (c) {
				case 0x000000: return "Black";
				case 0xffffff: return "White";
				case 0xce0000: return "Red";
				case 0x8b0000: return "DarkRed";
				case 0xffa500: return "Orange";
				case 0xff4500: return "OrangeRed";
				case 0xffff00: return "Yellow";
				case 0xffd700: return "Gold";
				case 0x008000: return "Green";
				case 0x00ff00: return "Lime";
				case 0x0000ff: return "Blue";
				case 0x00008b: return "DarkBlue";
				case 0x0080d1: return "LightBlue";
				case 0x800080: return "Purple";
				case 0xee82ee: return "Violet";
				case 0x008080: return "Teal";
				case 0xa9a9a9: return "Gray";
				case 0x808080: return "DarkGray";
				case 0x8b4513: return "Brown";
				default:
					var s:String = c.toString(16);
					while (s.length < 6) s = "0" + s;
					return "0x" + s;
					break;
			}
		}
		
		public static function toColorStringSVG(c:uint):String {
			var s:String = c.toString(16);
			while (s.length < 6) s = "0" + s;
			return "#" + s;
		}
		
		public static function parseCommand(command:String):Array {
			var r:Array = new Array();
			var p:int = command.indexOf("(");
			if (p >= 0) {
				r.push(command.substr(0, p));
				command = trim(command.substr(p + 1));
				p = command.indexOf(")");
				if (p >= 0) {
					command = trim(command.substr(0, p));
					p = command.indexOf(",");
					while (p > 0) {
						r.push(command.substr(0, p));
						command = trim(command.substr(p + 1));
						p = command.indexOf(",");
					}
					if (command!="") r.push(command);
				}
				return r;
			} else {
				p = command.indexOf(";");
				if (p >= 0) {
					command = trim(command.substr(0, p - 1));
				}
				r.push(command);
				return r;
			}
		}
		
		public static function trim( inputStr : String ) : String
		{
			while (inputStr.charAt(0) == " ") inputStr = inputStr.substr(1);
			while (inputStr.charAt(inputStr.length-1) == " ") inputStr = inputStr.substr(0, inputStr.length-1);
			return inputStr;
		}	
		
		private static function doEvaluateValue(s:String, current:int, previousOperation:String):int {
			var plus:int = s.indexOf("+");
			var minus:int = s.indexOf("-");
			var operation:String = "";
			var termLength:int;
			if (plus >= 0 && (plus < minus || minus<0)) {
				termLength = plus - 1;
				operation = "+";
			} else if (minus >= 0) {
				termLength = minus - 1;
				operation = "-";
			} else {
				termLength = s.length;
			}
			
			var term:String = s.substr(0, termLength + 1);
			var rest:String = s.substr(termLength + 2);
			
			//evaluate term
			var v:int = 0;
			var d:int = s.indexOf("D");
			if (d < 0) {
				v = parseInt(term);
			} else {
				var multiplier:int = 1;
				if (d > 0) {
					multiplier = parseInt(term.substr(0, d));
				}
				var dice:int = 0;
				dice = parseInt(term.substr(d + 1));
				while (multiplier > 0) {
					v += Math.floor(Math.random() * dice) + 1;
					multiplier--;
				}
			}
			if (previousOperation == "-") current -= v;
			else current += v;
			if (rest.length > 0) return doEvaluateValue(rest, current, operation);
			else return current;
		}
		
		public static function evaluateValue(s:String):int {
			return doEvaluateValue(s, 0, "+");
		}	
		
		public static function setFileExtention(fileName:String, ext:String):String {
			var p:int = fileName.lastIndexOf(".");
			if (p < 0) return fileName + "." + ext;
			else return fileName.substr(0, p + 1) + ext;
		}
		
		public static function splitString(string:String, delimiter:String, trimParts:Boolean = false):Vector.<String> {
			var result:Vector.<String> = new Vector.<String>();
			if (string == null) return result;
			var p:int = string.indexOf(delimiter);
			var s:String;
			while (p >= 0) {
				if (trimParts) s = trim(string.substr(0, p));
				else s = string.substr(0, p);
				result.push(s);
				string = string.substr(p + delimiter.length);
				p = string.indexOf(delimiter);
			}
			if (trimParts) string = trim(string);
			if (string.length > 0) result.push(string);
			return result;
		}
		
		
		public static function getCommand(string:String):String {
			var result:String;
			var p:int = string.indexOf("(");
			if (p >= 0) {
				result = string.substr(0, p);
				string = string.substr(0);
			} else {
				result = string;
				string = "";
			}
			return result;
		}
		
		public static function getCondition(string:String):String {
			var i:int = 0;
			var depth:int  = 0;
			var result:String = "";
			while (i < string.length) {
				var c:String = string.charAt(i);
				switch (c) {
					case "(":
						depth++;
						break;
					case ")":
						depth--;
						if (depth <= 0) {
							result += c;
							return result;
						}
						break;
				}
				i++;
				result += c;
			}
			return result;
		}
		
		public static function getParameters(string:String):Vector.<String> {
			var i:int = 0;
			var depth:int  = 0;
			var result:Vector.<String>= new Vector.<String>();
			var part:String = "";
			while (i < string.length) {
				var c:String = string.charAt(i);
				switch (c) {
					case "(":
						depth++;
						if (depth == 1) {
							c = "";
						}
						break;
					case ",":
						if (depth == 1) {
							result.push(part);
							part = "";
							c = "";
						}
						break;
					case ")":
						depth--;
						if (depth <= 0) {
							result.push(part);
							return result;
						}
						break;
				}
				i++;
				part += c;
			}
			string = "";
			return result;
		}
		
		static public function floatToStringMaxPrecision(v:Number, maxDigits:int):String 
		{
			var precision:Number = Math.pow(10, maxDigits);
			var f:Number = Math.floor(v * precision) / precision;
			var s:String = f.toString();
			var p:int = s.indexOf(".");
			if (p >= 0 && p < s.length - maxDigits - 1) {
				s = s.substr(0, p + maxDigits+1);
			}
			return s;
		}
	}

}