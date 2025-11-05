class_name GameData
extends Resource

@export_category("Info")
@export var game_name: String
@export_multiline var description: String
@export var creation_date: String = "Unknown" #MM/DD/YYYY
@export_enum("Scratch", "Unity", "Godot") var engine: String = "Scratch"
@export var tags: Array[StringName]
@export var file_size_mb: float
@export_category("Download")
@export var download_path: String
@export var api_icon_name := "logo"
@export var background_url: String
@export var icon_url: String
@export var screenshot_urls: Array[String]
@export_category("Graphics")
@export var icon: Texture2D
@export var background: Texture2D
@export var screenshots: Array[Texture2D]
@export_category("Meta")
@export var version_number := "1.0"
@export var has_discord_rpc := false

var is_outdated := false

static func to_dict(data: GameData) -> Dictionary:
	var dict: Dictionary
	
	dict.set("name", data.game_name)
	dict.set("description", data.description)
	dict.set("creation_data", data.creation_date)
	dict.set("engine", data.engine)
	dict.set("tags", data.tags)
	dict.set("file_size", data.file_size_mb)
	dict.set("download_path", data.download_path)
	dict.set("api_icon_name", data.api_icon_name)
	dict.set("background_url", data.background_url)
	dict.set("icon_url", data.icon_url)
	dict.set("screenshot_urls", data.screenshot_urls)
	if data.icon:
		dict.set("icon_path", data.icon.resource_path)
	else:
		dict.set("icon_path", "")
	if data.background:
		dict.set("background_path", data.background.resource_path)
	else:
		dict.set("background_path", "")
	dict.set("screenshot_paths", data.screenshots.map(func(element): return element.resource_path))
	dict.set("version_number", data.version_number)
	dict.set("has_discord_rpc", data.has_discord_rpc)
	
	return dict
