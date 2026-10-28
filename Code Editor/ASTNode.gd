class_name AST

class ASTNode:
	var line: int = 0

class LiteralNode extends ASTNode:
	var value
	func _init(v):
		value = v

class VariableNode extends ASTNode:
	var var_name: String
	func _init(n: String):
		var_name = n

class UnaryOpNode extends ASTNode:
	var op: String
	var operand
	func _init(o: String, e):
		op = o
		operand = e


class FunctionCallNode extends ASTNode:
	var func_name: String
	var args: Array = []
	func _init(name: String, a: Array = []):
		func_name = name
		args = a

class AssignmentNode extends ASTNode:
	var var_name: String
	var value
	func _init(name: String, val):
		var_name = name
		value = val


class ForLoopNode extends ASTNode:
	var init_expr
	var condition_expr
	var increment_expr
	var body: Array[ASTNode] = []
	func _init(init, condition, increment, b: Array[ASTNode]):
		init_expr = init
		condition_expr = condition
		increment_expr = increment
		body = b

class WhileLoopNode extends ASTNode:
	var condition_expr
	var body: Array[ASTNode] = []
	func _init(condition, b: Array[ASTNode]):
		condition_expr = condition
		body = b


class BinaryOpNode extends ASTNode:
	var left
	var op: String
	var right
	func _init(l, o, r):
		left = l
		op = o
		right = r


class IfNode extends ASTNode:
	var condition_expr
	var then_branch: Array[ASTNode]
	var else_branch: Array[ASTNode]
	
	func _init(p_cond, p_then: Array[ASTNode], p_else: Array[ASTNode] = []):
		condition_expr = p_cond
		then_branch = p_then
		else_branch = p_else

class FunctionDefNode extends ASTNode:
	var func_name: String
	var params: Array[String]
	var body: Array[ASTNode]
	func _init(n: String, p: Array[String], b: Array[ASTNode]):
		func_name = n
		params = p
		body = b

class ReturnNode extends ASTNode:
	var value
	func _init(v):
		value = v











	
	
	
	
