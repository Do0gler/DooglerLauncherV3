extends PanelContainer
class_name GamePanel

var game_data: GameData

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func set_button_group(button_group: ButtonGroup) -> void:
	%Button.button_group = button_group

func update_visuals() -> void:
	%NameLabel.text = game_data.game_name
	%Icon.texture = game_data.icon

func _on_pressed():
	SettingsManager.manager.select_game(game_data)
