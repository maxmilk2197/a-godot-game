@tool
@icon("res://addons/material_ui/icons/radio_button.svg")
class_name M3RadioButton
extends BaseButton
## ============================================================
## Material 3 单选按钮。和 CheckBox 一样用 button_pressed。
## 互斥请用 ButtonGroup 或在代码里控制。
## ============================================================

@export var 直径: int = 28:
	set(值):
		直径 = 值
		_刷新尺寸()

var _进度: float = 0.0
var _补间: Tween
var _起值: float = 0.0
var _目标值: float = 0.0


func _ready() -> void:
	toggle_mode = true
	_进度 = 1.0 if button_pressed else 0.0
	toggled.connect(_切换)
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_刷新尺寸()


func _刷新尺寸() -> void:
	custom_minimum_size = Vector2(M3Theme.px(直径), M3Theme.px(直径))
	queue_redraw()


func _切换(按下: bool) -> void:
	_动画到(1.0 if 按下 else 0.0)


func _动画到(目标: float) -> void:
	if Engine.is_editor_hint():
		_进度 = 目标
		queue_redraw()
		return
	if _补间 != null and _补间.is_valid():
		_补间.kill()
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
	var 直径像素 := minf(size.x, size.y)
	if 直径像素 <= 0.0:
		return
	var 中心 := size * 0.5
	var 外半径 := 直径像素 * 0.5

	# 外圈
	var 外圈色 := M3Theme.outline.lerp(M3Theme.primary, _进度)
	var 外圈 := M3Theme.样式(Color(0, 0, 0, 0), int(外半径))
	外圈.set_border_width_all(maxi(1, int(round(2.0 * M3Theme.scale))))
	外圈.border_color = 外圈色
	draw_style_box(外圈, Rect2(中心 - Vector2(外半径, 外半径), Vector2(直径像素, 直径像素)))

	# 内点
	var 内半径 := 外半径 * 0.5 * _进度
	if 内半径 > 0.5:
		var 内色 := M3Theme.primary
		if disabled:
			内色.a = 0.5
		draw_circle(中心, 内半径, 内色, true, -1.0, true)
