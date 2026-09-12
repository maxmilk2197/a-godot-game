@tool
class_name M3TextField
extends LineEdit
## ============================================================
## Material 3 输入框。用法和 LineEdit 完全一样。
## ============================================================

enum 输入样式 { FILLED, OUTLINED }

@export var 样式类型: 输入样式 = 输入样式.FILLED:
	set(值):
		样式类型 = 值
		_刷新样式()
@export var 圆角: int = M3Shape.中:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 字号: int = 22:
	set(值):
		字号 = 值
		_刷新样式()


func _ready() -> void:
	_刷新样式()


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var 圆角值 := int(round(圆角 * M3Theme.scale))
	var 普通: StyleBoxFlat
	var 焦点: StyleBoxFlat

	if 样式类型 == 输入样式.OUTLINED:
		普通 = M3Theme.描边样式(M3Theme.outline, 圆角值)
		焦点 = M3Theme.描边样式(M3Theme.primary, 圆角值, 2)
	else:
		普通 = M3Theme.样式(M3Theme.surface_container_high, 圆角值)
		var 焦点底 := M3Theme.样式(M3Theme.surface_container_high, 圆角值)
		焦点底.set_border_width_all(maxi(1, int(round(2.0 * M3Theme.scale))))
		焦点底.border_color = M3Theme.primary
		焦点 = 焦点底

	for sb in [普通, 焦点]:
		sb.content_margin_left = M3Theme.px(14)
		sb.content_margin_right = M3Theme.px(14)
		sb.content_margin_top = M3Theme.px(10)
		sb.content_margin_bottom = M3Theme.px(10)

	add_theme_stylebox_override("normal", 普通)
	add_theme_stylebox_override("focus", 焦点)
	add_theme_color_override("font_color", M3Theme.on_surface)
	add_theme_color_override("font_selected_color", M3Theme.on_primary)
	add_theme_color_override("font_placeholder_color", M3Theme.on_surface_variant)
	add_theme_color_override("caret_color", M3Theme.primary)
	add_theme_color_override("selection_color", M3Theme.primary_container)
	add_theme_font_size_override("font_size", M3Theme.fs(字号))
