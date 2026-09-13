@tool
@icon("res://addons/material_ui/icons/switch.svg")
class_name M3Switch
extends BaseButton
## ============================================================
## Material 3 开关（Switch）。和 CheckButton 一样用 button_pressed。
## ============================================================

@export var 轨道宽: int = 60:
	set(值):
		轨道宽 = 值
		_刷新尺寸()
@export var 轨道高: int = 38:
	set(值):
		轨道高 = 值
		_刷新尺寸()

var _进度: float = 0.0
var _补间: Tween
var _起值: float = 0.0
var _目标值: float = 0.0
## 上次同步过的 button_pressed，用来发现「静默改状态」
var _上次按下: bool = false


## 必须在 _init 里设 toggle_mode。
## Godot 的 BaseButton.set_pressed() 在 !toggle_mode 时会直接 return ——
## 放到 _ready 里就晚了：场景里存的 button_pressed = true 是在 _ready **之前**
## 应用的，那时候 toggle_mode 还是默认的 false，那个 true 会被丢掉。
func _init() -> void:
	toggle_mode = true


func _ready() -> void:
	_清空样式()
	_进度 = 1.0 if button_pressed else 0.0
	_上次按下 = button_pressed
	toggled.connect(_切换)
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_刷新尺寸()
	# 场景状态可能在 _ready 前就被丢掉过，按当前值再同步一次
	queue_redraw()


## 清掉 Button 自带的样式box。
## 场景里的节点类型常常是 Button（只是换了脚本），那样 Godot 的 Button 本体
## 照样会把 normal/hover 底色画出来 —— 开关后面就会多出一块方背景。
func _清空样式() -> void:
	for 名 in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(名, M3Theme.样式(Color(0, 0, 0, 0), 0))


func _刷新尺寸() -> void:
	custom_minimum_size = Vector2(M3Theme.px(轨道宽), M3Theme.px(轨道高))
	queue_redraw()


func _切换(按下: bool) -> void:
	_上次按下 = 按下
	_动画到(1.0 if 按下 else 0.0)


## 当前该画成什么样（0=关 1=开）—— 就是动画驱动的 _进度。
## 注意**不能**在这里回退成「没动画时直接读 button_pressed」：
## button_pressed 是先变状态、后发 toggled 的，_动画到 里读到的已经是新值，
## 起点=终点 => 从 1 动画到 1，开关就「不动了」。
func 当前进度() -> float:
	return _进度


## 用来发现「静默改状态」：set_pressed_no_signal() 不发信号，
## 只靠 toggled 驱动的 _进度 会一直停在旧值（开关明明开着却画成关）。
## 这里每帧比一下，发现被静默改了就把动画补上。
func _process(_增量: float) -> void:
	if button_pressed == _上次按下:
		return
	_上次按下 = button_pressed
	_动画到(1.0 if button_pressed else 0.0)


func _动画到(目标: float) -> void:
	if Engine.is_editor_hint():
		_进度 = 目标
		queue_redraw()
		return
	if _补间 != null and _补间.is_valid():
		_补间.kill()
	# 起点 = 上次真正画出来的样子（toggled 到达时 button_pressed 已经是新值了，不能用它）
	_起值 = _进度
	_目标值 = 目标
	_补间 = create_tween()
	# M3 Expressive 空间弹簧（带一点点过冲）
	_补间.tween_method(_设弹簧, 0.0, 1.0, M3Motion.弹簧_快_时长)


func _设弹簧(t: float) -> void:
	_设置进度(lerpf(_起值, _目标值, M3Motion.弹簧_快(t)))


func _设置进度(值: float) -> void:
	_进度 = 值
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	# 一律用 当前进度() 画：静默改过 button_pressed 也能画对
	var 进 := 当前进度()
	# 按设定的轨道尺寸画，并在这个矩形里居中 ——
	# 不能直接用 size：放进 HBoxContainer 会被纵向拉伸，轨道一高就变成圆角方块、
	# 拇指也会跑到中间去。横向同理（被 EXPAND 拉宽的话胶囊会长得离谱）。
	var 轨宽 := minf(size.x, M3Theme.px(float(轨道宽)))
	var 轨高 := minf(size.y, M3Theme.px(float(轨道高)))
	var 轨 := Rect2(Vector2((size.x - 轨宽) * 0.5, (size.y - 轨高) * 0.5), Vector2(轨宽, 轨高))
	var 半 := 轨高 * 0.5

	# 轨道：关 = surface_container_highest + outline 描边；开 = primary（官方就是这样）
	var 轨道色 := M3Theme.surface_container_highest.lerp(M3Theme.primary, 进)
	if disabled:
		轨道色.a = 0.4
	var 轨道样式 := M3Theme.样式(轨道色, int(round(半)))
	# 关着的时候描边跟 outline 走，打开后描边消失
	var 边色 := M3Theme.outline
	边色.a *= 1.0 - 进
	var 边宽 := int(round(M3Theme.px(2.0) * (1.0 - 进)))
	if 边宽 > 0:
		轨道样式.border_color = 边色
		轨道样式.set_border_width_all(边宽)
	draw_style_box(轨道样式, 轨)

	# 拇指：关 = 小圆（outline 色）；开 = 大圆（on_primary 色）
	var 半径 := lerpf(轨高 * 0.22, 轨高 * 0.36, 进)
	var 中心x := lerpf(半, 轨宽 - 半, 进)
	var 拇指色 := M3Theme.outline.lerp(M3Theme.on_primary, 进)
	if disabled:
		拇指色.a = 0.6
	draw_circle(轨.position + Vector2(中心x, 半), 半径, 拇指色, true, -1.0, true)
