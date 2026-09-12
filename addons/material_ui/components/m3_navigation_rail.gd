@tool
@icon("res://addons/material_ui/icons/navigation_rail.svg")
class_name M3NavigationRail
extends PanelContainer
## ============================================================
## Material 3 侧边导航轨道（Navigation Rail）。
##
## 两种用法：
##
## ① 自动生成（默认，`手动项目 = false`）
##    填 `项目` 数组就会自动生成一排 M3NavigationRailItem；
##    想带图标就再填 `图标` 数组（可以比 项目 短，缺的就没图标）。
##
## ② 自己往里放（`手动项目 = true`）
##    把 M3NavigationRailItem（或任意 BaseButton）直接加成轨道的子节点，
##    顺序 = 场景树顺序。轨道会接手它们的选中状态、布局和颜色。
##    也可以先放一个 VBoxContainer、把项目塞在它里面 —— 那样交给容器排版。
##
## 外观照官方规格：容器 96dp 宽、surface_container_low 底、CornerLarge 圆角、
## outline_variant 细描边；项目本身见 M3NavigationRailItem。
## ============================================================

signal 切换(索引: int)

## 项目之间 / 容器内边距的默认值（官方是 gap 12dp、padding 16dp 8dp）
const 默认项目间距 := 12
const 默认内边距 := Vector2i(8, 16)
const 默认项目最小高 := 64
const 默认容器宽 := 96
## 连接标记用的元数据键（重建时要先把旧连接摘掉）
const 回调键 := "__m3_rail_cb"

@export var 项目: PackedStringArray = PackedStringArray(["消息", "通讯录", "发现", "我"]):
	set(值):
		项目 = 值
		_重建()
## 自动生成时每个项目的图标（可以留空或比 项目 短）
@export var 图标: Array[Texture2D] = []:
	set(值):
		图标 = 值
		_重建()
## false = 按 `项目` 自动生成；true = 用你自己加进来的子节点当项目
@export var 手动项目: bool = false:
	set(值):
		手动项目 = 值
		_重建()
@export var 当前索引: int = 0:
	set(值):
		当前索引 = 值
		_刷新选中()
@export var 圆角: int = 16:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 字号: int = 18:
	set(值):
		字号 = 值
		_重建()
## 项目之间的间距
@export var 项目间距: int = 默认项目间距:
	set(值):
		项目间距 = maxi(0, 值)
		_重建()
## 容器内边距（横向, 纵向）
@export var 内边距: Vector2i = 默认内边距:
	set(值):
		内边距 = 值
		_重建()
## 容器最小宽度（官方 96dp；窄版 80dp）
@export var 容器宽: int = 默认容器宽:
	set(值):
		容器宽 = maxi(1, 值)
		_刷新样式()

var _列: VBoxContainer
var _按钮: Array[BaseButton] = []


func _ready() -> void:
	_重建()


func _notification(什么是: int) -> void:
	# 手动模式下，直接放在轨道里的项目由轨道自己排版
	if 什么是 == NOTIFICATION_SORT_CHILDREN and 手动项目:
		_排版()


# ---------------- 构建 ----------------

func _重建() -> void:
	if not is_inside_tree():
		return
	_按钮.clear()
	if 手动项目:
		_拆掉列()
		_收集()
	else:
		_构建列()
		_生成()
	_刷新选中()
	_刷新样式()
	queue_sort()


func _构建列() -> void:
	if _列 != null and is_instance_valid(_列):
		return
	_列 = VBoxContainer.new()
	_列.name = "项目列"
	_列.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_列.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_列.alignment = BoxContainer.ALIGNMENT_CENTER
	_列.add_theme_constant_override("separation", int(round(float(项目间距) * M3Theme.scale)))
	add_child(_列)


func _拆掉列() -> void:
	if _列 != null and is_instance_valid(_列):
		_列.queue_free()
	_列 = null


## 自动生成项目
func _生成() -> void:
	if _列 == null:
		return
	for 子 in _列.get_children():
		_列.remove_child(子)
		子.queue_free()
	for i in range(项目.size()):
		var 项 := M3NavigationRailItem.new()
		项.name = "项目%d" % i
		项.文字 = 项目[i]
		项.字号 = 字号
		if i < 图标.size():
			项.图标 = 图标[i]
		_列.add_child(项)
		_挂连接(项)


