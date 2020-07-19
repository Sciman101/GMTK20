extends TextureProgress

const WIGGLE = 2

export(String) var keyname

var start_pos : Vector2
var tween : Tween

func _ready() -> void:
	start_pos = rect_position

func _process(delta:float) -> void:
	rect_position = rect_position.move_toward(start_pos,delta*10)

func _on_Player_button_timer_value_changed(name:String,value:float) -> void:
	if name == keyname:
		self.value = value
		rect_position = start_pos + Vector2(rand_range(-WIGGLE,WIGGLE),rand_range(-WIGGLE,WIGGLE))
