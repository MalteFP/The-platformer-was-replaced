class_name SimpleParser

static var errors: Array[Dictionary] = []

const PRECEDENCE = {
	"==": 1, "!=": 1,
	"<": 2, ">": 2, "<=": 2, ">=": 2,
	"+": 3, "-": 3,
	"*": 4, "/": 4, "%": 4
}

static func parse(tokens: Array) -> Array[AST.ASTNode]:
	errors.clear()
	return _parse_block(tokens, 0).nodes

static func _tok(tokens: Array, i: int):
	return tokens[mini(i, tokens.size() - 1)]

static func _describe(token) -> String:
	if token.type == Lexer.TokenType.NEWLINE or token.type == Lexer.TokenType.EOF:
		return "the end of the line"
	return "'%s'" % token.value

static func _error(message: String, token) -> void:
	if errors.is_empty():
		errors.append({"line": token.line, "message": message})

static func _expect(tokens: Array, i: int, type, what: String) -> bool:
	var t = _tok(tokens, i)
	if t.type == type:
		return true
	_error("Expected %s but found %s" % [what, _describe(t)], t)
	return false

static func _at(node, token):
	node.line = token.line
	return node


static func _parse_block(tokens: Array, start_index: int, end_token_type = -1) -> Dictionary:
	var nodes: Array[AST.ASTNode] = []
	var i = start_index
	var closed = false
	
	while i < tokens.size() and errors.is_empty():
		var token = tokens[i]
		
		#Line skips
		if end_token_type != -1 and token.type == end_token_type:
			i += 1
			closed = true
			break
			
		if token.type == Lexer.TokenType.NEWLINE or token.type == Lexer.TokenType.EOF:
			i += 1
			continue
			
		# 1. For Loop
		if token.type == Lexer.TokenType.IDENTIFIER and token.value == "for":
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.IDENTIFIER, "a variable name after 'for'"): continue
			var var_name = tokens[i].value
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.EQUALS, "'=' after '%s'" % var_name): continue
			i += 1
			var init_expr = _parse_value_or_expr(tokens, i)
			i = init_expr.next_index

			if not _expect(tokens, i, Lexer.TokenType.SEMICOL, "';' after the loop start"): continue
			i += 1
			var cond_result = _parse_value_or_expr(tokens, i)
			i = cond_result.next_index

			if not _expect(tokens, i, Lexer.TokenType.SEMICOL, "';' after the loop condition"): continue
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.IDENTIFIER, "a variable name in the loop increment"): continue
			var inc_var = tokens[i].value
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.EQUALS, "'=' after '%s'" % inc_var): continue
			i += 1
			var inc_expr = _parse_value_or_expr(tokens, i)
			i = inc_expr.next_index

			if not _expect(tokens, i, Lexer.TokenType.LBRACE, "'{' to start the loop body"): continue
			i += 1
			var block_result = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
			i = block_result.next_index

			var assignment = _at(AST.AssignmentNode.new(var_name, init_expr.node), token)
			var increment = _at(AST.AssignmentNode.new(inc_var, inc_expr.node), token)
			nodes.append(_at(AST.ForLoopNode.new(assignment, cond_result.node, increment, block_result.nodes), token))
		
		# 2. While Loop
		elif token.type == Lexer.TokenType.IDENTIFIER and token.value == "while":
			i += 1
			var cond_result = _parse_value_or_expr(tokens, i)
			i = cond_result.next_index
			if not _expect(tokens, i, Lexer.TokenType.LBRACE, "'{' after the while condition"): continue
			i += 1
			var block_result = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
			i = block_result.next_index
			nodes.append(AST.WhileLoopNode.new(cond_result.node, block_result.nodes))
		
		
		# 3. Function definition
		elif token.type == Lexer.TokenType.IDENTIFIER and token.value == "func":
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.IDENTIFIER, "a function name after 'func'"): continue
			var func_name = tokens[i].value
			i += 1
			if not _expect(tokens, i, Lexer.TokenType.LPAREN, "'(' after the function name"): continue
			i += 1
			
			var params: Array[String] = []
			while errors.is_empty():
				var t = _tok(tokens, i)
				if t.type == Lexer.TokenType.RPAREN:
					i += 1
					break
				if not _expect(tokens, i, Lexer.TokenType.IDENTIFIER, "a parameter name"):
					break
				if t.value in params:
					_error("The parameter '%s' is used twice" % t.value, t)
					break
				params.append(t.value)
				i += 1
				var sep = _tok(tokens, i)
				if sep.type == Lexer.TokenType.COMMA:
					i += 1
				elif sep.type != Lexer.TokenType.RPAREN:
					_error("Expected ',' between parameters or ')' to end them, but found %s" % _describe(sep), sep)
			if not errors.is_empty(): continue
			i += 1
			var func_body = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
			i = func_body.next_index
			nodes.append(_at(AST.FunctionDefNode.new(func_name, params, func_body.nodes), token))
		
		# 4. Return
		elif token.type == Lexer.TokenType.IDENTIFIER and token.value == "return":
			i += 1
			var value_node = null
			var nxt = _tok(tokens, i)
			if nxt.type != Lexer.TokenType.NEWLINE and nxt.type != Lexer.TokenType.EOF and nxt.type != Lexer.TokenType.RBRACE:
				var value_result = _parse_value_or_expr(tokens, i)
				value_node = value_result.node
				i = value_result.next_index
			nodes.append(_at(AST.ReturnNode.new(value_node), token))
		
		
		# 5. Variable Assignment
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.EQUALS:
			var var_name = token.value
			i += 2 
			var expr_result = _parse_value_or_expr(tokens, i)
			nodes.append(AST.AssignmentNode.new(var_name, expr_result.node))
			i = expr_result.next_index
			
		# 6. Function Call
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.LPAREN:
			var call_result = _parse_call(tokens, i)
			nodes.append(call_result.node)
			i = call_result.next_index
		
		# 7. If statement
		elif token.type == Lexer.TokenType.IDENTIFIER and token.value == "if":
			i += 1
			var cond_result = _parse_value_or_expr(tokens, i)
			i = cond_result.next_index
			if not _expect(tokens, i, Lexer.TokenType.LBRACE, "'{' after the if condition"): continue
			i += 1
			var then_block = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
			i = then_block.next_index
			
			var else_nodes: Array[AST.ASTNode] = []
			var j = i
			while _tok(tokens, j).type == Lexer.TokenType.NEWLINE:
				j += 1
			var next = _tok(tokens, j)
			if next.type == Lexer.TokenType.IDENTIFIER and next.value == "else":
				i = j + 1
				if not _expect(tokens, i, Lexer.TokenType.LBRACE, "'{' after 'else'"): continue
				i += 1
				var else_block = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
				else_nodes = else_block.nodes
				i = else_block.next_index
				
			nodes.append(AST.IfNode.new(cond_result.node, then_block.nodes, else_nodes))

		else:
			if token.type == Lexer.TokenType.IDENTIFIER and token.value == "else":
				_error("'else' has no matching 'if'", token)
			else:
				_error("Unexpected %s. A line should be an assignment like x = 5, or a call like print(x)" % _describe(token), token)
	if end_token_type != -1 and not closed:
		_error("This '{' is never closed with a '}' ", tokens[start_index - 1])
			
	return { "nodes": nodes, "next_index": i }




