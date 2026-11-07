class_name GameInterpreter
extends Node

var player

signal error_occurred(line: int, message: String)

const MAX_LOOP_ITERATIONS = 10000
const MAX_CALL_DEPTH = 100
const BUILTINFUNCS = {
	"print": [1, 1],
	"move_left": [0, 0],
	"move_right": [0, 0],
	"move_stop": [0, 0],
	"wait": [1, 1],
	"jump": [0, 1],
	"dash": [1, 1]
}

var functions: Dictionary = {}
var scopes: Array[Dictionary] = [{}]

var halted := false

var call_depth := 0
var returning := false
var return_value = null

@onready var code_editor = $CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor
@onready var output: OutputLog = $CanvasLayer/VSplitContainer/Output
@onready var level_viewport: SubViewport = $CanvasLayer/VSplitContainer/HSplitContainer/subviewportcontation/SubViewport
var level: Node = null

func _load_level(load_code: bool = false) -> void:
	halted = true
	if is_instance_valid(level):
		level_viewport.remove_child(level)
		level.queue_free()
	
	var scene: PackedScene = load(ScreenHolder.currentScreenName)
	level = scene.instantiate()
	level_viewport.add_child(level)
	player = get_tree().get_first_node_in_group("player")
	
	await get_tree().process_frame
	var level_node = level.get_child(0)
	output.set_tutorial(level_node.tutorial)
	if load_code:
		Save._load_code()
func _ready() -> void:
	error_occurred.connect(_show_error)
	_load_level(true)

	

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
	var v = await evaluate_expression(expr)
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
		if node.line -1 >= 0:
			code_editor.set_line_background_color(node.line - 1, Color(0.471, 0.471, 0.471, 0.631))
		
		
		await get_tree().create_timer(0.01).timeout
		

		if halted:
			return
			
			
		if node is AST.AssignmentNode:
			var value = await evaluate_expression(node.value)
			if not halted:
				set_var(node.var_name, value)
				
				
		elif node is AST.ForLoopNode:
			push_scope()
			await run_ast([node.init_expr])
			var guard := 0
			while not halted and await eval_condition(node.condition_expr):
				guard += 1
				if guard > MAX_LOOP_ITERATIONS:
					fail("This loop ran more than %d times. Is it stuck in an infinite loop?" % MAX_LOOP_ITERATIONS, node)
					break
				await run_block(node.body)
				if returning:
					break
				await run_ast([node.increment_expr])
			pop_scope()
			
			
		elif node is AST.WhileLoopNode:
			var guard := 0
			while not halted and not returning and await eval_condition(node.condition_expr):
				guard += 1
				if guard > MAX_LOOP_ITERATIONS:
					fail("This loop ran more than %d times. Is it stuck in an infinite loop?" % MAX_LOOP_ITERATIONS, node)
					break
				await run_block(node.body)
				
				
		elif node is AST.FunctionCallNode:
			await evaluate_expression(node)
			
			
		elif node is AST.IfNode:
			var met = await eval_condition(node.condition_expr)
			if halted:
				return
			if met:
				await run_block(node.then_branch)
			elif not node.else_branch.is_empty():
				await run_block(node.else_branch)
		
		elif node is AST.FunctionDefNode:
			register_function(node)
		
		elif node is AST.ReturnNode:
			if call_depth == 0:
				fail("'return' can only be used inside a function", node)
				return
			var result = await evaluate_expression(node.value)
			if not halted:
				return_value = result
				returning = true
			return
		if node.line - 1 != -1:
			code_editor.set_line_background_color(node.line - 1, Color(0.471, 0.471, 0.471, 0.0))
		if halted or returning:
			return
		
func execute_function(func_name: String, args: Array, node):
	if BUILTINFUNCS.has(func_name):
		var low: int = BUILTINFUNCS[func_name][0]
		var high: int = BUILTINFUNCS[func_name][1]
		if args.size() < low or args.size() > high:
			var expected = str(low) if low == high else "%d to %d" % [low, high]
			fail("%s() takes %s argument(s), but got %d" % [func_name, expected, args.size()], node)
			return null
	
	match func_name:
		"move_left":
			await player.move_left()
		"move_right":
			await player.move_right()
		"move_stop":
			await player.move_stop()
		"wait":
			await player.wait(args)
		"jump":
			await player.jump(args)
		"dash":
			await player.dash(args)
		"print":
			var text = str(args[0]) if args.size() > 0 else ""
			output.print_line(text)
		_:
			fail("Unknown function '%s'" % func_name, node)
	return null




