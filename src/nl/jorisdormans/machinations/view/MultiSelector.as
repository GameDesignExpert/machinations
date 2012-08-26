package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import nl.jorisdormans.machinations.view.MachinationsEditView;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MultiSelector extends Sprite
	{
		private var setWidth:Number;
		private var setHeight:Number;
		
		public function MultiSelector() 
		{
			
		}
		
		public function setPosition(parent:DisplayObjectContainer, x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
			parent.addChild(this);
			setSize(0, 0);
		}
		
		public function setSize(w:Number, h:Number):void
		{
			setWidth = w;
			setHeight = h;
			graphics.clear();
			graphics.lineStyle(2, MachinationsViewElement.SELECTED_COLOR);
			graphics.drawRect(0, 0, w, h);
		}
		
		public function getRectangle():Rectangle
		{
			var r:Rectangle = new Rectangle(0, 0, Math.abs(setWidth), Math.abs(setHeight));
			r.x = Math.min(x, x + setWidth);
			r.y = Math.min(y, y + setHeight);
			return r;
		}
		
		
		
	}

}