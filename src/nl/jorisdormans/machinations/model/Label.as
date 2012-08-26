package nl.jorisdormans.machinations.model 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Label
	{
		public var position:Number;
		public var connection:MachinationsConnection;
		public var calculatedPosition:Vector3D;
		public var calculatedNormal:Vector3D;
		private var _text:String;
		public var align:String;
		public var size:Point;
		public var side:int = 1;
		private var intervalText:String;
		private var preIntervalText:String;
		private var postFix:Array;
		private var postFixInterval:Array;
		private var _value:Number;
		public var type:String;
		public var intervalType:String;
		//private var _changeValue:Number;
		private var probability:Number;
		private var inputStateValue:Number;
		private var inputStateInterval:Number;
		private var _interval:int;
		private var rangeTop:Number;
		private var rest:Number;
		public var drawRandom:Boolean = false;
		
		private var multiplier:int;
		private var originalMutliplier:int;
		
		public var generatedValues:Vector.<Number>;
		
		public static const TYPE_CALCULATED_VALUE:String = "calculated";
		public static const TYPE_FIXED_VALUE:String = "fixed";
		public static const TYPE_NONE:String = "none";
		public static const TYPE_CHANGE_VALUE:String = "change_value";
		public static const TYPE_CHANGE_INTERVAL:String = "change_interval";
		public static const TYPE_CHANGE_PROBABILITY:String = "change_probability";
		public static const TYPE_CHANGE_MULTIPLIER:String = "change_multiplier";
		public static const TYPE_PROBABILITY:String = "probability";
		public static const TYPE_PROBABILITY_DYNAMIC:String = "probability_dynamic";
		public static const TYPE_EQUAL_TO:String = "equal_to";
		public static const TYPE_NOT_EQUAL_TO:String = "not_equal_to";
		public static const TYPE_LESS:String = "less";
		public static const TYPE_GREATER:String = "greater";
		public static const TYPE_LESS_OR_EQUAL:String = "less_or_equal";
		public static const TYPE_GREATER_OR_EQUAL:String = "greater_or_equal";
		public static const TYPE_RANGE:String = "range";
		public static const TYPE_DICE:String = "dice";
		public static const TYPE_SKILL:String = "random";
		public static const TYPE_MULTIPLAYER:String = "multiplayer";
		public static const TYPE_STRATEGY:String = "strategy";
		public static const TYPE_TRIGGER:String = "trigger";
		public static const TYPE_REVERSE_TRIGGER:String = "reverse_trigger";
		public static const TYPE_ELSE:String = "else";
		public static const TYPE_ALL:String = "all";
		//public static const TYPE_DRAW:String = "draw";
		
		public static const LIMIT:Number = 9999;
		
		public var min:Number = -LIMIT;
		public var max:Number = LIMIT;
		
		private static const MAX_DIGIT:int = 3;
		private static const MAX_PROBABILITY_DIGIT:int = 1;
		private static const MAX_MULTIPLIER_DIGIT:int = 0;

		
		public function Label(connection:MachinationsConnection, position:Number, text:String) 
		{
			generatedValues = new Vector.<Number>();
			this.connection = connection;
			this.position = position;
			this.text = text;
			align = PhantomFont.ALIGN_LEFT;
			size = new Point();
			inputStateInterval = 0;
			inputStateValue = 0;
			preIntervalText = "";
			intervalText = "";
			rest = 0;
			drawRandom = false;
			multiplier = -1;
			originalMutliplier = multiplier;
		}
		
		public function pointInModifier(x:Number, y:Number):Boolean {
			switch (align) {
				default:
				case PhantomFont.ALIGN_LEFT:
					return (x > calculatedPosition.x - 5 && x < calculatedPosition.x + size.x + 5 && y > calculatedPosition.y - 10 && y < calculatedPosition.y + size.y);
				case PhantomFont.ALIGN_RIGHT:
					return (x > calculatedPosition.x - size.x - 5 && x < calculatedPosition.x + 5 && y > calculatedPosition.y - 10 && y < calculatedPosition.y + size.y);
				case PhantomFont.ALIGN_CENTER:
					return (x > calculatedPosition.x - size.x * 0.5  - 5 && x < calculatedPosition.x + size.x * 0.5 + 5 && y > calculatedPosition.y - 10 && y < calculatedPosition.y + size.y);
				
			}
		}
		
		public function generateNewValue():void
		{
			generatedValues.splice(0, generatedValues.length);
			
			switch (type) {
				case TYPE_EQUAL_TO:
				case TYPE_GREATER:
				case TYPE_GREATER_OR_EQUAL:
				case TYPE_CHANGE_INTERVAL:
				case TYPE_CHANGE_VALUE:
				case TYPE_CHANGE_PROBABILITY:
				case TYPE_CHANGE_MULTIPLIER:
				case TYPE_ALL:
				case TYPE_LESS:
				case TYPE_LESS_OR_EQUAL:
				case TYPE_NOT_EQUAL_TO:
				case TYPE_RANGE:
				case TYPE_TRIGGER:
				case TYPE_REVERSE_TRIGGER:
				case TYPE_PROBABILITY_DYNAMIC:
					generatedValues.push(_value);
					return;
				case TYPE_NONE:
					_value = 1;
					generatedValues.push(_value);
					return;
				case TYPE_ELSE:
					_value = 1;
					generatedValues.push(_value);
					return;
				case TYPE_DICE:
					if (connection.graph) _value = (connection.graph as MachinationsGraph).getDiceValue() + inputStateValue;
					generatedValues.push(_value);
					return;
				case TYPE_SKILL:
					if (connection.graph) _value = (connection.graph as MachinationsGraph).getSkillValue() + inputStateValue;
					generatedValues.push(_value);
					return;
				case TYPE_MULTIPLAYER:
					if (connection.graph) _value = (connection.graph as MachinationsGraph).getMultiplayerValue() + inputStateValue;
					generatedValues.push(_value);
					return;
				case TYPE_STRATEGY:
					if (connection.graph) _value = (connection.graph as MachinationsGraph).getStrategyValue() + inputStateValue;
					generatedValues.push(_value);
					return;
			}
			_value = 0;
			var m:int = multiplier;
			if (originalMutliplier<0) { 
				m = 1;
			}
			
			
			for (var i:int = 0; i < m; i++) {
				switch (type) {
					case TYPE_FIXED_VALUE:
						var v:Number = postFix[0] as Number;
						v += inputStateValue;
						if (connection is ResourceConnection) {
							v += rest;
							_value += Math.floor(v); 
							generatedValues.push(Math.floor(v));
							rest = v % 1;
							break;
						} else {
							_value += v;
							generatedValues.push(v);
						}
					case TYPE_CALCULATED_VALUE:
						v = MachinationsExpression.evaluatePostFix(postFix);
						v += inputStateValue;
						if (connection is ResourceConnection) {
							v += rest;
							_value += Math.floor(v); 
							generatedValues.push(Math.floor(v));
							rest = v % 1;
						} else {
							_value += v;
							generatedValues.push(v);
						}
						break;
					case TYPE_PROBABILITY:
						var p:Number = probability + inputStateValue;
						v = 0;
						while (p>100) {
							v += 1;
							p -= 100;
						}
						if ((Math.random() * 100) < p) {
							v++;
						}
						_value += v;
						generatedValues.push(v);
						break;
				}
				
			}
		}
		
		public function get value():Number {
			if (connection is ResourceConnection && intervalType != TYPE_NONE) {
				if (_interval > 1) {
					_interval--;
					return 0;
				} else {
					setNewInterval();
				}
			}
			switch (type) {
				case TYPE_PROBABILITY_DYNAMIC:
				case TYPE_PROBABILITY:
					if (connection.start is Gate) return Math.max(min, (Math.min, (max, probability + inputStateValue)));
					else return Math.max(min, (Math.min(max, _value)));
				case TYPE_ALL:
					if (connection.start is Pool) {
						if ((connection.start as Pool).color != connection.color) {
							return Math.max(0, Math.max(min, (Math.min(max, (connection.start as Pool).resourceColorCount(connection.color)))));
						} else {
							return Math.max(0, Math.max(min, (Math.min(max, (connection.start as Pool).resourceCount))));
						}
					}
					return 0;
				//case TYPE_DRAW:
				//	return Math.max(min, (Math.min(max, _value + inputStateValue)));
				case TYPE_CHANGE_VALUE:
				case TYPE_CHANGE_INTERVAL:
				case TYPE_CHANGE_PROBABILITY:
					var v:Number = _value + inputStateValue;
					return Math.max(min, (Math.min(max, v)));
				default:
					//var v:Number = _value + inputStateValue;
					//return v;
					return Math.max(min, (Math.min(max, _value)));
			}
		}
		
		private function setNewInterval():void
		{
			switch (intervalType) {
				default:
				case TYPE_NONE:
					_interval = 1;
					break;
				case TYPE_FIXED_VALUE:
					_interval = Math.floor(postFixInterval[0]) + inputStateInterval;
					break;
				case TYPE_CALCULATED_VALUE:
					_interval = Math.floor(MachinationsExpression.evaluatePostFix(postFixInterval)) + inputStateInterval;
					break;
			}
		}
		
		public function get text():String {
			if (_text == "") return "";
			var v:Number;
			var t:String = _text;
			switch (type) {
				case TYPE_NONE:
					return "";
				case TYPE_DICE:
				case TYPE_SKILL:
				case TYPE_MULTIPLAYER:
				case TYPE_STRATEGY:
					t = "   " + getIntervalText();
					return t;
			}
			
			t = this.preIntervalText;
			if (inputStateValue!=0) {
				switch (type) {
					case TYPE_FIXED_VALUE:
						v = postFix[0] as Number;
						v += inputStateValue;
						v = Math.round(v * 100) / 100;
						v = Math.max(min, (Math.min(max, v)));
						
						t = StringUtil.floatToStringMaxPrecision(v, MAX_DIGIT);
						break;
					case TYPE_CALCULATED_VALUE:
						v = Math.round(inputStateValue);
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t =(preIntervalText + StringUtil.floatToStringMaxPrecision(v, MAX_DIGIT));
						else if (v>0) t = (preIntervalText + "+" + StringUtil.floatToStringMaxPrecision(v, MAX_DIGIT));
						break;
					case TYPE_PROBABILITY:
						v = probability + Math.round(inputStateValue);
						v = Math.max(min, (Math.min(max, v)));
						t = (StringUtil.floatToStringMaxPrecision(v, MAX_PROBABILITY_DIGIT) + "%");
						break;
					case TYPE_PROBABILITY_DYNAMIC:
						v = probability;
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t = "%";
						else t = (StringUtil.floatToStringMaxPrecision(v, MAX_PROBABILITY_DIGIT) + "%");
						break;
					case TYPE_CHANGE_VALUE:
						//v = _changeValue + inputStateValue;
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t = (StringUtil.floatToStringMaxPrecision(v, MAX_DIGIT));
						else t = ("+" + StringUtil.floatToStringMaxPrecision(v, MAX_DIGIT));
						break;
					case TYPE_CHANGE_INTERVAL:
						//v = Math.round(_changeValue + inputStateValue);
						v = Math.round(_value + inputStateValue);
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t = (StringUtil.floatToStringMaxPrecision(v, MAX_MULTIPLIER_DIGIT) + "i");
						else t = ("+" + StringUtil.floatToStringMaxPrecision(v, MAX_MULTIPLIER_DIGIT) + "i");
						break;
					case TYPE_CHANGE_PROBABILITY:
						//v = _changeValue + inputStateValue;
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t = (StringUtil.floatToStringMaxPrecision(v, MAX_PROBABILITY_DIGIT) + "%");
						else t = ("+" + StringUtil.floatToStringMaxPrecision(v, MAX_PROBABILITY_DIGIT) + "%");
						break;
					case TYPE_CHANGE_MULTIPLIER:
						//v = _changeValue + inputStateValue;
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						if (v < 0) t = (StringUtil.floatToStringMaxPrecision(v, MAX_MULTIPLIER_DIGIT) + "m");
						else t = ("+" + StringUtil.floatToStringMaxPrecision(v, MAX_MULTIPLIER_DIGIT) + "m");
						break;
					case TYPE_EQUAL_TO:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = "==" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_NOT_EQUAL_TO:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = "!=" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_LESS_OR_EQUAL:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = "<=" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_LESS:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = "<" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_GREATER_OR_EQUAL:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = ">=" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_GREATER:
						v = _value + inputStateValue;
						v = Math.max(min, (Math.min(max, v)));
						t = ">" + StringUtil.floatToStringMaxPrecision(v, 0);
						break;
					case TYPE_TRIGGER:
						t = "!";
						break;
					case TYPE_TRIGGER:
						t = "*";
						break;
					case TYPE_ALL:
						t = "all";
						break;
				}
			}
			t += getIntervalText();
			if (drawRandom && t.substr(0, 4) != "draw") t = "draw" + t;
			
			if (originalMutliplier >= 0) {
				t = multiplier.toString() + "*" + t;
			}
			return t;
		}
		
		private function getIntervalText():String {
			var t:String;
			if (intervalText == null || intervalText == "") t = "";
			else t = "/" + intervalText;
			var v:int;
			if (inputStateInterval != 0) {
				switch (intervalType) {
					case TYPE_FIXED_VALUE:
						v = postFixInterval[0] + Math.round(inputStateInterval);
						t = "/"+(v.toString());
						break;
					case TYPE_CALCULATED_VALUE:
						v = Math.round(inputStateInterval);
						if (v < 0) t =(intervalText + v.toString());
						else if (v>0) t = "/"+(intervalText + "+" + v.toString());
						break;
				}
			}
			return t;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
			determineType();
			generateNewValue();
			setNewInterval();
		}
		
		public function getRealText():String {
			return _text;
		}
		
		/*public function get changeValue():Number { 
			return _changeValue + inputStateValue; 
		}
		
		public function set changeValue(value:Number):void 
		{
			_changeValue = value;
		}*/
		
		public function get interval():int { return _interval; }
		
		public function prepare():void {
			determineType();
			inputStateValue = 0;
			inputStateInterval = 0;
			rest = 0;
			generateNewValue();
			setNewInterval();
		}
		
		public function reset():void {
			inputStateValue = 0;
		}
		
		public function determineType():void {
			var text:String = this._text;
			drawRandom = false;
			
			var p:int;
			//var p2:int;
			intervalType = TYPE_NONE;
			if (text == "") {
				if (connection is ResourceConnection) {
					type = TYPE_NONE;
					generateNewValue();
				} else {
					type = TYPE_CHANGE_VALUE;
					_value = 1;
					//_changeValue = 1;
				}
				return;
			}
			
			p = text.indexOf("*");
			if (p > 0) {
				multiplier = parseInt(text.substr(0, p));
				text =  text.substr(p + 1);
			} else {
				multiplier = -1;
			}
			originalMutliplier = multiplier;
			
			p = text.indexOf("/");
			if (p >= 0) {
				preIntervalText = text.substr(0, p);
				intervalText = text.substr(p + 1);
				text = preIntervalText;
				postFixInterval = MachinationsExpression.toPostFix(intervalText);
				if (postFixInterval.length == 1) {
					intervalType = TYPE_FIXED_VALUE;
				} else {
					intervalType = TYPE_CALCULATED_VALUE;
				}
			} else {
				preIntervalText = text;
				intervalText = "";
			}
			
			if (text.substr(0, 4) == "draw") {
				drawRandom = true;
				text = text.substr(4);
			}
			
			
			if (text == "*") {
				type = TYPE_TRIGGER;
				_value = 0;				
			} else if (text == "!") {
				type = TYPE_REVERSE_TRIGGER;
				_value = 0;
			} else if (text == "%") {
				type = TYPE_PROBABILITY_DYNAMIC;
				probability = -1;
				_value = 0;
			} else if (text.toLowerCase() == "else") {
				type = TYPE_ELSE;
				probability = 0;
				_value = 0;
			} else if (text.toLowerCase()  == "all") {
				type = TYPE_ALL;
				probability = 0;
				_value = 0;
			} else if (text == "D" /*|| text.toLowerCase() == "dice"*/) {
				type = TYPE_DICE;
			} else if (text == "S" /*|| text.toLowerCase() == "skill"*/) {
				type = TYPE_SKILL;
			} else if (text == "ST" /*|| text.toLowerCase() == "strategy"*/) {
				type = TYPE_STRATEGY;
			} else if (text == "M" /*|| text.toLowerCase() == "multiplayer"*/) {
				type = TYPE_MULTIPLAYER;
			} else if (text.substr(0, 2) == "==") {
				type = TYPE_EQUAL_TO;
				_value = parseFloat(text.substr(2));
			} else if (text.substr(0, 2) == "!=") {
				type = TYPE_NOT_EQUAL_TO;
				_value = parseFloat(text.substr(2));
			} else if (text.substr(0, 2) == "<=") {
				type = TYPE_LESS_OR_EQUAL;
				_value = parseFloat(text.substr(2));
			} else if (text.substr(0, 2) == ">=") {
				type = TYPE_GREATER_OR_EQUAL;
				_value = parseFloat(text.substr(2));
			} else if (text.substr(0, 1) == "<") {
				type = TYPE_LESS;
				_value = parseFloat(text.substr(1));
			} else if (text.substr(0, 1) == ">") {
				type = TYPE_GREATER;
				_value = parseFloat(text.substr(1));
			} else if (connection.start is Gate && text.indexOf("-")>0) {
				type = TYPE_RANGE;
				p = text.indexOf("-");
				_value = parseFloat(text.substr(0, p));
				rangeTop = parseFloat(text.substr(p+1));
			} else if (text.charAt(0) == "+" || (text.charAt(0) == "-" && connection is StateConnection)) {
				type = TYPE_CHANGE_VALUE;
				p = text.indexOf("m");
				if (p >= 0) {
					type = TYPE_CHANGE_MULTIPLIER;
					text = text.substr(0, p);
				}
				p = text.indexOf("i");
				if (p >= 0) {
					type = TYPE_CHANGE_INTERVAL;
					text = text.substr(0, p);
				}
				p = text.indexOf("%");
				if (p >= 0) {
					type = TYPE_CHANGE_PROBABILITY;
					text = text.substr(0, p);
				}
				//changeValue = parseFloat(text.substr(1));
				_value = parseFloat(text.substr(1));
				if (text.charAt(0) == "-") _value *= -1;					
			} else if (text.indexOf("%") > 0) {
				type = TYPE_PROBABILITY;
				probability = parseFloat(text.substr(0, text.indexOf("%")));
				if (isNaN(probability)) probability = 0;
			} else {
				postFix = MachinationsExpression.toPostFix(text);
				if (postFix.length == 1) {
					type = TYPE_FIXED_VALUE;
				} else {
					type = TYPE_CALCULATED_VALUE;
				}
			}
			
		}
		
		public function stop():void {
			inputStateValue = 0;
			inputStateInterval = 0;
			multiplier = originalMutliplier;
		}
		
		public function modify(delta:Number):void {
			inputStateValue += delta;
			generateNewValue();
			if (connection.doEvents) connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
			if ((connection.start is Gate) && type == TYPE_PROBABILITY) {
				(connection.start as Gate).checkDynamicProbabilities();
			}
			if (isCondition() && connection is StateConnection) {
				(connection as StateConnection).inhibited = !checkCondition((connection as StateConnection).state)
				
			}			
			
			/*
			//Changes to label modifiers immediately take effect, maybe this should be an optional setting. 
			switch (type) {
				case TYPE_CHANGE_VALUE:
				case TYPE_CHANGE_INTERVAL:
				case TYPE_CHANGE_PROBABILITY:
					if (connection is StateConnection) {
						(connection as StateConnection).changeModifier(delta);
					}
					break;
			}
			//*/
		}
		
		public function modifyInterval(delta:int):void {
			inputStateInterval += delta;
			generateNewValue();
			if (connection.doEvents) connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
		}
		
		public function modifyMultiplier(delta:int):void {
			multiplier += delta;
			generateNewValue();
			if (connection.doEvents) connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
		}
		
		/*public function recalculate():void {
			inputStateValue = 0;
			inputStateInterval = 0;
			var l:int = connection.inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (connection.inputs[i] is StateConnection && (connection.inputs[i] as StateConnection).label.type == TYPE_CHANGE_INTERVAL) {
					inputStateInterval += (connection.inputs[i] as StateConnection).state;
				} else {
					inputStateValue += (connection.inputs[i] as StateConnection).state;
				}
			}
			generateNewValue();
			if (connection is StateConnection) (connection as StateConnection).resetState();
			
			if (connection.doEvents) connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
			
			if (connection.start is Gate && type == TYPE_PROBABILITY) {
				(connection.start as Gate).checkDynamicProbabilities();
			}
		}*/
		
		public function isCondition():Boolean
		{
			switch (type) {
				case Label.TYPE_GREATER:
				case Label.TYPE_GREATER_OR_EQUAL:
				case Label.TYPE_EQUAL_TO:
				case Label.TYPE_LESS:
				case Label.TYPE_LESS_OR_EQUAL:
				case Label.TYPE_NOT_EQUAL_TO:
				case Label.TYPE_RANGE:
				case Label.TYPE_ELSE:
					return true;
			}
			return false;
		}
		
		
		public function checkCondition(value:Number):Boolean
		{
			if (!connection.graph || !(connection.graph as MachinationsGraph).running) return  true;
			switch (type) {
				case Label.TYPE_GREATER:
					return (value > (_value + inputStateValue));
				case Label.TYPE_GREATER_OR_EQUAL:
					return (value >= (_value + inputStateValue));
				case Label.TYPE_EQUAL_TO:
					return (value == _value + inputStateValue);
				case Label.TYPE_LESS:
					return (value < (_value + inputStateValue));
				case Label.TYPE_LESS_OR_EQUAL:
					return (value <= _value + inputStateValue);
				case Label.TYPE_NOT_EQUAL_TO:
					return (value != _value + inputStateValue);
				case Label.TYPE_RANGE:
					return (value >= _value && value <= rangeTop);
				case Label.TYPE_FIXED_VALUE:
					return (value == _value + inputStateValue);
				case Label.TYPE_ELSE:
					return false;
			}
			return false;
		}
		
		public function setDynamicProbability(prob:Number):void
		{
			if (prob != probability) {
				probability = prob;
				inputStateValue = 1;
				if (connection.doEvents) connection.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, connection));
			}
		}
		
	}

}