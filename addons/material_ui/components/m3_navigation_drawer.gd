@tool
@icon("res://addons/material_ui/icons/navigation_drawer.svg")
class_name M3NavigationDrawer
extends PanelContainer
## ============================================================
## Material 3 抽屉导航（从左侧滑出）。
## 会自动锚定到左边 + 满高；「展开 / 收起」带动画。
##
## 注意：请放在**非容器**的父节点下（放进 VBox/HBox 之类的容器里，
## position 会被容器接管，滑出动画就失效）。
## ============================================================

signal 切换(索引: int)
signal 展开变化(展开: bool)

@export var 项目: PackedStringArray = PackedStringArray(["首页", "消息", "设置"]):
	set(值):
		项目 = 值
		_重建()
@export var 当前索引: int = 0:
	set(值):
		当前索引 = 值
		_刷新选中()
@export var 标题: String = "菜单":
	set(值):
		标题 = 值
		_刷新标题()
@export var 展开: bool = true:
	set(值):
		展开 = 值
		_应用展开(false)
@export var 宽度: int = 280:
	set(值):
		宽度 = 值
		_应用尺寸()
@export var 圆角: int = M3Shape.大:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 字号: int = 20:
	set(值):
		字号 = 值
		_刷新选中()
@export var 动画时长: float = 0.28

var _列: VBoxContainer
var _项目列: VBoxContainer
var _标题标签: Label
var _按钮: Array[Button] = []
var _补间: Tween


func _ready() -> void:
	_构建()
	_重建()
	_应用尺寸()
	_刷新样式()


func _构建() -> void:
	if _列 != null and is_instance_valid(_列):
		return
	_列 = VBoxContainer.new()
	_列.add_theme_constant_override("separation", int(round(10 * M3Theme.scale)))
	add_child(_列)

	_标题标签 = Label.new()
	_标题标签.add_theme_font_size_override("font_size", M3Theme.fs(24))
	_标题标签.add_theme_color_override("font_color", M3Theme.on_surface)
	_列.add_child(_标题标签)

	_项目列 = VBoxContainer.new()
	_项目列.add_theme_constant_override("separation", int(round(6 * M3Theme.scale)))
	_列.add_child(_项目列)


func _重建() -> void:
	_构建()
	if _项目列 == null:
		return
	for 子 in _项目列.get_children():
		子.queue_free()
	_按钮.clear()
	for i in range(项目.size()):
		var 按钮 := M3Button.new()
		按钮.text = 项目[i]
		按钮.toggle_mode = true
		按钮.focus_mode = Control.FOCUS_NONE
		按钮.alignment = HORIZONTAL_ALIGNMENT_LEFT
		按钮.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		按钮.custom_minimum_size = Vector2(0, M3Theme.px(56))
		按钮.toggled.connect(_某个切换.bind(i))
		_项目列.add_child(按钮)
		_按钮.append(按钮)
	_刷新标题()
	_刷新选中()


func _刷新标题() -> void:
	if _标题标签 != null and is_instance_valid(_标题标签):
		_标题标签.text = 标题


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
	var 圆角值 := int(round(999 * M3Theme.scale))
	var 空底 := M3Theme.样式(Color(0, 0, 0, 0), 圆角值)
	var 选中底 := M3Theme.样式(M3Theme.secondary_container, 圆角值)
	var 悬停底 := M3Theme.样式(Color(M3Theme.on_surface.r, M3Theme.on_surface.g, M3Theme.on_surface.b, M3Motion.状态_悬停), 圆角值)
	for sb in [空底, 选中底, 悬停底]:
		var 方框 := sb as StyleBoxFlat
		if 方框 != null:
			方框.content_margin_left = M3Theme.px(20)
			方框.content_margin_right = M3Theme.px(20)
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
	sb.content_margin_left = M3Theme.px(16)
	sb.content_margin_right = M3Theme.px(16)
	sb.content_margin_top = M3Theme.px(20)
	sb.content_margin_bottom = M3Theme.px(20)
	add_theme_stylebox_override("panel", sb)


func _应用尺寸() -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return
	set_anchors_preset(Control.PRESET_LEFT_WIDE)
	offset_right = M3Theme.px(宽度)
	offset_left = 0.0
	custom_minimum_size.x = M3Theme.px(宽度)
	_应用展开(false)


## 打开抽屉
func 打开() -> void:
	展开 = true
	_应用展开(true)


## 收起抽屉
func 关闭() -> void:
	展开 = false
	_应用展开(true)


## 开/关切换
func 开关() -> void:
	展开 = not 展开
	_应用展开(true)


func _应用展开(带动画: bool) -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return
	if _补间 != null and _补间.is_valid():
		_补间.kill()
	var 目标x := 0.0 if 展开 else -M3Theme.px(宽度)
	if 带动画:
		var 起x := position.x
		# MD3：进场用 强调减速、退场用 强调加速
		var 曲线: Callable = M3Motion.强调减速 if 展开 else M3Motion.强调加速
		_补间 = create_tween()
		_补间.tween_method(
			func(t: float) -> void:
				var 进度: float = 曲线.call(t)
				position.x = lerpf(起x, 目标x, 进度),
			0.0, 1.0, 动画时长)
	else:
		position.x = 目标x
	展开变化.emit(展开)
