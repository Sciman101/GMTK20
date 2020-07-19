extends Label


func _ready() -> void:
	text += "\nYour time: %.2fs" % Transition.timer
