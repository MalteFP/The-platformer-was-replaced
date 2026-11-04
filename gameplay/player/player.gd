extends CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var cam = $Camera2D

const MAX_RUNSPEED := 100
const MAX_JUMP := -300
const RUN_ACCEL := 1000
const RUN_REDUCE := 400

const AIR_MULT := 0.65
const GRAVITY := 1000
const MAX_FALL := 500
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.1

const DASH_LENGTH := 500
const DASH_TIME := 0.15
const DASH_END_SPEED := 300
const DASH_JUMP_GRACE := 0.1

const HYPER_SPEED := 360
const HYPER_JUMP_MULT := 0.6
const SUPER_SPEED := 260

var moving = 0
var facing := 1

var was_on_floor := false
var has_dash := true

var dash_timer := 0.0
var dash_grace_timer := 0.0
var dash_dir := Vector2.ZERO

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_scale := 1.0


func _physics_process(delta: float) -> void:
	_timers(delta)
	
	_update_dash(delta)
	_frame_move(delta)
	gravity(delta)

	if is_on_floor() and dash_timer <= 0.0:
		has_dash = true
	if is_on_floor() and !was_on_floor:
		land()
	was_on_floor = is_on_floor()
	
	_try_jump()
	
	move_and_slide()
	update_animation()



func _timers(delta: float) -> void:
	dash_grace_timer = max(dash_grace_timer - delta, 0.0)
	jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)


func move_right():
	moving = 1
	facing = 1
	sprite.scale.x = 1

func move_left():
	moving = -1
	facing = -1
	sprite.scale.x = -1

func move_stop():
	moving = 0

func wait(args):
	await get_tree().create_timer(args[0]).timeout

func _frame_move(delta):
	if dash_timer > 0.0:
		return
	var target: float = moving * MAX_RUNSPEED
	var mult := 1.0 if is_on_floor() else AIR_MULT
	
	if absf(velocity.x) > MAX_RUNSPEED and signf(velocity.x) == signf(target):
		velocity.x = move_toward(velocity.x, target, RUN_REDUCE * mult * delta)
	else:
		velocity.x = move_toward(velocity.x, target, RUN_ACCEL * mult * delta)
	
	
func jump(args: Array):
	if args.size() == 0:
		args.append(1)
	if args[0] > 1 or args[0] < 0:
		args[0] = 1
	jump_scale = args[0]
	jump_buffer_timer = JUMP_BUFFER
	_try_jump()

func land():
	sprite.play("land")

func dash(args):
	if not has_dash or dash_timer > 0.0:
		return
	if args.size() > 0:
		dash_dir = Vector2.RIGHT.rotated(-deg_to_rad(args[0]))
	else:
		dash_dir = Vector2(facing, 0)
	
	has_dash = false
	dash_timer = DASH_TIME
	velocity = dash_dir * DASH_LENGTH


func gravity(delta):
	if dash_timer > 0.0:
		return
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, MAX_FALL, GRAVITY * delta)

func death():
	sprite.play("death")

func _update_dash(delta: float) -> void:
	if dash_timer <= 0.0:
		return
	dash_timer -= delta
	velocity = dash_dir * DASH_LENGTH
	if dash_timer <= 0.0:
		_end_dash()

func _end_dash() -> void:
	dash_timer = 0.0
	velocity = dash_dir * DASH_END_SPEED
	if dash_dir.y < 0.0:
		velocity *= 0.75
	if is_on_floor():
		dash_grace_timer = DASH_JUMP_GRACE

func _try_jump() -> void:
	if jump_buffer_timer <= 0.0:
		return
	if not (is_on_floor() or coyote_timer > 0.0):
		return
	
	var dash_active := dash_timer > 0.0 or dash_grace_timer > 0.0
	
	if dash_active and dash_dir.y > 0.0 and dash_dir.x != 0.0:
		velocity.x = signf(dash_dir.x) * HYPER_SPEED
		velocity.y = MAX_JUMP * HYPER_JUMP_MULT * jump_scale
	elif dash_active and dash_dir.y == 0.0:
		velocity.x = signf(dash_dir.x) * SUPER_SPEED
		velocity.y = MAX_JUMP * jump_scale
	else:
		velocity.y = MAX_JUMP * jump_scale
	
	
	dash_timer = 0.0
	dash_grace_timer = 0.0
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	sprite.play("jump")
	
	
	
func update_animation():
	if sprite.animation == "jump" or sprite.animation == "land":
		if sprite.is_playing():
			return
	if not is_on_floor():
		return

	if moving != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
