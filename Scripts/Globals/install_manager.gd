extends Node

var current_http: HTTPRequest

## The game being downloaded, null if no game is being downloaded currently
var game_being_downloaded: GameData


## Installs a game
func install_game(game: GameData) -> void:
	var game_id := game.game_id
	
	current_http = HTTPRequest.new()
	add_child(current_http)
	
	_ensure_game_folder(game_id)
	
	# Create temp file to srote downloaded data
	var temp_file := FileAccess.create_temp(2, game_id,".zip")
	if temp_file == null:
		push_error("Could not create temp file while installing game")
		return
	
	current_http.download_file = temp_file.get_path_absolute()
	var error := current_http.request(game.download_url)
	
	# Update UI
	game_being_downloaded = game
	SettingsManager.ui_manager.update_game_visuals(game)
	
	await current_http.request_completed
	
	# Extract game files from temp file
	if error != OK:
		push_error("Failed to download ", game.game_name)
	else:
		_extract_zip_file(temp_file, get_game_install_dir_path(game))
		
		game.installed_version = game.version_number
		CacheManager.set_game_cache_entry(game_id, "installed_version", game.version_number)
	
	# Update UI
	game_being_downloaded = null
	SettingsManager.ui_manager.update_game_visuals(game)
	
	current_http.queue_free()
	current_http = null
	temp_file.close()


## Uninstalls a game
func uninstall_game(game: GameData) -> void:
	CacheManager.erase_game_cache_entry(game.game_id, "installed_version")
	game.outdated = false
	game.game_panel.update_visuals()
	
	var path = get_game_install_dir_path(game)
	_recursive_delete_game(path)


## Updates a game by uninstalling then re-installing
func update_game(game: GameData) -> void:
	uninstall_game(game)
	await install_game(game)


## Calculates the install progress of the current http request
func calculate_install_progress(game: GameData = null) -> int:
	if current_http == null:
		return -1
	
	var total = current_http.get_body_size()
	var downloaded = current_http.get_downloaded_bytes()
	
	# Fall back to saved file size
	if total <= 0 and game != null:
		total = game.file_size_mb
	
	var percent = floori(float(downloaded) / float(total) * 100)
	return percent


## Check if a game is installed
func game_is_installed(game: GameData) -> bool:
	var dir = DirAccess.open(get_game_install_dir_path(game))
	
	if dir == null:
		return false
	
	return dir.file_exists(game.executable_name)


## Get game installation directory path
func get_game_install_dir_path(game: GameData) -> String:
	return "user://library/" + game.game_id


## Get game executable path
func get_game_executable_path(game: GameData) -> String:
	return get_game_install_dir_path(game) + "/" + game.executable_name


## Creates the game installation directory if it does not exist
func _ensure_game_folder(game_id: String) -> void:
	var dir = DirAccess.open("user://")
	
	if not dir.dir_exists("library"):
		dir.make_dir("library")
	
	var game_install_dir := "library/" + game_id
	if not dir.dir_exists(game_install_dir):
		dir.make_dir_recursive(game_install_dir)


## Recursive function to delete all files in a directory
func _recursive_delete_game(dirPath) -> void:
	var dir = DirAccess.open(dirPath)
	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "":
		var filePath = dirPath + "/" + fileName
		if dir.current_is_dir():
			_recursive_delete_game(filePath)
		else:
			print("Deleting: " + filePath)
			var error := DirAccess.remove_absolute(filePath)
			if error != OK:
				push_error("Failed to delete file ", filePath)
		fileName = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(dirPath)


## Extracts a zip file to the provided path
func _extract_zip_file(zip_file: FileAccess, extract_to_path: String) -> void:
	var dir := DirAccess.open(extract_to_path)
	var reader := ZIPReader.new()
	var err := reader.open(zip_file.get_path_absolute())
	
	if err != OK:
		push_error("Could not extract game zip")
	
	for file in reader.get_files():
		if file.ends_with("/"):
			continue
		var file_base_dir = file.get_base_dir()
		if !dir.dir_exists(file_base_dir):
			dir.make_dir_recursive(file_base_dir)
		var new_file_path = extract_to_path.path_join(file)
		var new_file = FileAccess.open(new_file_path, FileAccess.WRITE)
		new_file.store_buffer(reader.read_file(file))
	
	reader.close()
