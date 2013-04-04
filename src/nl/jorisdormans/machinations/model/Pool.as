package nl.jorisdormans.machinations.model 
{
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Pool extends Source
	{
		private var _startingResources:int;
		public var capacity:int
		private var startingCapacity:int;
		public var resources:Vector.<Resource>;
		public var overPulled:Boolean;
		public var pulls:int = 0;
		private var shortage:int;
		public static const TOKEN_LIMIT:int = 25;
		public var displayCapacity:int = TOKEN_LIMIT;
		
		
		
		public function Pool() 
		{
			resources = new Vector.<Resource>();
			startingResources = 0;
			capacity = -1;
			super();
			activationMode = MODE_PASSIVE;	
			
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@startingResources = startingResources;
			xml.@capacity = capacity;
			if (displayCapacity != TOKEN_LIMIT) xml.@displayCapacity = displayCapacity;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			startingResources = xml.@startingResources;
			if (xml.@maxResources.length() > 0) capacity = xml.@maxResources;
			else capacity = xml.@capacity;
			if (xml.@tokenLimit.length() > 0) displayCapacity = parseInt(xml.@tokenLimit);
			if (xml.@displayCapacity.length() > 0) displayCapacity = parseInt(xml.@displayCapacity);
		}
		
		public function get startingResources():int { return _startingResources; }
		
		public function set startingResources(value:int):void 
		{
			_startingResources = value;
			resources.splice(0, resources.length);
			for (var i:int = 0; i < value; i++) resources.push(new Resource(resourceColor, 0));
		}
		
		override public function get resourceColor():uint { return super.resourceColor; }
		
		override public function set resourceColor(value:uint):void 
		{
			super.resourceColor = value;
			resources.splice(0, resources.length);
			for (var i:int = 0; i < startingResources; i++) resources.push(new Resource(value, 0));
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			
			//distributed = _startingResources;
			shortage = 0;
			overPulled = false;
			
			//setState();
			checkInhibition();
			//recalculate();
			
			if (resourceInputCount == 0) {
				if (pullMode == PULL_MODE_PULL_ANY) pullMode = PULL_MODE_PUSH_ANY;
				if (pullMode == PULL_MODE_PULL_ALL) pullMode = PULL_MODE_PUSH_ALL;
			}
			
			startingCapacity = capacity;
		}
		
		public function modify(delta:int):void {
			if (delta > 0) {
				for (var i:int = 0; i < delta; i++) receiveResource(this.resourceColor, null);
			}
			if (delta < 0) {
				for (i = 0; i < -delta; i++) {
					if (resourceCount <= 0) {
						shortage++;
						changeState(0x1000000, -1);
					} else {
						removeResource(0x01000000, 0);
					}
				}
			}
			
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		//replace by modify
		/*public function recalculate():void
		{
			calculated = 0;
			var setting:Boolean = false;
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection && (inputs[i] as StateConnection).isSetter()) {
					calculated += (inputs[i] as StateConnection).state;
					setting = true;
				}
			}
			if (setting) {
				//resources.splice(0, resources.length);
				var r:int = distributed + Math.floor(calculated);
				if (r > resources.length) {
					for (i = resources.length; i < r; i++) resources.push(new Resource(resourceColor, 0));
				}
				if (Math.max(0, r) < resources.length) {
					resources.splice(Math.max(0, r), resources.length - Math.max(0, r));
				}
				
				//resources.splice(0, resources.length);
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
				setState();
			}
		}*/
		
		override public function stop():void 
		{
			super.stop();
			capacity = startingCapacity;
			resources.splice(0, resources.length);
			for (var i:int = 0; i < startingResources; i++) resources.push(new Resource(resourceColor, 0));
			shortage = 0;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		override public function autoFire():void 
		{
			super.autoFire();
			//trace("POOL FIRED");
		}
		
		override public function update(time:Number):void 
		{
			pulls = 0;
			var r:int = 0;
			var l:int = resources.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if (resources[i].position > 0) {
					resources[i].position -= time;
					if (resources[i].position <= 0) {
						resources.splice(i, 1);
						r++;
						//setState();
					}
				}
			}
			if (firing > 0) {
				firing -= time;
				if (firing <= 0) {
					firing = 0;
					if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				}
			}				
			
			if (r > 0 && doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		override public function fire():void 
		{
			setFiring();
			switch (pullMode) {
				default:
					pull();
					break;
				case PULL_MODE_PUSH_ANY:
					var l:int = outputs.length;
					for (var i:int = l - 1; i >= 0; i--) {
						if (outputs[i] is ResourceConnection) (outputs[i] as ResourceConnection).pull();
					}
					break;
				case PULL_MODE_PUSH_ALL:
					l = outputs.length;
					var undo:Boolean  = false;
					for (i = l - 1; i >= 0; i--) {
						if (outputs[i] is ResourceConnection && !(outputs[i] as ResourceConnection).pull()) {
							undo = true;
						}
					}
					if (undo) {
						for (i = l - 1; i >= 0; i--) {
							if (outputs[i] is ResourceConnection) {
								(outputs[i] as ResourceConnection).undoPull(false);
							}
						}
					}
					break;
			}
			if (resourceInputCount == 0) {
				satisfy();
			}
		}
		
		override public function satisfy():void 
		{
			var l:int = outputs.length; 
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection) (outputs[i] as StateConnection).fire();
			}
		}
		
		override public function receiveResource(color:uint, flow:ResourceConnection):void 
		{
			if (capacity >= 0 && resources.length >= capacity) return;
			if (shortage > 0) {
				shortage--;
			} else {
				resources.push(new Resource(color, 0));
			}
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			//recalculate();
			//setState();
			changeState(color, 1);
			if (checkInputs()) satisfy();
		}
		
		public function returnResource(color:uint):void 
		{
			if (checkInputs()) satisfy();
			//if (maxResources >= 0 && resources.length >= maxResources) return;
			
			changeState(color, 1);
			
			//try remove one of the removed resources
			var l:int = resources.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if ((color == 0x01000000 || resources[i].color == color) && resources[i].position >= 0.01) {
					resources[i].position = 0;
					return;
				}
			}
			
			if (shortage > 0) {
				shortage--;
				//changeState(color, 1);
			} else {
				resources.push(new Resource(color, 0));
				//changeState(color, 1);
			}
				
					
			//if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			//recalculate();
			//setState();
		}
		
		
		public function removeResource(color:uint, time:Number):uint {
			var l:int = resources.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if ((color == 0x01000000 || resources[i].color == color) && resources[i].position == 0) {
					var c:uint = resources[i].color;
					if (time > 0) {
						resources[i].position = time+0.01;
					} else {
						resources[i].position = 0.01;
						//resources.splice(i, 1);
						//if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
						//setState();
					}
					changeState(c, -1);
					return c;
				}
			}
			//changeState(0x01000000, -1);
			return 0x01000000;
		}
		
		public function removeRandomResource(time:Number):uint {
			var l:int = resources.length;
			var c:int = 0;
			for (var i:int = l - 1; i >= 0; i--) {
				if (resources[i].position == 0) {
					c++;
				}
			}
			var r:int = Math.random() * c;
			for (i = l - 1; i >= 0; i--) {
				if (resources[i].position == 0) {
					r--;
					if (r < 0) {
						if (time > 0) {
							resources[i].position = time+0.01;
						} else {
							resources[i].position = 0.01;
						}
						changeState(resources[i].color, -1);
						return resources[i].color;
					}
				}
			}
			return 0x01000000;
		}
		
		
		public function canRemoveResource(color:uint, amount:int):Boolean {
			var l:int = resources.length;
			for (var i:int = l - 1; i >= 0; i--) {
				if ((color == 0x01000000 || resources[i].color == color) && resources[i].position == 0) {
					amount--;
					if (amount <= 0) return  true;
				}
			}
			return false;
		}
		
		public function changeState(resourceColor:uint, delta:int):void {
			var l:int = outputs.length;
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection) {
					if ((outputs[i] as StateConnection).color == this.color || resourceColor == 0x01000000 || (outputs[i] as StateConnection).color == resourceColor || (graph as MachinationsGraph).colorCoding == 0) {
						(outputs[i] as StateConnection).changeState(delta);
					}
				}
				if (outputs[i] is ResourceConnection) (outputs[i] as ResourceConnection).checkInhibition(true);
			}
			if (delta != 0) {
				checkInhibition();
			}
			
		}
		
		// This function is replaced by changeState
		/*public function setState():void {
			var l:int = outputs.length;
			var s:int = resourceCount
			for (var i:int = 0; i < l; i++) {
				if (outputs[i] is StateConnection) {
					if ((outputs[i] as StateConnection).color == color) {
						(outputs[i] as StateConnection).state = s;
					} else {
						(outputs[i] as StateConnection).state = resourceColorCount((outputs[i] as StateConnection).color);
					}
				}
				if (outputs[i] is ResourceConnection) (outputs[i] as ResourceConnection).checkInhibition(true);
			}
			//if (s == 0) checkInhibition();
			
		}*/
		
		public function get resourceCount():int {
			var l:int = resources.length;
			var c:int = 0;
			for (var i:int = 0; i < l; i++) {
				if (resources[i].position == 0) c++;
			}
			return c - shortage;
		}
		
		public function resourceColorCount(c:uint):int {
			var l:int = resources.length;
			var s:int = 0;
			for (var i:int = 0; i < l; i++) {
				if (resources[i].color == c) s++;
			}
			return s;
			
		}
		
		public function resolveOverPull():void {
			if (overPulled) {
				overPulled = false;
				
				if (pulls > 1) {
					//if there was more than one pull, ignore the overpull
					for (var i:int = 0; i < resources.length; i++) {
						resources[i].position = 0;
						//distributed++;
					}
					for (i = 0; i < outputs.length; i++) {
						if (outputs[i] is ResourceConnection) {
							(outputs[i] as ResourceConnection).undoPull();
						}
					}
				}
			}
		}
		
		public function modifyCapacity(delta:int):void {
			capacity += delta;
			if (capacity < resources.length) {
				var m:int = Math.max(capacity, 0);
				var r:int = resources.length - m;
				for (var i:int = m; i < m + r; i++)
				{
					changeState(resources[i].color, -1);				
				}
				resources.splice(m, r);
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE, this));
			}
		}
		
	}

}