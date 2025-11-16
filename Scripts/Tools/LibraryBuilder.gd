@tool
extends EditorScript

const GAME_DIR_PATH = "res://GamesLibrary"

func _run() -> void:
	var dict: Dictionary
	var library_folder = DirAccess.open(GAME_DIR_PATH)
	
	if library_folder:
		library_folder.list_dir_begin()
		var file_name = library_folder.get_next()
		
		while file_name != "":
			var game_data_path = GAME_DIR_PATH + "/" + file_name
			var game_data = (load(game_data_path) as GameData)
			dict.set(game_data.game_id, GameData.to_dict(game_data))
			file_name = library_folder.get_next()
	else:
		print("Error: ", error_string(DirAccess.get_open_error()))
	
	var file = FileAccess.open("user://game_data.txt", FileAccess.WRITE)
	file.store_string(JSON.stringify(dict))
	file.close()
	print("Saved library data file to ", file.get_path_absolute())
