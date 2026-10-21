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
			i += 1
			break
			
		if token.type == Lexer.TokenType.NEWLINE or token.type == Lexer.TokenType.EOF:
			i += 1
			continue
			
		# 1. For Loop
		if token.type == Lexer.TokenType.IDENTIFIER and token.value == "for":
			i += 1 
			var var_name = tokens[i].value
			i += 2
			var asignment_result = _parse_value_or_expr(tokens, i)
			var asignment = AST.AssignmentNode.new(var_name, asignment_result)
			i = asignment_result.next_index
			i += 3
			
			print(i)
			
			var cond_result = _parse_value_or_expr(tokens, i)
			i = cond_result.next_index
			i += 1
			
			print(i)
			
			var increment_result = _parse_value_or_expr(tokens, i)
			var increment = AST.AssignmentNode.new(var_name, increment_result)
			i = increment_result.next_index
			i += 0
			if i < tokens.size() and tokens[i].type == Lexer.TokenType.LBRACE:
				i += 1
				var block_result = _parse_block(tokens, i, Lexer.TokenType.RBRACE)
				nodes.append(AST.ForLoopNode.new(asignment, cond_result, increment, block_result.nodes))
				i = block_result.next_index
		
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
				if tokens[i].type != Lexer.TokenType.NEWLINE:
					args.append(tokens[i].value)
				i += 1
				
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


static func _parse_value_or_expr(tokens: Array, i: int) -> Dictionary:
	var raw_val = tokens[i].value
	var left_val = int(raw_val) if raw_val.is_valid_int() else raw_val
	i += 1
	
	var vaild_ops = ["+", "-", "*", "/", "%", "==", "!=", "<", ">", "<=", ">="]
	
	if i < tokens.size() and tokens[i].value in vaild_ops:
		var op = tokens[i].value
		i += 1
		
		if i < tokens.size():
			var raw_right = tokens[i].value
			var right_val = int(raw_right) if raw_right.is_valid_int() else raw_right
			i += 1
			
			var node = AST.BinaryOpNode.new(left_val, op, right_val)
			
			if i < tokens.size() and tokens[i].value in vaild_ops:
				var op2 = tokens[i].value
				i += 1
				
				if i < tokens.size():
					var raw_right2 = tokens[i].value
					var right_val2 = int(raw_right2) if raw_right2.is_valid_int() else raw_right2
					i += 1
					
					node = AST.BinaryOpNode.new(node,op2, right_val2)
			
			return { "node": node, "next_index": i }
			
	return { "node": left_val, "next_index": i }
		
		
		
		
