package 
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import nl.jorisdormans.graph.Graph;
	import nl.jorisdormans.graph.GraphGrammar;
	import nl.jorisdormans.machinations.controller.MachinationsController;
	import nl.jorisdormans.machinations.model.MachinationsExpression;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.view.MachinationsEditView;
	import nl.jorisdormans.machinations.view.MachinationsView;
	import nl.jorisdormans.phantomGraphics.PhantomFont;
	import nl.jorisdormans.utils.Expression;
	
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			//DONE: Ranges for activators don't seem to work
			
			//DONE: Remove white text from generated SVGs
			//DONE: Modulo doesn't seem to work in register formulae
			//DONE: Change Token Limit to Display Limit
			//DONE: Replace press INSERT to add way point to press W to add waypoint (but also support insert). 
			//TODO: Make sure all special nodes and labels are not case sensitive
			   //DONE: for actions register
			   //DONE: for all and else labels
			//DONE: Make sure all commands are not case sensitive
			//NOTDONE: Make sure references to nodes from APs are not case sensitive NOTE: This would go against the book
			//DONE: APs fire all nodes with the same name at once //CHECK FOR CONFLICTS
			//DONE: color-coding new style for Artificial Players
			//DONE: if you are in the middle of drawing state/resource connections, it would be cool if you could press ESC to cancel the adding of the connection.
			//DONE: would also be great if by pressing ESC you would go back to the select tool (the arrow)
			//DONE: I can select the Select Tool. Then I can unselect it... what does that mean? What tool am I using then?
			//DONE: Interval is obsolete, action/turn is not
			//NOTDONE: Can you add the .xml extension by default when saving? NOTE: Only available as AIR run time
			//DONE: Report the end condition for Quick runs
			
			//DONE: Dragging unconnected connections don't move their labels (22-4) 
			//DONE: Problem with nested parantheses: "if((steps % 10 < 1) && (money > 4 + steps * 0.04)) fire(buy)" doesn't work
			//DONE: Delay Converter Bug (converter after a delay doesn't work)
			//DONE: Graph setting for Dice 50% doesn't work properly
			
			//DONE: There is a bug in the average playtime somewhere. 
			//DONE: fix registers dropping multipliers below zero and going back up again

			//DONE: Make a pop up or something to flag nodes the AP cannot find
			//DONE: Check if a new XML converter needs to be written
			//DONE: ??Remove dynamic thickness for resource connections (of width 0) 
			
			//DONE: Rename Delayer Class to Delay
			
			//DONE: Change version to 4.0
			
			//TODO: If gate labels contain a probability formula use that formula to calculate the random value used.
			
			//TODO: Fix reverse trigger from triggering when the remainder is collected. (See figure B.16)
			//TODO: Fix graying out of conditional triggers in figure 6.40
			
			//TODO: Ready Made diagrams and automatically loading those doesn't seem to work for Chrome on PC and Opera and Saphari on Mac? Hard to reproduce...
			//TODO: Undo behavior is not always as consistent as it should be
			//TODO: I REALLY like when certain paths are greyed out, because they are not active. I think that interactive buttons should be disabled, when they are not allowed to fire.
			
			//TODO: ??Store average runtimes with charts in data
			//TODO: ??Display ansd store 'spreiding' of average run time
			//TODO: ??Move Run Report to Context Panel in editor mode?
			//TODO: ??Create Run Report for normal runs?
			
			
			//TODO: For PRO version, Create a special run mode that automatically replaces all random factors by deterministic equivalents
			//TODO: V5.0 a revert to saved button would be nice!  =)
			//TODO: V5.0 Find a way a converter can convert any number of incomming resources to output resources according to a specific ratio. Easiest if converters gain an extra setting that indicates if the conversion is determined by input and output, or by output only (and output would be a ratio "3/2")
			//TODO: V5.0 Hierarchical Diagrams
			//DOTO: V5.0 Making changes at run time to pool size and register starting values will change the labels and nodes (to make editing easier)
			//DOTO: V5.0 Make case-sensesivity consistent (everything is or everything is not!)
			//TODO: multicolor on one pool is impossible to see when the numbers start appearing instead of the stacks. Ideally a pool should have a number indicating the number of tokens of each color on it. That would reduce memory and imporve performance
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			// entry point
			PhantomFont.createSimpleFont();
			
			var c:MachinationsController;
			
			var test:Boolean = false;
			//test = true;
			
			trace("Machinations initializing...");
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			if (this.loaderInfo.parameters.mode=="view") {
				trace("Setting view mode...");
				var w:Number = 800;
				var h:Number = 600;
				if (this.loaderInfo.parameters.width != null) w = this.loaderInfo.parameters.width;
				if (this.loaderInfo.parameters.height != null) h = this.loaderInfo.parameters.height;
				var runs:Boolean = false;
				if (this.loaderInfo.parameters.quickrun == "true") runs = true;
				c = new MachinationsController(new MachinationsGraph(), new MachinationsView(this, 0, 0, w, h));
				if (runs || test) c.view.createQuickRunControls();
				this.scaleX = 800 / w;
				this.scaleY = 600 / h;
				if (this.loaderInfo.parameters.start) {
					c.view.runAfterLoad = true;
				}
				if (this.loaderInfo.parameters.file != null && this.loaderInfo.parameters.file != "") {
					trace("loading file "+this.loaderInfo.parameters.file+"...");
					c.view.loadGraph(this.loaderInfo.parameters.file);
				//} else if (test) {
				//	c.view.loadGraph("test.xml");
				}
			} else {
				trace("Setting edit mode...");
				c = new MachinationsController(new MachinationsGraph(), new MachinationsEditView(this, 0, 0, 800, 600));
				if (this.loaderInfo.parameters.start) {
					c.view.runAfterLoad = true;
				//} else if (test) {
				//	c.view.loadGraph("test.xml");
				}
				if (this.loaderInfo.parameters.file != null && this.loaderInfo.parameters.file != "") {
					trace("loading file "+this.loaderInfo.parameters.file+"...");
					c.view.loadGraph(this.loaderInfo.parameters.file);
				}
				
			}			
		}
	}
	
}