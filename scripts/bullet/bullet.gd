extends Area2D

@export var speed = 350
@export var damage = 10

@export var body_radius: float = 2
@export var body_color: Color = Color.WHITE

func _ready():
	body_entered.connect(_on_body_entered)

func _draw():
	draw_circle(Vector2.ZERO, body_radius, body_color)

func _physics_process(_delta):
	position += transform.x * speed * _delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
