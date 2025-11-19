extends Control

const BORDER_COLOR = Color(1, 1, 1, 0.08)

func _draw() -> void:
	var rect = Rect2(Vector2.ONE, size - Vector2.ONE)
	draw_rect(rect, BORDER_COLOR, false, 1)
