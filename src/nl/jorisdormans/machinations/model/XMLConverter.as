package nl.jorisdormans.machinations.model 
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
		
		public static function convertV35V40(v35:XML):XML {
			var v40:XML = new XML(v35.toXMLString());
			
			var children:XMLList = v40.children();
			for each (var child:XML in children) {
				if (child.localName() == "node" && child.@symbol == "ArtificialPlayer") {
					child.@actionsPerTurn = child.@interval;
				}
				if (child.localName() == "node" && child.@symbol == "Delayer") {
					child.@symbol = "Delay";
				}
			}
			trace("CONVERTED v3.5 > v4.0");
			return v40;
		}
		
		public static function convertV30V35(v30:XML):XML {
			var v35:XML = <graph/>;
			v35.@version = "v3.5";
			v35.@name = v30.@name;
			v35.@author = v30.@author;
			v35.@interval = v30.@interval;
			if (v30.@actions == "0") {
				v35.@timeMode = "asynchronous";
				v35.@actions = "1";
			} else {
				v35.@timeMode = "turn-based";
				v35.@actions = v30.@actions;
			}
			v35.@distributionMode = "fixed speed";
			v35.@speed = v30.@speed;
			v35.@dice = v30.@dice;
			v35.@skill = v30.@skill;
			v35.@strategy = v30.@strategy;
			v35.@multiplayer = v30.@multiplayer;
			v35.@width = v30.@width;
			v35.@height = v30.@height;
			v35.@numberOfRuns = v30.@numberOfRuns;
			v35.@visibleRuns = v30.@visibleRuns;
			
			var children:XMLList = v30.children();
			for each (var child:XML in children) {
				if (child.localName() == "node") {
					v35.appendChild(convertNodeV30V35(child));
				}
				if (child.localName() == "connection") {
					v35.appendChild(convertConnectionV30V35(child));
				}
			}
			trace("CONVERTED v3.0 > v3.5");
			return v35;
		}
		
		static private function convertNodeV30V35(v30:XML):XML
		{
			var v35:XML = new XML(v30.toXMLString());
			if (v35.@symbol == "Label") {
				v35.@symbol = "TextLabel";
			}
			
			
			return v35;
		}
		
		static private function convertConnectionV30V35(v30:XML):XML
		{
			var v35:XML = new XML(v30.toXMLString());
			if (v35.@type == "State") {
				v35.@type = "State Connection";
			}
			v35.@label = v30.@modifier;
			return v35;
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
			trace("CONVERTED v2.0 > v3.0");
			
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
			v30.@interactive = (v2.@clickable == "true") ? "1" : "0";
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
					v30.@gateType = s;
					break;
				case "Chart":
					v30.@width = v2.@width;
					v30.@height = v2.@height;
					v30.@scaleX = v2.@scaleX;
					v30.@scaleY = v2.@scaleY;
					break;
				case "AIBox":
				case "ArtificialPlayer":
					v30.@symbol = "ArtificialPlayer";
					//translate the script too
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
				if (v2.@endModifier == "*") {
					modifier = v2.@startModifier;
					if (type == "State") {
						if (modifier.charAt(0) != "<" && modifier.charAt(1) != "=" && modifier.charAt(0) != ">" ) {
							modifier = ">=" + modifier;
						}
					}
				}
				else modifier = v2.@endModifier + "/" + v2.@startModifier;
			} else if (v2.@startModifier != "") {
				modifier = v2.@startModifier;
				position = 0.25;
				if (type == "State") {
					modifier = "1/" + modifier;
				}
			} else if (v2.@endModifier != "") {
				modifier = v2.@endModifier;
				position = 0.75;
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