extends Node

var current_game_pid := 0
var launched_game_id: StringName

func _process(_delta: float) -> void:
	if launched_game_id: # A game is currently running
		if not OS.is_process_running(current_game_pid):
			current_game_pid = 0
			launched_game_id = &""
			SettingsManager.ui_manager.display_game(SettingsManager.manager.selected_game)

func launch_game(game: GameData) -> void:
	if not InstallManager.game_is_installed(game):
		return
	
	var executable_path := ProjectSettings.globalize_path(InstallManager.get_game_executable_path(game))
	
	if game.executable_name.get_extension() == "exe":
		var error := _launch_exe(executable_path)
		if error == OK:
			launched_game_id = game.game_id
		else:
			push_error("Failed to launch " + game.game_name)
	else: # Game file is HTML
		var error := _launch_html(executable_path)
		if error != OK:
			push_error("Failed to launch " + game.game_name)


func stop_current_game() -> void:
	if current_game_pid == 0:
		return
	
	var error := OS.kill(current_game_pid)
	if error == OK:
		current_game_pid = 0
		launched_game_id = &""


func _launch_exe(path: String) -> Error:
	stop_current_game()
	
	current_game_pid = OS.create_process(path,[])
	if current_game_pid == -1:
		current_game_pid = 0
		return FAILED
	else:
		return OK


func _launch_html(path: String) -> Error:
	var exit_code = OS.execute("CMD.exe",["/C", '"' + path + '"'])
	if exit_code == -1:
		return FAILED
	else:
		return OK
