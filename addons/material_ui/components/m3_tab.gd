@tool
class_name M3Tab
extends Button
## ============================================================
## Material 3 标签页（单个）。一般配合 M3TabBar 使用。
## 选中时文字用主色，底部有一条平直的指示条。
## ============================================================

@export var 选中: bool = false:
	set(值):
		选中 = 值
		set_pressed_no_signal(值)
		_刷新()
@export var 字号: int = 22:
	set(值):
		字号 = 值
		_刷新()

var _指示条: Panel


func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE
	_确保指示条()
	if not toggled.is_connected(_切换):
		toggled.connect(_切换)
	if not resized.is_connected(_摆指示条):
		resized.connect(_摆指示条)
	_刷新()


func _确保指示条() -> void:
	if _指示条 != null and is_instance_valid(_指示条):
		return
	_指示条 = Panel.new()
	_指示条.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_指示条)


func _切换(按下: bool) -> void:
	选中 = 按下


func _摆指示条() -> void:
	if _指示条 == null or not is_instance_valid(_指示条):
		return
	var 高 := maxf(2.0, 3.0 * M3Theme.scale)
	var 宽 := maxf(16.0, size.x * 0.55)
	_指示条.size = Vector2(宽, 高)
	_指示条.position = Vector2(roundf((size.x - 宽) * 0.5), size.y - 高)


func _刷新() -> void:
	if not is_inside_tree():
		return
	_确保指示条()
	var 圆角值 := int(round(12 * M3Theme.scale))

	var 空底 := M3Theme.样式(Color(0, 0, 0, 0), 圆角值)
	空底.content_margin_left = M3Theme.px(20)
	空底.content_margin_right = M3Theme.px(20)
	空底.content_margin_top = M3Theme.px(12)
	空底.content_margin_bottom = M3Theme.px(16)

	var 悬停底 := M3Theme.样式(Color(M3Theme.on_surface.r, M3Theme.on_surface.g, M3Theme.on_surface.b, 0.06), 圆角值)
	悬停底.content_margin_left = M3Theme.px(20)
	悬停底.content_margin_right = M3Theme.px(20)
	悬停底.content_margin_top = M3Theme.px(12)
	悬停底.content_margin_bottom = M3Theme.px(16)

	add_theme_stylebox_override("normal", 空底)
	add_theme_stylebox_override("hover", 悬停底)
	add_theme_stylebox_override("pressed", 空底)
	add_theme_stylebox_override("focus", 空底)
	add_theme_stylebox_override("disabled", 空底)

	var 文字色 := M3Theme.primary if 选中 else M3Theme.on_surface_variant
	add_theme_color_override("font_color", 文字色)
	add_theme_color_override("font_hover_color", 文字色)
	add_theme_color_override("font_pressed_color", M3Theme.primary)
	add_theme_color_override("font_hover_pressed_color", 文字色)
	add_theme_color_override("font_focus_color", 文字色)
	add_theme_font_size_override("font_size", M3Theme.fs(字号))

	if _指示条 != null and is_instance_valid(_指示条):
		_指示条.visible = 选中
		_指示条.add_theme_stylebox_override("panel", M3Theme.样式(M3Theme.primary, 2))
		_摆指示条()
