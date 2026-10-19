class_name Lexer

enum TokenType { IDENTIFIER, NUMBER, LPAREN, RPAREN, LBRACE, RBRACE, EQUALS, COLON, NEWLINE, EOF }

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
		
		var formatted = trimmed \
			.replace("(", " ( ") \
			.replace(")", " ) ") \
			.replace("{", " { ") \
			.replace("}", " } ") \
			.replace("=", " = ")
			
		var words = formatted.split(" ", false)
		for word in words:
			match word:
				"(": tokens.append(Token.new(TokenType.LPAREN))
				")": tokens.append(Token.new(TokenType.RPAREN))
				"{": tokens.append(Token.new(TokenType.LBRACE))
				"}": tokens.append(Token.new(TokenType.RBRACE))
				"=": tokens.append(Token.new(TokenType.EQUALS))
				_: tokens.append(Token.new(TokenType.IDENTIFIER, word))
				
		tokens.append(Token.new(TokenType.NEWLINE))
		
	tokens.append(Token.new(TokenType.EOF))
	return tokens
