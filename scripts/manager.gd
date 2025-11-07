class_name Manager
extends Control


const GAME_DATA_DIR = "res://GamesLibrary"
var games_library: Array[GameData]
var selected_game: GameData

func _ready() -> void:
	get_library()
	%UIManager.display_games_list()
	if not games_library.is_empty():
		select_game(games_library[0])


## Selects and displays a game
func select_game(game: GameData):
	selected_game = game
	%UIManager.display_game(selected_game)


## Gets the game library
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


## Returns the default built-in library
func create_default_library() -> Array[GameData]:
	var default_library: Array[GameData] = []
	
	var library_dir := ResourceLoader.list_directory(GAME_DATA_DIR)
	
	for game_file in library_dir:
		var game_data = load(GAME_DATA_DIR + "/" + game_file)
		default_library.append(game_data)
	
	return default_library
