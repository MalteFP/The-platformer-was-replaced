class_name GameInterpreter
extends Node

@export var player: Node2D
var scopes: Array[Dictionary] = [{}]

func run_block(nodes: Array[AST.ASTNode]):
	push_scope()
	await run_ast(nodes)
	pop_scope()

func run_ast(nodes: Array[AST.ASTNode]):
	for node in nodes:
		await get_tree().create_timer(0).timeout
		if node is AST.AssignmentNode:
			set_var(node.var_name, evaluate_expression(node.value))
		elif node is AST.ForLoopNode:
			push_scope()
			await run_ast([node.init_expr])
			while evaluate_expression(node.condition_expr):
				await run_block(node.body)
				await run_ast([node.increment_expr])
			pop_scope()
		elif node is AST.WhileLoopNode:
			while evaluate_expression(node.condition_expr):
				await run_block(node.body)
		elif node is AST.FunctionCallNode:
			var evaluated_args: Array = []
			for arg in node.args:
				evaluated_args.append(evaluate_expression(arg))
			await execute_function(node.func_name, evaluated_args)
		elif node is AST.IfNode:
			if evaluate_expression(node.condition_expr):
				await run_block(node.then_branch)
			elif not node.else_branch.is_empty():
				await run_block(node.else_branch)



func execute_function(func_name: String, args: Array):
	match func_name:
		"move":
			await player.move(args)
		"print":
			print("OUTPUT: ", args[0] if args.size() > 0 else "")

func evaluate_expression(node):
	if node is AST.LiteralNode:
		return node.value

	if node is AST.VariableNode:
		if has_var(node.var_name):
			return get_var(node.var_name)
		push_error("Undefined variable: " + node.var_name)
		return null

	if node is AST.UnaryOpNode:
		var v = evaluate_expression(node.operand)
		match node.op:
			"-": return -v
			"!": return not v

	if node is AST.BinaryOpNode:
		var l = evaluate_expression(node.left)
		var r = evaluate_expression(node.right)

		match node.op:
			"+":
				if l is String or r is String:
					return str(l) + str(r)
				return l + r
			"-": return l - r
			"*": return l * r
			"/":
				if r == 0:
					push_error("Division by zero")
					return 0
				return l / r
			"%":
				if r == 0:
					push_error("Modulo by zero")
					return 0
				return l % r if (l is int and r is int) else fmod(l, r)
			"==": return l == r
			"!=": return l != r
			"<": return l < r
			">": return l > r
			"<=": return l <= r
			">=": return l >= r

	return null


func _on_run_pressed() -> void:
	scopes = [{}]
	var user_code = $CodeEditor.text
	var tokens = Lexer.tokenize(user_code)
	var ast = SimpleParser.parse(tokens)
	await run_ast(ast)

func push_scope() -> void:
	scopes.append({})

func pop_scope() -> void:
	scopes.pop_back()

func has_var(var_name: String) -> bool:
	for i in range(scopes.size() -1, -1, -1):
		if scopes[i].has(var_name):
			return true
	return false

func get_var(var_name: String):
	for i in range(scopes.size() -1, -1, -1):
		if scopes[i].has(var_name):
			return scopes[i][var_name]
	return null

func set_var(var_name: String, value) -> void:
	for i in range(scopes.size() -1, -1, -1):
		if scopes[i].has(var_name):
			scopes[i][var_name] = value
			return
	scopes[-1][var_name] = value
	
