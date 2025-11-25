class_name Manager
extends Control

const GAME_DATA_DIR = "res://GamesLibrary"
const PLACEHOLDER_ICON = preload("uid://civsuy21pbsgd")
const PLACEHOLDER_BG = preload("uid://civsuy21pbsgd")

var games_library: Array[GameData]
var selected_game: GameData


func _ready() -> void:
	get_library()
	if not games_library.is_empty():
		select_game(games_library[0])


## Selects and displays a game
func select_game(game: GameData):
	selected_game = game
	%UIManager.display_game(selected_game)


## Readies the game library
func get_library() -> void:
	games_library.clear()
	var library_file := FileAccess.open(SettingsManager.GAME_LIBRARY_PATH, FileAccess.READ)
	
	if not library_file:
		push_warning("Failed to open library file, falling back to packaged library")
		games_library = create_default_library()
	else:
		var library_dict: Dictionary = JSON.parse_string(library_file.get_as_text())
		for key in library_dict:
			games_library.append(GameData.from_dict(library_dict.get(key)))
		library_file.close()
	
	
	setup_game_placeholders()
	
	%UIManager.relevant_games = GameOrganizer.search_games("") # Initialize relevant games
	%UIManager.display_games_list()
	
	# Load images in background
	process_games_async()


## Setup games with placeholder images initially
func setup_game_placeholders() -> void:
	for game in games_library:
		CacheManager.setup_game_data(game)
		
		# Check if images exist in cache or bundled, else use placeholder
		var cached_icon = CacheManager.load_image_texture(game.game_id, "icon")
		var cached_background = CacheManager.load_image_texture(game.game_id, "background")
		
		game.icon = cached_icon if cached_icon else PLACEHOLDER_ICON
		game.background = cached_background if cached_background else PLACEHOLDER_BG
		game.screenshots = CacheManager.get_all_screenshots(game.game_id)


## Process games in the background, updates UI when images downloaded
func process_games_async() -> void:
	for game in games_library:
		await CacheManager.prefetch_game_images(game)
		
		# Load the actual images after download
		var new_background = CacheManager.load_image_texture(game.game_id, "background")
		var new_icon = CacheManager.load_image_texture(game.game_id, "icon")
		var new_screenshots = CacheManager.get_all_screenshots(game.game_id)
		
		# Update game data if new images were loaded
		var needs_update = false
		
		if new_background and game.background != new_background:
			game.background = new_background
			needs_update = true
		
		if new_icon and game.icon != new_icon:
			game.icon = new_icon
			needs_update = true
		
		if not new_screenshots.is_empty() and new_screenshots != game.screenshots:
			game.screenshots = new_screenshots
			needs_update = true
		
		# Update UI for this specific game
		if needs_update:
			%UIManager.update_game_visuals(game)


## Returns the default built-in library
func create_default_library() -> Array[GameData]:
	var default_library: Array[GameData] = []
	
	var library_dir := ResourceLoader.list_directory(GAME_DATA_DIR)
	
	for game_file in library_dir:
		var game_data = load(GAME_DATA_DIR + "/" + game_file)
		default_library.append(game_data)
	
	return default_library


## Sets if the selected games is favorited
func set_selected_favorite(toggle: bool):
	set_game_favorite(selected_game, toggle)


## Sets if a game is favorited
func set_game_favorite(game: GameData, toggle: bool) -> void:
	game.favorited = toggle
	CacheManager.set_game_cache_entry(game.game_id, "favorited", game.favorited)
	%UIManager.display_games_list()
	%UIManager.update_game_visuals(game)


## Opens the installation location of the current game
func open_selected_game_file_location() -> void:
	open_game_file_location(selected_game)


## Opens the installation location of a game
func open_game_file_location(game: GameData) -> void:
	if not InstallManager.game_is_installed(game):
		return
	
	var game_dir = ProjectSettings.globalize_path("user://library/" + game.game_id)
	OS.shell_show_in_file_manager(game_dir)


## Installs the selected game
func install_selected_game() -> void:
	if selected_game == null:
		return
	
	await InstallManager.install_game(selected_game)


## Uninstalls the selected game
func uninstall_selected_game() -> void:
	if selected_game == null and InstallManager.game_is_installed(selected_game):
		return
	
	InstallManager.uninstall_game(selected_game)
	%UIManager.update_game_visuals(selected_game)


## Updates the selected game
func update_selected_game() -> void:
	if selected_game == null and InstallManager.game_is_installed(selected_game):
		return
	
	await InstallManager.update_game(selected_game)
	%UIManager.display_game(selected_game)


## Launches the current game
func launch_selected_game() -> void:
	if selected_game == null:
		return
	
	GameLauncher.launch_game(selected_game)
	%UIManager.display_game(selected_game)


## Stops the current game
func stop_selected_game() -> void:
	if selected_game == null:
		return
	
	GameLauncher.stop_current_game()
	%UIManager.display_game(selected_game)
