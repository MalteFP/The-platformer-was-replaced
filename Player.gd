extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D


const RUNSPEED := 10

var current_run: Dictionary = {"distance": 0, "speed": 0}

func _physics_process(delta: float) -> void:
	if velocity == Vector2.ZERO:
		sprite.play("idle")
	frame_move(delta)
	move_and_slide()

func move(args):
	current_run = {"distance": args[0], "speed": args[1]}

func frame_move(delta):
	velocity.x = RUNSPEED * current_run["speed"]
	current_run.distance -= RUNSPEED * current_run["speed"] * delta
	sprite.play("run")
	if velocity.x >= 0:
		pass

func jump(args):
	velocity.y = -args[0]
	sprite.play("jump")


func death():
	sprite.play("death")
