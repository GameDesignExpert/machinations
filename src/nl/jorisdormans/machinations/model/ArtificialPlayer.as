package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class ArtificialPlayer extends MachinationsNode
	{
		
		public var script:String;
		public var instructions:Vector.<APInstruction>;
		public var actionsPerTurn:Number;
		private var _autoFire:Number;
		private var _timer:Number;
		//public var active:Boolean;
		public var actionsExecuted:int;
		public var actionsPerStep:int;
		private var initialMode:String;
		public var pregeneratedRandom:Vector.<Number>;
		
		
		public function ArtificialPlayer() 
		{
			script = "";
			actionsPerTurn = 1;
			//active = true;
			activationMode = MODE_AUTOMATIC;
			actions = 0;
			pregeneratedRandom = new Vector.<Number>();
			for (var i:int = 0; i < 10; i++) pregeneratedRandom.push(0);
			
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.appendChild(script);
			//xml.@active = active?"1":"0";
			xml.@actionsPerTurn = actionsPerTurn;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			script = xml.toString();
			//active = (xml.@active == "1");
			actionsPerTurn = xml.@actionsPerTurn;
		}
		
		public function readInstructions():void 
		{
			instructions = new Vector.<APInstruction>();
			var s:String = script;
			var p:int = s.indexOf("\r");
			if (p < 0) p = s.indexOf("\n");
			while (p > 0) {
				var i:String = StringUtil.trim(s.substr(0, p));
				if (i.length>0) instructions.push(new APInstruction(this, s));
				s = s.substr(p + 1);
				p = s.indexOf("\r");
				if (p < 0) p = s.indexOf("\n");
			}
			i = StringUtil.trim(s.substr(0, p));
			if (i.length > 0) instructions.push(new APInstruction(this, s));
		}	
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			_timer = 0;
			_autoFire = 0;
			actionsExecuted = 0;
			actionsPerStep = 0;
			actions = 0;
			initialMode = activationMode;
			for (var i:int = 0; i < pregeneratedRandom.length; i++) {
				pregeneratedRandom[i] = Math.random();
			}
		}
		
		override public function stop():void 
		{
			activationMode = initialMode;
			super.stop();
		}
		
		override public function autoFire():void 
		{
			actionsPerStep = 0;
			if ((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_TURN_BASED) {
				if (actionsPerTurn >= 1 && activationMode == MODE_AUTOMATIC) {
					if (!inhibited) fire();
					_autoFire += Math.floor(actionsPerTurn-1);
					//_fired = 0.8;
				}			
			} else {
				super.autoFire();
			}

		}
		
		override public function update(time:Number):void 
		{
			if (this.firing > 0) {
				this.firing -= time;
				if (this.firing <= 0) {
					this.firing = 0;
					if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				}
			}
			
			if (_autoFire > 0) {
				if ((_autoFire % 1) - time*0.8 <= 0 && (_autoFire % 1) > 0) {
					if (!inhibited) fire();
					//_fired = 1;
				}
				_autoFire-= time * 0.8;
			}
			
			if ((graph as MachinationsGraph).ended || (graph as MachinationsGraph).actionsPerTurn>0) return;
			_timer += time;
			if (_timer >= actionsPerTurn) {
				_timer -= actionsPerTurn;
				if (activationMode == MODE_AUTOMATIC && !inhibited) fire();
			}			
		}
		
		override public function fire():void
		{
			if (caption == "F") {
				throw new Error("how did I get here");
			}
			//TODO: color-coding new style
			actionsExecuted++;
			actionsPerStep++;
			setFiring();
			for (var i:int = 0; i < instructions.length; i++) {
				
				if (instructions[i].activate()) {
					/*var n:MachinationsNode = instructions[i].node;
					if (n) {
						n.click();
						n.setFiring();
					}*/
					break;
				}
				
			}
		}	
		
		public function activate():void {
			if (activationMode == MODE_PASSIVE) {
				activationMode = MODE_AUTOMATIC;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
		}
		
		public function deactivate():void {
			if (activationMode == MODE_AUTOMATIC) {
				activationMode = MODE_PASSIVE;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
			
		}
		
		
	}

}