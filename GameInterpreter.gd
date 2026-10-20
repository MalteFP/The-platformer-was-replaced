class_name GameInterpreter
extends Node

@export var player: Node2D
var memory: Dictionary = {}

func run_ast(nodes: Array[AST.ASTNode]):
	for node in nodes:
		if node is AST.AssignmentNode:
			var evaluated_val = evaluate_expression(node.value)
			memory[node.var_name] = evaluated_val
		elif node is AST.LoopNode:
			var raw_count = evaluate_expression(node.count_expr)
			var count = int(raw_count)
			for step in range(count):
				await run_ast(node.body)
		elif node is AST.FunctionCallNode:
			var temp_args: Array = []
			for arg in node.args:
				if memory.has(arg):
					temp_args.append(memory[arg])
				else:
					temp_args.append(arg)
			await execute_function(node.func_name, temp_args)
		elif node is AST.IfNode:
			var condition_met = evaluate_expression(node.condition_expr)
			if condition_met:
				await run_ast(node.then_branch)
			elif not node.else_branch.is_empty():
				await run_ast(node.else_branch)



func execute_function(func_name: String, args: Array):
	match func_name:
		"move":
			await player.move(args)
		"print":
			var actual_value = evaluate_expression(args[0]) if args.size() > 0 else ""
			print("OUTPUT: ", actual_value)

func evaluate_expression(node):
	if node is int or node is float:
		return node
	if node is AST.BinaryOpNode:
		var left_val = evaluate_expression(node.left)
		var right_val = evaluate_expression(node.right)
		
		match node.op:
			"+": return left_val + right_val
			"-": return left_val - right_val
			"*": return left_val * right_val
			"/": return int(left_val / right_val) if right_val != 0 else 0
			"%": return left_val % right_val if right_val != 0 else 0
			
			"==": return left_val == right_val
			"!=": return left_val != right_val
			"<": return left_val < right_val
			">": return left_val > right_val
			"<=": return left_val <= right_val
			">=": return left_val >= right_val
	
	if node is String and memory.has(node):
		return memory[node]
	
			
	return int(str(node)) if str(node).is_valid_int() else 0


func _on_run_pressed() -> void:
	var user_code = $CodeEditor.text
	var tokens = Lexer.tokenize(user_code)
	var ast = SimpleParser.parse(tokens)
	await run_ast(ast)
