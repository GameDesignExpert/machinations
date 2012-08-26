package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.phantomGUI.PhantomGUISettings;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PopUp extends Sprite
	{
		
		public function PopUp(parent:DisplayObjectContainer, x:Number, y:Number, caption:String, message:String) 
		{
			var w:Number = 300;
			var h:Number = 70;
			
			this.x = x;
			this.y = y;
			
			graphics.clear();
			graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
			graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFace);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
			graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorBorder);
			graphics.drawRect(0, 0, w, 30);
			graphics.endFill();
			graphics.lineStyle();
			
			graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorFaceHover);
			PhantomFont.drawText(caption, graphics, 10, 20, 10, PhantomFont.ALIGN_LEFT);
			PhantomFont.drawText("X", graphics, 290, 20, 10, PhantomFont.ALIGN_RIGHT);
			
			graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
			PhantomFont.drawText(message, graphics, 10, 45, 10, PhantomFont.ALIGN_LEFT);
			
			parent.addChild(this);
			
			var t:Timer = new Timer(3);
			t.addEventListener(TimerEvent.TIMER, onTimer);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if (parent) parent.removeChild(this);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onTimer(e:TimerEvent):void 
		{
			if (parent) parent.removeChild(this);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
	}

}