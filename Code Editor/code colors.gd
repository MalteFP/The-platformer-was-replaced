class_name CodeColors
extends RefCounted


const TEXT := Color(0.545, 0.692, 0.999, 1.0)
const STRING := Color.DARK_GREEN
const COMMENT := Color.DARK_GRAY
const NUMBER := Color.DARK_SEA_GREEN
const FUNCTION := Color.PURPLE
const SYMBOL := Color.WHITE

const KEYWORDS := {
	"while": Color.ORANGE,
	"for": Color.ORANGE,
	"if": Color.ORANGE,
	"else": Color.ORANGE,
	"func": Color.RED,
	"false": Color.DARK_RED,
	"true": Color.DARK_RED,
	"return": Color.ORANGE
}

static func hex(c: Color) -> String:
	return "#" + c.to_html(false)
