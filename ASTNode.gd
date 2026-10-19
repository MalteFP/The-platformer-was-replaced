class_name AST

class ASTNode:
	pass


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
		print(var_name + " = " + str(value))


class LoopNode extends ASTNode:
	var count_expr
	var body: Array[ASTNode] = []
	func _init(cnt, b: Array[ASTNode]):
		count_expr = cnt
		body = b


class BinaryOpNode extends ASTNode:
	var left
	var op: String
	var right
	
	func _init(l, o, r):
		left = l
		op = o
		right = r
