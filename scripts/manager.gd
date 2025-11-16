class_name Manager
extends Control

const GAME_DATA_DIR = "res://GamesLibrary"
var games_library: Array[GameData]
var selected_game: GameData
var can_switch_games := true


func _ready() -> void:
	get_library()
	if not games_library.is_empty():
		select_game(games_library[0])


## Selects and displays a game
func select_game(game: GameData):
	if can_switch_games:
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
	
	await process_games()
	# TODO: Make games display instantly instead of waiting for images (use placeholder)
	%UIManager.relevant_games = GameOrganizer.search_games("") # Initialize relevant games
	%UIManager.display_games_list()


## Populate games with cached data
func process_games() -> void:
	for game in games_library:
		CacheManager.setup_game_data(game)
		await CacheManager.prefetch_game_images(game)
		game.background = CacheManager.load_image_texture(game.game_id, "background")
		game.icon = CacheManager.load_image_texture(game.game_id, "icon")
		game.screenshots = CacheManager.get_all_screenshots(game.game_id)


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
	selected_game.favorited = toggle
	CacheManager.set_game_cache_entry(selected_game.game_id, "favorited", selected_game.favorited)
	%UIManager.display_games_list()


## Opens the installation location of the current game
func open_selected_game_file_location() -> void:
	if not InstallManager.game_is_installed(selected_game):
		return
	
	var game_dir = ProjectSettings.globalize_path("user://library/" + selected_game.game_id)
	OS.shell_show_in_file_manager(game_dir)


## Installs the selected game
func install_selected_game() -> void:
	if selected_game == null:
		return
	
	can_switch_games = false
	%UIManager.set_game_display_installing()
	await InstallManager.install_game(selected_game)
	can_switch_games = true
	%UIManager.set_game_display_installed()
	%UIManager.display_game(selected_game)

## Uninstalls the selected game
func uninstall_selected_game() -> void:
	InstallManager.uninstall_game(selected_game)
	%UIManager.display_game(selected_game)


## Launches the current game
func launch_selected_game() -> void:
	GameLauncher.launch_game(selected_game)
	%UIManager.display_game(selected_game)


## Stops the current game
func stop_selected_game() -> void:
	GameLauncher.stop_current_game()
	%UIManager.display_game(selected_game)
