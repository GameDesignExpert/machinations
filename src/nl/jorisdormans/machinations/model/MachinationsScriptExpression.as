package nl.jorisdormans.machinations.model 
{
	import nl.jorisdormans.utils.StringUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class MachinationsScriptExpression
	{
		
		public function MachinationsScriptExpression() 
		{
			
		}
		
		private static const operands:String = "0123456789.";
		private static function isOperand(c:String):Boolean {
			return (operands.indexOf(c) >= 0);
		}
		
		//private static const variables:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		//private static function isVariable(c:String):Boolean {
		//	return (variables.indexOf(c) >= 0);
		//}
		
		private static const operators:String = "()-+*/%&|^=!><";
		private static function isOperator(c:String):Boolean {
			if (c.length > 0) return (operators.indexOf(c.substring(0, 1))>=0);
			return (operators.indexOf(c) >= 0);
		}
		
		private static var postFix:Array;
		private static var stack:Array;
		
		public static function toPostFix(string:String):Array {
			var input:Array = new Array();
			postFix = new Array();
			stack = new Array();
			
			//remove all spaces
			while (string.indexOf(" ")>=0) string = string.replace(" ", "");
			
			//parse string
			while (string.length > 0) {
				//find the first part
				var l:int = 0;
				var c:String; 
				var part:String = ""; 
				var operator:int  = 0;
				
				while (l < string.length) {
					c = string.charAt(l);
					if (operator == 0) {
						if (isOperator(c)) {
							operator = 1;
						} else {
							operator = -1;
						}
					}
					
					if (operator == 1) {
						if ((c == "-" || c=="(" || c==")") && l > 0)  {
							break;
						}
						if (!isOperator(c)) {
							break;
						}
					}
					if (operator == -1) {
						if (isOperator(c)) {
							break;
						}
					}
					part += c;
					l++;
					if (c == ")" || c == "(") {
						break;
					}
				}
				
				if (operator == 1) {
					input.push(part);
				} if (operator == -1) {
					var f:Number = parseFloat(part);
					if (isNaN(f)) {
						input.push(part);
					} else {
						input.push(f);
					}
				}
				
				string = string.substr(part.length);
			}
			
			
			//check special cases
			var i:int = 0;
			while (i < input.length) {
				if (input[i] == "-") {
					if (i == 0 || isOperator(input[i - 1] as String)) {
						if (input[i + 1] is Number) {
							input[i + 1] = (input[i + 1] as Number) * -1;
						} else {
							input.splice(i + 1, 0, -1, "*");
						}
						input.splice(i, 1);
						continue;
					}
				}
				i++;
			}
			
			//create postFix
			while (input.length > 0) {
				c = input[0] as String;
				if (c != null) c = StringUtil.trim(c);
				switch(c) {
					case "||":
						gotOperator(c, 1);
						break;
					case "&&":
						gotOperator(c, 2);
						break;
					case "|":
						gotOperator(c, 3);
						break;
					case "^":
						gotOperator(c, 4);
						break;
					case "&":
						gotOperator(c, 5);
						break;
					case "==":
					case "!=":
						gotOperator(c, 6);
						break;
					case "<":
					case ">":
					case "<=":
					case ">=":
						gotOperator(c, 7);
						break;
					case "-":
					case "+":
						gotOperator(c, 8);
						break;
					case "%":
					case "/":
					case "*":
						gotOperator(c, 9);
						break;
					case "(":
						stack.push(c);
						break;
					case ")":
						gotParenthesis();
						break;
					default:
						if (c) {
							postFix.push(c);
						} else {
							postFix.push(input[0]);
						}
				}	
				input.splice(0, 1);
			}
			while (stack.length > 0) {
				postFix.push(stack.pop());
			}
			return postFix;
		}
		
		private static function gotOperator(opThis:String, precedence:int):void {
			while (stack.length > 0) {
				var opTop:String = stack.pop();
				if (opTop == "(") {
					stack.push(opTop);
					break;
				} else {
					var precedenceTop:int;
					switch (opTop) {
						case "||":
							precedenceTop = 1;
							break;
						case "&&":
							precedenceTop = 2;
							break;
						case "|":
							precedenceTop = 3;
							break;
						case "^":
							precedenceTop = 4;
							break;
						case "&":
							precedenceTop = 5;
							break;
						case "==":
						case "!=":
							precedenceTop = 6;
							break;
						case "<":
						case ">":
						case "<=":
						case ">=":
							precedenceTop = 7;
							break;
						case "-":
						case "+":
							precedenceTop = 8;
							break;
						case "%":
						case "/":
						case "*":
							precedenceTop = 9;
							break;						
					}
					if (precedenceTop < precedence) {
						stack.push(opTop);
						break;
					} else {
						postFix.push(opTop);
					}
				}
			}
			stack.push(opThis);
		}
		
		private static function gotParenthesis():void {
			while (stack.length>0) {
				var chx:String = stack.pop();
				if (chx == "(") {
					break;
				} else {
					postFix.push(chx);
				}
			}
		}
		
		public static function evaluate(postFix:Array, instruction:APInstruction):Number {
			stack = new Array();
			var num1:Number;
			var num2:Number;
			var interAns:Number;
			var l:int = postFix.length;
			for (var i:int = 0; i < l; i++) {
				if (!(postFix[i] is String)) {
					stack.push(postFix[i]);
				} else {
					var stackLength:int = stack.length;
					num2 = stack.pop() as Number;
					num1 = stack.pop() as Number;
					switch (postFix[i]) {
						case "||":
							interAns = (num1>0 || num2>0)?1:0;
							break;
						case "&&":
							interAns = (num1>0 && num2>0)?1:0;
							break;
						case "|":
							interAns = num1 | num2;
							break;
						case "^":
							interAns = num1 ^ num2;
							break;
						case "&":
							interAns = num1 & num2;
							break;
						case "==":
							interAns = (num1 == num2)?1:0;
							break;
						case "!=":
							interAns = (num1 != num2)?1:0;
							break;
						case "<":
							interAns = (num1 < num2)?1:0;
							break;
						case ">":
							interAns = (num1 > num2)?1:0;
							break;
						case "<=":
							interAns = (num1 <= num2)?1:0;
							break;
						case ">=":
							interAns = (num1 >= num2)?1:0;
							break;							
						case "+":
							interAns = num1 + num2;
							break;
						case "-":
							interAns = num1 - num2;
							break;
						case "*":
							interAns = num1 * num2;
							break;
						case "/":
							interAns = num1 / num2;
							break;
						case "%":
							interAns = num1 % num2;
							break;
						default:
							interAns = instruction.getVariable(postFix[i]);
							if (stackLength > 1) stack.push(num1);
							if (stackLength > 0) stack.push(num2);
							break;
					}
					stack.push(interAns);
				}
			}
			interAns = stack.pop() as Number;
			return interAns;
		}
	}

}