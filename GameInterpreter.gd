class_name GameInterpreter
extends Node

@export var player: Node2D

const MAX_LOOP_ITERATIONS = 10000

var scopes: Array[Dictionary] = [{}]
signal error_occurred(line: int, message: String)

var halted := false

func _ready() -> void:
	error_occurred.connect(_show_error)

func fail(message: String, node) -> void:
	if halted:
		return
	halted = true
	error_occurred.emit(node.line if node is AST.ASTNode else 0, message)

func type_name(v) -> String:
	if v == null: return "nothing"
	if v is bool: return "a boolean"
	if v is int: return "an integer"
	if v is float: return "a float"
	if v is String: return "a string"
	return "an unknown value"

func eval_condition(expr) -> bool:
	var v = evaluate_expression(expr)
	if halted:
		return false
	if not (v is bool):
		fail("The condition must be true or false, but got %s" % type_name(v), expr)
		return false
	return v


func run_block(nodes: Array[AST.ASTNode]):
	push_scope()
	await run_ast(nodes)
	pop_scope()


func run_ast(nodes: Array[AST.ASTNode]):
	for node in nodes:
		if halted:
			return
			
			
		if node is AST.AssignmentNode:
			var value = evaluate_expression(node.value)
			if not halted:
				set_var(node.var_name, value)
				
				
		elif node is AST.ForLoopNode:
			push_scope()
			await run_ast([node.init_expr])
			var guard := 0
			while not halted and eval_condition(node.condition_expr):
				guard += 1
				if guard > MAX_LOOP_ITERATIONS:
					fail("This loop ran more than %d times. Is it stuck in an infinite loop?" % MAX_LOOP_ITERATIONS, node)
					break
				await run_block(node.body)
				await run_ast([node.increment_expr])
			pop_scope()
			
			
		elif node is AST.WhileLoopNode:
			var guard := 0
			while not halted and eval_condition(node.condition_expr):
				guard += 1
				if guard > MAX_LOOP_ITERATIONS:
					fail("This loop ran more than %d times. Is it stuck in an infinite loop?" % MAX_LOOP_ITERATIONS, node)
					break
				await run_block(node.body)
				
				
		elif node is AST.FunctionCallNode:
			var evaluated_args: Array = []
			for arg in node.args:
				evaluated_args.append(evaluate_expression(arg))
			if halted:
				return
			await execute_function(node.func_name, evaluated_args, node)
			
			
		elif node is AST.IfNode:
			var met = eval_condition(node.condition_expr)
			if halted:
				return
			if met:
				await run_block(node.then_branch)
			elif not node.else_branch.is_empty():
				await run_block(node.else_branch)

func execute_function(func_name: String, args: Array, node):
	match func_name:
		"move":
			if args.size() != 1:
				fail("move() needs 1 argument, but got %d" % args.size(), node)
				return
			await player.move(args)
		"print":
			var text = str(args[0]) if args.size() > 0 else ""
			$Output.text += "OUTPUT: " + text + "\n"
		_:
			fail("Unknown function '%s'" % func_name, node)




func evaluate_expression(node):
	if node is AST.LiteralNode:
		return node.value

	if node is AST.VariableNode:
		if has_var(node.var_name):
			return get_var(node.var_name)
		fail("Variable '%s' doesn't exist here (not created yet, or out of scope)" % node.var_name, node)
		return null

	if node is AST.UnaryOpNode:
		var v = evaluate_expression(node.operand)
		if halted:
			return null
		if node.op == "-":
			if v is int or v is float:
				return -v
			fail("Can't use '-' on %s" % type_name(v), node)
		elif node.op == "!":
			if v is bool:
				return not v
			fail("Can't use '!' on %s, it needs true or false" % type_name(v), node)
		return null
	
	if node is AST.BinaryOpNode:
		var l = evaluate_expression(node.left)
		if halted:
			return null
		var r = evaluate_expression(node.right)
		if halted:
			return null
		return apply_binary(node, l, r)
	return null

func apply_binary(node: AST.BinaryOpNode, l, r):
	var op = node.op
	if op == "==": return l == r
	if op == "!=": return l != r
	
	if op == "+" and (l is String or r is String):
		return str(l) + str(r)
	
	var both_num = (l is int or l is float) and (r is int or r is float)
	var string_compare = op in ["<", ">", "<=", ">="] and l is String and r is String
	if not both_num and not string_compare:
		fail("Can't use '%s' between %s and %s" % [op, type_name(l), type_name(r)], node)
		return null
	
	match op:
		"+": return l + r
		"-": return l - r
		"*": return l * r
		"/":
			if r == 0:
				fail("Division by zero", node)
				return null
			return l / r
		"%":
			if r == 0:
				fail("Modulo by zero", node)
				return null
			return l % r if (l is int and r is int) else fmod(l, r)
		"<": return l < r
		">": return l > r
		"<=": return l <= r
		">=": return l >= r

	fail("Unknown operator '%s'" % op, node)
	return null


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
	
func _show_error(line: int, message: String) -> void:
	$Output.text += "Error on line %d: %s" % [line, message] + "\n"
	if line > 0 and line <= $CodeEditor.get_line_count():
		$CodeEditor.set_line_background_color(line - 1, Color(0.643, 0.0, 0.0, 0.631))
		$CodeEditor.set_caret_line(line - 1)

func _clear_error() -> void:
	$Output.text = ""
	for l in $CodeEditor.get_line_count():
		$CodeEditor.set_line_background_color(l, Color(0.0, 0.0, 0.0, 0.0))

func _on_run_pressed() -> void:
	scopes = [{}]
	halted = false
	_clear_error()
	
	var tokens = Lexer.tokenize($CodeEditor.text)
	if not Lexer.errors.is_empty():
		_show_error(Lexer.errors[0].line, Lexer.errors[0].message)
		return
	
	var ast = SimpleParser.parse(tokens)
	if not SimpleParser.errors.is_empty():
		_show_error(SimpleParser.errors[0].line, SimpleParser.errors[0].message)
		return
	
	await run_ast(ast)


	
	
	
	
	
	
