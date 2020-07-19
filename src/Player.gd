extends KinematicBody2D

const JUMP_HEIGHT : float = 96.0
const WALL_STICK_TIME : float = 0.2
const COYOTE_TIME_DUR : float = 0.1

const KEY_START_VAL : float = 1.0

export(bool) var infinite_keytime
export(float) var move_speed
export(float) var wall_slide_speed
export(float) var acceleration
export(float) var decceleration
export(float) var gravity

onready var ground_finder = $GroundFinder
onready var run_particles = $RunParticles
onready var sfx_jump = $SfxJump

var jump_speed : float
var motion : Vector2
var start_pos : Vector2

# Object containing all the values of how long we can hold a button down
var button_timers = {
	"right":KEY_START_VAL,
	"left":KEY_START_VAL,
	"jump":KEY_START_VAL
}

var wall_stick : float
var wall_dir : int
var coyote_time : float

signal button_timer_value_changed(name,value)

func _ready() -> void:
	# Calculate jump speed
	jump_speed = sqrt(2 * gravity * JUMP_HEIGHT)
	start_pos = position

# Get user input
func _process(delta:float) -> void:
	
	if Input.is_action_just_pressed("restart"):
		Transition.restart()
	
	# Horizontal movement
	var hor = sign(check_strength("right",delta) - check_strength("left",delta))
	
	if not (hor == 0 and not is_on_floor()):
		run_particles.direction.x = -hor
		if hor != sign(motion.x):
			motion.x = move_toward(motion.x,hor*move_speed,delta*decceleration)
		else:
			motion.x = move_toward(motion.x,hor*move_speed,delta*acceleration)
	
	run_particles.emitting = hor != 0 and is_on_floor()
	
	# Ground check and coyote time
	if is_on_floor():
		coyote_time = COYOTE_TIME_DUR
	elif coyote_time > 0:
		coyote_time -= delta
	
	# What should we do if wall sliding?
	var do_wallslide = hor != 0 and is_on_wall() and not ground_finder.is_colliding()
	if do_wallslide:
		wall_stick = WALL_STICK_TIME
		wall_dir = hor
	elif wall_stick > 0:
		wall_stick -= delta
	
	# Gravity
	motion.y += gravity * (1.25 if motion.y > 0 else 1) * delta
	
	# Wall slide
	if do_wallslide:
		motion.y = min(motion.y,wall_slide_speed)
	
	# Jump
	if check_pressed("jump",delta):
		if coyote_time >= 0:
			motion.y = -jump_speed
			sfx_jump.play()
		elif wall_stick > 0:
			# Walljump
			motion.x = -move_speed * wall_dir
			motion.y = -jump_speed
			sfx_jump.play()
	elif check_strength("jump",delta) == 0:
		motion.y = max(motion.y,-100)

func _physics_process(delta:float) -> void:
	motion = move_and_slide(motion,Vector2.UP)

func add_time(name:String,dur:float) -> void:
	button_timers[name] = clamp(button_timers[name]+dur,0,KEY_START_VAL)
	emit_signal("button_timer_value_changed",name,button_timers[name])

func reload() -> void:
	position = start_pos
	motion = Vector2.ZERO
	add_time("right",KEY_START_VAL)
	add_time("left",KEY_START_VAL)
	add_time("jump",KEY_START_VAL)

# Button press helper function
func check_strength(name:String,delta:float) -> float:
	var st = Input.get_action_strength(name)
	if st > 0:
		if button_timers[name] > 0 or infinite_keytime:
			button_timers[name] -= delta
			emit_signal("button_timer_value_changed",name,button_timers[name])
			return st
	return 0.0
func check_pressed(name:String,delta:float) -> bool:
	if Input.is_action_just_pressed(name):
		if button_timers[name] > 0 or infinite_keytime:
			button_timers[name] -= delta
			emit_signal("button_timer_value_changed",name,button_timers[name])
			return true
	return false
