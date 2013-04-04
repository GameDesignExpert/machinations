package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.Graph;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsGraph extends Graph
	{
		private var _running:Boolean;
		public var fireInterval:Number;
		private var fireIntervalCounter:Number;
		public var resourceSpeed:Number;
		public var originalActionsPerTurn:int;
		public var actionsPerTurn:int;
		public var actionsThisTurn:int;
		public var name:String;
		public var author:String;
		public var dice:String;
		public var skill:String;
		public var strategy:String;
		public var multiplayer:String;
		public var width:int;
		public var height:int;
		public var visibleRuns:int;
		public var numberOfRuns:int;
		public var timeMode:String;
		public var distributionMode:String;
		public var colorCoding:int;
		
		private var dicePostFix:Array;
		private var skillPostFix:Array;
		private var strategyPostFix:Array;
		private var multiplayerPostFix:Array;
		
		private var dicePercentage:Number;
		private var skillPercentage:Number;
		private var strategyPercentage:Number;
		private var multiplayerPercentage:Number;
		
		public var ended:Boolean;
		public var endCondition:String;
		public var doEvents:Boolean;
		public var steps:int;
		private var up:Boolean;
		private var fireUp:Boolean;
		
		public static const TIME_MODE_ASYNCHRONOUS:String = "asynchronous";
		public static const TIME_MODE_SYNCHRONOUS:String = "synchronous";
		public static const TIME_MODE_TURN_BASED:String = "turn-based";
		
		public static const DISTRIBUTION_MODE_INSTANTANEOUS:String = "instantaneous";
		public static const DISTRIBUTION_MODE_FIXED_SPEED:String = "fixed speed";
		
		public function MachinationsGraph() 
		{
			super();
			grammar = new MachinationsGrammar();
			_running = false;
		}
		
		override public function clear():void 
		{
			super.clear();
			fireInterval = 1;
			fireIntervalCounter = 0;
			resourceSpeed = 100;
			actionsPerTurn = 1;
			name = "";
			author = "";
			dice = "D6";
			skill = "";
			strategy = "";
			multiplayer = "";
			width = 600;
			height = 560;
			ended = false;
			visibleRuns = 25;
			numberOfRuns = 100;
			colorCoding = 0;
			timeMode = TIME_MODE_ASYNCHRONOUS;
			//distributionMode = DISTRIBUTION_MODE_INSTANTANEOUS;
			distributionMode = DISTRIBUTION_MODE_FIXED_SPEED;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@version = MachinationsGrammar.version;
			xml.@name = name;
			xml.@author = author;
			xml.@interval = fireInterval;
			xml.@timeMode = timeMode;
			xml.@distributionMode = distributionMode;
			xml.@speed = resourceSpeed;
			xml.@actions = actionsPerTurn;
			xml.@dice = dice;
			xml.@skill = skill;
			xml.@strategy = strategy;
			xml.@multiplayer = multiplayer;
			xml.@width = width;
			xml.@height = height;
			xml.@numberOfRuns = numberOfRuns;
			xml.@visibleRuns = visibleRuns;
			xml.@colorCoding = colorCoding;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			if (xml.@version.length() == 0) {
				trace("CONVERTING v2.0 > v3.0...");
				//xml = XMLConverter.convertV2V30(xml);
				xml = XMLConverter.convertV2V30(xml);
			}
			if (xml.@version.substring(0,4) == "v3.0") {
				trace("CONVERTING v3.0 > v3.5...");
				xml = XMLConverter.convertV30V35(xml);
			}
			if (xml.@version.substring(0,4) == "v3.5") {
				trace("CONVERTING v3.5 > v4.0...");
				xml = XMLConverter.convertV35V40(xml);
			}
			super.readXML(xml);
			name = xml.@name;
			author = xml.@author;
			fireInterval = xml.@interval;
			//resourceSpeed = xml.@speed;
			if (xml.@timeMode.length()>0) timeMode = xml.@timeMode;
			if (xml.@distributionMode.length()>0) distributionMode = xml.@distributionMode;
			actionsPerTurn = xml.@actions;
			dice = xml.@dice;
			skill = xml.@skill;
			strategy = xml.@strategy;
			multiplayer = xml.@multiplayer;
			width = xml.@width;
			height = xml.@height;
			numberOfRuns = xml.@numberOfRuns;
			visibleRuns = xml.@visibleRuns;
			if (xml.@colorCoding.length() > 0) colorCoding = xml.@colorCoding;
			else colorCoding = 1;
			//prepare();
		}
		
		public function buildTestGraph():void {
			addNode("pool", new Vector3D(200, 200));
			addNode("pool", new Vector3D(250, 150));
			addNode("pool", new Vector3D(250, 250));
			
			addConnection("flow", new Vector3D(100, 100), new Vector3D(300, 150));
		}
		
		public function get running():Boolean { return _running; }
		
		public function set running(value:Boolean):void 
		{
			_running = value;
			if (_running) prepare();
			else stop();
		}
		
		public function end(condition:String):void {
			trace("GRAPH ENDED", condition);
			//TODO: display the condition in a message. Better feedback for AP that stop the diagram.
			ended = true;
			endCondition = condition;
			updateCharts();
			actionsPerTurn = originalActionsPerTurn;
		}
		
		public function prepare():void {
			trace("PREPARING GRAPH");
			steps = 0;
			actionsThisTurn = 0;
			originalActionsPerTurn = actionsPerTurn;
			ended = false;
			if (dice.indexOf("%") == dice.length - 1) {
				dicePercentage = parseFloat(dice.substr(0, dice.length - 1));
				dicePostFix = null;
			} else {
				dicePostFix = MachinationsExpression.toPostFix(dice);
			}
			if (skill.indexOf("%") == skill.length - 1) {
				skillPercentage = parseFloat(skill.substr(0, skill.length - 1));
				skillPostFix = null;
			} else {
				skillPostFix = MachinationsExpression.toPostFix(skill);
			}
			
			if (strategy.indexOf("%") == strategy.length - 1) {
				strategyPercentage = parseFloat(strategy.substr(0, strategy.length - 1));
				strategyPostFix = null;
			} else {
				strategyPostFix = MachinationsExpression.toPostFix(strategy);
			}
			
			if (multiplayer.indexOf("%") == multiplayer.length - 1) {
				multiplayerPercentage = parseFloat(multiplayer.substr(0, multiplayer.length - 1));
				multiplayerPostFix = null;
			} else {
				multiplayerPostFix = MachinationsExpression.toPostFix(multiplayer);
			}
			
			
			
			var l:int = elements.length;
			//reset registers
			for (i = 0; i < l; i++) {
				if (elements[i] is Register) (elements[i] as Register).reset();
			}
			for (var i:int = 0; i < l; i++) {
				if (elements[i] is MachinationsConnection) (elements[i] as MachinationsConnection).prepare(doEvents);
			}
			for (i = 0; i < l; i++) {
				if (elements[i] is MachinationsNode) (elements[i] as MachinationsNode).prepare(doEvents);
			}
			for (i = 0; i < l; i++) {
				if (elements[i] is ArtificialPlayer) (elements[i] as ArtificialPlayer).readInstructions();
			}
			for (i = 0; i < l; i++) {
				if (elements[i] is Register) (elements[i] as Register).prepare(doEvents);
			}
			//prepare connections again in reverse order to make sure nothing is inhibited // dirty dirty dirty but efficient
			for (i = l-1; i >= 0; i--) {
				if (elements[i] is MachinationsConnection) (elements[i] as MachinationsConnection).prepare(doEvents);
			}
			fireIntervalCounter = fireInterval;
			
			//check calculated registers NO LONGER REQUIRED?
			//trace("PREPARING CALCULATED");
			//for (i = 0; i < l; i++) {
			//	if (elements[i] is Register) (elements[i] as Register).prepareCalculated();
			//}
			
			
			//check dynamic probabilities
			for (i = 0; i < l; i++) {
				if (elements[i] is Gate) (elements[i] as Gate).checkDynamicProbabilities();
			}
			
			
			
			
			up = false;
			fireUp = false;
			
			//fire onStart nodes
			for (i = 0; i < l; i++) {
				if (elements[i] is MachinationsNode && (elements[i] as MachinationsNode).activationMode == MachinationsNode.MODE_ONSTART) (elements[i] as MachinationsNode).fire();
			}
			
		}
		
		public function stop():void {
			var l:int = elements.length;
			for (var i:int = 0; i < l; i++) {
				if (elements[i] is MachinationsNode) (elements[i] as MachinationsNode).stop();
				if (elements[i] is MachinationsConnection) (elements[i] as MachinationsConnection).stop();
			}
			for (i = 0; i < l; i++) {
				//if (elements[i] is Pool) (elements[i] as Pool).recalculate();
				if (elements[i] is MachinationsNode) (elements[i] as MachinationsNode).inhibited=false;
			}
		}
		
		public function updateCharts():void {
			var l:int = elements.length;
			var i:int;
			for (i = 0; i < l; i++) {
				if (elements[i] is Chart) (elements[i] as MachinationsNode).fire();
			}
		}
		
		public function update(time:Number, doEvents:Boolean):void {
			var l:int = elements.length;
			var i:int;
			if (ended) {
				for (i = 0; i < l; i++) {
					if (elements[i] is EndCondition) (elements[i] as EndCondition).update(time);
				}				
				return;
			}
			var firing:Boolean;
			
			switch (timeMode) {
				case TIME_MODE_ASYNCHRONOUS:
				case TIME_MODE_SYNCHRONOUS:
					//runningTime += time;
					fireIntervalCounter += time;
					firing = (fireIntervalCounter > fireInterval);
					if (firing) fireIntervalCounter -= fireInterval;
					break;
				case TIME_MODE_TURN_BASED:
					if (actionsThisTurn >= actionsPerTurn) {
						actionsThisTurn -= actionsPerTurn;
						firing = true;
					} else {
						firing = false;
					}
					break;
			}
			
			
			//alternate going up or down the list of element to avoid unfair advantages to elements that have been created earlier.
			up = !up;
			if (firing) {
				steps++;
				fireUp = !fireUp;
				if (fireUp) {
					for (i = 0; i < l; i++) {
						if (elements[i] is MachinationsNode && !(elements[i] is Delay)) (elements[i] as MachinationsNode).autoFire();
					}
				} else {
					for (i = l-1; i >= 0; i--) {
						if (elements[i] is MachinationsNode && !(elements[i] is Delay)) (elements[i] as MachinationsNode).autoFire();
					}
				}
				
				//fire delays aleter
				if (fireUp) {
					for (i = 0; i < l; i++) {
						if (elements[i] is Delay) (elements[i] as MachinationsNode).autoFire();
					}
				} else {
					for (i = l-1; i >= 0; i--) {
						if (elements[i] is Delay) (elements[i] as MachinationsNode).autoFire();
					}
				}
				
			}
			
			//resolve overpull
			if (timeMode == TIME_MODE_SYNCHRONOUS) {
				for (i = 0; i < l; i++) {
					if (elements[i] is Pool) (elements[i] as Pool).resolveOverPull();
				}
			}
			
			//activate other time based events
			if (up) {
				for (i = 0; i < l; i++) {
					if (elements[i] is MachinationsNode) (elements[i] as MachinationsNode).update(time);
					if (elements[i] is MachinationsConnection) (elements[i] as MachinationsConnection).update(time);
				}
			} else {
				for (i = l-1; i >= 0; i--) {				
					if (elements[i] is MachinationsNode) (elements[i] as MachinationsNode).update(time);
					if (elements[i] is MachinationsConnection) (elements[i] as MachinationsConnection).update(time);
				}
			}
		}
		
		public function getDiceValue():Number {
			if (dicePercentage > 0) {
				var r:int = Math.floor(dicePercentage / 100);
				if (Math.random() * 100 < (dicePercentage % 100)) r++;
				return r;
			}
			if (dicePostFix) return Math.max(0, MachinationsExpression.evaluatePostFix(dicePostFix));
			else return 0;
		}
		
		public function getSkillValue():Number {
			if (skillPercentage > 0) {
				var r:int = Math.floor(skillPercentage / 100);
				if (Math.random() * 100 < (skillPercentage % 100)) r++;
				return r;
			}
			if (skillPostFix) return Math.max(0, MachinationsExpression.evaluatePostFix(skillPostFix));
			else return 0;
		}
		
		public function getStrategyValue():Number {
			if (strategyPercentage > 0) {
				var r:int = Math.floor(strategyPercentage / 100);
				if (Math.random() * 100 < (strategyPercentage % 100)) r++;
				return r;
			}
			if (strategyPostFix) return Math.max(0, MachinationsExpression.evaluatePostFix(strategyPostFix));
			else return 0;
		}

		public function getMultiplayerValue():Number {
			if (multiplayerPercentage > 0) {
				var r:int = Math.floor(multiplayerPercentage / 100);
				if (Math.random() * 100 < (multiplayerPercentage % 100)) r++;
				return r;
			}
			if (multiplayerPostFix) return Math.max(0, MachinationsExpression.evaluatePostFix(multiplayerPostFix));
			else return 0;
		}
		
		public function findAllNodesByCaptionAndColor(caption:String, color:uint):Vector.<MachinationsNode> {
			var r:Vector.<MachinationsNode> = new Vector.<MachinationsNode>();
			if (caption == "") return r;
			for (var i:int = 0; i < elements.length; i++) {
				if (elements[i] is MachinationsNode) {
					if (StringUtil.trim((elements[i] as MachinationsNode).caption) == caption && (elements[i] as MachinationsNode).color == color) {
						r.push(elements[i] as MachinationsNode);
					}
				}
			}
			return r;
		}	
		
		public function findNodeByCaptionAndColor(caption:String, color:uint):MachinationsNode {
			if (caption == "") return null;
			for (var i:int = 0; i < elements.length; i++) {
				if (elements[i] is MachinationsNode) {
					if (StringUtil.trim((elements[i] as MachinationsNode).caption) == caption && (elements[i] as MachinationsNode).color == color) return (elements[i] as MachinationsNode);
				}
			}
			return null;
		}	
		
		public function findAllNodesByCaption(caption:String):Vector.<MachinationsNode> {
			var r:Vector.<MachinationsNode> = new Vector.<MachinationsNode>();
			if (caption == "") return r;
			for (var i:int = 0; i < elements.length; i++) {
				if (elements[i] is MachinationsNode) {
					if (StringUtil.trim((elements[i] as MachinationsNode).caption) == caption) {
						r.push(elements[i] as MachinationsNode);
					}
				}
			}
			return r;
		}
		
		public function findNodeByCaption(caption:String):MachinationsNode {
			if (caption == "") return null;
			for (var i:int = 0; i < elements.length; i++) {
				if (elements[i] is MachinationsNode) {
					if (StringUtil.trim((elements[i] as MachinationsNode).caption) == caption) return (elements[i] as MachinationsNode);
				}
			}
			return null;
		}
		

		
		public function pushToTop(element:GraphElement):void
		{
			var l:int = elements.length;
			for (var i:int = 0; i < l - 1; i++) {
				if (elements[i] == element) {
					elements.splice(i, 1);
					elements.push(element);
					break;
				}
			}
		}
		
	}

}