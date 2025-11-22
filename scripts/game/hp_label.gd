extends Label

@onready var player_character = $"../../Player/CharacterBody2D"

func _ready():
	text = str(player_character.current_hp) 
	player_character.health_updated.connect(_on_player_health_updated)

func _on_player_health_updated(new_hp):
	text = str(new_hp) + "/" + str(player_character.max_hp)
