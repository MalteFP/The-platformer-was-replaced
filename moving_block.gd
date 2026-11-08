extends AnimatableBody2D

const TILE := 16


@export var size_in_tiles := Vector2i(2, 2):
	set(value):
		size_in_tiles = value.max(Vector2i.ONE)
		_update_size()

@export var direction := Vector2.RIGHT:
	set(value):
		rotation = value.angle()
@export var speed := 25.0

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var patch: NinePatchRect = $NinePatchRect

var moving := false

func _ready():
	sync_to_physics = false
	_update_size()

func _update_size():
	if not is_node_ready():
		return
	var px := Vector2(size_in_tiles * TILE)
	patch.position = Vector2.ZERO
	patch.size = px
	shape.shape = RectangleShape2D.new()
	shape.shape.size = px
	shape.position = px / 2.0

func _physics_process(delta):
	if not moving:
		return
	move_and_collide(direction.normalized() * speed * delta)
