extends Node

const IMAGE_CACHE_DIR = "user://cache/game_images/"
const IMAGE_CACHE_INDEX = "user://cache/game_image_cache.json"
const GAME_DATA_CACHE_INDEX = "user://cache/game_data_cache.json"
const BUNDLED_DIR = "res://Images/GameImages/"

var image_cache_index: Dictionary
var game_data_cache_index: Dictionary

func _ready() -> void:
	ensure_cache_dir()
	load_image_cache_index()
	load_game_data_cache_index()


## Creates the cache directories if they do not exist
func ensure_cache_dir():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("cache"):
		dir.make_dir("cache")
	if not dir.dir_exists("cache/game_images"):
		dir.make_dir_recursive("cache/game_images")


## Loads image cache index from disk
func load_image_cache_index():
	if FileAccess.file_exists(IMAGE_CACHE_INDEX):
		var file = FileAccess.open(IMAGE_CACHE_INDEX, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			image_cache_index = json.get_data()
		else:
			push_error("Error parsing image cache index")
			image_cache_index = {}
	else:
		image_cache_index = {}


## Saves image cache index to disk
func save_image_cache_index():
	var file = FileAccess.open(IMAGE_CACHE_INDEX, FileAccess.WRITE)
	file.store_string(JSON.stringify(image_cache_index, "\t"))
	file.close()


## Loads image cache index from disk
func load_game_data_cache_index():
	if FileAccess.file_exists(GAME_DATA_CACHE_INDEX):
		var file = FileAccess.open(GAME_DATA_CACHE_INDEX, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			game_data_cache_index = json.get_data()
		else:
			push_error("Error parsing game data cache index")
			game_data_cache_index = {}
	else:
		game_data_cache_index = {}


## Saves game data cache index to disk
func save_game_data_cache_index():
	var file = FileAccess.open(GAME_DATA_CACHE_INDEX, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_data_cache_index, "\t"))
	file.close()


## Returns the path to an image if found in image cache or bundled
func get_image_path(game_id: String, image_type: String) -> String:
	
	# Open relevant game cache
	if not image_cache_index.has(game_id):
		image_cache_index.set(game_id, {})
	
	var game_cache: Dictionary = image_cache_index.get(game_id)
	
	# Check if we have it in game cache
	if game_cache.has(image_type):
		var cached_info: Dictionary = game_cache[image_type]
		var path = cached_info.get("path")
		
		# Verify the file actually exists
		if cached_info.get("source") == "bundled":
			if FileAccess.file_exists(path):
				return path
		else:  # downloaded
			if FileAccess.file_exists(path):
				return path
			else:
				# Cache index says we have it but file is missing - remove from index
				game_cache.erase(image_type)
				save_image_cache_index()
	
	# Check if bundled with app (for pre-packaged games)
	var bundled_path = BUNDLED_DIR + game_id + "/" + image_type + ".png"
	if FileAccess.file_exists(bundled_path):
		# Add to game cache for faster lookup next time
		game_cache[image_type] = {
			"path": bundled_path,
			"source": "bundled",
			"timestamp": Time.get_unix_time_from_system()
		}
		save_image_cache_index()
		return bundled_path
	
	# Not found anywhere - return empty string
	return ""

## Download an image and add it to image cache
func download_image(game_id: String, image_type: String, url: String) -> String:
	var local_path = IMAGE_CACHE_DIR + game_id + "_" + image_type + ".png"
	
	# Download the image
	var http = HTTPRequest.new()
	add_child(http)
	
	var error = http.request(url)
	if error != OK:
		print("Error starting download: ", error)
		http.queue_free()
		return ""
	
	# Wait for download to complete
	var result = await http.request_completed
	var response_code = result[1]
	var body = result[3]
	
	http.queue_free()
	
	if response_code == 200:
		# Save the file
		var file = FileAccess.open(local_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		print("Downloaded ", url, " to ", local_path)
		
		# Update cache index
		if not image_cache_index.has(game_id):
			image_cache_index.set(game_id, {})
		
		var game_cache: Dictionary = image_cache_index.get(game_id)
		
		game_cache[image_type] = {
			"path": local_path,
			"source": "downloaded",
			"url": url,
			"timestamp": Time.get_unix_time_from_system()
		}
		save_image_cache_index()
		
		return local_path
	else:
		print("Download failed with code: ", response_code)
		return ""

## Check if an image exists (without downloading)
func has_image(game_id: String, image_type: String) -> bool:
	var path = get_image_path(game_id, image_type)
	return path != ""


## Load texture from image cache or bundled assets
func load_image_texture(game_id: String, image_type: String) -> Texture2D:
	var path = get_image_path(game_id, image_type)
	if path == "":
		return null
	
	# Load based on source type
	if path.begins_with("res://"):
		return load(path)
	else:
		# Load from user:// directory
		var image = Image.new()
		var error = image.load(path)
		if error != OK:
			print("Error loading image: ", error)
			return null
		return ImageTexture.create_from_image(image)


## Get all screenshot textures for a game
func get_all_screenshots(game_id: String) -> Array[Texture2D]:
	var screenshots: Array[Texture2D] = []
	
	for i in range(get_screenshot_count(game_id)):
		var screenshot_type = "screenshot_" + str(i)
		var texture = load_image_texture(game_id, screenshot_type)
		
		if texture == null:
			break
		
		screenshots.append(texture)
	
	return screenshots

## Count how many screenshots exist for a game
func get_screenshot_count(game_id: String) -> int:
	var count = 0
	while has_image(game_id, "screenshot_%d" % count):
		count += 1
	return count

## Prefetch images for a game
func prefetch_game_images(game_data: GameData) -> void:
	var game_id = game_data.game_id
	if game_id == "":
		return
	
	var images_to_download = []
	
	# Check which images we need to download
	if not game_data.background_url.is_empty():
		if not has_image(game_id, "background"):
			images_to_download.append({"type": "background", "url": game_data.background_url})
	
	if not game_data.icon_url.is_empty():
		if not has_image(game_id, "icon"):
			images_to_download.append({"type": "icon", "url": game_data["icon_url"]})
	
	if not game_data.screenshot_urls.is_empty():
		for i in range(game_data.get("screenshot_urls").size()):
			var screenshot_type = "screenshot_%d" % i
			if not has_image(game_id, screenshot_type):
				images_to_download.append({
					"type": screenshot_type,
					"url": game_data.get("screenshot_urls")[i]
				})
	
	# Download missing images
	for img_data: Dictionary in images_to_download:
		await download_image(game_id, img_data.get("type"), img_data.get("url"))


## Import the cached values for a game
func setup_game_data(game_data: GameData):
	var game_id = game_data.game_id
	if game_id == "":
		return
	
	if not game_data_cache_index.has(game_id):
		return
	
	var game_cache: Dictionary = game_data_cache_index.get(game_id)
	game_data.favorited = game_cache.get("favorited", false)
	game_data.playtime_secs = game_cache.get("playtime_secs", 0)
	
	if game_cache.has("file_size_mb"):
		game_data.file_size_mb = game_cache.get("file_size_mb")
	if game_cache.has("version"):
		game_data.version_number = game_cache.get("version")


## Sets a value in the game data cache
func set_game_cache_entry(game_id: String, key: Variant, value: Variant) -> void:
	if not game_data_cache_index.has(game_id):
		game_data_cache_index.set(game_id, {})
	
	var game_cache: Dictionary = game_data_cache_index.get(game_id)
	
	game_cache.set(key, value)
	save_game_data_cache_index()


## Clear image cache data and delete cached images for a game
func clear_image_cache(game_id: String) -> void:
	if not image_cache_index.has(game_id):
		return
	
	var game_cache: Dictionary = image_cache_index.get(game_id)
	
	for key in game_cache:
		# Don't delete image if bundled
		if game_cache.get(key).get("source") == "bundled":
			continue
		
		var image_path = game_cache.get(key).get("path")
		
		var error := DirAccess.remove_absolute(image_path)
		if error != OK:
			print("Failed to delete cached image: ", image_path)
	
	game_cache.clear()
	save_image_cache_index()
