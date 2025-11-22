extends Area2D

@export var heal_amount = 10

@export var body_radius = 2
@export var body_color: Color = Color.AQUAMARINE

func _ready():
	body_entered.connect(_on_body_entered)
	pass

func _draw():
	draw_circle(Vector2.ZERO, body_radius, body_color)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_heal"):
			if body.take_heal(heal_amount):
				queue_free()
