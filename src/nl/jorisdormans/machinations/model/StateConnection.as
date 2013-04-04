package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.graph.GraphEvent;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class StateConnection extends MachinationsConnection
	{
		private var _state:int;
		private var _alreadyTriggered:Boolean;
		
		//TODO: Fix a bug with state connections (activators) activating pools!
		
		public function StateConnection() 
		{
			
		}
		
		public function fire():void {
			if ((label.type == Label.TYPE_TRIGGER || start is Gate) && !_alreadyTriggered) {
				_alreadyTriggered = true;
				if (end is MachinationsNode && (!(end as MachinationsNode).inhibited || (end is EndCondition))) (end as MachinationsNode).fire();
				if (end is ResourceConnection) (end as ResourceConnection).fire();
				firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
		}
		
		public function reverseFire():void {
			if ((label.type == Label.TYPE_REVERSE_TRIGGER) && !_alreadyTriggered) {
				_alreadyTriggered = true;
				if (end is MachinationsNode && (!(end as MachinationsNode).inhibited || (end is EndCondition))) (end as MachinationsNode).fire();
				if (end is ResourceConnection) (end as ResourceConnection).fire();
				firing = Math.min((graph as MachinationsGraph).fireInterval * 0.75, 0.5);
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
		}
		
		override public function update(time:Number):void 
		{
			_alreadyTriggered = false;
			super.update(time);
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			_state = 0;
			if (start is Pool) {
				_state = (start as Pool).resourceCount;
				if ((graph as MachinationsGraph).colorCoding > 0) {
					if (this.color != (start as Pool).color) {
					_state = (start as Pool).resourceColorCount(this.color);
					} 
				}
			}
			if (start is Register) _state = (start as Register).value;
			changeState(0);
		}
		
		public function get state():Number { return _state; }
		
		public function set state(value:Number):void 
		{
			if (end is Register) {
				if (start is Pool) {
					value = (start as Pool).resourceCount;
				} else if (start is Register) value= (start as Register).value;
				else value = 0;
			} 
			var previous:int = _state;  
			var interval:int = 1;
			if (label.intervalType == Label.TYPE_FIXED_VALUE) {
				interval = label.interval;
			}
			switch (label.type) {
				default:
					_state = value;
				case Label.TYPE_CHANGE_MULTIPLIER:
					_state = value;
					if (end is MachinationsConnection) (end as MachinationsConnection).label.modifyMultiplier((_state/interval - previous/interval)*label.value);
					break;
				case Label.TYPE_CHANGE_CAPACITY:
					_state = value;
					if (end is Pool) (end as Pool).modifyCapacity((_state/interval - previous/interval)*label.value);
					break;
				case Label.TYPE_CHANGE_INTERVAL:
					_state = value;
					if (end is MachinationsConnection) (end as MachinationsConnection).label.modifyInterval((_state/interval - previous/interval)*label.value);
					break;
				case Label.TYPE_FIXED_VALUE:
				case Label.TYPE_CALCULATED_VALUE:
				case Label.TYPE_CHANGE_PROBABILITY:
				case Label.TYPE_CHANGE_VALUE:
					_state = value;
					if (end is MachinationsConnection && interval!=1) (end as MachinationsConnection).label.modify((Math.floor(_state/interval) - Math.floor(previous/interval))*label.value);
					else if (end is MachinationsConnection) (end as MachinationsConnection).label.modify((_state - previous) * label.value);
					else if (end is Register) (end as Register).calculateValue();
					else if (end is Pool) (end as Pool).modify((Math.floor(_state / interval) - Math.floor(previous / interval))* label.value);
					else if (end is Gate) (end as Gate).modify((_state/interval - previous/interval)*label.value);
					else if (end is Delay) (end as Delay).modify((_state/interval - previous/interval)*label.value);
					break;
				case Label.TYPE_GREATER:
				case Label.TYPE_GREATER_OR_EQUAL:
				case Label.TYPE_EQUAL_TO:
				case Label.TYPE_LESS:
				case Label.TYPE_LESS_OR_EQUAL:
				case Label.TYPE_NOT_EQUAL_TO:
				case Label.TYPE_RANGE:
					_state = value;
					inhibited =  !label.checkCondition(value);
					break;
			}
		}
		
		public function changeState(delta:int):void {
			state = _state + delta;
			checkInhibition();
		}
		
		public function changeModifier(delta:Number):void {
			if (start is Pool) {
				var c:Number = (start as Pool).resourceCount * delta;
				_state += c;
				
				var interval:int = 1;
				if (label.intervalType == Label.TYPE_FIXED_VALUE) {
					interval = label.interval;
				}

				if (end is MachinationsConnection && interval!=1) (end as MachinationsConnection).label.modify(c);
				else if (end is MachinationsConnection) (end as MachinationsConnection).label.modify(c);
				else if (end is Pool) (end as Pool).modify(c);
				else if (end is Gate) (end as Gate).modify(c);
				else if (end is Register) {
					state = _state;
					(end as Register).calculateValue();
				}
			}
			//checkInhibition();
		}

		
		public function resetState():void {
			if (start is Pool) {
				state = (start as Pool).resources.length;
			} else if (start is Register) {
				_state = 0;
				if (end is MachinationsConnection) (end as MachinationsConnection).label.reset();
				state = (start as Register).value;
			}
			
		}
		
		public function isSetter():Boolean {
			switch (label.type) {
				case Label.TYPE_FIXED_VALUE:
				case Label.TYPE_CALCULATED_VALUE:
				case Label.TYPE_CHANGE_INTERVAL:
				case Label.TYPE_CHANGE_PROBABILITY:
				case Label.TYPE_CHANGE_VALUE:
					return true;
			}
			return false;
			
		}
		
		public function isActivator():Boolean {
			return (label.isCondition());
		}
		
		
		public function checkInhibition():void {
			if (start is MachinationsNode && (label.type == Label.TYPE_TRIGGER || start is Gate)) {
				inhibited = (start as MachinationsNode).inhibited;   
			}
		}
		
		
		
	}

}