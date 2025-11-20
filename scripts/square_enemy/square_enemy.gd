extends CharacterBody2D

@export var speed = 100
@export var maxhp = 20
@export var damage_to_player = 10

@export var body_color: Color = Color.DARK_ORANGE
@export var body_size: Vector2 = Vector2(10, 10)

@onready var currethp = 20

var direction: Vector2 = Vector2.ZERO

func _ready():
	if direction == Vector2.ZERO:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT
		direction = direction.normalized()

func _physics_process(_delta):
	velocity = direction * speed
	move_and_slide()

func _draw():
	var body_rect = Rect2(-body_size / 2, body_size)
	draw_rect(body_rect, body_color)
func take_damage(damage):
	currethp -= damage
	
	if currethp <= 0:
		die()

func die():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
