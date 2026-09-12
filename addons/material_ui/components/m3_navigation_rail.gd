@tool
class_name M3NavigationRail
extends PanelContainer
## ============================================================
## Material 3 侧边导航栏（竖向版 NavigationBar）。
## 适合中等宽度布局，放屏幕左侧或右侧。
## ============================================================

signal 切换(索引: int)

@export var 项目: PackedStringArray = PackedStringArray(["消息", "通讯录", "发现", "我"]):
	set(值):
		项目 = 值
		_重建()
@export var 当前索引: int = 0:
	set(值):
		当前索引 = 值
		_刷新选中()
@export var 圆角: int = 24:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 字号: int = 18:
	set(值):
		字号 = 值
		_刷新选中()

var _列: VBoxContainer
var _按钮: Array[Button] = []


func _ready() -> void:
	_构建()
	_重建()


func _构建() -> void:
	if _列 != null and is_instance_valid(_列):
		return
	_列 = VBoxContainer.new()
	_列.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_列.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_列.alignment = BoxContainer.ALIGNMENT_CENTER
	_列.add_theme_constant_override("separation", int(round(8 * M3Theme.scale)))
	add_child(_列)


func _重建() -> void:
	_构建()
	if _列 == null:
		return
	for 子 in _列.get_children():
		子.queue_free()
	_按钮.clear()
	for i in range(项目.size()):
		var 按钮 := M3Button.new()
		按钮.text = 项目[i]
		按钮.toggle_mode = true
		按钮.focus_mode = Control.FOCUS_NONE
		按钮.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		按钮.custom_minimum_size = Vector2(M3Theme.px(96), M3Theme.px(64))
		按钮.toggled.connect(_某个切换.bind(i))
		_列.add_child(按钮)
		_按钮.append(按钮)
	_刷新选中()
	_刷新样式()


func _某个切换(按下: bool, 索引: int) -> void:
	if _有效(索引) and not 按下:
		_按钮[索引].set_pressed_no_signal(true)
		return
	当前索引 = 索引
	切换.emit(索引)


func _有效(索引: int) -> bool:
	return 索引 >= 0 and 索引 < _按钮.size()


func _刷新选中() -> void:
	for i in range(_按钮.size()):
		_按钮[i].set_pressed_no_signal(i == 当前索引)
		_套用按钮样式(_按钮[i], i == 当前索引)


func _套用按钮样式(按钮: Button, 选中: bool) -> void:
	var 圆角值 := int(round(圆角 * M3Theme.scale))
	var 空底 := M3Theme.样式(Color(0, 0, 0, 0), 圆角值)
	var 选中底 := M3Theme.样式(M3Theme.secondary_container, 圆角值)
	var 悬停底 := M3Theme.样式(Color(M3Theme.on_surface.r, M3Theme.on_surface.g, M3Theme.on_surface.b, M3Motion.状态_悬停), 圆角值)
	按钮.add_theme_stylebox_override("normal", 选中底 if 选中 else 空底)
	按钮.add_theme_stylebox_override("hover", 选中底 if 选中 else 悬停底)
	按钮.add_theme_stylebox_override("pressed", 选中底)
	按钮.add_theme_stylebox_override("focus", 空底)
	var 字色 := M3Theme.on_secondary_container if 选中 else M3Theme.on_surface_variant
	按钮.add_theme_color_override("font_color", 字色)
	按钮.add_theme_color_override("font_hover_color", 字色)
	按钮.add_theme_color_override("font_pressed_color", M3Theme.on_secondary_container)
	按钮.add_theme_color_override("font_hover_pressed_color", 字色)
	按钮.add_theme_font_size_override("font_size", M3Theme.fs(字号))


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var sb := M3Theme.样式(M3Theme.surface_container_low, 圆角)
	sb.content_margin_left = M3Theme.px(8)
	sb.content_margin_right = M3Theme.px(8)
	sb.content_margin_top = M3Theme.px(8)
	sb.content_margin_bottom = M3Theme.px(8)
	add_theme_stylebox_override("panel", sb)
