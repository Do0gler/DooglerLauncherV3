extends Node

var settings_popup: PopupMenu
var loading_screen: Control

func set_settings_state(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates", false))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled", false))
