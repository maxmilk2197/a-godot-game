@tool
@icon("res://addons/material_ui/icons/button.svg")
class_name M3Button
extends Button
## ============================================================
## Material 3 按钮。支持 Filled / Tonal / Outlined / Text / Elevated。
## 直接当普通 Button 用（text、pressed 信号都在），样式自动套用 M3。
## ============================================================

enum 按钮样式 { FILLED, TONAL, OUTLINED, TEXT, ELEVATED }

@export var 样式类型: 按钮样式 = 按钮样式.FILLED:
	set(值):
		样式类型 = 值
		_刷新样式()
@export var 圆角: int = M3Shape.大加强:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 字号: int = 24:
	set(值):
		字号 = 值
		_刷新样式()
## 覆盖文字颜色（alpha 为 0 时用样式默认色）
@export var 自定义文字色: Color = Color(0, 0, 0, 0):
	set(值):
		自定义文字色 = 值
		_刷新样式()
## 点击 / 悬停状态层的颜色（alpha 为 0 时默认用 secondary_container，即 dbe2f9）
@export var 点击颜色: Color = Color(0, 0, 0, 0):
	set(值):
		点击颜色 = 值
		_刷新样式()
## ---- 涟漪（点击水波）----
## 下面几个留 **-1 = 跟随全局**。全局值在 M3Theme 里（涟漪扩散时长 等），
## 编辑器里在 项目设置 → m3/ripple 就能改；设成 0 或正数则这个按钮单独覆盖。
## 时长含义照 Material Web 官方 ripple（生长 450ms / 最小按压 225ms / 淡入 105ms / 淡出 375ms）。
@export_group("涟漪")
## 起始不透明度
@export_range(-1.0, 1.0, 0.05) var 涟漪不透明度: float = -1.0
## 生长时长（官方 450ms）
@export_range(-1.0, 2.0, 0.05) var 涟漪扩散时长: float = -1.0:
	set(值):
		涟漪扩散时长 = 值
		同步涟漪参数()
## 不透明度淡入时长（官方 105ms）
@export_range(-1.0, 1.0, 0.01) var 涟漪淡入时长: float = -1.0:
	set(值):
		涟漪淡入时长 = 值
		同步涟漪参数()
## 松开后的淡出时长（官方 375ms）
@export_range(-1.0, 2.0, 0.05) var 涟漪淡出时长: float = -1.0:
	set(值):
		涟漪淡出时长 = 值
		同步涟漪参数()
## 最短按压时间（官方 225ms）：按住不足这么久，松手也要等满再淡出
@export_range(-1.0, 2.0, 0.05) var 涟漪最小按压: float = -1.0:
	set(值):
		涟漪最小按压 = 值
		同步涟漪参数()

var _涟漪: M3Ripple


## 把按钮上的覆盖值同步到涟漪实例上（-1 原样传过去，涟漪那边会回落到全局值）
func 同步涟漪参数() -> void:
	if _涟漪 == null or not is_instance_valid(_涟漪):
		return
	_涟漪.扩散时长 = 涟漪扩散时长
	_涟漪.淡入时长 = 涟漪淡入时长
	_涟漪.淡出时长 = 涟漪淡出时长
	_涟漪.最小按压 = 涟漪最小按压


## 生效的涟漪不透明度（-1 时取全局）
func 涟漪不透明度值() -> float:
	return 涟漪不透明度 if 涟漪不透明度 >= 0.0 else M3Theme.涟漪不透明度


func _ready() -> void:
	clip_contents = true
	button_down.connect(_按下)
	button_up.connect(_松开)
	_刷新样式()


## 按下：涟漪扩散并保持（长按也一直有）
func _按下() -> void:
	if Engine.is_editor_hint():
		return
	if _涟漪 == null or not is_instance_valid(_涟漪):
		_涟漪 = M3Ripple.new()
		add_child(_涟漪)
	同步涟漪参数()
	var 波纹 := 状态色()
	波纹.a = 涟漪峰值()
	_涟漪.按下(get_local_mouse_position(), 波纹)
	# 只有真的被指针按下才开兜底（键盘激活没有鼠标按下）
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		set_process(true)


