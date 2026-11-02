extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D


const RUNSPEED := 10

var current_run: Dictionary = {"distance": 0, "speed": 0}

func _physics_process(delta: float) -> void:
	if velocity == Vector2.ZERO:
		sprite.play("idle")
	frame_move(delta)
	move_and_slide()

func move(distance, speed = 1):
	current_run = {"distance": distance, "speed": speed}

func frame_move(delta):
	velocity.x = RUNSPEED * current_run["speed"]
	current_run.distance -= RUNSPEED * current_run["speed"] * delta
	sprite.play("run")
	if velocity.x >= 0:
		pass

func jump(height):
	velocity.y = -height
	sprite.play("jump")


func death():
	sprite.play("death")
