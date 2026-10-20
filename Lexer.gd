class_name Lexer

enum TokenType { IDENTIFIER, NUMBER, LPAREN, RPAREN, LBRACE, RBRACE, EQUALS, OPERATOR, NEWLINE, EOF }

class Token:
	var type: TokenType
	var value: String
	func _init(t: TokenType, v: String = ""):
		type = t
		value = v

static func tokenize(code: String) -> Array[Token]:
	var tokens: Array[Token] = []
	var lines = code.split("\n")
	
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed == "" or trimmed.begins_with("#"):
			continue
		
		var i = 0
		while i < trimmed.length():
			var c = trimmed[i]
			
			if c == " " or c == "\t":
				i += 1
				continue
				
			if i + 1 < trimmed.length():
				var two_chars = trimmed.substr(i, 2)
				if two_chars in ["==", "!=", "<=", ">="]:
					tokens.append(Token.new(TokenType.OPERATOR, two_chars))
					i += 2
					continue
			
			match c:
				"(":
					tokens.append(Token.new(TokenType.LPAREN, "("))
					i += 1
				")":
					tokens.append(Token.new(TokenType.RPAREN, ")"))
					i += 1
				"{":
					tokens.append(Token.new(TokenType.LBRACE, "{"))
					i += 1
				"}":
					tokens.append(Token.new(TokenType.RBRACE, "}"))
					i += 1
				"=":
					tokens.append(Token.new(TokenType.EQUALS, "="))
					i += 1
				"+", "-", "*", "/", "%", "<", ">":
					tokens.append(Token.new(TokenType.OPERATOR, c))
					i += 1
				_:
					var start = i
					while i < trimmed.length():
						var next_c = trimmed[i]
						if next_c in [" ", "\t", "(", ")", "{", "}", "=", "+", "-", "*", "/", "%", "<", ">", "!"]:
							break
						i += 1
					var word = trimmed.substr(start, i - start)
					if word != "":
						if word.is_valid_int():
							tokens.append(Token.new(TokenType.NUMBER, word))
						else:
							tokens.append(Token.new(TokenType.IDENTIFIER, word))
							
		tokens.append(Token.new(TokenType.NEWLINE))
		
	tokens.append(Token.new(TokenType.EOF))
	return tokens
