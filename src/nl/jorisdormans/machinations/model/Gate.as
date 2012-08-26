package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.ResourceConnection;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Gate extends MachinationsNode
	{
		public static const GATE_DETERMINISTIC:String = "deterministic";
		public static const GATE_DICE:String = "dice";
		public static const GATE_SKILL:String = "skill";
		public static const GATE_STRATEGY:String = "strategy";
		public static const GATE_MULTIPLAYER:String = "multiplayer";
		
		private static const OUTPUT_PROBABLE:String = "probable";
		private static const OUTPUT_PROBABLE_PERCENTAGE:String = "probable_percentage";
		private static const OUTPUT_CONDITIONAL:String = "conditional";
		private static const OUTPUT_COLOR_CODED:String = "color_coded";
		
		public var gateType:String;
		private var outputType:String;
		
		
		public var value:int;
		public var displayValue:Number = 0;
		public var counting:Number = 0;
		public var inputStateValue:Number;
		
		
		public function Gate() 
		{
			super();
			size = 16;
			gateType = GATE_DETERMINISTIC;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@gateType = gateType;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			gateType = xml.@gateType;
		}
		
		override public function fire():void 
		{
			super.fire();
			if (resourceInputCount == 0) {
				satisfy();
				receiveResource(0xffffff, null);
			} else {
				pull();
			}
		}
		override public function satisfy():void 
		{
			super.satisfy();
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection && (outputs[i] as StateConnection).label.type == Label.TYPE_TRIGGER) (outputs[i] as StateConnection).fire();
			}
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			outputType = OUTPUT_PROBABLE;
			//determine output type
			resourceOutputCount = 0;
			var l:int = outputs.length;
			var color:uint = this.color;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = outputs[i] as MachinationsConnection;
				if (output) {
					resourceOutputCount++;
					if (output.label.type == Label.TYPE_PROBABILITY) {
						outputType = OUTPUT_PROBABLE_PERCENTAGE;
					}
					if (output.label.isCondition()) {
						outputType = OUTPUT_CONDITIONAL;
					}
					if (resourceOutputCount == 1) {
						color = output.color;
					} else {
						if (color != output.color && outputType == OUTPUT_PROBABLE) {
							outputType = OUTPUT_COLOR_CODED;
						}
					}
				}
			}
			if (outputType == OUTPUT_CONDITIONAL && gateType == GATE_DETERMINISTIC) value = 0;
			else value = -1;
			counting = 0;
			inputStateValue = 0;
			if (outputType == OUTPUT_PROBABLE_PERCENTAGE) checkDynamicProbabilities();
			//trace("GATE", gateType, outputType);
		}
		
		override public function stop():void 
		{
			displayValue = 0;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			super.stop();
		}
		
		override public function receiveResource(color:uint, flow:ResourceConnection):void 
		{
			//if (_inhibited) return;
			super.receiveResource(color, flow);
			//determine value
			switch (outputType) {
				case OUTPUT_CONDITIONAL:
					distributeConditional(color);
					break;
				case OUTPUT_PROBABLE:
					distributeProbable(color);
					break;
				case OUTPUT_PROBABLE_PERCENTAGE:
					distributeProbablePercentage(color);
					break;
				case OUTPUT_COLOR_CODED:
					distributeColorCoded(color);
					break;
			}
			
			//if (doEvents && flowOutputCount == 1) {
			if (doEvents && outputType == OUTPUT_CONDITIONAL) {
				displayValue = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
				dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			}
			
		}
		
		override public function autoFire():void 
		{
			if ((graph as MachinationsGraph).actionsPerTurn > 0 && outputType == OUTPUT_CONDITIONAL && gateType == GATE_DETERMINISTIC) {
				value = 0;
			}
			super.autoFire();
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if (counting > 0) {
				counting -= time;
				if (counting <= 0) {
					counting = 0;
					value =  inputStateValue;
				}
			}
			if (displayValue > 0) {
				displayValue-= time;
				if (displayValue <= 0) {
					displayValue = 0;
					dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
				}
			}
		}
		
		private function produce(color:uint, output:MachinationsConnection):void
		{
			var flow:ResourceConnection = output as ResourceConnection;
			if (flow) {
				flow.resources.push(new Resource(color, 0));
				flow.requestQueue.push(1);
			}
			var state:StateConnection = output as StateConnection;
			if (state) {
				state.fire();
			}
		}
		
		private function distributeColorCoded(color:uint):void
		{
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = outputs[i] as MachinationsConnection
				if (output && output.color == color) {
					produce(color, output);
					return;
				}
			}
			
			if ((graph as MachinationsGraph).colorCoding>0) {
				//still here so distribute probable and change the color
				distributeProbable(0x01000000);
			/*} else {
				//still here so direct to the first connection with the same color as the gate
				for (i = 0; i < l; i++) {
					output = outputs[i] as MachinationsConnection
					if (output && output.color == this.color) {
						produce(color, output);
						return;
					}
				}*/
			}
			
		}
		
		private function distributeProbablePercentage(color:uint):void
		{
			if (gateType == GATE_DETERMINISTIC) {
				value += 11;
				value %= 100;
			} else {
				value = Math.random() * 100;
			}
			var r:Number = value;
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = outputs[i] as MachinationsConnection
				if (output) {
					if (r < output.label.value) {
						produce(color, output);
						return;
					}
					r -= output.label.value;
				}
			}
		}
		
		private function distributeProbable(color:uint):void
		{
			var t:Number = 0;
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = outputs[i] as MachinationsConnection
				if (output) {
					t += output.label.value;
				}
			}
			
			if (gateType == GATE_DETERMINISTIC) {
				value++;
				value %= t;
			} else {
				value = Math.random() * t;
			}
			var r:Number = value;
			
			for (i = 0; i < l; i++) {
				output = outputs[i] as MachinationsConnection
				if (output) {
					if (r < output.label.value) {
						//if color is undetermined, adapt color from output
						if (color == 0x01000000) {
							color = output.color;
						}
						produce(color, output);
						return;
					}
					r -= output.label.value;
				}
			}
			
			
		}
		
		private function distributeConditional(color:uint):void
		{
			switch (gateType) {
				case GATE_DETERMINISTIC:
					value++;
					if (counting == 0 && (graph as MachinationsGraph).actionsPerTurn==0) {
						counting = (graph as MachinationsGraph).fireInterval - 0.001;
					}
					break;
				default:
				case GATE_DICE:
					value = (graph as MachinationsGraph).getDiceValue() + inputStateValue;
					break;
				case GATE_SKILL:
					value = (graph as MachinationsGraph).getSkillValue() + inputStateValue;
					break;
				case GATE_STRATEGY:
					value = (graph as MachinationsGraph).getStrategyValue() + inputStateValue;
					break;
				case GATE_MULTIPLAYER:
					value = (graph as MachinationsGraph).getMultiplayerValue() + inputStateValue;
					break;
				
			}
			
			var produced:Boolean = false;
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = outputs[i] as MachinationsConnection
				if (output) {
					if (output.label.checkCondition(value)) {
						produced = true;
						produce(color, output);
					}
				}
			}
			if (!produced) {
				for (i = 0; i < l; i++) {
					output = outputs[i] as MachinationsConnection
					if (output && output.label.type == Label.TYPE_ELSE) {
						produce(color, output);
					}
				}
			}
			
			
		}
		
		public function modify(delta:Number):void {
			inputStateValue += delta;
		}
		
		/*public function recalculate():void {
			inputStateValue = 0;
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection) inputStateValue += (inputs[i] as StateConnection).state;
			}
		}*/	
		
		public function checkDynamicProbabilities():void {
			var prob:Number = 0;
			var dynProb:int = 0;
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				var output:MachinationsConnection = (outputs[i] as MachinationsConnection);
				if (output.label.type == Label.TYPE_PROBABILITY_DYNAMIC) {
					dynProb++;
				}
				if (output.label.type == Label.TYPE_PROBABILITY) {
					prob+=output.label.value;
				}
			}
			if (dynProb > 0) {
				prob = Math.max(0, (100 - prob) / dynProb);
				for (i = 0; i < l; i++) {
					output = (outputs[i] as MachinationsConnection);
					if (output.label.type == Label.TYPE_PROBABILITY_DYNAMIC) {
						output.label.setDynamicProbability(prob);
					}
				}
			}
		}
		
	}

}