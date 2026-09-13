@tool
@icon("res://addons/material_ui/icons/slider.svg")
class_name M3Slider
extends HSlider
## ============================================================
## Material 3 Expressive 滑块（竖条手柄 + 胶囊轨道）。
## 用法和 HSlider 完全一样（value / value_changed / min_value / max_value / step）。
##
## 几何取自 md3e 的 <md-slider>：
##   轨道     16dp 高、全圆角；底轨 secondary_container，已选段 primary
##   手柄     44dp 高、静止 4dp 宽；悬停 6dp；按下/聚焦 2dp 且 scale(1.15, 0.95)
##   刻度点   4dp 圆点；已经过的用 on_primary@0.7，还没到的用 on_secondary_container@0.5
##   手柄宽度过渡 200ms（expressive 空间弹簧）
##
## 实现方式：把内建的 StyleBox 全部清空，所有绘制由 _draw() 自己完成，
## 这样既能用 HSlider 的取值/拖动/信号，又能完全控制外观。
## ============================================================

## 轨道高 / 手柄高（dp）
const 轨道高 := 16.0
const 手柄高 := 44.0
## 手柄在 静止 / 悬停 / 按下 时的宽度（dp）
const 柄宽_静止 := 4.0
const 柄宽_悬停 := 6.0
const 柄宽_按下 := 2.0
## 按下时手柄的缩放（md3e: scale(1.15, 0.95)）
const 按下缩放 := Vector2(1.15, 0.95)
## 刻度点直径（dp）
const 刻度点径 := 4.0
## 整个控件的高度（dp）
const 控件高 := 48.0

## 是否画离散刻度点
@export var 显示刻度: bool = false:
	set(值):
		显示刻度 = 值
		queue_redraw()
## 刻度段数（0 = 按 step 自动算；太多会自动不画）
@export var 刻度数: int = 0:
	set(值):
		刻度数 = maxi(0, 值)
		queue_redraw()
## 按住/悬停时在手柄上方显示数值气泡
@export var 显示数值: bool = false:
	set(值):
		显示数值 = 值
		queue_redraw()
## 数值气泡的字号（dp）
@export var 气泡字号: int = 14:
	set(值):
		气泡字号 = maxi(8, 值)
		queue_redraw()

var _柄宽: float = 0.0
var _按下中: bool = false
var _悬停: bool = false
## 键盘切过来的焦点才算「focus-visible」。鼠标点出来的焦点不算 ——
## 否则点过一次之后手柄会永久停在按下宽度，悬停放大就再也回不来了。
var _键盘聚焦: bool = false
var _补间: Tween


func _ready() -> void:
	_清空内建样式()
	_柄宽 = M3Theme.px(柄宽_静止)
	custom_minimum_size.y = maxf(custom_minimum_size.y, M3Theme.px(控件高))
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	if not value_changed.is_connected(_值变了):
		value_changed.connect(_值变了)
	if not changed.is_connected(queue_redraw):
		changed.connect(queue_redraw)
	if not drag_started.is_connected(_拖动开始):
		drag_started.connect(_拖动开始)
	if not drag_ended.is_connected(_拖动结束):
		drag_ended.connect(_拖动结束)
	if not mouse_entered.is_connected(_进):
		mouse_entered.connect(_进)
	if not mouse_exited.is_connected(_出):
		mouse_exited.connect(_出)
	if not focus_entered.is_connected(_获得焦点):
		focus_entered.connect(_获得焦点)
	if not focus_exited.is_connected(_失去焦点):
		focus_exited.connect(_失去焦点)
	queue_redraw()


func _进() -> void:
	_悬停 = true
	_刷新柄宽()


func _出() -> void:
	_悬停 = false
	_刷新柄宽()


func _获得焦点() -> void:
	# 鼠标（或触摸）正在按下时拿到的焦点，是点出来的，不算 focus-visible
	_键盘聚焦 = not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_刷新柄宽()


func _失去焦点() -> void:
	_键盘聚焦 = false
	_刷新柄宽()


## 把 Godot 自带的绘制全部关掉，改由 _draw 自己画
func _清空内建样式() -> void:
	var 空 := StyleBoxEmpty.new()
	for 名 in ["slider", "grabber_area", "grabber_area_highlight", "grabber", "grabber_highlight"]:
		add_theme_stylebox_override(名, 空)


func _值变了(_新值: float) -> void:
	queue_redraw()


func _拖动开始() -> void:
	_按下中 = true
	# 能用鼠标拖了，说明焦点不是键盘切过来的
	_键盘聚焦 = false
	_刷新柄宽()


func _拖动结束(_值被改: bool) -> void:
	_按下中 = false
	_刷新柄宽()


# ---------------- 手柄宽度动画 ----------------

func _目标柄宽() -> float:
	if _按下中 or _键盘聚焦:
		return 柄宽_按下
	if _悬停:
		return 柄宽_悬停
	return 柄宽_静止


