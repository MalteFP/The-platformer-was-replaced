class_name SimpleParser



static func parse(tokens: Array) -> Array[AST.ASTNode]:
	return _parse_block(tokens, 0).nodes

static func _parse_block(tokens: Array, start_index: int, end_token_type = -1) -> Dictionary:
	var nodes: Array[AST.ASTNode] = []
	var i = start_index
	
	while i < tokens.size():
		var token = tokens[i]
		
		#Line skips
		if end_token_type != -1 and token.type == end_token_type:
			i += 1 # Move past the closing brace
			break
			
		if token.type == Lexer.TokenType.NEWLINE or token.type == Lexer.TokenType.EOF:
			i += 1
			continue
			
		# 1.Loop
		if token.type == Lexer.TokenType.IDENTIFIER and token.value == "repeat":
			i += 1 
			var count_val = tokens[i].value
			i += 1
			
			
			if i < tokens.size() and tokens[i].type == Lexer.TokenType.LBRACE:
				i += 1
				
				var block_result = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
				nodes.append(AST.LoopNode.new(count_val, block_result.nodes))
				i = block_result.next_index
				
		# 2. Variable Assignment
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.EQUALS:
			var var_name = token.value
			i += 2 
			var expr_result = _parse_value_or_expr(tokens, i)
			var value = GameInterpreter.new().evaluate_expression(expr_result.node)
			nodes.append(AST.AssignmentNode.new(var_name, value))
			i = expr_result.next_index
			
		# 3. Function Call
		elif token.type == Lexer.TokenType.IDENTIFIER and i + 1 < tokens.size() and tokens[i + 1].type == Lexer.TokenType.LPAREN:
			var func_name = token.value
			i += 2 
			
			var args: Array = []
			while i < tokens.size() and tokens[i].type != Lexer.TokenType.RPAREN:
				if tokens[i].type != Lexer.TokenType.NEWLINE:
					args.append(tokens[i].value)
				i += 1
				
			if i < tokens.size() and tokens[i].type == Lexer.TokenType.RPAREN:
				i += 1 
				
			nodes.append(AST.FunctionCallNode.new(func_name, args))
		
		else:
			i += 1
			
	return { "nodes": nodes, "next_index": i }


static func _parse_value_or_expr(tokens: Array, i: int) -> Dictionary:
	var raw_val = tokens[i].value
	var left_val = int(raw_val) if raw_val.is_valid_int() else raw_val
	i += 1
	
	if i < tokens.size() and tokens[i].value in ["+", "-", "*", "/", "%"]:
		var op = tokens[i].value
		i += 1
		
		if i < tokens.size():
			var raw_right = tokens[i].value
			var right_val = int(raw_right) if raw_right.is_valid_int() else raw_right
			i += 1
			
			var node = AST.BinaryOpNode.new(left_val, op, right_val)
			return { "node": node, "next_index": i }
			
	return { "node": left_val, "next_index": i }
		
		
		
		