## 收集用户自己加进来的项目：直接的 BaseButton，或容器里的 BaseButton
func _收集() -> void:
	for 子 in get_children():
		if 子 is BaseButton:
			_挂连接(子)
		elif 子 is Container:
			for 孙 in 子.get_children():
				if 孙 is BaseButton:
					_挂连接(孙)


func _挂连接(项: BaseButton) -> void:
	var 索引 := _按钮.size()
	_按钮.append(项)
	项.toggle_mode = true
	项.focus_mode = Control.FOCUS_NONE
	# 先摘掉上一轮留下的连接（索引可能已经变了）
	if 项.has_meta(回调键):
		var 旧: Callable = 项.get_meta(回调键)
		if 项.toggled.is_connected(旧):
			项.toggled.disconnect(旧)
	var 回调 := _某个切换.bind(索引)
	项.set_meta(回调键, 回调)
	项.toggled.connect(回调)


# ---------------- 选中 ----------------

func _某个切换(按下: bool, 索引: int) -> void:
	if 按下 and _有效(索引):
		当前索引 = 索引
		切换.emit(索引)
	else:
		_刷新选中()


func _有效(索引: int) -> bool:
	return 索引 >= 0 and 索引 < _按钮.size()


func _刷新选中() -> void:
	for i in range(_按钮.size()):
		var 项 := _按钮[i]
		项.set_pressed_no_signal(i == 当前索引)
		项.queue_redraw()
		if not (项 is M3NavigationRailItem):
			_套用按钮样式(项, i == 当前索引)


## 给不是 M3NavigationRailItem 的普通按钮兜底套色（老用法）
func _套用按钮样式(按钮: BaseButton, 选中: bool) -> void:
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


# ---------------- 排版（只处理直接放在轨道里的项目） ----------------

func _排版() -> void:
	var 直接项: Array[BaseButton] = []
	for 项 in _按钮:
		if 项.get_parent() == self:
			直接项.append(项)
	if 直接项.is_empty():
		return
	var 内边x := M3Theme.px(float(内边距.x))
	var 内边y := M3Theme.px(float(内边距.y))
	var 间距值 := M3Theme.px(float(项目间距))
	var 可用宽 := maxf(1.0, size.x - 内边x * 2.0)
	var 最小高 := M3Theme.px(float(默认项目最小高))
	# 项目是固定高度（最小 64dp），不拉伸 —— 和真机一样
	var 项高 := 最小高
	for 项 in 直接项:
		项高 = maxf(项高, 项.custom_minimum_size.y)
	var 数 := float(直接项.size())
	var 总高 := 项高 * 数 + 间距值 * (数 - 1.0)
	var y := (size.y - 总高) * 0.5
	for 项 in 直接项:
		项.position = Vector2(内边x, y)
		项.size = Vector2(可用宽, 项高)
		y += 项高 + 间距值


# ---------------- 外观 ----------------

func _刷新样式() -> void:
	if not is_inside_tree():
		return
	custom_minimum_size.x = maxf(custom_minimum_size.x, M3Theme.px(float(容器宽)))
	var sb := M3Theme.样式(M3Theme.surface_container_low, 圆角)
	var 线 := maxi(1, int(round(M3Theme.scale)))
	sb.border_width_left = 线
	sb.border_width_top = 线
	sb.border_width_right = 线
	sb.border_width_bottom = 线
	sb.border_color = M3Theme.outline_variant
	sb.content_margin_left = M3Theme.px(float(内边距.x))
	sb.content_margin_right = M3Theme.px(float(内边距.x))
	sb.content_margin_top = M3Theme.px(float(内边距.y))
	sb.content_margin_bottom = M3Theme.px(float(内边距.y))
	add_theme_stylebox_override("panel", sb)
	if _列 != null and is_instance_valid(_列):
		_列.add_theme_constant_override("separation", int(round(float(项目间距) * M3Theme.scale)))
	queue_sort()
