extends Node

const CACHE_DIR = "user://cache/game_images/"
const CACHE_INDEX = "user://cache/library_cache.json"
const BUNDLED_DIR = "res://bundled_assets/game_images/"

var cache_index: Dictionary

func _ready() -> void:
	ensure_cache_dir()
	load_cache_index()


## Creates the cache directories if they do not exist
func ensure_cache_dir():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("cache"):
		dir.make_dir("cache")
	if not dir.dir_exists("cache/game_images"):
		dir.make_dir_recursive("cache/game_images")


## Loads cache index from disk
func load_cache_index():
	if FileAccess.file_exists(CACHE_INDEX):
		var file = FileAccess.open(CACHE_INDEX, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			cache_index = json.get_data()
		else:
			push_error("Error parsing cache index")
			cache_index = {}
	else:
		cache_index = {}


## Saves cache index to disk
func save_cache_index():
	var file = FileAccess.open(CACHE_INDEX, FileAccess.WRITE)
	file.store_string(JSON.stringify(cache_index, "\t"))
	file.close()
