package nl.jorisdormans.machinations.model 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import nl.jorisdormans.phantomGraphics.DrawUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Resource extends Sprite
	{

		public var color:uint;
		public var position:Number;
		public var connection:ResourceConnection;
		
		public function Resource(color:uint, position:Number) 
		{
			this.color = color;
			this.position = position;
			this.connection = null;
		}
		
	}

}