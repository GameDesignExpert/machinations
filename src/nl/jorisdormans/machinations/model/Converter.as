package nl.jorisdormans.machinations.model 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Converter extends Source
	{
		public function Converter() 
		{
			activationMode = MODE_PASSIVE;			
		}
		
		override public function fire():void 
		{
			//super.fire();
			setFiring();
			pull();
		}
		
		override public function satisfy():void 
		{
			super.satisfy();
			if (!_inhibited) {
				var l:int = outputs.length;
				for (var i:int = 0; i < l; i++) {
					if (outputs[i] is StateConnection) (outputs[i] as StateConnection).fire();
				}
			}
		}
		
		override public function get inhibited():Boolean { return super.inhibited; }
		
		override public function set inhibited(value:Boolean):void 
		{
			super.inhibited = value;
			var l:int = inputs.length; 
			for (var i:int; i < l; i++) {
				if (inputs[i] is ResourceConnection) {
					(inputs[i] as ResourceConnection).checkInhibition(false);
				}
			}			
		}		
		
		override public function checkInhibition():void 
		{
			var inh:Boolean = _inhibited;
			_inhibited = false;
			var l:int = inputs.length; 
			for (var i:int; i < l; i++) {
				if (inputs[i] is ResourceConnection) {
					(inputs[i] as ResourceConnection).checkInhibition(false);
				}
			}			
			_inhibited = inh;
			super.checkInhibition();
		}	
		
		public function canDrain():Boolean {
			var l:int = inputs.length; 
			for (var i:int; i < l; i++) {
				if (inputs[i] is StateConnection) {
					if (!((inputs[i] as StateConnection).start is Delay) && !((inputs[i] as StateConnection).start is Gate) && (inputs[i] as StateConnection).label.type != Label.TYPE_TRIGGER && (inputs[i] as StateConnection).label.type != Label.TYPE_REVERSE_TRIGGER && !(inputs[i] as StateConnection).label.checkCondition((inputs[i] as StateConnection).state)) {
						return false;
					}
				}
			}			
			return true;
		}
		
	}

}