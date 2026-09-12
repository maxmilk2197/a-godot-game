@tool
class_name M3Tooltip
extends PanelContainer
## ============================================================
## Material 3 提示气泡。
## 用法：放进场景（顶层），需要时调用 弹出(位置)，不用时 收起()。
## ============================================================

@export_multiline var 文本: String = "提示":
	set(值):
		文本 = 值
		_刷新()
@export var 跟随鼠标: bool = false:
	set(值):
		跟随鼠标 = 值
		set_process(值)

var _标签: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_构建()
	_刷新()
	set_process(跟随鼠标)


func _process(_增量: float) -> void:
	if visible and 跟随鼠标:
		position = get_global_mouse_position() + Vector2(14, 14)


func _构建() -> void:
	if _标签 != null and is_instance_valid(_标签):
		return
	_标签 = Label.new()
	_标签.add_theme_font_size_override("font_size", M3Theme.fs(20))
	add_child(_标签)


func _刷新() -> void:
	_构建()
	if _标签 != null:
		_标签.text = 文本
		_标签.add_theme_color_override("font_color", M3Theme.surface)
	if not is_inside_tree():
		return
	var sb := M3Theme.样式(M3Theme.on_surface_variant, int(round(6 * M3Theme.scale)))
	sb.content_margin_left = M3Theme.px(14)
	sb.content_margin_right = M3Theme.px(14)
	sb.content_margin_top = M3Theme.px(9)
	sb.content_margin_bottom = M3Theme.px(9)
	add_theme_stylebox_override("panel", sb)


## 在指定位置弹出
func 弹出(位置: Vector2) -> void:
	_构建()
	_刷新()
	position = 位置
	visible = true


## 收起
func 收起() -> void:
	visible = false
