extends AnimatableBody2D

const TILE := 16


const idle_region = Rect2(4, 4, 24, 24)
const moving_region = Rect2(36, 4, 24, 24)
const dead_region = Rect2(68, 4, 24, 24)

@export var size_in_tiles := Vector2i(2, 2):
	set(value):
		size_in_tiles = value.max(Vector2i.ONE)
		_update_size()

@export var direction := Vector2.RIGHT
@export var speed := 75

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var patch: NinePatchRect = $NinePatchRect
@onready var detect_shape: CollisionShape2D = $"Detect player area/PlayerDetection"
@onready var arrow: AnimatedSprite2D = $Arrow


var moving := false

var last_pos: Vector2

var test_params := PhysicsTestMotionParameters2D.new()
var test_result := PhysicsTestMotionResult2D.new()

func _ready():
	_update_size()
	_update_direction()

func _update_direction():
	arrow.rotation = direction.angle()

func _update_size():
	if not is_node_ready():
		return
	var px := Vector2(size_in_tiles * TILE)
	patch.position = Vector2.ZERO
	patch.size = px
	shape.shape = RectangleShape2D.new()
	shape.shape.size = px - Vector2(2, 2)
	shape.position = px / 2.0
	
	detect_shape.shape.size = Vector2(TILE * size_in_tiles.x, 0)
	detect_shape.position.x = (TILE * size_in_tiles.x) / 2
	detect_shape.position.y = -2
	arrow.position = (size_in_tiles * TILE) / 2
	
func _physics_process(delta):
	if not moving:
		return
	var motion = direction.normalized() * speed * delta
	if _would_hit_wall(motion):
		moving = false
		arrow.play("dead")
		patch.region_rect = dead_region
	else:
		global_position += motion
	
func _would_hit_wall(motion: Vector2) -> bool:
	test_params.from = global_transform
	test_params.motion = motion
	test_params.margin = 0.01
	var excluded: Array[int] = []
	for p in get_tree().get_nodes_in_group("player"):
		excluded.append(p.get_instance_id())
	test_params.exclude_objects = excluded
	return PhysicsServer2D.body_test_motion(get_rid(), test_params, test_result)

func _on_detect_player_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		moving = true
		arrow.play("moving")
		patch.region_rect = moving_region
