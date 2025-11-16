extends Node

signal settings_loaded

const SETTINGS_FILE_PATH = "user://settings.cfg"
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
	var settings_dict := {}
	var config := ConfigFile.new()
	
	var result = config.load(SETTINGS_FILE_PATH)
	
	# If the file didn't load, create file if it didn't exist
	if result != OK:
		push_warning("Failed to load settings file")
		if not FileAccess.file_exists(SETTINGS_FILE_PATH):
			save_settings()
		return
	
	# Get data as dict
	var auto_update: bool = config.get_value("Settings", "auto_check_updates", false)
	var rpc_enabled: bool = config.get_value("Settings", "rich_presence_enabled", false)
	var sorting: String = config.get_value("Sorting", "sorting", "alphabetical")
	var sorting_reversed: bool = config.get_value("Sorting", "sorting_reversed", false)
	var grouping: String = config.get_value("Sorting", "grouping", "favorited")
	
	settings_dict.set("auto_check_updates", auto_update)
	settings_dict.set("rich_presence_enabled", rpc_enabled)
	settings_dict.set("sorting", sorting)
	settings_dict.set("sorting_reversed", sorting_reversed)
	settings_dict.set("grouping", grouping)
	
	Updater.auto_check_updates = auto_update
	
	GameOrganizer.current_grouping = grouping
	GameOrganizer.set_sorting(sorting, sorting_reversed)
	
	ui_manager.set_settings_ui(settings_dict)
	settings_loaded.emit()


## Save settings to disk
func save_settings() -> void:
	var config := ConfigFile.new()
	
	config.set_value("Settings", "auto_check_updates", ui_manager.settings_popup.is_item_checked(0))
	config.set_value("Settings", "rich_presence_enabled", ui_manager.settings_popup.is_item_checked(1))
	
	config.set_value("Sorting", "sorting", GameOrganizer.current_sorting)
	config.set_value("Sorting", "sorting_reversed", GameOrganizer.sorting_reversed)
	config.set_value("Sorting", "grouping", GameOrganizer.current_grouping)
	
	var result = config.save(SETTINGS_FILE_PATH)
	if result != OK:
		push_error("Failed to save settings file")
