extends PanelContainer
class_name GamePanel

var game_data: GameData

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func update_visuals() -> void:
	%NameLabel.text = game_data.game_name
	%Icon.texture = game_data.icon

# TODO: Select game
func _on_pressed():
	pass