## 兜底：松手事件有可能被别的节点吃掉 —— 比如列表的拖拽滚动会在 _input 里
## set_input_as_handled()，而 _input 比 GUI 派发更早，于是 button_up 永远不来，
## 涟漪就一直停在满格（看起来像「松手了还高亮」）。所以按住期间盯一下指针，
## 松开了就自己把涟漪收掉。
func _process(_增量: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	_松开()


## 松开：涟漪淡出
func _松开() -> void:
	set_process(false)
	if _涟漪 != null and is_instance_valid(_涟漪):
		_涟漪.松开()


## 点击时涟漪 / 状态层的实际颜色。
## 官方是「按变体取 on-primary / on-secondary-container / primary」，
## 但这里默认用 secondary_container（dbe2f9）：官方那套在填充底上会把按钮冲得发白。
## 想恢复官方的按变体取色：设 M3Theme.涟漪颜色 = Color(0,0,0,0) 并把下面改回官方映射。
func 状态色() -> Color:
	if 点击颜色.a > 0.0:
		return 点击颜色
	if M3Theme.涟漪颜色.a > 0.0:
		return M3Theme.涟漪颜色
	if 样式类型 == 按钮样式.TONAL:
		# 色调按钮的底色本身就是 secondary_container，再用同色叠上去等于没反应
		return M3Theme.on_secondary_container
	return M3Theme.secondary_container


## 涟漪峰值不透明度。
## 填充/色调底的按钮，涟漪色与底色的明度差很大，按 涟漪不透明度 全量叠上去会
## 把整颗按钮冲淡或压黑（文字对比度跟着掉），所以这两类要压低峰值；
## 浅底（描边/文字/抬升）上涟漪色本身很浅，得保持全量才看得见。
func 涟漪峰值() -> float:
	var 基准 := clampf(涟漪不透明度值(), 0.0, 1.0)
	match 样式类型:
		按钮样式.FILLED:
			return 基准 * 0.32
		按钮样式.TONAL:
			return 基准 * 0.22
	return 基准


## 该样式下的文字/图标颜色
func 前景色() -> Color:
	match 样式类型:
		按钮样式.FILLED:
			return M3Theme.on_primary
		按钮样式.TONAL:
			return M3Theme.on_secondary_container
		按钮样式.OUTLINED, 按钮样式.TEXT, 按钮样式.ELEVATED:
			return M3Theme.primary
	return M3Theme.on_surface


func _底色() -> Color:
	match 样式类型:
		按钮样式.FILLED:
			return M3Theme.primary
		按钮样式.TONAL:
			return M3Theme.secondary_container
		按钮样式.ELEVATED:
			return M3Theme.surface_container_low
		按钮样式.OUTLINED, 按钮样式.TEXT:
			return Color(0, 0, 0, 0)
	return M3Theme.surface


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var 圆角值 := int(round(圆角 * M3Theme.scale))
	var 文字色 := 前景色()
	if 自定义文字色.a > 0.0:
		文字色 = 自定义文字色
	var 状态叠加 := 状态色()

	# 普通态
	var 普通: StyleBoxFlat
	if 样式类型 == 按钮样式.OUTLINED:
		普通 = M3Theme.描边样式(M3Theme.outline, 圆角值)
	elif 样式类型 == 按钮样式.ELEVATED:
		普通 = M3Theme.海拔样式(M3Theme.surface_container_low, 圆角值, 1)
	else:
		普通 = M3Theme.样式(_底色(), 圆角值)

	# 悬停：叠一层状态层
	var 悬停 := M3Theme.状态层(_底色(), 状态叠加, 圆角值, M3Motion.状态_悬停)
	# 按下：**不再叠状态层**。MD3 里涟漪本身就是按下状态层，两者叠起来会到
	# 0.10 + 0.12 ≈ 0.22，整个按钮变成一块实心色（又高又窄的按钮尤其明显，
	# 看起来像「方块」）。所以按下态直接用普通底，按下反馈交给涟漪。
	var 按下态 := 普通
	var 禁用 := M3Theme.样式(Color(M3Theme.on_surface.r, M3Theme.on_surface.g, M3Theme.on_surface.b, 0.12), 圆角值)
	var 焦点 := M3Theme.描边样式(M3Theme.primary, 圆角值, 2)

	add_theme_stylebox_override("normal", 普通)
	add_theme_stylebox_override("hover", 悬停)
	add_theme_stylebox_override("pressed", 按下态)
	add_theme_stylebox_override("disabled", 禁用)
	add_theme_stylebox_override("focus", 焦点)

	add_theme_color_override("font_color", 文字色)
	add_theme_color_override("font_hover_color", 文字色)
	add_theme_color_override("font_pressed_color", 文字色)
	add_theme_color_override("font_hover_pressed_color", 文字色)
	add_theme_color_override("font_focus_color", 文字色)
	add_theme_color_override("font_disabled_color", M3Theme.on_surface_variant)
	add_theme_font_size_override("font_size", M3Theme.fs(字号))

	# 让内容左右留出 M3 的内边距
	普通.content_margin_left = M3Theme.px(24)
	普通.content_margin_right = M3Theme.px(24)
	普通.content_margin_top = M3Theme.px(10)
	普通.content_margin_bottom = M3Theme.px(10)
