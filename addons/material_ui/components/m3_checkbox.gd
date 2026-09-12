@tool
@icon("res://addons/material_ui/icons/checkbox.svg")
class_name M3Checkbox
extends BaseButton
## ============================================================
## Material 3 复选框。和 CheckBox 一样用 button_pressed。
## ============================================================

@export var 边长: int = 28:
	set(值):
		边长 = 值
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
	custom_minimum_size = Vector2(M3Theme.px(边长), M3Theme.px(边长))
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
	var 边长像素 := minf(size.x, size.y)
	if 边长像素 <= 0.0:
		return
	var 方 := Rect2(Vector2((size.x - 边长像素) * 0.5, (size.y - 边长像素) * 0.5), Vector2(边长像素, 边长像素))

	var sb := M3Theme.样式(M3Theme.surface.lerp(M3Theme.primary, _进度), int(边长像素 * 0.22))
	sb.set_border_width_all(maxi(1, int(round(2.0 * M3Theme.scale))))
	sb.border_color = M3Theme.outline.lerp(M3Theme.primary, _进度)
	if disabled:
		sb.bg_color.a = 0.4
	draw_style_box(sb, 方)

	if _进度 > 0.01:
		var 线宽 := maxi(1, int(round(2.5 * M3Theme.scale)))
		var p1 := 方.position + Vector2(边长像素 * 0.24, 边长像素 * 0.52)
		var p2 := 方.position + Vector2(边长像素 * 0.43, 边长像素 * 0.72)
		var p3 := 方.position + Vector2(边长像素 * 0.78, 边长像素 * 0.30)
		var 线色 := M3Theme.on_primary
		if disabled:
			线色.a = 0.6
		draw_line(p1, p1.lerp(p2, minf(_进度 * 2.0, 1.0)), 线色, 线宽, true)
		if _进度 > 0.5:
			draw_line(p2, p2.lerp(p3, (_进度 - 0.5) * 2.0), 线色, 线宽, true)
