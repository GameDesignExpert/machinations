package nl.jorisdormans.machinations.model 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphConnection;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.graph.GraphNode;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.MathUtil;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsNode extends GraphNode
	{
		public var thickness:Number;
		public var color:uint;
		public var size:Number;
		public var caption:String;
		public var actions:int;
		protected var _captionPosition:Number;
		public var captionAlign:String;
		public var captionCalculatedPosition:Vector3D;
		public var captionSize:Point;
		public var activationMode:String;
		public var pullMode:String;
		protected var doEvents:Boolean;
		public var resourceInputCount:int;
		public var resourceOutputCount:int;
		public var stateOutputCount:int;
		public var stateInputCount:int;
		protected var _inhibited:Boolean;
		public var aiControled:Boolean;
		public var firing:Number;
		public var fireFlag:Boolean;
		
		public static const MODE_AUTOMATIC:String = "automatic";
		public static const MODE_INTERACTIVE:String = "interactive";
		public static const MODE_PASSIVE:String = "passive";
		public static const MODE_ONSTART:String = "onstart";
		
		public static const PULL_MODE_PULL_ANY:String = "pull any";
		public static const PULL_MODE_PULL_ALL:String = "pull all";
		public static const PULL_MODE_PUSH_ANY:String = "push any";
		public static const PULL_MODE_PUSH_ALL:String = "push all";
		
		//public static const TYPE_TRIGGERED:String = "triggered";
		
		public function MachinationsNode() 
		{
			size = 20;
			thickness = 2;
			color = 0x000000;
			caption = "";
			captionCalculatedPosition = new Vector3D(0, 0);
			captionPosition = 0.25;
			captionSize = new Point();
			activationMode = MODE_PASSIVE;
			actions = 1;
			fireFlag = false;
			pullMode = PULL_MODE_PULL_ANY;
		}
		
		override public function getConnection(towards:Vector3D):Vector3D 
		{
			var c:Vector3D = position.clone();
			var d:Vector3D = towards.subtract(position);
			d.normalize();
			d.scaleBy(size + thickness + 2);
			c.incrementBy(d);
			return c;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@color = StringUtil.toColorString(color);
			xml.@caption = caption;
			if (!(this is TextLabel)) {
				xml.@thickness = thickness;
				xml.@captionPos = Math.round(captionPosition * 100) / 100;
				xml.@activationMode = activationMode;
				xml.@pullMode = pullMode;
				xml.@actions = actions;
			}
			return xml;
		}	
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			color = StringUtil.toColor(xml.@color);
			caption = xml.@caption;
			if (!(this is TextLabel)) {
				thickness = xml.@thickness;
				captionPosition = xml.@captionPos;
				if (xml.@activationMode.length() > 0) activationMode = xml.@activationMode;
				if (xml.@pullMode.length() > 0) pullMode = xml.@pullMode;
				if (xml.@interactive == "1") activationMode = MODE_INTERACTIVE;
				actions = xml.@actions;
			}
		}
		
		public function pointInCaption(x:Number, y:Number):Boolean
		{
			x -= position.x;
			y -= position.y;
			switch (captionAlign) {
				default:
				case PhantomFont.ALIGN_LEFT:
					return (x >= captionCalculatedPosition.x - 5 && x <= captionCalculatedPosition.x + captionSize.x +5 && y >= captionCalculatedPosition.y - 10 && y <= captionCalculatedPosition.y + captionSize.y);
				case PhantomFont.ALIGN_CENTER:
					return (x >= captionCalculatedPosition.x - captionSize.x * 0.5 - 5 && x <= captionCalculatedPosition.x + captionSize.x * 0.5 +5 && y >= captionCalculatedPosition.y - 10 && y <= captionCalculatedPosition.y + captionSize.y);
				case PhantomFont.ALIGN_RIGHT:
					return (x >= captionCalculatedPosition.x - captionSize.x - 5 && x <= captionCalculatedPosition.x + 5 && y >= captionCalculatedPosition.y - 10 && y <= captionCalculatedPosition.y + captionSize.y);
			}
		}
		
		public function get captionPosition():Number { return _captionPosition; }
		
		public function set captionPosition(value:Number):void 
		{
			if (Math.abs(value-0.00) < 0.05) value = 0.00;
			if (Math.abs(value-0.25) < 0.05) value = 0.25;
			if (Math.abs(value-0.50) < 0.05) value = 0.50;
			if (Math.abs(value-0.75) < 0.05) value = 0.75;
			if (Math.abs(value-1.00) < 0.05) value = 0.00;
			_captionPosition = value;
			if (size == 0) {
				captionCalculatedPosition.x = 0;
				captionCalculatedPosition.y = 0;
			} else {
				captionCalculatedPosition.x = Math.cos(_captionPosition * Math.PI * 2);
				captionCalculatedPosition.y = Math.sin(_captionPosition * Math.PI * 2);
				
				if (this is Register || this is EndCondition || this is ArtificialPlayer) {
					captionCalculatedPosition = MathUtil.getSquareOutlinePoint(captionCalculatedPosition, 0.5 * size + thickness + 7);
				} else {
					captionCalculatedPosition.scaleBy(size + 10);
				}

				
				if (_captionPosition == 0.25 || _captionPosition == 0.75 ) {
					captionAlign = PhantomFont.ALIGN_CENTER;
					if (_captionPosition == 0.75) {
						var h:Number  = 0;
						for (var i:int = 0; i < caption.length; i++) {
							if (caption.charAt(i) == "|") h += 16;
						}
						captionCalculatedPosition.y -= h;
					}
				} else if (_captionPosition < 0.25 || _captionPosition > 0.75) {
					captionAlign = PhantomFont.ALIGN_LEFT;
				} else {
					captionAlign = PhantomFont.ALIGN_RIGHT;
				}
			}
		}
		
		public function get inhibited():Boolean { return _inhibited; }
		
		public function set inhibited(value:Boolean):void 
		{
			if (_inhibited == value) return;
			_inhibited = value;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			var l:int = outputs.length; 
			for (var i:int; i < l; i++) {
				if (outputs[i] is ResourceConnection) {
					(outputs[i] as ResourceConnection).checkInhibition();
				}
				if (outputs[i] is StateConnection) {
					//(outputs[i] as StateConnection).state = 0;
					(outputs[i] as StateConnection).checkInhibition();
				}
			}
		}
		
		public function checkInhibition():void {
			var inh:Boolean = false;
			var livingInputs:int = 0;
			var l:int = inputs.length; 
			for (var i:int; i < l; i++) {
				if (inputs[i] is StateConnection && (inputs[i] as StateConnection).label.type != Label.TYPE_TRIGGER && !((inputs[i] as StateConnection).start is Gate) && (inputs[i] as StateConnection).inhibited) {
					inh = true;
				}
				if (inputs[i] is StateConnection && this is Pool && !(inputs[i] as StateConnection).inhibited && (inputs[i] as StateConnection).isSetter()) {
					livingInputs++;
				}
				if (inputs[i] is ResourceConnection && !(inputs[i] as ResourceConnection).inhibited) {
					livingInputs++;
				}
			}
			
			if (livingInputs == 0) {
				if (this is Pool) {
					if ((this as Pool).resources.length == 0) inh = true;
				//} else {
					//if (this.toString() != "[object Source]" && !(this is EndCondition) && !(this is ArtificialPlayer) && !(this is Gate)) inh = true;
				}
			}
			inhibited = inh;
		}
		
		public function prepare(doEvents:Boolean):void {
			var l:int;
			var i:int;
			
			l = outputs.length;
			resourceOutputCount = 0;
			stateOutputCount = 0;
			for (i = 0; i < l; i++) {
				if (outputs[i] is ResourceConnection) {
					resourceOutputCount++;
				}
				if (outputs[i] is StateConnection) {
					stateOutputCount++;
				}
			}			
			l = inputs.length;
			resourceInputCount = 0;
			stateInputCount = 0;
			for (i = 0; i < l; i++) {
				if (inputs[i] is ResourceConnection) {
					resourceInputCount++;
				}
				if (inputs[i] is StateConnection) {
					stateInputCount++;
				}
			}			
			//determine node type
			/*
			// code is obsolete because type is set by user
			nodeType = TYPE_AUTOMATIC;
			var l:int = inputs.length; 
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection && ((inputs[i] as StateConnection).modifier.type == Modifier.TYPE_TRIGGER || inputs[i].start is Gate)) {
					nodeType = TYPE_TRIGGERED;
					break;
				}
			}
			if (interactive) nodeType = TYPE_INTERACTIVE;
			
			
			//count flow inputs
			flowInputCount = 0;
			var interactiveInputs:int = 0;
			l = inputs.length; 
			for (i = 0; i < l; i++) {
				if (inputs[i] is FlowConnection) {
					flowInputCount++;
					if (inputs[i].start && (inputs[i].start as MachinationsNode).nodeType == TYPE_INTERACTIVE) {
						interactiveInputs++;
					}
				}
			}
			
			if (flowInputCount > 0 && flowInputCount == interactiveInputs && nodeType == TYPE_AUTOMATIC) {
				nodeType = TYPE_PASSIVE;
			}*/
			
			aiControled = false;
			
			firing = 0;
			
			this.doEvents = doEvents;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		public function stop():void {
			firing = 0;
			inhibited = false;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		public function autoFire():void {
			if ((activationMode == MODE_AUTOMATIC || fireFlag) && !_inhibited && !aiControled) {
				fire();
				fireFlag = false;
			}
		}
		
		public function update(time:Number):void
		{
			if (this.firing > 0) {
				this.firing -= time;
				if (this.firing <= 0) {
					this.firing = 0;
					if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				}
			}					
		}
		
		public function click():void {
			if ((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS) {
				fireFlag = true;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			} else {
				fire();
				if ((graph as MachinationsGraph).actionsPerTurn > 0 && activationMode == MODE_INTERACTIVE ) {
					(graph as MachinationsGraph).actionsThisTurn+=actions;
				}
			}
		}
		
		public function fire():void {
			setFiring();
		}
		
		public function setFiring():void {
			if (activationMode == MODE_AUTOMATIC && !(this is ArtificialPlayer) && !aiControled) return;
			firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
		}
		
		public function satisfy():void {
			//to be overridden
		}
		
		public function receiveResource(color:uint, flow:ResourceConnection):void {
			if (checkInputs()) satisfy();
		}
		
		public function pull():void {
			var l:int = inputs.length;
			var d:int;
			var i:int;
			var flow:ResourceConnection;
			
			/*if (pullMode == PULL_MODE_ALL) {
				var blocked:Boolean = false;
				for (var i:int = 0; i < l; i++) {
					var flow:FlowConnection = (inputs[i] as FlowConnection);
					if (flow) {
						if (this.activationMode == MODE_INTERACTIVE) {
							d = flow.delivered;
							d += flow.resources.length;
						} else {
							d = 0;
						}
						if (!flow.canPull(d)) blocked = true;
					}
				}
				if (blocked) return;
			}*/
			var blocked:Boolean = false;
			for (i = 0; i < l; i++) {
				flow = (inputs[i] as ResourceConnection);
				if (flow) {
					if (!flow.inhibited) {
						d = flow.delivered;
						d += flow.resources.length;
						if (!flow.pull(d)) blocked = true;
						//blocked = !flow.pull(d) || blocked;
					} else {
						blocked = true;
					}
				}
			}
			
			if (blocked) {
				//trace("Node ", caption, "blocked");
				for (i = 0; i < outputs.length; i++) {
					if (outputs[i] is StateConnection && (outputs[i] as StateConnection).label.type == Label.TYPE_REVERSE_TRIGGER) {
						(outputs[i] as StateConnection).reverseFire();
					}
				}
			}
			
			if (blocked && pullMode == PULL_MODE_PULL_ALL) {
				undoPull();
			}
			
			if (checkInputs()) satisfy();
		}
		
		public function checkInputs():Boolean {
			var l:int = inputs.length; 
			for (var i:int = 0; i < l; i++) {
				var flow:ResourceConnection = (inputs[i] as ResourceConnection);
				if (flow) {
					if (flow.requestQueue.length > 0 && flow.delivered < flow.requestQueue[0]) {
						return false;
					}
					if (flow.requestQueue.length == 0) {
						return false;
					}					
				}
			}
			var total:int = 0;
			for (i = 0; i < l; i++) {
				flow = (inputs[i] as ResourceConnection);
				if (flow) {
					var q:int;
					if (flow.requestQueue.length > 0) {
						q = flow.requestQueue[0];
						flow.delivered -= q;
						if (flow.delivered < 0) flow.delivered = 0;
						flow.requestQueue.splice(0, 1);
						total += q;
					}
				}
			}
			return (total > 0);
		}
		
		public function undoPull():void {
			for (var i:int = 0; i < inputs.length; i++) {
				if (inputs[i] is ResourceConnection /*&& (inputs[i] as ResourceConnection).blocked <= 0*/) {
					(inputs[i] as ResourceConnection).undoPull(false);
				}
			}
		}
		
		override public function removeInput(connection:GraphConnection):void 
		{
			super.removeInput(connection);
			if (connection is ResourceConnection) {
				resourceInputCount--;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			}
		}
		
		
		
	}

}