extends LineEdit

func _ready() -> void:
	text_submitted.connect(search)
	text_changed.connect(_on_text_changed)
	search()

func search(new_text := "") -> void:
	%UIManager.relevant_games = GameOrganizer.search_games(new_text)
	%UIManager.display_games_list()

func _on_text_changed(new_text: String) -> void:
	# Show all games when search cleared
	if new_text == "":
		search()
