@tool
class_name M3ProgressIndicator
extends Control
## ============================================================
## Material 3 进度指示器（线性 / 圆形）。
## 确定进度：设 值(0~1)；不确定（加载中）：把 不定 设为 true。
##
## 不定动画照 mdui / Material 的环形进度来做：
##   · 整段弧持续旋转 —— mdui 是「容器 1568ms/圈」+「图层 5332ms 转 3 圈」，
##     合计约 1.6 圈/周期；这里用 尾/头 自身 1 圈 + 附加 0.6 圈凑成同样速度
##   · 前半段「头往前跑」把弧拉长，后半段「尾往前追」把弧收短
##     —— 两端永远同向向前，不会有一头倒着缩
##   · 弧长在 10° ~ 270° 之间（Material 的 MIN/MAX_SWEEP），缓动 standard
## ============================================================

enum 样式类型 { LINEAR, CIRCULAR }

## 不定动画一伸一缩的周期（秒）。mdui 的钳口旋转是 1333ms
const 周期 := 1.33
## 除「尾/头自身每周期 1 圈」之外，额外叠加的旋转圈数（凑够 mdui 的 ~1.6 圈/周期）
const 附加圈数 := 0.6
## 弧的最小 / 最大角度（度）
const 最小弧 := 10.0
const 最大弧 := 270.0

@export var 类型: 样式类型 = 样式类型.LINEAR:
	set(值):
		类型 = 值
		_刷新尺寸()
@export_range(0.0, 1.0, 0.01) var 值: float = 0.4:
	set(值):
		值 = 值
		queue_redraw()
@export var 不定: bool = false:
	set(值):
		不定 = 值
		set_process(值)
		queue_redraw()
@export var 粗细: int = 4:
	set(值):
		粗细 = 值
		_刷新尺寸()

var _相位: float = 0.0
var _旋转: float = 0.0


func _ready() -> void:
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	set_process(不定)
	_刷新尺寸()


func _process(增量: float) -> void:
	_相位 = fmod(_相位 + 增量 / 周期, 1.0)
	# 附加旋转：连续累加，按整圈回绕（肉眼看不出跳变）
	_旋转 += 增量 / 周期 * 附加圈数 * TAU
	if _旋转 >= TAU * 1024.0:
		_旋转 -= TAU * 1024.0
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
		_画滑条(_相位, 0.0, 像素, 顶部)
		_画滑条(_相位, 0.5, 像素, 顶部)
	else:
		var 宽 := size.x * clampf(值, 0.0, 1.0)
		if 宽 > 0.0:
			draw_style_box(M3Theme.样式(M3Theme.primary, int(半)), Rect2(0.0, 顶部, 宽, 像素))


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
		var 小 := deg_to_rad(最小弧)
		var 大 := deg_to_rad(最大弧)
		var 尾 := 0.0
		var 头 := 0.0
		if _相位 < 0.5:
			# 生长：尾不动，头往前跑（standard 减速）
			尾 = 0.0
			头 = 小 + (大 - 小) * M3Motion.标准(_相位 / 0.5)
		else:
			# 收缩：头几乎不动，尾往前追（standard 加速）
			var k := (_相位 - 0.5) / 0.5
			尾 = k * TAU
			头 = 尾 + 大 - (大 - 小) * M3Motion.标准(k)
		_画弧(中心, 半径, _旋转 + 尾 - PI * 0.5, 头 - 尾, 像素, M3Theme.primary)
	else:
		_画弧(中心, 半径, -PI * 0.5, TAU * clampf(值, 0.0, 1.0), 像素, M3Theme.primary)


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
