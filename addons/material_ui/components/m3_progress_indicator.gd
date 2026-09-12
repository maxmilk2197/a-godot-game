@tool
@icon("res://addons/material_ui/icons/progress_indicator.svg")
class_name M3ProgressIndicator
extends Control
## ============================================================
## Material 3 进度指示器（线性 / 圆形）。
## 确定进度：设 值(0~1)；不确定（加载中）：把 不定 设为 true。
##
## 环形不定量照 mdui 的 circular-progress 来，它是「双半圆遮罩」：
## 两个 clipper 各露出一半圆环，里面的 <circle> 只画半圈（dasharray=周长、
## dashoffset=周长/2），各自被 left-spin / right-spin 反向旋转。
## 把两半在屏幕上的可见部分并起来，等价于一整段弧：
##
##     起始角 = 容器自转 + 图层旋转 + 钳口角
##     扫过角 = 540° − 2 × 钳口角
##
## 三段时序（原文见 components/circular-progress/style.js）：
##   · 容器整圈自转  1568ms  linear            360°
##   · 图层旋转      5332ms  8 段 × 135°        1080°
##   · 钳口伸缩      1333ms  265° ↔ 130°        standard
##
## 关键性质：图层每段正好也是 666.5ms，与钳口半周期同长、同缓动，两者叠加后
## 两个端点全程都只前进、不会有一端倒着缩（旧版自创公式会倒缩，已修）。
## ============================================================

enum 样式类型 { LINEAR, CIRCULAR }

# ---------------- 环形不定量时序 ----------------
## 容器整圈自转
const 容器周期 := 1.568
## 图层旋转：5332ms 转 1080°（8 段，每段 standard 缓动）
const 图层周期 := 5.332
const 图层总角 := 1080.0
const 图层段数 := 8
## 半圆钳口伸缩：265° ↔ 130°，对应弧长 10° ↔ 280°
const 钳口周期 := 1.333
const 钳口外 := 265.0
const 钳口内 := 130.0
## 三个周期的公倍数（2090144ms ≈ 35 分钟）：到这里回绕不会有任何可见跳变
const 回绕周期 := 2090.144

## 确定进度的弧长过渡时长（mdui 的 long2）
const 值过渡 := 0.5

@export var 类型: 样式类型 = 样式类型.LINEAR:
	set(值):
		类型 = 值
		_刷新尺寸()
@export_range(0.0, 1.0, 0.01) var 值: float = 0.4:
	set(新值):
		值 = clampf(新值, 0.0, 1.0)
		_缓到值(值)
@export var 不定: bool = false:
	set(值):
		不定 = 值
		_时刻 = 0.0
		set_process(值)
		queue_redraw()
@export var 粗细: int = 4:
	set(值):
		粗细 = 值
		_刷新尺寸()

var _时刻: float = 0.0
## 实际画出来的进度值（会缓动到 值）
var _显示值: float = 0.4
var _值补间: Tween


func _ready() -> void:
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_显示值 = 值
	set_process(不定)
	_刷新尺寸()


func _process(增量: float) -> void:
	if not 不定:
		return
	_时刻 += 增量
	if _时刻 >= 回绕周期:
		_时刻 = fmod(_时刻, 回绕周期)
	queue_redraw()


func _刷新尺寸() -> void:
	var 像素 := maxi(2, int(round(粗细 * M3Theme.scale)))
	if 类型 == 样式类型.LINEAR:
		custom_minimum_size = Vector2(custom_minimum_size.x, 像素)
	else:
		var 直径 := maxi(像素 * 4, int(round(48 * M3Theme.scale)))
		custom_minimum_size = Vector2(直径, 直径)
	set_process(不定)
	queue_redraw()


## 值变化时用 500ms standard 缓动过去（编辑器里直接跳，方便预览）
func _缓到值(目标: float) -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		_显示值 = 目标
		queue_redraw()
		return
	if _值补间 != null and _值补间.is_valid():
		_值补间.kill()
	var 起 := _显示值
	_值补间 = create_tween()
	_值补间.tween_method(
		func(t: float) -> void:
			_显示值 = lerpf(起, 目标, M3Motion.标准(t))
			queue_redraw(),
		0.0, 1.0, 值过渡)


