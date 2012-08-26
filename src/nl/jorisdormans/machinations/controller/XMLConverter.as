package nl.jorisdormans.machinations.controller
{
	import flash.xml.XMLNode;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class XMLConverter
	{
		
		public function XMLConverter() 
		{
			
		}
		
		
		
		public static function convertV2V30(v2:XML):XML {
			var v30:XML = <graph/>;
			v30.@version = "v3.0";
			v30.@name = v2.@name;
			v30.@author = v2.@author;
			v30.@interval = "1";
			v30.@speed = v2.@speed;
			v30.@actions = v2.@actions;
			v30.@dice = v2.@dice;
			v30.@skill = v2.@skill;
			v30.@strategy = v2.@strategy;
			v30.@multiplayer = v2.@multiplayer;
			v30.@width = v2.@width;
			v30.@height = v2.@height;
			v30.@numberOfRuns = "100";
			v30.@visibleRuns = "25";
			
			var nodes:int = 0;
			var children:XMLList = v2.children();
			for each (var child:XML in children) {
				if (child.localName() == "node") {
					v30.appendChild(convertNodeV2V30(child));
					nodes++;
				}
			}
			for each (child in children) {
				if (child.localName() == "connection") {
					v30.appendChild(convertConnectionV2V30(child, nodes));
				}
			}
			
			return v30;
		}
		
		static private function convertNodeV2V30(v2:XML):XML
		{
			var v30:XML = <node/>;
			v30.@symbol = v2.@symbol;
			v30.@x = v2.@x;
			v30.@y = v2.@y;
			v30.@color = v2.@colorLine;
			v30.@caption = v2.@label;
			v30.@thickness = v2.@thickness;
			v30.@captionPos = (v2.@labelPosition == "1") ? "0.25" : "0.75";
			v30.@interactive = (v2.@clickable == "true" || v2.@active == "true"  || v2.@interactive == "true" ) ? "1" : "0";
			v30.@actions = (v2.@free == "true") ? "0" : "1";
			var symbol:String = v30.@symbol;
			switch (symbol) {
				case "Source":
				case "Converter":
				case "Drain":
					v30.@resourceColor = v2.@colorResources;
					break;
				case "Pool":
					v30.@resourceColor = v2.@colorResources;
					v30.@startingResources = v2.@startingResources;
					v30.@maxResources = v2.@maxResources;
					break;
				case "Knot":
				case "Gate":
					v30.@symbol = "Gate";
					var s:String = v2.@type;
					s = s.toLowerCase();
					if (s == "random") s = "dice";
					v30.@gateType = s;
					break;
				case "GroupBox":
					v30.@width = v2.@width;
					v30.@height = v2.@height;
				case "Chart":
					v30.@width = v2.@width;
					v30.@height = v2.@height;
					v30.@scaleX = v2.@scaleX;
					v30.@scaleY = v2.@scaleY;
					break;
				case "AIBox":
				case "ArtificialPlayer":
					v30.@symbol = "ArtificialPlayer";
					v30.@active = "1";
					var r:Number = v2.@rate;
					v30.@interval = 1 / r;
					v30.@sequence = (v2.@sequence == "true") ? "1" : "0";
					v30.appendChild(v2.toString());
					break;
					
			}
			
			return v30;
		}
		
		static private function convertConnectionV2V30(v2:XML, nodes:int):XML
		{
			var v30:XML = <connection/>;
			var start:int;
			var end:int;
			var type:String = v2.@type;
			v30.@type = type;

			v30.@start = v2.@start;
			start = v2.@start;
			if (start < 0) {
				var p:XML = <point/>;
				p.@x = v2.@startX;
				p.@y = v2.@startY;
				v30.appendChild(p);
			}
			
			var children:XMLList = v2.children();
			for each (var child:XML in children) {
				if (child.localName() == "waypoint") {
					p = <point/>;
					p.@x = child.@x;
					p.@y = child.@y;
					v30.appendChild(p);
				}
			}
			
			v30.@end= v2.@end;
			end = v2.@end;
			if (end < 0) {
				p = <point/>;
				p.@x = v2.@endX;
				p.@y = v2.@endY;
				v30.appendChild(p);
			}
			
			var modifier:String = "";
			var position:Number  = 0.5;
			if (v2.@startModifier != "" && v2.@endModifier != "") {
				position *=  v2.@startModifierPosition;
				if (v2.@endModifier == "*") {
					modifier = v2.@startModifier;
					if (type == "State") {
						if (modifier.charAt(0) != "<" && modifier.charAt(1) != "=" && modifier.charAt(0) != ">" && modifier.charAt(0) != "!") {
							modifier = ">=" + modifier;
						}
					}
				}
				else modifier = v2.@endModifier + "/" + v2.@startModifier;
			} else if (v2.@startModifier != "") {
				modifier = v2.@startModifier;
				position = 0.25 * v2.@startModifierPosition;
				if (type == "State") {
					if (modifier.charAt(0) != "<" && modifier.charAt(1) != "=" && modifier.charAt(0) != ">" && modifier.charAt(0) != "!") {
						modifier = "1/" + modifier;
					}
				}
			} else if (v2.@endModifier != "") {
				modifier = v2.@endModifier;
				position = 0.75 * v2.@endModifierPosition;
			}
			if (modifier == "*/*") modifier = "*";
			if (type == "State" && modifier == "*") {
				modifier = ">0";
				position = 0.5;
			}
			
			if (type == "Flow" && modifier == "*") {
				position = 0.5;
				v30.@type = "State";
			}
			
			v30.@modifier = modifier;
			v30.@position = position;
			v30.@color = v2.@color;
			v30.@thickness = v2.@thickness;
			
			if (end > nodes) {
				end -= nodes;
				end = Math.floor(end / 2);
				end += nodes;
				v30.@end = end;
			}
			
			if (start > nodes) {
				start -= nodes;
				start = Math.floor(start / 2);
				start += nodes;
				v30.@start = start;
			}
			
			
			
			return v30;
		}
		
	}

}