static func _parse_value_or_expr(tokens: Array, i: int, min_prec: int = 1) -> Dictionary:
	var left = _parse_primary(tokens, i)
	var node = left.node
	i = left.next_index
	
	while i < tokens.size() \
			and tokens[i].type == Lexer.TokenType.OPERATOR \
			and PRECEDENCE.has(tokens[i].value) \
			and PRECEDENCE[tokens[i].value] >= min_prec:
		var op_token = tokens[i]
		var right = _parse_value_or_expr(tokens, i + 1, PRECEDENCE[op_token.value] + 1)
		node = _at(AST.BinaryOpNode.new(node, op_token.value, right.node), op_token)
		i = right.next_index
	
	return {"node": node, "next_index": i}

static func _parse_primary(tokens: Array, i: int) -> Dictionary:
	var token = _tok(tokens, i)
	
	if token.type == Lexer.TokenType.LPAREN:
		var inner = _parse_value_or_expr(tokens, i + 1)
		if not _expect(tokens, inner.next_index, Lexer.TokenType.RPAREN, "')' to close the '('"):
			return inner
		return {"node": inner.node, "next_index": inner.next_index + 1}

	if token.type == Lexer.TokenType.OPERATOR and (token.value == "-" or token.value == "!"):
		var operand = _parse_primary(tokens, i + 1)
		return {"node": _at(AST.UnaryOpNode.new(token.value, operand.node), token), "next_index": operand.next_index}

	if token.type == Lexer.TokenType.STRING:
		return {"node": _at(AST.LiteralNode.new(token.value), token), "next_index": i + 1}

	if token.type == Lexer.TokenType.NUMBER:
		var num = int(token.value) if token.value.is_valid_int() else float(token.value) if token.value.is_valid_float() else token.value
		return {"node": _at(AST.LiteralNode.new(num), token), "next_index": i + 1}

	if token.type == Lexer.TokenType.IDENTIFIER:
		if token.value == "true" or token.value == "false":
			return {"node": _at(AST.LiteralNode.new(token.value == "true"), token), "next_index": i + 1}
		if  _tok(tokens, i + 1).type == Lexer.TokenType.LPAREN:
			return _parse_call(tokens, i)
		return {"node": _at(AST.VariableNode.new(token.value), token), "next_index": i + 1}

	_error("Expected a value but found %s" % _describe(token), token)
	return {"node": _at(AST.LiteralNode.new(null), token), "next_index": i}
		

static func _parse_call(tokens: Array, i: int) -> Dictionary:
	var name_token = tokens[i]
	var args: Array = []
	i += 2
	while errors.is_empty():
		var t = _tok(tokens, i)
		if t.type == Lexer.TokenType.RPAREN:
			i += 1
			break
		if t.type == Lexer.TokenType.NEWLINE or t.type == Lexer.TokenType.EOF:
			_error("Missing ')' to close the call to %s()" % name_token.value, t)
			break
		var arg = _parse_value_or_expr(tokens, i)
		args.append(arg.node)
		i = arg.next_index
		var sep = _tok(tokens, i)
		if sep.type == Lexer.TokenType.COMMA:
			i += 1
		elif sep.type != Lexer.TokenType.RPAREN:
			_error("Expected ',' between arguments or ')' to end til call, but found %s" % _describe(sep), sep)
	return {"node": _at(AST.FunctionCallNode.new(name_token.value, args), name_token), "next_index": i}
	
	
	
	
	
	
