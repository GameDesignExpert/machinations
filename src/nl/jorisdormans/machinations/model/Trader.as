package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.machinations.model.ResourceConnection;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Trader extends Source
	{
		private var actAsConverter:Boolean;

		public function Trader() 
		{
			activationMode = MODE_PASSIVE;			
		}
		
		override public function fire():void 
		{
			//super.fire();
			var l:int = inputs.length; 
			for (var i:int; i < l; i++) {
				if (inputs[i] is StateConnection && (inputs[i] as StateConnection).inhibited) return; 
			}	

			setFiring();
			pull();
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			var l:int = outputs.length;
			var color:uint = this.color;
			
			if (resourceOutputCount < 2 || resourceInputCount < 2) {
				actAsConverter = true;
			} else {
				actAsConverter = false;
			}
		}
		
		override public function receiveResource(color:uint, flow:ResourceConnection):void 
		{
			if (actAsConverter) {
				super.receiveResource(color, flow);
			} else {
				//redistribute
				var l:int = outputs.length;
				for (var i:int = 0; i < l; i++) {
					var fl:ResourceConnection = outputs[i] as ResourceConnection;
					if (fl && fl.color == flow.color) {
						fl.resources.push(new Resource(color, 0));
						break;
					}
				}
				if (checkInputs()) satisfy();
				
			}
		}
		
		override public function satisfy():void 
		{
			if (actAsConverter) {
				super.satisfy();
			} else {
				checkInhibition();
			}
			
			if (!_inhibited) {
				var l:int = outputs.length;
				for (var i:int = 0; i < l; i++) {
					if (outputs[i] is StateConnection) (outputs[i] as StateConnection).fire();
				}
			}
		}
		
	}

}