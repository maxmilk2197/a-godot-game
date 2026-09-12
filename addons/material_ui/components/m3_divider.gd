@tool
@icon("res://addons/material_ui/icons/divider.svg")
class_name M3Divider
extends Control
## ============================================================
## Material 3 分隔线。水平或垂直，颜色/粗细自动套用。
## ============================================================

@export var 垂直: bool = false:
	set(值):
		垂直 = 值
		_刷新()
@export var 粗细: int = 1:
	set(值):
		粗细 = 值
		_刷新()


func _ready() -> void:
	_refresh_connections()
	_刷新()


func _refresh_connections() -> void:
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)


func _刷新() -> void:
	var 像素 := maxi(1, int(round(粗细 * M3Theme.scale)))
	if 垂直:
		custom_minimum_size = Vector2(像素, 0)
	else:
		custom_minimum_size = Vector2(0, 像素)
	queue_redraw()


func _draw() -> void:
	var 像素 := maxi(1, int(round(粗细 * M3Theme.scale)))
	if 垂直:
		var x := roundf(size.x * 0.5 - float(像素) * 0.5)
		draw_rect(Rect2(x, 0.0, float(像素), size.y), M3Theme.outline_variant)
	else:
		var y := roundf(size.y * 0.5 - float(像素) * 0.5)
		draw_rect(Rect2(0.0, y, size.x, float(像素)), M3Theme.outline_variant)
