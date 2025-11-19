class_name GamePanel
extends PanelContainer

var color_running := Color("9cff91ff").to_html()
var color_installing := Color("91e5ffff").to_html()
var color_uninstalled := Color("a6a6a6").to_html()

var game_data: GameData


func _ready() -> void:
	%Button.pressed.connect(_on_pressed)


func set_button_group(button_group: ButtonGroup) -> void:
	%Button.button_group = button_group


func update_visuals() -> void:
	%NameLabel.text = _get_formatted_game_name()
	%Icon.texture = game_data.icon
	%UpdateIndicator.visible = game_data.outdated


func _get_formatted_game_name() -> String:
	if InstallManager.game_is_installed(game_data):
		if game_data.launched:
			return "[color=%s]%s - Running[/color]" % [color_running ,game_data.game_name]
		else:
			return game_data.game_name
	elif game_data == InstallManager.game_being_downloaded:
		return "[color=%s]%s - Installing[/color]" % [color_installing, game_data.game_name]
	else:
		return "[color=%s]%s[/color]" % [color_uninstalled, game_data.game_name]


func _on_pressed():
	SettingsManager.manager.select_game(game_data)
