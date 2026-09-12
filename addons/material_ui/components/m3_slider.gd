@tool
class_name M3Slider
extends HSlider
## ============================================================
## Material 3 滑块（连续值）。用法和 HSlider 完全一样。
## ============================================================

@export var 轨道高: int = 8:
	set(值):
		轨道高 = 值
		_刷新样式()
@export var 手柄直径: int = 26:
	set(值):
		手柄直径 = 值
		_刷新样式()


func _ready() -> void:
	_刷新样式()


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var 轨高 := maxi(2, int(round(轨道高 * M3Theme.scale)))
	var 直径 := maxi(8, int(round(手柄直径 * M3Theme.scale)))
	var 圆角 := int(轨高 * 0.5)

	var 底色 := M3Theme.样式(M3Theme.secondary_container, 圆角)
	底色.content_margin_top = 轨高 * 0.5
	底色.content_margin_bottom = 轨高 * 0.5

	var 已选 := M3Theme.样式(M3Theme.primary, 圆角)
	已选.content_margin_top = 轨高 * 0.5
	已选.content_margin_bottom = 轨高 * 0.5

	var 手柄 := M3Theme.样式(M3Theme.primary, int(直径 * 0.5))
	var 手柄边距 := 直径 * 0.5
	手柄.content_margin_left = 手柄边距
	手柄.content_margin_right = 手柄边距
	手柄.content_margin_top = 手柄边距
	手柄.content_margin_bottom = 手柄边距

	var 手柄悬停 := M3Theme.样式(M3Theme.primary.lightened(0.1), int(直径 * 0.5))
	手柄悬停.content_margin_left = 手柄边距
	手柄悬停.content_margin_right = 手柄边距
	手柄悬停.content_margin_top = 手柄边距
	手柄悬停.content_margin_bottom = 手柄边距

	add_theme_stylebox_override("slider", 底色)
	add_theme_stylebox_override("grabber_area", 已选)
	add_theme_stylebox_override("grabber_area_highlight", 已选)
	add_theme_stylebox_override("grabber", 手柄)
	add_theme_stylebox_override("grabber_highlight", 手柄悬停)

	custom_minimum_size.y = maxf(custom_minimum_size.y, 直径)
