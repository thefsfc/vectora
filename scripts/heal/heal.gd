extends Area2D

signal freed

@export var heal_amount = 10

@export var body_radius = 2
@export var body_color: Color = Color.AQUAMARINE

@onready var despawn_timer: Timer = $HealDespawnTimer

func _ready():
	body_entered.connect(_on_body_entered)
	pass

func _process(_delta):
	if not despawn_timer.is_stopped() and despawn_timer.time_left <= 3.0:
		queue_redraw()

func _draw():
	var current_color = body_color
	if not despawn_timer.is_stopped() and despawn_timer.time_left <= 3.0:
		var time_factor = Time.get_ticks_msec() * 0.02
		var alpha = (sin(time_factor) + 1.0) / 2.0
		current_color.a = clamp(alpha, 0.2, 1.0)
	draw_circle(Vector2.ZERO, body_radius, current_color)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_heal"):
			if body.take_heal(heal_amount):
				freed.emit()
				queue_free()

func _on_heal_despawn_timer_timeout() -> void:
	freed.emit()
	queue_free()
