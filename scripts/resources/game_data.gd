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

@export_category("Meta")
@export var version_number := &"1.0"
@export var has_discord_rpc := false
@export var game_id: StringName

var icon: Texture2D
var background: Texture2D
var screenshots: Array[Texture2D]

var is_outdated := false
var playtime_secs: int

static func to_dict(data: GameData) -> Dictionary:
	var dict: Dictionary
	
	dict.set("name", data.game_name)
	dict.set("description", data.description)
	dict.set("creation_date", data.creation_date)
	dict.set("engine", data.engine)
	dict.set("tags", data.tags)
	dict.set("file_size", data.file_size_mb)
	dict.set("download_path", data.download_path)
	dict.set("api_icon_name", data.api_icon_name)
	dict.set("background_url", data.background_url)
	dict.set("icon_url", data.icon_url)
	dict.set("screenshot_urls", data.screenshot_urls)
	dict.set("version_number", data.version_number)
	dict.set("has_discord_rpc", data.has_discord_rpc)
	dict.set("game_id", data.game_id)
	
	return dict


static func from_dict(dict: Dictionary) -> GameData:
	var data = GameData.new()
	
	data.game_name = dict.get("name")
	data.description = dict.get("description")
	data.creation_date = dict.get("creation_date")
	data.engine = dict.get("engine")
	
	var new_tags = dict.get("tags")
	for tag in new_tags:
		data.tags.append(tag as StringName)
	
	data.file_size_mb = dict.get("file_size")
	data.download_path = dict.get("download_path")
	data.api_icon_name = dict.get("api_icon_name")
	data.background_url = dict.get("background_url")
	data.icon_url = dict.get("icon_url")
	
	var new_screenshot_urls = dict.get("screenshot_urls")
	for screenshot_url in new_screenshot_urls:
		data.screenshot_urls.append(screenshot_url as String)
	
	data.version_number = dict.get("version_number") as StringName
	data.has_discord_rpc = dict.get("has_discord_rpc")
	data.game_id = dict.get("game_id")
	
	return data

static func secs_to_time_string(secs: int) -> String:
	var time_string := "%dh %dm"
	
	@warning_ignore("integer_division")
	var hours = secs / 3600
	@warning_ignore("integer_division")
	var mins = (secs % 3600) / 60
	
	return time_string % [hours, mins]
