extends Node

var current_grouping := "favorited"
var current_sorting := "alphabetical"
var sorting_reversed := false

## Returns organized games grouped and sorted according to current methods
func get_organized_games() -> Dictionary:
	if current_grouping == "none":
		# Return sorted array as one group
		var sorted_games = get_sorted_games(SettingsManager.manager.games_library)
		return {"All": sorted_games}
	else:
		# Group games and sort within groups
		return get_grouped_and_sorted_games()


## Sorts games in an array
func get_sorted_games(games_array: Array) -> Array:
	var sorted_games = games_array.duplicate()
	sorted_games.sort_custom(func(a, b): return compare_games(a, b))
	
	if sorting_reversed:
		sorted_games.reverse()
	
	return sorted_games


## Returns grouped and sorted games according to current methods
func get_grouped_and_sorted_games() -> Dictionary:
	var grouped = {}
	
	for game in SettingsManager.manager.games_library:
		var key = get_group(game)
		if not grouped.has(key):
			grouped[key] = []
		grouped[key].append(game)
	
	# Sort within each group
	for key in grouped:
		grouped[key] = get_sorted_games(grouped[key])
	
	# Sort the group keys themselves for consistent order
	var sorted_keys = grouped.keys()
	sorted_keys.sort()
	
	var sorted_grouped = {}
	for key in sorted_keys:
		sorted_grouped[key] = grouped[key]
	
	return sorted_grouped


## Returns true if game a is should come before game b
func compare_games(a: GameData, b: GameData) -> bool:
	match current_sorting:
		"alphabetical":
			return a.game_name.to_lower() < b.game_name.to_lower() # Compare using unicode order
		"date_created":
			# Extract date array, formatted [month, day, year]
			var a_date = (a.creation_date.split("/") as Array).map(func(e): return int(e))
			var b_date = (b.creation_date.split("/") as Array).map(func(e): return int(e))
			
			# Compare year, then month, then day
			if a_date[2] != b_date[2]:
				return a_date[2] < b_date[2]
			if a_date[0] != b_date[0]:
				return a_date[0] < b_date[0]
			return a_date[1] < b_date[1]
		"play_time":
			return a.playtime_secs > b.playtime_secs
		"size":
			return a.file_size_mb > b.file_size_mb
		_:
			return false


## Return which group the game belongs to
func get_group(game: GameData) -> String:
	match current_grouping:
		"engine":
			return game.engine
		"status":
			return game.completion_status
		"favorited":
			return "Favorited" if game.favorited else "Other"
		"none":
			return "All"
		_:
			return "All"


func set_sorting(sorting_type: String, reversed := false) -> void:
	sorting_reversed = reversed
	current_sorting = sorting_type
	SettingsManager.ui_manager.display_games_list()


func set_grouping(grouping_type: String) -> void:
	current_grouping = grouping_type
	SettingsManager.ui_manager.display_games_list()
