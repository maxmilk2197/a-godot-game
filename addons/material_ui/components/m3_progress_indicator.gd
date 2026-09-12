@tool
class_name M3ProgressIndicator
extends Control
## ============================================================
## Material 3 进度指示器（线性 / 圆形）。
## 确定进度：设 值(0~1)；不确定进度：把 不定 设为 true。
## ============================================================

enum 样式类型 { LINEAR, CIRCULAR }

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


func _ready() -> void:
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	set_process(不定)
	_刷新尺寸()


func _process(增量: float) -> void:
	_相位 = fmod(_相位 + 增量 * 0.8, 1.0)
	queue_redraw()


func _刷新尺寸() -> void:
	var 像素 := maxi(2, int(round(粗细 * M3Theme.scale)))
	if 类型 == 样式类型.LINEAR:
		custom_minimum_size = Vector2(custom_minimum_size.x, 像素)
	else:
		var 直径 := maxi(像素 * 4, int(round(40 * M3Theme.scale)))
		custom_minimum_size = Vector2(直径, 直径)
	set_process(不定)
	queue_redraw()


func _draw() -> void:
	if 类型 == 样式类型.CIRCULAR:
		_画圆形()
	else:
		_画线性()


func _画线性() -> void:
	var 像素 := maxf(2.0, 粗细 * M3Theme.scale)
	var 半 := 像素 * 0.5
	draw_style_box(M3Theme.样式(M3Theme.secondary_container, int(半)), Rect2(0, size.y * 0.5 - 半, size.x, 像素))
	if 不定:
		var 段宽 := size.x * 0.28
		var 起点 := (size.x + 段宽) * _相位 - 段宽
		var 左 := maxf(0.0, 起点)
		var 右 := minf(size.x, 起点 + 段宽)
		if 右 > 左:
			draw_style_box(M3Theme.样式(M3Theme.primary, int(半)), Rect2(左, size.y * 0.5 - 半, 右 - 左, 像素))
	else:
		draw_style_box(M3Theme.样式(M3Theme.primary, int(半)), Rect2(0, size.y * 0.5 - 半, size.x * clampf(值, 0.0, 1.0), 像素))


func _画圆形() -> void:
	var 像素 := maxf(2.0, 粗细 * M3Theme.scale)
	var 中心 := size * 0.5
	var 半径 := maxf(1.0, minf(size.x, size.y) * 0.5 - 像素 * 0.5)
	draw_arc(中心, 半径, 0.0, TAU, 64, M3Theme.secondary_container, 像素, true)
	var 起 := -PI * 0.5
	if 不定:
		起 += TAU * _相位
		draw_arc(中心, 半径, 起, 起 + TAU * 0.28, 32, M3Theme.primary, 像素, true)
	else:
		draw_arc(中心, 半径, 起, 起 + TAU * clampf(值, 0.0, 1.0), 64, M3Theme.primary, 像素, true)
