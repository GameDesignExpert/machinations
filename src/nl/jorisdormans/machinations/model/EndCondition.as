package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class EndCondition extends MachinationsNode
	{
		public function EndCondition() 
		{
			
		}
		
		override public function prepare(doEvents:Boolean):void 
		{
			super.prepare(doEvents);
			_inhibited = true;
			if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
		}
		
		override public function update(time:Number):void 
		{
			if (!inhibited && !(graph as MachinationsGraph).ended) {
				(graph as MachinationsGraph).end(caption);
				this.firing = 0.25;
				if (doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
			}
			if (!inhibited) {
				if (this.firing >= 0) {
					this.firing -= time;
					if (this.firing < 0 && doEvents) dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
				} else {
					this.firing -= time;
					if (this.firing < -0.25 && doEvents) {
						this.firing += 0.5;
						dispatchEvent(new GraphEvent(GraphEvent.ELEMENT_CHANGE));
					}
				}
			}
		}
		
		override public function fire():void 
		{
			super.fire();
			trace("FIRED");
			(graph as MachinationsGraph).end(caption);
			this.firing = 0.25;
			_inhibited = false;
		}
		
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
		
	}

}