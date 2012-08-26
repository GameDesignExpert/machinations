package nl.jorisdormans.machinations.view 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.phantomGUI.PhantomGUISettings;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class RunReport extends Sprite
	{
		private var reportWidth:int;
		private var ends:Vector.<String>;
		private var counts:Vector.<int>;
		private var totalRuns:int;
		private var runs:int;
		private var totalTime:Number;
		private var minHeight:Number;
		
		public function RunReport(parent:DisplayObjectContainer, totalRuns:int ) 
		{
			//* Visible in the middle
			reportWidth = 200;
			x = (600 - reportWidth) * 0.5;
			y = 100;
			minHeight = 40;
			//*/
			
			/* visible on context panel
			reportWidth = 196;
			x = 601;
			y = 241;
			minHeight = 358;
			//*/
			ends = new Vector.<String>();
			counts = new Vector.<int>();
			this.totalRuns = totalRuns;
			runs = 0;
			draw();
			parent.addChild(this);
			totalTime = 0;
		}
		
		private function draw():void {
			graphics.clear();
			graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
			graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFace);
			//graphics.drawRect(0, 0, reportWidth, ends.length * 20 + 62);
			graphics.drawRect(0, 0, reportWidth, Math.max(minHeight, ends.length * 20 + 62));
			graphics.endFill();
			graphics.lineStyle();
			
			
			var t:Number = totalTime / runs;
			
			if (runs == 1 && totalRuns == 1) {
				graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
				PhantomFont.drawText("Time: "+t.toFixed(2), graphics, 10, 20, 10, PhantomFont.ALIGN_LEFT);
				var l:int = ends.length;
				for (var i:int = 0; i < l; i++) {
					PhantomFont.drawText("Ended by: " +ends[i], graphics, 10, 45+20*i, 10, PhantomFont.ALIGN_LEFT);
				}
			} else {
				graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorBorder);
				graphics.drawRect(4, 4, reportWidth-8, 22);
				graphics.endFill();
				graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFaceDisabled);
				graphics.drawRect(6, 6, reportWidth-12, 18);
				graphics.endFill();
				graphics.beginFill(PhantomGUISettings.colorSchemes[0].colorFaceHover);
				graphics.drawRect(6, 6, (reportWidth-12)*(runs/totalRuns), 18);
				graphics.endFill();
				
				graphics.lineStyle(2, PhantomGUISettings.colorSchemes[0].colorBorder);
				PhantomFont.drawText("Runs: " + runs, graphics, 10, 20, 10, PhantomFont.ALIGN_LEFT);
				PhantomFont.drawText("Average time: "+t.toFixed(2), graphics, 10, 45, 10, PhantomFont.ALIGN_LEFT);
				l = ends.length;
				for (i = 0; i < l; i++) {
					PhantomFont.drawText(ends[i]+": "+counts[i].toString(), graphics, 10, 70+20*i, 10, PhantomFont.ALIGN_LEFT);
					//PhantomFont.drawText(counts[i].toString(), graphics, reportWidth-50, 70+20*i, 10, PhantomFont.ALIGN_RIGHT);
				}
			}
		}
		
		public function countEnd(end:String, time:Number):void {
			runs++;
			while (true) {
				var p:int = end.indexOf("|");
				if (p < 0) break;
				end = end.substr(0, p) + " " + end.substr(p + 1);
				break;
			}
			totalTime += time;
			var found:Boolean = false;
			var l:int = ends.length;
			for (var i:int = 0; i < l; i++) {
				if (ends[i] == end) {
					counts[i]++;
					found = true;
					break;
				}
			}
			if (!found) {
				ends.push(end);
				counts.push(1);
			}
			draw();
		}
		
	}

}