extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D

const MAXRUNSPEED := 100
const MAXJUMP := -300

var moving = 0

var was_on_floor := false

func _physics_process(delta: float) -> void:
	frame_move()
	gravity(delta)
	move_and_slide()
	
	if is_on_floor() and !was_on_floor:
		land()
	was_on_floor = is_on_floor()

func move_right():
	moving = 1
	sprite.play("run")
	sprite.scale.x = 1

func move_left():
	moving = -1
	sprite.play("run")
	sprite.scale.x = -1

func move_stop():
	moving = 0
	sprite.play("idle")

func wait(args):
	await get_tree().create_timer(args[0]).timeout

func frame_move():
	velocity.x = moving * MAXRUNSPEED
	
func jump(args: Array):
	if args.size() == 0:
		args.append(1)
	if is_on_floor():
		velocity.y = args[0] * MAXJUMP
		sprite.play("jump")

func land():
	sprite.play("land")


func gravity(delta):
	if not is_on_floor():
		velocity.y += 1000 * delta

func death():
	sprite.play("death")


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.play("idle")
