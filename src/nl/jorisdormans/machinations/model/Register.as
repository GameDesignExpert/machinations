package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.utils.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Register extends MachinationsNode
	{
		private var _value:int;
		private var calculated:Boolean;
		public var minValue:int;
		public var maxValue:int;
		private var _startValue:int;
		public var valueStep:int;
		public static const LIMIT:int = 9999;
		public var interaction:int = 0;
		public var hasTriggers:Boolean = false;
		public var isTriggered:Boolean = false;
		
		private var postFix:Array;
		private var values:Array;
		private var expression:Boolean;
		
		public function Register() 
		{
			
			super();
			size = 32;
			_value = 0;
			calculated = true;
			minValue = -LIMIT;
			maxValue = LIMIT;
			valueStep = 1;
			_startValue = 0;
			values = new Array();
			this.actions = 0;
			for (var i:int = 0; i < 26; i++) values.push(0);
		}
		
		public function reset():void {
			calculated = false;
		}
		
		override public function fire():void 
		{
			if (hasTriggers && isTriggered && interaction==0) {
				var r:Number = Math.random() * 100;
				for (i = 0; i < this.outputs.length; i++) {
					if (this.outputs[i] is StateConnection && (this.outputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER) {
						if (r < _value) 
							(this.outputs[i] as StateConnection).fire();
					}
					if (this.outputs[i] is StateConnection && (this.outputs[i] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER) {
						if (r >= _value) 
							(this.outputs[i] as StateConnection).reverseFire();
					}
				}
			}
			
			//implement changes
			if (interaction!=0) {
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				var previous:int = _value;
				_value += interaction;
				interaction = 0;
				_value = Math.min(Math.max(_value, minValue), maxValue);
				calculateValue();
				var l:int = outputs.length;
				for (var i:int = 0; i < l; i++) {
					if (outputs[i] is StateConnection) {
						(outputs[i] as StateConnection).changeState(_value-previous);
					}
				}				
				
				
			}
			
			super.fire();
		}
		
		override public function autoFire():void 
		{
			super.autoFire();
			if (hasTriggers && !isTriggered) {
				var r:Number = Math.random() * 100;
				for (var i:int = 0; i < this.outputs.length; i++) {
					if (this.outputs[i] is StateConnection && (this.outputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER) {
						if (r < _value) 
							(this.outputs[i] as StateConnection).fire();
					}
					if (this.outputs[i] is StateConnection && (this.outputs[i] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER) {
						if (r >= _value) 
							(this.outputs[i] as StateConnection).reverseFire();
					}
				}

			}
		}
		
		public function get value():int
		{
			if (!calculated) {
				calculateValue();
			}
			return _value;
		}
		
		public function get startValue():int 
		{
			return _startValue;
		}
		
		public function set startValue(value:int):void 
		{
			_startValue = value;
			if (activationMode == MODE_INTERACTIVE) _value = _startValue;
		}
		
		/*public function set value(value:Number):void 
		{
			_value = value;
		}*/
		
		override public function getConnection(towards:Vector3D):Vector3D 
		{
			var d:Vector3D = position.clone();
			var u:Vector3D = towards.subtract(position);
			u.normalize();
			var p:Vector3D = MathUtil.getSquareOutlinePoint(u, 0.5 * size + thickness + 1);
			d.incrementBy(p);
			return d;			
			//return super.getConnection(towards);
		}
		
		public function calculateValue():void {
			if (activationMode == MODE_INTERACTIVE) {
				calculated = true;
				return;
			}
			var l:int = inputs.length;
			var i:int;
			var newValue:int = 0;
			if (expression) {
				for (i = 0; i < l; i++) {
					if (inputs[i] is StateConnection) {
						var j:int = (inputs[i] as StateConnection).label.text.charCodeAt(0) - 97;
						if (j >= 0 && j < values.length) values[j] = (inputs[i] as StateConnection).state;
					}
				}
				newValue = MachinationsRegisterExpression.evaluate(postFix, values);
			} else if (caption.toLowerCase() == "max") {
				//find the maximum value
				newValue = int.MIN_VALUE;
				for (i = 0; i < l; i++) {
					if (inputs[i] is StateConnection) {
						if (newValue < (inputs[i] as StateConnection).state) {
							newValue = (inputs[i] as StateConnection).state
						}
					}
				}
			} else if (caption.toLowerCase() == "min") {
				//find the maximum value
				newValue = int.MAX_VALUE;
				for (i = 0; i < l; i++) {
					if (inputs[i] is StateConnection) {
						if (newValue > (inputs[i] as StateConnection).state) {
							newValue = (inputs[i] as StateConnection).state
						}
					}
				}
			} else {
				//no caption simply add all inputs;
				for (i = 0; i < l; i++) {
					if (inputs[i] is StateConnection) {
						newValue += (inputs[i] as StateConnection).state * (inputs[i] as StateConnection).label.value;
					}
				}		
				if (caption.toLowerCase() == "actions" && (graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
					(graph as MachinationsGraph).actionsPerTurn = newValue;
				}
			}
			
			newValue = Math.min(Math.max(newValue, minValue), maxValue);
			
			if (newValue != _value) {
				var delta:int = newValue-_value;
				_value = newValue;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				l = outputs.length;
				for (i = 0; i < l; i++) {
					if (outputs[i] is StateConnection) {
						(outputs[i] as StateConnection).changeState(delta);
					}
				}
			}
			calculated = true;
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			/*if (stateInputCount == 0) {
				this.activationMode = MODE_INTERACTIVE;
			} else {
				this.activationMode = MODE_PASSIVE;
			}*/
			expression = false;
			if (this.activationMode != MODE_INTERACTIVE && caption != "" && caption != "max" && caption != "min") {
				if (!MachinationsRegisterExpression.isVariable(caption) && caption.indexOf("+") < 0 && caption.indexOf("-") < 0 && caption.indexOf("%") < 0  && caption.indexOf("*") < 0 && caption.indexOf("/") < 0 && caption.indexOf("D") < 0 && caption.indexOf("(") < 0 && caption.indexOf(")") < 0) {
					expression = false;
				} else {
					postFix = MachinationsRegisterExpression.toPostFix(caption);
					expression = true;
					for (var i:int = 0; i < values.length; i++) values[i] = 0;
					calculateValue();
				}
			}
			if (this.activationMode == MODE_INTERACTIVE) {
				calculated = true;
				_value = startValue;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			} else if (!calculated) {
				_value = 0;
			}
			
			hasTriggers = false;
			for (i = 0; i < this.outputs.length; i++) {
				if (this.outputs[i] is StateConnection && ((this.outputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER || (this.outputs[i] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER)) {
					hasTriggers = true;
					break;
				}
			}
			
			isTriggered = false;
			for (i = 0; i < this.inputs.length; i++) {
				if (this.inputs[i] is StateConnection && ((this.inputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER || (this.inputs[i] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER)) {
					isTriggered = true;
					break;
				}
			}
		}
		
		public function prepareCalculated():void {
			if (this.activationMode == MODE_INTERACTIVE) return;
			if (!calculated)
			{
				_value = 0;
			}
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection) {
					(outputs[i] as StateConnection).resetState();
				}
			}
			calculateValue();
		}
		
		override public function stop():void 
		{
			super.stop();
			if (activationMode == MODE_INTERACTIVE) {
				_value = startValue;
			} else {
				_value = 0;
			}
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@min = minValue;
			xml.@max = maxValue;
			xml.@start = startValue;
			xml.@step = valueStep;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			minValue = xml.@min;
			maxValue = xml.@max;
			startValue = xml.@start;
			valueStep = xml.@step;
			this.actions = 0;
		}
		
		
	}

}