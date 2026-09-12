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


func _ready() -> void:
	toggle_mode = true
	_进度 = 1.0 if button_pressed else 0.0
	toggled.connect(_切换)
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_刷新尺寸()


func _刷新尺寸() -> void:
	custom_minimum_size = Vector2(M3Theme.px(轨道宽), M3Theme.px(轨道高))
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
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var 高 := size.y
	var 半 := 高 * 0.5
	var 轨道色 := M3Theme.surface_container_high.lerp(M3Theme.primary, _进度)
	if disabled:
		轨道色.a = 0.4
	draw_style_box(M3Theme.样式(轨道色, int(半)), Rect2(Vector2.ZERO, size))

	var 半径 := lerpf(高 * 0.22, 高 * 0.36, _进度)
	var 中心x := lerpf(半, size.x - 半, _进度)
	var 拇指色 := M3Theme.outline.lerp(M3Theme.on_primary, _进度)
	if disabled:
		拇指色.a = 0.6
	draw_circle(Vector2(中心x, 高 * 0.5), 半径, 拇指色, true, -1.0, true)
