extends CharacterBody2D

signal health_updated(current_health)
signal ammo_updated(current_ammo, max_ammo)

@export var speed = 100
@export var shoot_slowdown_factor = 0.5 
@export var rotation_speed_normal = 8.0
@export var rotation_speed_shooting = 3.0
@export var knockback_power = 350.0
@export var knockback_decay = 0.1

@export var max_hp = 100
@export var invulnerability_time = 1.0

@export var body_radius: float = 12.0
@export var body_color: Color = Color.RED
@export var muzzle_radius: float = 5.0
@export var muzzle_color: Color = Color.CYAN
@export var max_ammo = 5
@export var reload_time = 1.6
@export var burst_fire_delay = 0.05
@export var click_fire_delay = 0.2

@onready var muzzle: Marker2D = $Muzzle
@onready var label: Label = $BulletLabel

@onready var reload_timer: Timer = Timer.new()
@onready var burst_timer: Timer = Timer.new()
@onready var cooldown_timer: Timer = Timer.new()
@onready var invincibility_timer: Timer = Timer.new()

var screen_size: Vector2
var current_hp = 100
var current_ammo = 0
var is_reloading = false
var is_holding_fire = false
var can_shoot = true
var is_invincible = false
var knockback = Vector2.ZERO

var bullet_scene = preload("res://scenes/bullet.tscn")
var time_per_bullet: float

func _ready():
	screen_size = get_viewport_rect().size
	current_hp = max_hp
	current_ammo = max_ammo

	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_step)

	add_child(burst_timer)
	burst_timer.one_shot = true
	burst_timer.timeout.connect(_on_auto_fire_step)

	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_expired)

	add_child(invincibility_timer)
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_on_invincibility_expired)

	ammo_updated.connect(_update_label)
	time_per_bullet = reload_time / float(max_ammo)
	health_updated.emit(current_hp)
	ammo_updated.emit(current_ammo, max_ammo)

func _draw():
	draw_circle(Vector2.ZERO, body_radius, body_color)
	draw_circle(muzzle.position, muzzle_radius, muzzle_color)
	if is_invincible:
		var alpha = (sin(Time.get_ticks_msec() * 0.03) + 1) / 2.0 * 1
		draw_circle(Vector2.ZERO, body_radius, Color(1, 1, 1, alpha))

func _physics_process(delta):
	var target_angle = (get_global_mouse_position() - global_position).angle()
	var current_rot_speed = rotation_speed_normal

	if is_holding_fire:
		current_rot_speed = rotation_speed_shooting

	rotation = lerp_angle(rotation, target_angle, current_rot_speed * delta)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var current_speed = speed
	if is_holding_fire:
		current_speed = speed * shoot_slowdown_factor
	velocity = (direction * current_speed) + knockback
	knockback = lerp(knockback, Vector2.ZERO, knockback_decay)
	move_and_slide()
	check_enemy_collision()

	global_position.x = clamp(global_position.x, body_radius, screen_size.x - body_radius)
	global_position.y = clamp(global_position.y, body_radius, screen_size.y - body_radius)

	if is_invincible:
		queue_redraw()

func check_enemy_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemies") and not is_invincible:
			var push_direction = (global_position - collider.global_position).normalized()
			take_damage(collider.damage_to_player, push_direction)

func take_damage(amount, push_direction = Vector2.ZERO):
	if current_hp <= 0 or is_invincible:
		return

	current_hp -= amount
	if current_hp < 0:
		current_hp = 0

	health_updated.emit(current_hp)

	if current_hp <= 0:
		return

	if push_direction != Vector2.ZERO:
		knockback = push_direction * knockback_power
	is_invincible = true
	invincibility_timer.start(invulnerability_time)
	queue_redraw()

func take_heal(amount) -> bool:
	if current_hp >= max_hp:
		return false
	current_hp = min(current_hp + amount, max_hp)
	health_updated.emit(current_hp)
	return true

func _on_invincibility_expired():
	is_invincible = false
	queue_redraw()

func _input(event):
	if event.is_action_pressed("fire"):
		is_holding_fire = true
		if current_ammo > 0 and can_shoot:
			fire()
			burst_timer.start(burst_fire_delay)
		elif current_ammo <= 0:
			start_reload()

	if event.is_action_released("fire"):
		is_holding_fire = false
		burst_timer.stop()
		start_reload()

func fire():
	if current_ammo <= 0:
		return

	if is_reloading:
		is_reloading = false
		reload_timer.stop()

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = self.global_rotation

	current_ammo -= 1
	ammo_updated.emit(current_ammo, max_ammo)

	can_shoot = false
	cooldown_timer.start(click_fire_delay)

	if current_ammo <= 0:
		burst_timer.stop()
		start_reload()

func _on_cooldown_expired():
	can_shoot = true

func _on_auto_fire_step():
	if is_holding_fire and current_ammo > 0:
		fire()
		if current_ammo > 0:
			burst_timer.start(burst_fire_delay)
	else:
		start_reload()

func start_reload():
	if is_reloading or current_ammo >= max_ammo:
		return

	is_reloading = true
	reload_timer.start(time_per_bullet)

func _on_reload_step():
	current_ammo += 1
	ammo_updated.emit(current_ammo, max_ammo)
	if is_holding_fire:
		fire()
		if current_ammo > 0:
			burst_timer.start(burst_fire_delay)
	elif current_ammo < max_ammo:
		reload_timer.start(time_per_bullet)
	else:
		is_reloading = false

func _update_label(current, _max):
	label.text = str(current)
