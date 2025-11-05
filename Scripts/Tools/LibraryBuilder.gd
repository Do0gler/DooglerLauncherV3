@tool
extends EditorScript

const GAMES_LIBRARY_PATH = "res://GamesLibrary"

func _run() -> void:
	var dict: Dictionary
	var library_folder = DirAccess.open(GAMES_LIBRARY_PATH)
	
	if library_folder:
		library_folder.list_dir_begin()
		var file_name = library_folder.get_next()
		
		var i := 0
		while file_name != "":
			var game_data_path = GAMES_LIBRARY_PATH + "/" + file_name
			var game_data = (load(game_data_path) as GameData)
			dict.set(i, GameData.to_dict(game_data))
			file_name = library_folder.get_next()
			i += 1
	else:
		print("Error: ", error_string(DirAccess.get_open_error()))
	
	var file = FileAccess.open("user://game_data.txt", FileAccess.WRITE)
	file.store_string(str(dict))
	file.close()
	print("Saved version data file to ", file.get_path_absolute())
