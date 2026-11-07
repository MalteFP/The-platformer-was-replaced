extends Node2D

@export var tutorial: Array[String]

func _ready() -> void:
	var output: OutputLog = get_tree().get_first_node_in_group("output")
	output.set_tutorial(tutorial)
