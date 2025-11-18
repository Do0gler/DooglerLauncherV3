extends Node


var current_game_pid := 0
var launched_game: GameData

var game_start_time := 0.0

func _process(_delta: float) -> void:
	if launched_game != null: # A game is currently running
		if not OS.is_process_running(current_game_pid):
			_handle_game_stop()
			SettingsManager.ui_manager.display_game(SettingsManager.manager.selected_game)


func launch_game(game: GameData) -> void:
	if not InstallManager.game_is_installed(game):
		return
	
	var executable_path := ProjectSettings.globalize_path(InstallManager.get_game_executable_path(game))
	
	if game.executable_name.get_extension() == "exe":
		var error := _launch_exe(executable_path)
		if error == OK:
			launched_game = game
			game_start_time = Time.get_unix_time_from_system()
			
			launched_game.launched = true
			launched_game.game_panel.update_visuals()
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
		_handle_game_stop()


func _handle_game_stop() -> void:
	_record_play_session()
	current_game_pid = 0
	launched_game.launched = false
	launched_game.game_panel.update_visuals()
	launched_game = null


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


func _record_play_session() -> void:
	if game_start_time > 0:
		var session_duration := Time.get_unix_time_from_system() - game_start_time
		var total_playtime: float = CacheManager.get_game_cache_entry(launched_game.game_id, "playtime_secs", 0.0)
		var new_playtime := total_playtime + session_duration
		
		launched_game.playtime_secs = new_playtime
		CacheManager.set_game_cache_entry(launched_game.game_id, "playtime_secs", new_playtime)
		
		game_start_time = 0.0
