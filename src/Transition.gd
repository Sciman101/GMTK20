extends CanvasLayer

onready var anim = $AnimationPlayer

var scene_to_load : String
var reload : bool = false

var timer : float = 0

func _ready() -> void:
	anim.play("Open")
	set_process(false)

func _process(delta:float) -> void:
	timer += delta

func load_scene(fname:String) -> void:
	if not anim.is_playing():
		scene_to_load = fname
		reload = false
		anim.play("Close")
		# Reset timer
		if fname == "res://LEVELS/Level0.tscn":
			set_process(false)
			timer = 0

func restart() -> void:
	if not anim.is_playing():
		reload = true
		anim.play("Close")

func do_load() -> void:
	if not reload:
		get_tree().change_scene(scene_to_load)
	else:
		get_tree().call_group("Pickup","reload")
		get_tree().call_group("Player","reload")
	anim.play("Open")
	set_process(true)
