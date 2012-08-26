package nl.jorisdormans.machinations.model 
{
	import flash.xml.XMLNode;
	import nl.jorisdormans.graph.GraphEvent;
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class APInstruction
	{
		private var condition:Array;
		private var parameters:Vector.<String>;
		private var command:String;
		private var counter:int;
		private var actionsOfCommand:int;
		private var artificialPlayer:ArtificialPlayer;
		
		public function APInstruction(artificialPlayer:ArtificialPlayer, instruction:String) 
		{
			//instruction = instruction.toLowerCase();
			
			this.artificialPlayer = artificialPlayer;
			//trace("Parsing instruction");
			//trace("instr:", instruction);
			command = StringUtil.getCommand(instruction);
			instruction = instruction.substr(command.length);
			command = StringUtil.trim(command);
			//trace("comm", command, instruction);
			switch (command.toLowerCase()) {
				case "if":
					var con:String = StringUtil.getCondition(instruction);
					instruction = instruction.substr(con.length);
					con = StringUtil.trim(con);
					//trace("con1:", con, instruction);
					condition = MachinationsScriptExpression.toPostFix(con);
					//trace("con2:", condition);
					command = StringUtil.getCommand(instruction);
					instruction = instruction.substr(command.length);
					command = StringUtil.trim(command);
					//trace("comm:", command, instruction);
					break;
			}
			parameters = StringUtil.getParameters(instruction);
			for (var i:int = 0; i < parameters.length; i++) {
				parameters[i] = StringUtil.trim(parameters[i]);
			}
			counter = 0;
			actionsOfCommand = 0;
		}
		
		
		public function getVariable(variable:String):Number {
			var n:MachinationsNode;
			if ((artificialPlayer.graph as MachinationsGraph).colorCoding > 0) {
				n = (artificialPlayer.graph as MachinationsGraph).findNodeByCaptionAndColor(variable, artificialPlayer.color);
			} else {
				n = (artificialPlayer.graph as MachinationsGraph).findNodeByCaption(variable);
			}
			if (n is Pool) {
				return (n as Pool).resourceCount;
			}
			if (n is Register) {
				return (n as Register).value;
			}
			switch (variable.toLowerCase()) {
				case "pregen0":
					return artificialPlayer.pregeneratedRandom[0];
				case "pregen1":
					return artificialPlayer.pregeneratedRandom[1];
				case "pregen2":
					return artificialPlayer.pregeneratedRandom[2];
				case "pregen3":
					return artificialPlayer.pregeneratedRandom[3];
				case "pregen4":
					return artificialPlayer.pregeneratedRandom[4];
				case "pregen5":
					return artificialPlayer.pregeneratedRandom[5];
				case "pregen6":
					return artificialPlayer.pregeneratedRandom[6];
				case "pregen7":
					return artificialPlayer.pregeneratedRandom[7];
				case "pregen8":
					return artificialPlayer.pregeneratedRandom[8];
				case "pregen9":
					return artificialPlayer.pregeneratedRandom[9];
				case "random":
					return Math.random();
				case "actions":
					return artificialPlayer.actionsExecuted;
				case "steps":
					return (artificialPlayer.graph as MachinationsGraph).steps;
				case "actionsofcommand":
					return actionsOfCommand;
				case "actionsperstep":
					return artificialPlayer.actionsPerStep;
				default:
					var s:String = "Cannot find pool, register or variable| labeled '" + variable + "'";
					if ((artificialPlayer.graph as MachinationsGraph).colorCoding > 0) {
						s += " (color " + StringUtil.toColorString(artificialPlayer.color).toLowerCase()+")";
					}					
					artificialPlayer.graph.dispatchEvent(new GraphEvent(GraphEvent.GRAPH_WARNING, null, s));
					//(artificialPlayer.graph as MachinationsGraph).end("Error");
					return 0;
			}
			
		}
		
		public function activate():Boolean {
			if (condition) {
				if (MachinationsScriptExpression.evaluate(condition, this) == 0) return false;
			}
			actionsOfCommand++;
			switch (command.toLowerCase()) {
				case "fire":
					commandFire();
					return true;
				case "fireall":
					commandFireAll();
					return true;
				case "firesequence":
				case "do":
					commandFireSequence();
					return true;
				case "firerandom":
				case "choose":
					commandFireRandom();
					return true;
				case "increase":
					changeRegister(1);
					return true;
				case "decrease":
					changeRegister(-1);
					return true;
				case "endturn":
					endTurn();
					return true;
				case "stopdiagram":
					stopDiagram();
					return true;
				case "activate":
					activateAP();
					return true;
				case "deactivate":
					artificialPlayer.deactivate();
					return true;
			}
			return false;
		}
		
		private function clickNode(node:MachinationsNode):void {
			if (!node) return;
			node.click();
			node.setFiring();
		}
		
		private function fireNode(caption:String):void {
			var graph:MachinationsGraph = artificialPlayer.graph as MachinationsGraph;
			if (!graph) return;
			/* Fire only the first node 
			if (graph.colorCoding > 0) {
				clickNode(graph.findNodeByCaptionAndColor(caption, artificialPlayer.color));
			} else {
				clickNode(graph.findNodeByCaption(caption));
			}
			//*/
			
			//* Fire all nodes with the same caption
			var nodes:Vector.<MachinationsNode>;
			if (graph.colorCoding > 0) {
				nodes = graph.findAllNodesByCaptionAndColor(caption, artificialPlayer.color);
			} else {
				nodes = graph.findAllNodesByCaption(caption);
			}
			if (nodes.length < 1) {
				var s:String = "Cannot find node '" + caption + "'";
				if (graph.colorCoding > 0) {
					s += "|(color " + StringUtil.toColorString(artificialPlayer.color).toLowerCase()+")";
				}
				//trace("WARNING: " + s);
				graph.dispatchEvent(new GraphEvent(GraphEvent.GRAPH_ERROR, null, s));
				//graph.end("Error");
			}
			for (var i:int = 0; i < nodes.length; i++) clickNode(nodes[i]);
			//*/
		}
		
		private function commandFire():void
		{
			if (parameters.length > 0) {
				fireNode(parameters[0]);
			}
		}
		
		private function commandFireAll():void
		{
			for (var i:int = 0; i < parameters.length; i++) {
				fireNode(parameters[i]);
			}
		}
		
		private function commandFireSequence():void
		{
			if (parameters.length > 0) {
				fireNode(parameters[counter]);
				counter++;
				counter %= parameters.length;
			}
		}
		
		private function commandFireRandom():void
		{
			if (parameters.length > 0) {
				var r:int = Math.random() * parameters.length;
				fireNode(parameters[r]);
			}
		}
		
		private function changeRegister(d:int):void
		{
			var graph:MachinationsGraph = artificialPlayer.graph as MachinationsGraph;
			if (parameters.length > 0 && graph) {
				var register:Register = graph.findNodeByCaptionAndColor(parameters[0], artificialPlayer.color) as Register;
				if (register && register.activationMode == MachinationsNode.MODE_INTERACTIVE) {
					trace(d*register.valueStep);
					register.interaction = d * register.valueStep;
					register.fire();
				}
			}
		}
		
		private function endTurn():void
		{
			var graph:MachinationsGraph = artificialPlayer.graph as MachinationsGraph;
			if (graph && graph.actionsPerTurn>0) {
				graph.actionsThisTurn = graph.actionsPerTurn;
			}
		}
		
		private function stopDiagram():void
		{
			var graph:MachinationsGraph = artificialPlayer.graph as MachinationsGraph;
			if (graph && graph.running) {
				if (parameters.length > 0) graph.end(parameters[0]);
				else graph.end(artificialPlayer.caption);
			}
		}
		
		private function activateAP():void
		{
			var graph:MachinationsGraph = artificialPlayer.graph as MachinationsGraph;
			if (parameters.length > 0 && graph) {
				var node:MachinationsNode = graph.findNodeByCaptionAndColor(parameters[counter], artificialPlayer.color);
				counter++;
				counter %= parameters.length;
				if (node is ArtificialPlayer) {
					(node as ArtificialPlayer).activate();
				}
				
			}
			artificialPlayer.deactivate();
		}
		
	}

}