package nl.jorisdormans.utils 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Expression
	{
		
		public function Expression() 
		{
			
		}
		
		private static const operands:String = "0123456789.";
		private static function isOperand(c:String):Boolean {
			return (operands.indexOf(c) >= 0);
		}
		
		private static const operators:String = "()-+*/";
		private static function isOperator(c:String):Boolean {
			return (operators.indexOf(c) >= 0);
		}
		
		private static var postFix:Array;
		private static var stack:Array;
		
		public static function toPostFix(string:String):Array {
			var input:Array = new Array();
			postFix = new Array();
			stack = new Array();
			
			//parse string
			while (string.length > 0) {
				//find the first part
				var l:int = 0;
				var c:String; 
				var o:String = ""; 
				while (l < string.length) {
					c = string.charAt(l);
					if (!isOperand(c)) {
						break;
					}
					o += c;
					l++;
				}
				if (o.length == 0) {
					if (isOperator(c)) input.push(c);
					string = string.substr(1);
				} else {
					input.push(parseFloat(o));
					string = string.substr(o.length);
				}
			}
			
			//check special cases
			var i:int = 0;
			while (i < input.length) {
				if (input[i] == "-") {
					if (i == 0 || isOperator(input[i - 1] as String)) {
						if (input[i + 1] is Number) {
							input[i + 1] = (input[i + 1] as Number) * -1;
						}
						input.splice(i, 1);
						continue;
					}
				}
				i++;
			}
			trace(input);
			
			//create postFix
			while (input.length > 0) {
				c = input[0] as String;
				switch(c) {
					case "-":
					case "+":
						gotOperator(c, 1);
						break;
					case "/":
					case "*":
						gotOperator(c, 2);
						break;
					case "(":
						stack.push(c);
						break;
					case ")":
						gotParenthesis();
						break;
					default:
						postFix.push(input[0]);
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
						case "-":
						case "+":
							precedenceTop = 1;
							break;
						default:	
						case "*":
						case "/":
							precedenceTop = 2;
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
		
		public static function evaluate(postFix:Array):Number {
			stack = new Array();
			var num1:Number;
			var num2:Number;
			var interAns:Number;
			var l:int = postFix.length;
			for (var i:int = 0; i < l; i++) {
				if (!(postFix[i] is String)) {
					stack.push(postFix[i]);
				} else {
					num2 = stack.pop() as Number;
					num1 = stack.pop() as Number;
					switch (postFix[i]) {
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
						default:
							interAns = 0;
					}
					stack.push(interAns);
				}
			}
			interAns = stack.pop() as Number;
			return interAns;
		}
	}

}