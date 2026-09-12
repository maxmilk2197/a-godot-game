@tool
class_name M3Ripple
extends Control
## ============================================================
## Material 3 涟漪效果。
## 用法：把它作为某个可点击控件的子节点（铺满），
## 然后在按下时调用 播放(局部坐标, 颜色)。
## ============================================================

var _中心: Vector2 = Vector2.ZERO
var _半径: float = 0.0
var _进度: float = 0.0
var _颜色: Color = Color(1, 1, 1, 0.24)
var _活动中: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## 在局部坐标处播放一次涟漪
func 播放(位置: Vector2, 颜色: Color = Color(1, 1, 1, 0.24)) -> void:
	if Engine.is_editor_hint():
		return
	_中心 = 位置
	_颜色 = 颜色
	_半径 = maxf(size.x, size.y)
	_进度 = 0.0
	_活动中 = true
	queue_redraw()
	var 补间 := create_tween()
	补间.tween_method(_设置进度, 0.0, 1.0, 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	补间.tween_callback(_结束)


func _设置进度(值: float) -> void:
	_进度 = 值
	queue_redraw()


func _结束() -> void:
	_活动中 = false
	queue_redraw()


func _draw() -> void:
	if not _活动中:
		return
	var 当前半径 := _半径 * _进度
	var 绘制色 := _颜色
	绘制色.a = _颜色.a * (1.0 - _进度)
	if 当前半径 > 0.0:
		draw_circle(_中心, 当前半径, 绘制色)
