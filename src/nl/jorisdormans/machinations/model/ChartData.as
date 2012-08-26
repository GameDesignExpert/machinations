package nl.jorisdormans.machinations.model 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.machinations.model.StateConnection;
	import nl.jorisdormans.phantomGraphics.DrawUtil;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class ChartData
	{
		public var data:Vector.<Number>;
		public var color:uint;
		public var color2:uint;
		public var thickness:int;
		public var connection:StateConnection;
		public var name:String;
		public var run:int;
		
		public function ChartData(connection:StateConnection, run:int) 
		{
			data = new Vector.<Number>();
			color = connection.color
			color2 = DrawUtil.lerpColor(color, 0xffffff, 0.7);
			thickness = connection.thickness;
			this.connection = connection;
			data.push(connection.state);
			if (connection.start is Pool) name = (connection.start as Pool).caption;
			else name = "";
			this.run = run;
		}
		
		public function toString():String {
			var s:String = name + "," + thickness.toString() + "," + StringUtil.toColorString(color);
			for (var i:int = 0; i < data.length; i++) s += "," + data[i].toString();
			return s;
		}
		
		
		
		
		
	}

}