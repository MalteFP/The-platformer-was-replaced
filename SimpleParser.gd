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
			
			if i < tokens.size() and tokens[i].type == Lexer.TokenType.LBRACE:
				i += 1
				var block_result = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
				
				nodes.append(AST.WhileLoopNode.new(cond_result.node, block_result.nodes))
				i = block_result.next_index
			
		# 3. Variable Assignment
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.EQUALS:
			var var_name = token.value
			i += 2 
			var expr_result = _parse_value_or_expr(tokens, i)
			nodes.append(AST.AssignmentNode.new(var_name, expr_result.node))
			i = expr_result.next_index
			
		# 4. Function Call
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.LPAREN:
			var func_name = token.value
			i += 2

			var args: Array = []
			while i < tokens.size() and tokens[i].type != Lexer.TokenType.RPAREN:
				if tokens[i].type == Lexer.TokenType.DOT or tokens[i].type == Lexer.TokenType.NEWLINE:
					i += 1
					continue
				var arg = _parse_value_or_expr(tokens, i)
				args.append(arg.node)
				i = arg.next_index

			if i < tokens.size() and tokens[i].type == Lexer.TokenType.RPAREN:
				i += 1

			nodes.append(AST.FunctionCallNode.new(func_name, args))
		
		# 5. If statement
		elif token.type == Lexer.TokenType.IDENTIFIER and token.value == "if":
			i += 1
			
			var cond_result = _parse_value_or_expr(tokens, i)
			i = cond_result.next_index
			
			if i < tokens.size() and tokens[i].type == Lexer.TokenType.LBRACE:
				i += 1
				var then_block = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
				i = then_block.next_index
				var else_nodes: Array[AST.ASTNode] = []
			
				if i < tokens.size() and tokens[i].type == Lexer.TokenType.IDENTIFIER and tokens[i].value == "else":
					i += 1
					if i < tokens.size() and tokens[i].type == Lexer.TokenType.LBRACE:
						i += 1
						var else_block = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
						else_nodes = else_block.nodes
						i = else_block.next_index
				
				nodes.append(AST.IfNode.new(cond_result.node, then_block.nodes, else_nodes))
		
		
		else:
			i += 1
			
	return { "nodes": nodes, "next_index": i }




static func _parse_value_or_expr(tokens: Array, i: int, min_prec: int = 1) -> Dictionary:
	var left = _parse_primary(tokens, i)
	var node = left.node
	i = left.next_index
	
	while i < tokens.size() \
			and tokens[i].type == Lexer.TokenType.OPERATOR \
			and PRECEDENCE.has(tokens[i].value) \
			and PRECEDENCE[tokens[i].value] >= min_prec:
		var op = tokens[i].value
		var right = _parse_value_or_expr(tokens, i + 1, PRECEDENCE[op] + 1)
		node = AST.BinaryOpNode.new(node, op, right.node)
		i = right.next_index
	
	return {"node": node, "next_index": i}

static func _parse_primary(tokens: Array, i: int) -> Dictionary:
	if i >= tokens.size():
		return {"node": AST.LiteralNode.new(null), "next_index": i}

	var token = tokens[i]

	if token.type == Lexer.TokenType.LPAREN:
		var inner = _parse_value_or_expr(tokens, i + 1)
		var next_i = inner.next_index
		if next_i < tokens.size() and tokens[next_i].type == Lexer.TokenType.RPAREN:
			next_i += 1
		return {"node": inner.node, "next_index": next_i}

	if token.type == Lexer.TokenType.OPERATOR and (token.value == "-" or token.value == "!"):
		var operand = _parse_primary(tokens, i + 1)
		return {"node": AST.UnaryOpNode.new(token.value, operand.node), "next_index": operand.next_index}

	if token.type == Lexer.TokenType.STRING:
		return {"node": AST.LiteralNode.new(token.value), "next_index": i + 1}

	if token.type == Lexer.TokenType.NUMBER:
		var num = int(token.value) if token.value.is_valid_int() else float(token.value)
		return {"node": AST.LiteralNode.new(num), "next_index": i + 1}

	if token.type == Lexer.TokenType.IDENTIFIER:
		if token.value == "true":
			return {"node": AST.LiteralNode.new(true), "next_index": i + 1}
		if token.value == "false":
			return {"node": AST.LiteralNode.new(false), "next_index": i + 1}
		return {"node": AST.VariableNode.new(token.value), "next_index": i + 1}

	return {"node": AST.LiteralNode.new(null), "next_index": i + 1}
