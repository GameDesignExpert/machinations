package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.graph.GraphConnection;
	import nl.jorisdormans.graph.GraphElement;
	import nl.jorisdormans.graph.GraphEvent;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class ResourceConnection extends MachinationsConnection
	{
		public var justPulled:int;
		public var resources:Vector.<Resource>;
		public var speed:Number;
		public var delivered:int;
		public var requestQueue:Vector.<int>;
		public var instantaneous:Boolean;
		
		public function ResourceConnection() 
		{
			resources = new Vector.<Resource>();
		}
		
		public function produce(source:Source):void {
			var amount:int = label.value;
			label.generateNewValue();
			requestQueue.push(Math.max(amount, 0));
			if (amount <= 0) return;
			var period:Number = (graph as MachinationsGraph).fireInterval;
			period = (period / amount) * -speed;
			var c:uint;
			if (color == source.color) c = source.resourceColor;
			else c = color;
			for (var i:int = 0; i < amount; i++) {
				resources.push(new Resource(c, i * period));
			}
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			var s:Number = (graph as MachinationsGraph).resourceSpeed;
			if (s>0) {
				speed = (graph as MachinationsGraph).resourceSpeed / totalLength;
			} else {
				speed = 1;
			}
			delivered = 0;
			justPulled = 0;
			requestQueue = new Vector.<int>();
			instantaneous = ((graph as MachinationsGraph).distributionMode == MachinationsGraph.DISTRIBUTION_MODE_INSTANTANEOUS);
			checkInhibition();

		}
		
		override public function stop():void 
		{
			resources.splice(0, resources.length);
			super.stop();
		}
		
		override public function update(time:Number):void 
		{
			super.update(time);
			if (instantaneous) {
				var l:int = resources.length;
				for (var i:int = l - 1; i >= 0; i--) {
					if (resources[i].position <= 0) {
						resources[i].position += 1;
					} else {
						delivered++;
						if (end is MachinationsNode) (end as MachinationsNode).receiveResource(resources[i].color, this);
						resources.splice(i, 1);
						checkInhibition();
					}
				}
			} else {
				l = resources.length;
				for (i = l - 1; i >= 0; i--) {
					resources[i].position += time * speed;
					if (resources[i].position >= 1) {
						delivered++;
						if (end is MachinationsNode) (end as MachinationsNode).receiveResource(resources[i].color, this);
						resources.splice(i, 1);
						checkInhibition();
					}
				}
				if (l > 0 && doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
		}
		
		public function pull(discount:int = 0):Boolean
		{
			if (discount < 0) discount = 0;
			var pool:Pool = start as Pool;
			if (!pool && start is Source && (start as Source).activationMode == MachinationsNode.MODE_PASSIVE) {
				produce(start as Source);
				return true;
			}
			if (!pool) return false;
			var amount:int = label.value;
			for (var i:int = 0; i < label.generatedValues.length; i++) {
				requestQueue.push(Math.max(label.generatedValues[i], 0));
			}
			label.generateNewValue();
			if (amount <= 0) return true;
			
			//keep track of the number of demands on a single pool
			pool.pulls++;
			
			var period:Number = (graph as MachinationsGraph).fireInterval;
			period /= amount;
			var spawnPos:Number = period* -speed;
			
			var c:uint;
			if (color == pool.color || (graph as MachinationsGraph).colorCoding == 0) c = 0x01000000;
			else c = color;
			
			justPulled = 0;
			
			for (i = 0; i < amount; i++) {
				var rc:uint;
				var t:Number = 0;
				if (!instantaneous) t = i * period;
				if (label.drawRandom) {
					rc = pool.removeRandomResource(t);
				} else {
					rc = pool.removeResource(c, t);
				}
				if (rc < 0x01000000) {
					resources.push(new Resource(rc, i * spawnPos));
					justPulled++;
				}
				if (rc == 0x01000000) {
					if (i == 0 && end is MachinationsNode && (end as MachinationsNode).activationMode!=MachinationsNode.MODE_AUTOMATIC) {
						blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
						if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
					}
					if ((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS) {
						if (i==0) blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);						
						pool.overPulled = true;
					}
					if (justPulled == 0)
					{
					   //nothing is pulled cancel the pull request in queue
					   requestQueue.splice(requestQueue.length - 1, 1);
					}
					return false;
				}
				pool.checkInhibition();
			}
			return true;
		}
		
		public function canPull(discount:int = 0):Boolean
		{
			var pool:Pool = start as Pool;
			if (pool) {
				var amount:int = label.value;
				amount -= discount;
				if (amount <= 0) return true;
				var c:uint;
				if (color == pool.color) c = 0x01000000;
				else c = color;
				if (pool.canRemoveResource(c, amount)) {
					return true;
				}
				
				if ((graph as MachinationsGraph).timeMode == MachinationsGraph.TIME_MODE_SYNCHRONOUS) {
					pool.overPulled = true;
					blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
					trace("CANNOT PULL", amount);
				}			
			}
			
			if (end is MachinationsNode && (end as MachinationsNode).activationMode!=MachinationsNode.MODE_AUTOMATIC) {
				blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
			
			
			return false;
			
		}

		public function checkInhibition(communicate:Boolean = true):void {
			communicateInhibition = communicate;
			
			var inh:Boolean = false;
			var l:int = inputs.length;
			for (var i:int = 0; i < l; i++) {
				if (inputs[i] is StateConnection && (inputs[i] as StateConnection).isActivator() && (inputs[i] as StateConnection).inhibited) {
					inh = true;
					break;
				}
			} 
			if ((start is Pool) && (start as Pool).caption == "keys") trace(inh);
			if (!inh) {
				if (start is MachinationsNode && (start as MachinationsNode).inhibited) {
					inh = true;
				}
				//Disabled these checks to prevent unwanted (and seemingly random) inhibiting of resource connections at the start of a session
				/*
				if (end is Drain && !(end as Drain).canDrain()) {
					inh = true;
				}
				if (end is Converter && !(end as Converter).canDrain()) {
					inh = true;
				}*/
				if (resources.length > 0) inh = false;
			}
			inhibited = inh;
		}
		
		public function fire():void {
			firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
			if (start is Pool) {
				pull(0);
			} else if (start is Source && !start is Converter) {
				produce(start as Source);
			} 
		}
		
		public function undoPull(undoAllOfEndNode:Boolean = true):void {
			var u:int = 0;
			var i:int = resources.length;
			while (i > 0 && u < justPulled) {
				i--;
				if (resources[i].position <= 0) {
					if (!undoAllOfEndNode) {
						if (start is Pool) {
							(start as Pool).returnResource(resources[i].color);
						}
						
					}
					u++;
					resources.splice(i, 1);
				}
			}
			if (u > 0) {
				blocked = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
				requestQueue.splice(requestQueue.length - 1, 1);
				if (undoAllOfEndNode && (end as MachinationsNode).pullMode == MachinationsNode.PULL_MODE_PULL_ALL) {
					(end as MachinationsNode).undoPull();
				}
			}
			justPulled = 0;
		}
		
		override public function get end():GraphElement { return super.end; }
		
		override public function set end(value:GraphElement):void 
		{
			super.end = value;
			if (end is MachinationsNode) {
				(end as MachinationsNode).resourceInputCount++;
				if (doEvents) end.dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
		}
		
		override public function toMMString():String 
		{
			var str:String = this.getMMName()+": ";
			str += this.start.getMMName();
			str += " -" + this.label.getMMText() + "-> ";
			str += this.end.getMMName();
			
			return str;
		}
		
	}

}