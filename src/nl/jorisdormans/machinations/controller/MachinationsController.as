package nl.jorisdormans.machinations.controller 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.getTimer;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.machinations.model.MachinationsGraph;
	import nl.jorisdormans.machinations.view.MachinationsEditView;
	import nl.jorisdormans.machinations.view.MachinationsView;
	import nl.jorisdormans.machinations.view.RunReport;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsController
	{
		public var graph:MachinationsGraph;
		public var view:MachinationsView;
		private var runs:int;
		private var report:RunReport;
		private var timer:int;
		
		
		public function MachinationsController(graph:MachinationsGraph, view:MachinationsView) 
		{
			this.graph = graph;
			this.view = view;
			this.view.graph = graph;
			
			view.addEventListener(GraphEvent.GRAPH_RUN, onRun);
			view.addEventListener(GraphEvent.GRAPH_QUICKRUN, onQuickRun);
			view.addEventListener(GraphEvent.GRAPH_MULTIPLERUN, onMultipleRun);
		}
		
		private function onMultipleRun(e:GraphEvent):void 
		{
			if (graph.running) {
				if (graph.ended) {
					graph.doEvents = true;
					graph.running = false;
					view.setInteraction(true);
					view.refresh();
					if (report && report.parent) report.parent.removeChild(report);
				} else {
					view.removeEventListener(Event.ENTER_FRAME, onEnterFrameMultipleRuns);
					graph.end("Quit by user");
					
				}
			} else {
				graph.doEvents = false;
				graph.running = true;
				view.setInteraction(false);
				view.addEventListener(Event.ENTER_FRAME, onEnterFrameMultipleRuns);
				runs = 0;
				report = new RunReport(view.parent, graph.numberOfRuns);
			}
			
		}
		
		private function onEnterFrameMultipleRuns(e:Event):void 
		{
			var i:int = 0;
			while (!graph.ended && i < 10000) {
				i++;
				graph.update(1 / 10, true);
			}
			if (!graph.ended) {
				graph.end("Stopped before end");
			}
			view.refresh();
			runs++;
			report.countEnd(graph.endCondition, graph.steps);
			if (runs < graph.numberOfRuns) {
				graph.running = false;
				graph.running = true;
			} else {
				view.removeEventListener(Event.ENTER_FRAME, onEnterFrameMultipleRuns);
				view.multipleRuns.caption = "Reset";
			}
		}
		
		private function onQuickRun(e:GraphEvent):void 
		{
			if (graph.running) {
				if (graph.ended) {
					graph.doEvents = true;
					graph.running = false;
					view.setInteraction(true);
					view.refresh();
					if (report && report.parent) report.parent.removeChild(report);
				} else {
					view.removeEventListener(Event.ENTER_FRAME, onEnterFrameQuickRun);
					graph.end("Quit by user");
				}
			} else {
				graph.doEvents = false;
				graph.running = true;
				view.setInteraction(false);
				view.addEventListener(Event.ENTER_FRAME, onEnterFrameQuickRun);
			}
			
		}
		
		private function onEnterFrameQuickRun(e:Event):void 
		{
			var i:int = 0;
			while (!graph.ended && i < 100) {
				i++;
				graph.update(1 / 10, true);
			}
			view.refresh();
			if (graph.ended) {
				view.removeEventListener(Event.ENTER_FRAME, onEnterFrameQuickRun);
				view.quickRun.caption = "Reset";
				
				report = new RunReport(view.parent, 1);
				runs++;
				report.countEnd(graph.endCondition, graph.steps);
			}
		}
		
		private function onRun(e:GraphEvent):void 
		{
			graph.doEvents = true;
			graph.running = !graph.running;
			if (graph.running) {
				view.setInteraction(false);
				view.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				timer = getTimer();
			} else {
				view.setInteraction(true);
				view.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		private function onEnterFrame(e:Event):void 
		{
			var t:int = getTimer();
			var d:Number = (t - timer)/1000;
			timer = t;
			if (d > 0.1) d = 0.1;
			graph.update(d, true);
		}
		
		
	}

}