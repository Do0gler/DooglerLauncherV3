extends Node
class_name UIManager

@export var game_panel: PackedScene

@onready var games_vbox: VBoxContainer = %GamesVBox
@onready var loading_screen: Control = %LoadingScreen
var settings_popup: PopupMenu

func set_settings_state(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates", false))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled", false))

func display_games() -> void:
	# Clear previous games
	for child in games_vbox.get_children():
		child.queue_free()
	
	for game in SettingsManager.manager.games_library:
		var new_game_panel: GamePanel = game_panel.instantiate()
		new_game_panel.game_data = game
		new_game_panel.update_visuals()
		games_vbox.add_child(new_game_panel)