func _draw() -> void:
	if 类型 == 样式类型.CIRCULAR:
		_画圆形()
	else:
		_画线性()


# ---------------- 线性 ----------------
func _画线性() -> void:
	var 像素 := maxf(2.0, 粗细 * M3Theme.scale)
	var 半 := 像素 * 0.5
	var 顶部 := size.y * 0.5 - 半
	draw_style_box(M3Theme.样式(M3Theme.secondary_container, int(半)), Rect2(0.0, 顶部, size.x, 像素))

	if 不定:
		_画滑条(_环形相位(), 0.0, 像素, 顶部)
		_画滑条(_环形相位(), 0.5, 像素, 顶部)
	else:
		var 宽 := size.x * clampf(_显示值, 0.0, 1.0)
		if 宽 > 0.0:
			draw_style_box(M3Theme.样式(M3Theme.primary, int(半)), Rect2(0.0, 顶部, 宽, 像素))


func _环形相位() -> float:
	return fmod(_时刻, 1.33) / 1.33


func _画滑条(相位: float, 偏移: float, 像素: float, 顶部: float) -> void:
	var 阶段 := fmod(相位 + 偏移, 1.0)
	var 头 := lerpf(-0.30, 1.0, 阶段)
	var 尾 := lerpf(-0.50, 0.62, 阶段)
	var 左 := clampf(尾, 0.0, 1.0) * size.x
	var 右 := clampf(头, 0.0, 1.0) * size.x
	if 右 - 左 > 0.5:
		draw_style_box(M3Theme.样式(M3Theme.primary, int(像素 * 0.5)), Rect2(左, 顶部, 右 - 左, 像素))


# ---------------- 圆形 ----------------
func _画圆形() -> void:
	var 像素 := maxf(2.0, 粗细 * M3Theme.scale)
	var 中心 := size * 0.5
	var 半径 := maxf(1.0, minf(size.x, size.y) * 0.5 - 像素 * 0.5)
	draw_arc(中心, 半径, 0.0, TAU, 96, M3Theme.secondary_container, 像素, true)

	if 不定:
		var 角 := _环形角度(_时刻)
		_画弧(中心, 半径, deg_to_rad(角.x), deg_to_rad(角.y), 像素, M3Theme.primary)
	else:
		_画弧(中心, 半径, -PI * 0.5, TAU * clampf(_显示值, 0.0, 1.0), 像素, M3Theme.primary)


## 环形不定量当前这一帧的 Vector2(起始角, 扫过角)，单位是度
func _环形角度(时刻: float) -> Vector2:
	var 容器 := 360.0 * fmod(时刻, 容器周期) / 容器周期
	var 图层 := 图层总角 * _图层进度(fmod(时刻, 图层周期) / 图层周期)
	var u := fmod(时刻, 钳口周期) / 钳口周期
	var 钳 := 0.0
	if u < 0.5:
		钳 = lerpf(钳口外, 钳口内, M3Motion.标准(u * 2.0))
	else:
		钳 = lerpf(钳口内, 钳口外, M3Motion.标准(u * 2.0 - 1.0))
	return Vector2(容器 + 图层 + 钳, 540.0 - 2.0 * 钳)


## 图层旋转的「8 段步进」：每 12.5% 走 135°，段内 standard 缓动
func _图层进度(x: float) -> float:
	var 段 := clampi(int(floor(x * float(图层段数))), 0, 图层段数 - 1)
	var 局部 := x * float(图层段数) - float(段)
	return (float(段) + M3Motion.标准(局部)) / float(图层段数)


## 画一段圆头弧 —— Material 的环形进度两端是圆的（draw_arc 默认是平头）
func _画弧(中心: Vector2, 半径: float, 起: float, 扫: float, 像素: float, 色: Color) -> void:
	if 扫 <= 0.001:
		return
	var 段数 := maxi(8, int(round(扫 / TAU * 96.0)))
	draw_arc(中心, 半径, 起, 起 + 扫, 段数, 色, 像素, true)
	if 扫 >= TAU - 0.001:
		return
	var 半 := 像素 * 0.5
	draw_circle(中心 + Vector2(cos(起), sin(起)) * 半径, 半, 色, true, -1.0, true)
	draw_circle(中心 + Vector2(cos(起 + 扫), sin(起 + 扫)) * 半径, 半, 色, true, -1.0, true)
