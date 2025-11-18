extends PanelContainer
class_name GamePanel

var game_data: GameData

func _ready() -> void:
	%Button.pressed.connect(_on_pressed)

func set_button_group(button_group: ButtonGroup) -> void:
	%Button.button_group = button_group

func update_visuals() -> void:
	if InstallManager.game_is_installed(game_data):
		var running_text = "[color=green]%s - Running[/color]" % game_data.game_name
		%NameLabel.text = running_text if game_data.launched else game_data.game_name
	else:
		%NameLabel.text = "[color=a6a6a6]%s[/color]" % game_data.game_name
	
	%Icon.texture = game_data.icon
	%UpdateIndicator.visible = game_data.outdated

func _on_pressed():
	SettingsManager.manager.select_game(game_data)
