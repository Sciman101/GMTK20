extends Area2D
tool

export(String) var direction

onready var sprite = $Sprite
onready var particles = $Particles2D
onready var sfx = $Sfx

func _on_Pickup_body_entered(body):
	if sprite.visible and body.is_in_group("Player"):
		body.add_time(direction,1)
		# Hide
		sprite.visible = false
		particles.emitting = true
		sfx.play()

func reload() -> void:
	sprite.visible = true
