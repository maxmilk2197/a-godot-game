@tool
@icon("res://addons/material_ui/icons/scroll_stretch.svg")
class_name M3ScrollStretch
extends Node
## ============================================================
## 给父级 ScrollContainer 加：
##   1) 鼠标 / 手指拖动滚动（像手机那样拖着滑）
##   2) Material 3 风格的过度滚动「拉伸」，松手后回弹
##
## 用法：作为 ScrollContainer 的直接子节点放进去即可。
## 拖动超过 拖动阈值 才算拖动（轻点仍然能点到里面的按钮）。
## ============================================================

## 最多拉长多少（占内容高度的比例）
@export var 最大拉伸: float = 0.08
## 每一格滚轮拉多少
@export var 滚轮力度: float = 0.012
## 拖动 → 拉伸的灵敏度：越小，要划得越长才有同样大的回弹（线性换算）
@export_range(0.05, 1.0, 0.05) var 拖动阻尼: float = 0.4
## 拖动多少像素才算「拖动」（低于它算点击）
@export var 拖动阈值: float = 6.0
## 滚轮停止后多久才回弹（拖动是松手立刻回弹）
@export var 释放延迟: float = 0.06
## 回弹时长
@export var 回弹时长: float = 0.35

var _滚动: ScrollContainer
var _内容: Control
var _拉伸: float = 0.0
var _回弹起: float = 0.0
var _底部: bool = false
var _补间: Tween
var _释放计时: float = 0.0
var _等待释放: bool = false
var _按下中: bool = false
var _已拖动: bool = false
var _起手: Vector2 = Vector2.ZERO


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_滚动 = get_parent() as ScrollContainer
	if _滚动 == null:
		push_warning("M3ScrollStretch 需要放在 ScrollContainer 下面")
		return
	if _滚动.get_child_count() > 0:
		_内容 = _滚动.get_child(0) as Control
	set_process(false)


func _process(增量: float) -> void:
	if not _等待释放:
		set_process(false)
		return
	_释放计时 -= 增量
	if _释放计时 <= 0.0:
		_等待释放 = false
		set_process(false)
		_回弹()


# 用 _input + 位置判断：即使 ScrollContainer 会吃掉拖拽事件也能收到（触摸必需）
func _input(事件: InputEvent) -> void:
	if _内容 == null or _滚动 == null or not _滚动.is_visible_in_tree():
		return

	if 事件 is InputEventMouseButton:
		var 鼠标 := 事件 as InputEventMouseButton
		if 鼠标.button_index == MOUSE_BUTTON_LEFT:
			if 鼠标.pressed:
				_开始按下(鼠标.global_position)
			else:
				_结束按下()
			return
		if not 鼠标.pressed:
			return
		if not _滚动.get_global_rect().has_point(鼠标.global_position):
			return
		if 鼠标.button_index == MOUSE_BUTTON_WHEEL_UP and _滚动.scroll_vertical <= 0:
			_滚轮拉伸(滚轮力度, false)
		elif 鼠标.button_index == MOUSE_BUTTON_WHEEL_DOWN and _到底():
			_滚轮拉伸(滚轮力度, true)
		return

	if 事件 is InputEventScreenTouch:
		var 触摸 := 事件 as InputEventScreenTouch
		if 触摸.pressed:
			_开始按下(触摸.position)
		else:
			_结束按下()
		return

	if 事件 is InputEventScreenDrag:
		var 拖动 := 事件 as InputEventScreenDrag
		_拖动(拖动.position, 拖动.relative)
		return

	if 事件 is InputEventMouseMotion:
		var 移动 := 事件 as InputEventMouseMotion
		if 移动.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_拖动(移动.global_position, 移动.relative)


func _开始按下(位置: Vector2) -> void:
	if not _滚动.get_global_rect().has_point(位置):
		return
	_按下中 = true
	_已拖动 = false
	_起手 = 位置


func _结束按下() -> void:
	var 拖过 := _已拖动
	_按下中 = false
	_已拖动 = false
	if 拖过:
		get_viewport().set_input_as_handled()
	if _拉伸 > 0.0:
		_回弹()


func _拖动(位置: Vector2, 相对: Vector2) -> void:
	if not _按下中:
		return
	if not _已拖动:
		if absf((位置 - _起手).y) < 拖动阈值:
			return
		_已拖动 = true
	var 增量 := 相对.y
	if absf(增量) < 0.01:
		return
	_滚动拖动(增量)
	get_viewport().set_input_as_handled()


func _滚动拖动(增量: float) -> void:
	var 条 := _滚动.get_v_scroll_bar()
	var 最大 := int(条.max_value - 条.page)
	var 内容高 := maxf(1.0, _内容.size.y)
	# 像素 → 拉伸比例的线性换算（拖动阻尼越小，同样拉伸需要划得越长）
	var 比例 := 拖动阻尼 / 内容高

	# 已有拉伸时：反向拖动先把拉伸收回去
	if _拉伸 > 0.0:
		var 同向 := (增量 > 0.0 and not _底部) or (增量 < 0.0 and _底部)
		if 同向:
			_拉伸 = clampf(_拉伸 + absf(增量) * 比例, 0.0, 最大拉伸)
			增量 = 0.0
		else:
			var 可收 := _拉伸 / 比例
			var 用掉 := minf(absf(增量), 可收)
			_拉伸 = maxf(0.0, _拉伸 - 用掉 * 比例)
			增量 -= signf(增量) * 用掉

	if absf(增量) > 0.01:
		var 目标 := _滚动.scroll_vertical - int(增量)
		if 目标 < 0:
			_滚动.scroll_vertical = 0
			_底部 = false
			_拉伸 = clampf(_拉伸 + float(-目标) * 比例, 0.0, 最大拉伸)
		elif 目标 > 最大:
			_滚动.scroll_vertical = 最大
			_底部 = true
			_拉伸 = clampf(_拉伸 + float(目标 - 最大) * 比例, 0.0, 最大拉伸)
		else:
			_滚动.scroll_vertical = 目标

	_应用()


func _到底() -> bool:
	if _滚动 == null:
		return false
	var 条 := _滚动.get_v_scroll_bar()
	var 最大 := int(条.max_value - 条.page)
	return _滚动.scroll_vertical >= 最大


func _滚轮拉伸(量: float, 底部: bool) -> void:
	_底部 = 底部
	_拉伸 = clampf(_拉伸 + 量, 0.0, 最大拉伸)
	_应用()
	_释放计时 = 释放延迟
	_等待释放 = true
	set_process(true)


func _回弹() -> void:
	if _补间 != null and _补间.is_valid():
		_补间.kill()
	_回弹起 = _拉伸
	_补间 = create_tween()
	# M3 Expressive 弹簧曲线：收得快、尾巴轻轻停住，不会像 BACK 那样甩过头
	_补间.tween_method(_设回弹, 0.0, 1.0, 回弹时长)


func _设回弹(t: float) -> void:
	_设置拉伸(lerpf(_回弹起, 0.0, M3Motion.弹簧_快(t)))


func _设置拉伸(值: float) -> void:
	_拉伸 = 值
	_应用()


func _应用() -> void:
	if _内容 == null:
		return
	var 原点y := _内容.size.y if _底部 else 0.0
	_内容.pivot_offset = Vector2(_内容.size.x * 0.5, 原点y)
	_内容.scale = Vector2(1.0, 1.0 + _拉伸)
