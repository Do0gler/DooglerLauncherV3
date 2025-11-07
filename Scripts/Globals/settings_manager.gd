extends Node

signal settings_loaded

const SETTINGS_FILE_PATH = "user://UserSettings.settings"
const GAME_LIBRARY_PATH := "user://game_data.txt"
var manager: Manager
var ui_manager: UIManager


func _ready() -> void:
	manager = get_tree().root.get_node("Manager") as Manager
	ui_manager = manager.get_node("%UIManager")
	ui_manager.loading_screen = manager.get_node("%LoadingScreen")
	
	settings_loaded.connect(Updater._on_settings_loaded)
	
	load_settings()


## Load settings from disk
func load_settings() -> void:
	var settings_dict: Dictionary
	var settings_file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if settings_file:
		settings_dict = JSON.parse_string(settings_file.get_as_text())
	else:
		push_error("Failed to load settings file")
	var auto_update: bool = settings_dict.get("auto_check_updates", false)
	var rpc_enabled: bool = settings_dict.get("rich_presence_enabled", false)
	
	# TODO: Apply loaded settings
	Updater.auto_check_updates = auto_update
	#DiscordRpcManager.rich_presence_enabled = settings_dict["rich_presence_enabled"]
	
	ui_manager.set_settings_state(settings_dict)
	settings_loaded.emit()


## Save settings to disk
func save_settings() -> void:
	var settings_dict := {
		"auto_check_updates":  ui_manager.settings_popup.is_item_checked(0),
		"rich_presence_enabled": ui_manager.settings_popup.is_item_checked(1)
	}
	var settings_file := FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if settings_file:
		settings_file.store_string(JSON.stringify(settings_dict))
