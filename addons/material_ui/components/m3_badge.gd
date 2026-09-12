@tool
@icon("res://addons/material_ui/icons/badge.svg")
class_name M3Badge
extends Label
## ============================================================
## Material 3 徽标 / 小红点。
## 有文字时显示药丸形，没文字时显示圆点。
## ============================================================

@export var 圆点大小: int = 8:
	set(值):
		圆点大小 = 值
		_刷新样式()
@export var 用错误色: bool = true:
	set(值):
		用错误色 = 值
		_刷新样式()


func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_刷新样式()


## 外部改了 text 之后调用它重新套用样式（圆点 / 药丸）
func 刷新() -> void:
	_刷新样式()


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var 底色 := M3Theme.error if 用错误色 else M3Theme.primary
	var 字色 := M3Theme.on_error if 用错误色 else M3Theme.on_primary

	var sb := M3Theme.样式(底色, 999)
	if text.strip_edges().is_empty():
		# 圆点
		var 直径 := maxi(4, int(round(圆点大小 * M3Theme.scale)))
		custom_minimum_size = Vector2(直径, 直径)
		sb.set_corner_radius_all(int(直径 * 0.5))
		sb.content_margin_left = 0
		sb.content_margin_right = 0
		sb.content_margin_top = 0
		sb.content_margin_bottom = 0
	else:
		var 高 := int(round(20 * M3Theme.scale))
		custom_minimum_size = Vector2(高, 高)
		sb.set_corner_radius_all(int(高 * 0.5))
		sb.content_margin_left = M3Theme.px(6)
		sb.content_margin_right = M3Theme.px(6)
		sb.content_margin_top = 0
		sb.content_margin_bottom = 0

	add_theme_stylebox_override("normal", sb)
	add_theme_color_override("font_color", 字色)
	add_theme_font_size_override("font_size", M3Theme.fs(16))
