class_name Lexer

enum TokenType { IDENTIFIER, NUMBER, STRING, LPAREN, RPAREN, LBRACE, RBRACE, SEMICOL, DOT, COMMA, EQUALS, OPERATOR, NEWLINE, EOF }

class Token:
	var type: TokenType
	var value: String
	var line: int = 0
	func _init(t: TokenType, v: String = ""):
		type = t
		value = v

static var errors: Array[Dictionary] = []

static func tokenize(code: String) -> Array[Token]:
	errors.clear()
	var tokens: Array[Token] = []
	var lines = code.split("\n")
	
	for line_index in lines.size():
		var line_number = line_index + 1
		var trimmed = lines[line_index].strip_edges()
		if trimmed == "" or trimmed.begins_with("#"):
			continue
		
		var first_token = tokens.size()
		
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
				";":
					tokens.append(Token.new(TokenType.SEMICOL, ";"))
					i += 1
				"=":
					tokens.append(Token.new(TokenType.EQUALS, "="))
					i += 1
				".":
					tokens.append(Token.new(TokenType.DOT, "."))
					i += 1
				",":
					tokens.append(Token.new(TokenType.COMMA, ","))
					i += 1
				"\"":
					i += 1
					var str_value = ""
					while i < trimmed.length() and trimmed[i] != "\"":
						if trimmed[i] == "\\" and i + 1 < trimmed.length():
							i += 1
							match trimmed[i]:
								"n": str_value += "\n"
								"t": str_value += "\t"
								_: str_value += trimmed[i]
						else:
							str_value += trimmed[i]
						i += 1
					if i >= trimmed.length():
						errors.append({"line": line_number, "message": "This string is missing its closing quote"})
					i += 1
					tokens.append(Token.new(TokenType.STRING, str_value))
				"+", "-", "*", "/", "%", "<", ">":
					tokens.append(Token.new(TokenType.OPERATOR, c))
					i += 1
				_:
					var start = i
					while i < trimmed.length():
						var next_c = trimmed[i]
						if next_c in [" ", "\t", "(", ")", "{", "}", "=", "+", "-", "*", "/", "%", "<", ">", "!", ";", ",", ".", "\""]:
							break
						i += 1
					var word = trimmed.substr(start, i - start)
					if word != "":
						if word.is_valid_int() or word.is_valid_float():
							tokens.append(Token.new(TokenType.NUMBER, word))
						else:
							tokens.append(Token.new(TokenType.IDENTIFIER, word))
					if i == start:
						errors.append({"line": line_number, "message": "Unexpected character '%s'" % trimmed[i]})
						i += 1
							
		tokens.append(Token.new(TokenType.NEWLINE))
		for t in range(first_token, tokens.size()):
			tokens[t].line = line_number
	var eof = Token.new(TokenType.EOF)
	eof.line = lines.size()
	tokens.append(eof)
	return tokens
