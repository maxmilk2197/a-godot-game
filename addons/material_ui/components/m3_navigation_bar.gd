@tool
@icon("res://addons/material_ui/icons/navigation_bar.svg")
class_name M3NavigationBar
extends PanelContainer
## ============================================================
## Material 3 底部导航栏（m3.material.io/components/navigation-bar）。
##
## 解剖结构跟侧边轨道项目**完全一样**（图标在上、文字在下、胶囊指示器），
## 所以这里直接复用 `M3NavigationRailItem` 当项目 —— 好处是一起拿到了：
##   · 指示器颜色过渡（120ms）和预乘 alpha 淡入淡出（不会闪黑）
##   · 图标名字形（跟着前景色走，不用管图标本身颜色）
##   · 悬停 / 按下状态层
##
## 规格：容器 80dp 高、`surface_container` 底；项目指示器 64×32dp 胶囊；
##       图标 24dp；文字 label-medium。
##
## 想自己往里放项目：把 `M3NavigationRailItem` 加成子节点即可（会按顺序排一行）。
## ============================================================

signal 切换(索引: int)

## 每个项目的文字
@export var 项目: PackedStringArray = PackedStringArray(["消息", "通讯录", "发现", "我"]):
	set(值):
		项目 = 值
		_重建()
## 每个项目的图标名（Material Design Icons，比如 ["message","account-multiple","compass","account"]）。
## 名字去哪查：编辑器菜单 工具 → Find Material Icon。
@export var 图标名: PackedStringArray = PackedStringArray():
	set(值):
		图标名 = 值
		_重建()
@export var 当前索引: int = 0:
	set(值):
		当前索引 = 值
		_刷新选中()
## 指示器胶囊的圆角（官方是全圆 16dp；这里默认取指示器高的一半）
@export var 圆角: int = 16:
	set(值):
		圆角 = 值
		_刷新选中()
@export var 字号: int = 20:
	set(值):
		字号 = 值
		_刷新选中()
## 指示器尺寸（官方 64×32dp）
@export var 指示器尺寸: Vector2i = Vector2i(64, 32):
	set(值):
		指示器尺寸 = 值
		_刷新选中()
## 图标大小（官方 24dp）
@export var 图标大小: int = 24:
	set(值):
		图标大小 = maxi(1, 值)
		_刷新选中()
## 每个项目的最小尺寸
@export var 项目最小尺寸: Vector2i = Vector2i(64, 64):
	set(值):
		项目最小尺寸 = 值
		_刷新选中()

var _行: HBoxContainer
var _按钮: Array[BaseButton] = []


func _ready() -> void:
	if not child_entered_tree.is_connected(_子节点变了):
		child_entered_tree.connect(_子节点变了)
	if not child_exiting_tree.is_connected(_子节点变了):
		child_exiting_tree.connect(_子节点变了)
	_重建()


## 子节点有增删：手动模式下延迟重建一次
func _子节点变了(_节点: Node) -> void:
	if is_inside_tree():
		_重建.call_deferred()


func _构建() -> void:
	if _行 != null and is_instance_valid(_行):
		return
	_行 = HBoxContainer.new()
	_行.name = "行"
	_行.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_行.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_行.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_行)


## 有没有用户自己放的项目（自己放的话就不按 `项目` 生成）
func _有自建项目() -> bool:
	for 子 in get_children():
		if 子 is M3NavigationRailItem:
			return true
	return false


func _重建() -> void:
	_构建()
	if _行 == null:
		return
	if not _有自建项目():
		for 子 in _行.get_children():
			_行.remove_child(子)
			子.queue_free()
		for i in range(项目.size()):
			var 项 := _新建项目(项目[i])
			if i < 图标名.size():
				项.图标名 = 图标名[i]
			_行.add_child(项)
	_收集()
	_刷新选中()
	_刷新样式()


func _新建项目(文字: String) -> M3NavigationRailItem:
	var 项 := M3NavigationRailItem.new()
	项.文字 = 文字
	项.字号 = 字号
	项.指示器宽 = 指示器尺寸.x
	项.指示器高 = 指示器尺寸.y
	项.图标大小 = 图标大小
	项.项目最小尺寸 = 项目最小尺寸
	项.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return 项


## 收集项目：直接子节点里的 M3NavigationRailItem，或容器里的
func _收集() -> void:
	_按钮.clear()
	for 子 in get_children():
		if 子 == _行:
			for 孙 in _行.get_children():
				if 孙 is BaseButton:
					_挂(孙)
		elif 子 is M3NavigationRailItem:
			_挂(子)
		elif 子 is Container:
			for 孙 in 子.get_children():
				if 孙 is BaseButton:
					_挂(孙)


func _挂(项: BaseButton) -> void:
	_按钮.append(项)
	项.toggle_mode = true
	项.focus_mode = Control.FOCUS_NONE
	var 索引 := _按钮.size() - 1
	var 键 := "__m3_navbar_cb"
	if 项.has_meta(键):
		var 旧: Callable = 项.get_meta(键)
		if 项.toggled.is_connected(旧):
			项.toggled.disconnect(旧)
	var 回调 := _某个切换.bind(索引)
	项.set_meta(键, 回调)
	项.toggled.connect(回调)


func _某个切换(按下: bool, 索引: int) -> void:
	if 按下 and 按钮_有效(索引):
		当前索引 = 索引
		切换.emit(索引)
	else:
		_刷新选中()


func 按钮_有效(索引: int) -> bool:
	return 索引 >= 0 and 索引 < _按钮.size()


## 供外部/子项目调用：把自己设为选中项
func 选中项目(项: BaseButton) -> void:
	var 索引 := _按钮.find(项)
	if 索引 < 0 or 索引 == 当前索引:
		_刷新选中()
		return
	当前索引 = 索引
	切换.emit(索引)


func _刷新选中() -> void:
	for i in range(_按钮.size()):
		var 项 := _按钮[i]
		项.set_pressed_no_signal(i == 当前索引)
		# set_pressed_no_signal 不发信号，得显式刷一下外观，否则会留着上一轮的胶囊色
		if 项.has_method("刷新外观"):
			项.call("刷新外观")
		# 不是 M3NavigationRailItem 的普通按钮：兜底套色（老用法）
		if not (项 is M3NavigationRailItem):
			_套用按钮样式(项, i == 当前索引)


## 给不是 M3NavigationRailItem 的普通按钮兜底套色
func _套用按钮样式(按钮: BaseButton, 选中: bool) -> void:
	var 圆角值 := int(round(圆角 * M3Theme.scale))
	var 空底 := M3Theme.样式(Color(0, 0, 0, 0), 圆角值)
	var 选中底 := M3Theme.样式(M3Theme.secondary_container, 圆角值)
	var 悬停底 := M3Theme.样式(
		Color(M3Theme.on_surface.r, M3Theme.on_surface.g, M3Theme.on_surface.b, M3Motion.状态_悬停), 圆角值)
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
	# 官方底部导航栏：surface_container 底、80dp 高
	var sb := M3Theme.样式(M3Theme.surface_container, 圆角_容器())
	sb.content_margin_left = M3Theme.px(8)
	sb.content_margin_right = M3Theme.px(8)
	sb.content_margin_top = M3Theme.px(8)
	sb.content_margin_bottom = M3Theme.px(8)
	add_theme_stylebox_override("panel", sb)


## 容器圆角：贴在屏幕底部，默认不留圆角（除非自己在场景里设过）
func 圆角_容器() -> int:
	return 0