func evaluate_expression(node):
	if node is AST.LiteralNode:
		return node.value

	if node is AST.VariableNode:
		if has_var(node.var_name):
			return get_var(node.var_name)
		fail("Variable '%s' doesn't exist here (not created yet, or out of scope)" % node.var_name, node)
		return null
	
	if node is AST.FunctionCallNode:
		return await call_function(node)
	
	if node is AST.UnaryOpNode:
		var v = await evaluate_expression(node.operand)
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
		var l = await evaluate_expression(node.left)
		if halted:
			return null
		var r = await evaluate_expression(node.right)
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
	var lowest := 1 if call_depth > 0 else 0
	for i in range(scopes.size() -1, lowest - 1, -1):
		if scopes[i].has(var_name):
			scopes[i][var_name] = value
			return
	scopes[-1][var_name] = value
	
func _show_error(line: int, message: String) -> void:
	output.error_line(line, message)
	if line > 0 and line <= code_editor.get_line_count():
		code_editor.set_line_background_color(line - 1, Color(0.643, 0.0, 0.0, 0.631))
		code_editor.set_caret_line(line - 1)

func _clear_error() -> void:
	output.clear_log()
	for l in code_editor.get_line_count():
		code_editor.set_line_background_color(l, Color(0.0, 0.0, 0.0, 0.0))

func _on_run_pressed() -> void:
	Save._save()
	run_code()
	
	
func run_code() -> void:
	await get_tree().process_frame
	_load_level()
	scopes = [{}]
	halted = false
	functions.clear()
	call_depth = 0
	returning = false
	return_value = null
	_clear_error()
	
	var tokens = Lexer.tokenize(code_editor.text)
	if not Lexer.errors.is_empty():
		_show_error(Lexer.errors[0].line, Lexer.errors[0].message)
		return
	
	var ast = SimpleParser.parse(tokens)
	if not SimpleParser.errors.is_empty():
		_show_error(SimpleParser.errors[0].line, SimpleParser.errors[0].message)
		return
	
	for node in ast:
		if node is AST.FunctionDefNode:
			register_function(node)
	
	await run_ast(ast)

func register_function(def: AST.FunctionDefNode) -> void:
	if def.func_name in BUILTINFUNCS:
		fail("'%s' is a built-in function and can't be redefined" % def.func_name, def)
	elif functions.has(def.func_name) and functions[def.func_name] != def:
		fail("A function named '%s' already exists" % def.func_name, def)
	else:
		functions[def.func_name] = def
		
func call_function(node: AST.FunctionCallNode):
	var args: Array = []
	for arg in node.args:
		args.append(await evaluate_expression(arg))
		if halted:
			return null
	
	if functions.has(node.func_name):
		return await call_user_function(functions[node.func_name], args, node)
	
	return await execute_function(node.func_name, args, node)
	
func call_user_function(def: AST.FunctionDefNode, args: Array, call_node):
	if args.size() != def.params.size():
		fail("%s() needs %d arguments(s), but got %d" % [def.func_name, def.params.size(), args.size()], call_node)
		return null
	if call_depth >= MAX_CALL_DEPTH:
		fail("Too many nested calls (over %d). Is %s() calling itself forever?" % [MAX_CALL_DEPTH, call_depth], call_node)
		return null
	
	var locals := {}
	for i in def.params.size():
		locals[def.params[i]] = args[i]

	var saved_scopes = scopes
	var function_scopes: Array[Dictionary] = []
	function_scopes.append(scopes[0])
	function_scopes.append(locals)
	scopes = function_scopes
	call_depth += 1
	
	await run_ast(def.body)
	
	call_depth -= 1
	scopes = saved_scopes
	
	var result = return_value
	returning = false
	return_value = null
	return result
	
	
	
	


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
