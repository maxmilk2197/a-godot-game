@tool
@icon("res://addons/material_ui/icons/ripple.svg")
class_name M3Ripple
extends Control
## ============================================================
## 涟漪（径向反馈）效果。
## 参数照 mdui 2 的 ripple 来：
##   从 scale(0.4) 长到 1 —— standard 缓动
##   不透明度 0 → 峰值 —— 75ms、线性
##   松开后再淡出 —— 150ms、线性
##
## 两种生长速度：
##   按住不放用 长按时长（慢），长按过程才看得清扩散；
##   松开时按 扩散时长 这个「原来的速度」把剩下的补完（并夹在 0.04~0.10s 内），
##   所以轻点还是很快、长按则慢悠悠地铺开。
##
## 四个时长留 -1 就是「跟随全局」——全局值在 M3Theme 里（涟漪长按时长 等），
## 编辑器里也能在 项目设置 → m3/ripple 改。设成 0 或正数则本实例单独覆盖。
## ============================================================

## 松开补完时的速度基准 —— 也就是「原来的速度」（mdui: 225ms）；-1 = 跟随全局
@export var 扩散时长: float = -1.0
## 按住不放时的生长时长 —— 比 扩散时长 慢；-1 = 跟随全局
@export var 长按时长: float = -1.0
## 不透明度淡入时长（mdui: 75ms）；-1 = 跟随全局
@export var 淡入时长: float = -1.0
## 淡出时长（mdui: 150ms）；-1 = 跟随全局
@export var 淡出时长: float = -1.0
## 起始半径比例（mdui 的 scale(.4)）
@export_range(0.0, 1.0, 0.05) var 起始比例: float = 0.4
## 松开补完用时的下限 / 上限（秒）
const 松开最快 := 0.04
const 松开最慢 := 0.10


# ---------------- 生效值（-1 就走全局） ----------------
func 生效扩散时长() -> float:
	return 扩散时长 if 扩散时长 >= 0.0 else M3Theme.涟漪扩散时长


func 生效长按时长() -> float:
	return 长按时长 if 长按时长 >= 0.0 else M3Theme.涟漪长按时长


func 生效淡入时长() -> float:
	return 淡入时长 if 淡入时长 >= 0.0 else M3Theme.涟漪淡入时长


func 生效淡出时长() -> float:
	return 淡出时长 if 淡出时长 >= 0.0 else M3Theme.涟漪淡出时长


var _中心: Vector2 = Vector2.ZERO
var _半径: float = 0.0
var _进度: float = 0.0
var _不透明度: float = 0.0
var _峰值: float = 0.0
var _颜色: Color = Color(0, 0, 0, 0.12)
var _活动中: bool = false
var _生长补间: Tween
var _淡出补间: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## 按下：从该点扩散并保持
func 按下(位置: Vector2, 颜色: Color = Color(0, 0, 0, 0.12)) -> void:
	if Engine.is_editor_hint():
		return
	if _生长补间 != null and _生长补间.is_valid():
		_生长补间.kill()
	if _淡出补间 != null and _淡出补间.is_valid():
		_淡出补间.kill()
	_中心 = 位置
	_颜色 = 颜色
	_峰值 = 颜色.a
	_不透明度 = 0.0
	_半径 = _到最远角(位置)
	_进度 = 0.0
	_活动中 = true
	queue_redraw()
	# 生长 + 淡入 并行（生长用长按时长，慢一点才看得出扩散过程）
	_生长补间 = create_tween()
	_生长补间.set_parallel(true)
	_生长补间.tween_method(_设生长, 0.0, 1.0, 生效长按时长())
	_生长补间.tween_method(_设不透明度, 0.0, _峰值, 生效淡入时长())


## 松开：把剩下的按「原来的速度」补完，再淡出
## —— 所以轻点整体很快；长按到一半松手，剩下的一段仍是原来的快速度
func 松开() -> void:
	if not _活动中:
		return
	if _淡出补间 != null and _淡出补间.is_valid():
		_淡出补间.kill()
	if _生长补间 != null and _生长补间.is_valid():
		_生长补间.kill()
	var 剩余 := 1.0 - clampf(_进度, 0.0, 1.0)
	_淡出补间 = create_tween()
	if 剩余 > 0.01:
		var 收敛 := clampf(生效扩散时长() * 剩余, 松开最快, 松开最慢)
		_淡出补间.tween_method(_设进度, _进度, 1.0, 收敛)
	_淡出补间.tween_method(_设不透明度, _不透明度, 0.0, 生效淡出时长())
	_淡出补间.tween_callback(_结束)


## 兼容旧调用：按下后自动松开
func 播放(位置: Vector2, 颜色: Color = Color(0, 0, 0, 0.12)) -> void:
	按下(位置, 颜色)
	var 定时 := get_tree().create_timer(0.12)
	定时.timeout.connect(松开)


func _到最远角(位置: Vector2) -> float:
	var 最远 := 0.0
	最远 = maxf(最远, 位置.distance_to(Vector2.ZERO))
	最远 = maxf(最远, 位置.distance_to(Vector2(size.x, 0.0)))
	最远 = maxf(最远, 位置.distance_to(Vector2(0.0, size.y)))
	最远 = maxf(最远, 位置.distance_to(size))
	return maxf(最远, 1.0)


## 生长用：把线性时间 t 套上 standard 缓动
func _设生长(t: float) -> void:
	_进度 = M3Motion.标准(t)
	queue_redraw()


## 补完用：直接设进度
func _设进度(值: float) -> void:
	_进度 = 值
	queue_redraw()


func _设不透明度(值: float) -> void:
	_不透明度 = 值
	queue_redraw()


func _结束() -> void:
	_活动中 = false
	_进度 = 0.0
	_不透明度 = 0.0
	queue_redraw()


func _draw() -> void:
	if not _活动中:
		return
	var 当前半径 := _半径 * lerpf(起始比例, 1.0, _进度)
	if 当前半径 <= 0.0:
		return
	var 绘制色 := _颜色
	绘制色.a = _不透明度
	draw_circle(_中心, 当前半径, 绘制色, true, -1.0, true)