func _刷新柄宽() -> void:
	var 目标 := M3Theme.px(_目标柄宽())
	if Engine.is_editor_hint() or not is_inside_tree():
		_柄宽 = 目标
		queue_redraw()
		return
	if absf(_柄宽 - 目标) < 0.01:
		_柄宽 = 目标
		queue_redraw()
		return
	if _补间 != null and _补间.is_valid():
		_补间.kill()
	var 起 := _柄宽
	_补间 = create_tween()
	_补间.tween_method(
		func(t: float) -> void:
			_柄宽 = lerpf(起, 目标, M3Motion.弹簧_快(t))
			queue_redraw(),
		0.0, 1.0, M3Motion.弹簧_快_时长)


# ---------------- 绘制 ----------------

func _比例() -> float:
	var 跨度 := max_value - min_value
	if 跨度 <= 0.0:
		return 0.0
	return clampf((value - min_value) / 跨度, 0.0, 1.0)


## 圆角夹到不超过短边一半，避免窄了之后变成怪形状
func _胶囊(色: Color, 宽: float, 高: float) -> StyleBoxFlat:
	return M3Theme.样式(色, int(round(minf(宽, 高) * 0.5)))


func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	var 轨高 := M3Theme.px(轨道高)
	var 中心y := size.y * 0.5
	var 柄宽 := maxf(1.0, _柄宽)
	# 轨道两端各留出手柄一半，手柄在最左/最右时不会探出去
	var 轨宽 := maxf(1.0, size.x - 柄宽)
	var 轨x := (size.x - 轨宽) * 0.5
	var 轨y := 中心y - 轨高 * 0.5
	var 比 := _比例()

	# 底轨
	draw_style_box(_胶囊(M3Theme.secondary_container, 轨宽, 轨高), Rect2(轨x, 轨y, 轨宽, 轨高))

	# 已选段
	if 比 > 0.0005:
		var 已选宽 := maxf(1.0, 轨宽 * 比)
		draw_style_box(_胶囊(M3Theme.primary, 已选宽, 轨高), Rect2(轨x, 轨y, 已选宽, 轨高))

	# 刻度点
	if 显示刻度:
		_画刻度(轨x, 中心y, 轨宽, 比)

	# 手柄
	var 实宽 := 柄宽
	var 实高 := M3Theme.px(手柄高)
	if _按下中:
		实宽 *= 按下缩放.x
		实高 *= 按下缩放.y
	var 柄心x := 轨x + 轨宽 * 比
	draw_style_box(
		M3Theme.海拔样式(M3Theme.primary, int(round(minf(实宽, 实高) * 0.5)), 1),
		Rect2(柄心x - 实宽 * 0.5, 中心y - 实高 * 0.5, 实宽, 实高))

	# 数值气泡：放在**手柄上方**，不能压在手柄/轨道上
	if 显示数值 and (_按下中 or _悬停):
		_画气泡(柄心x, 中心y - 实高 * 0.5)


func _画刻度(轨x: float, 中心y: float, 轨宽: float, 比: float) -> void:
	var 数 := 刻度数
	if 数 <= 0:
		if step <= 0.0:
			return
		数 = int(round((max_value - min_value) / step))
	# 太多就不画了，否则整条轨道糊成一片
	if 数 <= 0 or 数 > 40:
		return
	var 径 := M3Theme.px(刻度点径)
	for i in range(数 + 1):
		var p := float(i) / float(数)
		var 过了 := p <= 比
		var 色 := M3Theme.on_primary if 过了 else M3Theme.on_secondary_container
		色.a = 0.7 if 过了 else 0.5
		draw_circle(Vector2(轨x + 轨宽 * p, 中心y), 径 * 0.5, 色, true, -1.0, true)


func _数值文本() -> String:
	if max_value <= 1.0001 and min_value >= -0.0001:
		return "%d%%" % int(round(value * 100.0))
	if step >= 1.0:
		return "%d" % int(round(value))
	return "%.2f" % value


## 画数值气泡。柄顶y = 手柄矩形上沿 —— 气泡要整个在它上面，
## 以前是按「轨道上沿」定位的，而手柄比轨道高（44 vs 16），
## 结果手柄上半截被气泡压住，看起来像重叠。
func _画气泡(柄心x: float, 柄顶y: float) -> void:
	var 文 := _数值文本()
	var 字 := get_theme_font("font")
	if 字 == null:
		return
	var 号 := maxi(8, int(round(M3Theme.px(float(气泡字号)))))
	var 文宽 := 字.get_string_size(文, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 号).x
	var 内x := M3Theme.px(8.0)
	var 内y := M3Theme.px(4.0)
	var 宽 := 文宽 + 内x * 2.0
	var 高 := 字.get_height(号) + 内y * 2.0
	var x := clampf(柄心x - 宽 * 0.5, 0.0, maxf(0.0, size.x - 宽))
	# 手柄上方留一点空隙
	var y := 柄顶y - M3Theme.px(6.0) - 高
	draw_style_box(M3Theme.样式(M3Theme.inverse_surface, int(round(M3Theme.px(8.0)))), Rect2(x, y, 宽, 高))
	draw_string(字, Vector2(x + 内x, y + 内y + 字.get_ascent(号)), 文,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, 号, M3Theme.inverse_on_surface)
