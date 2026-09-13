@tool
@icon("res://addons/material_ui/icons/ripple.svg")
class_name M3Ripple
extends Control
## ============================================================
## 涟漪（径向按压反馈）。参数照 **Material Web**（Google 官方 Web 组件库）
## 的 ripple 实现来，不再是 mdui 那套近似。
##
##   PRESS_GROW_MS             450ms   生长时长，standard 缓动
##   MINIMUM_PRESS_MS          225ms   按住不足这么久，松手也要等满再淡出
##   INITIAL_ORIGIN_SCALE      0.2     起始直径 = max(宽,高) × 0.2
##   PADDING                   10px    最大半径 = 对角线 + 10
##   SOFT_EDGE_MINIMUM_SIZE    75px    软边宽度下限
##   SOFT_EDGE_CONTAINER_RATIO 0.35    软边宽度 = max(0.35 × max(宽,高), 75)
##
## 两个和 mdui 版最不一样的地方：
##   1. **从点击点一边长一边移到元素中心**（官方 keyframes 就是这样：
##      起点 translate(点击点) → 终点 translate(元素中心)）；
##   2. 涟漪是**径向渐变软边**（实心到半径 65%，再渐隐到边缘），不是硬边实心圆。
##      —— 这是「点下去像一块方块」的根因：硬边实心圆铺满后就是一整片。
##
## 不透明度：淡入 105ms linear → 峰值；淡出 375ms linear → 0。
##
## 四个时长留 -1 = 跟随全局（M3Theme 里的 涟漪扩散时长 等），
## 编辑器里也能在 项目设置 → m3/ripple 改。
## ============================================================

# ---------------- 官方常量 ----------------
const 生长时长_默认 := 0.45
const 淡入时长_默认 := 0.105
const 淡出时长_默认 := 0.375
const 最小按压_默认 := 0.225
const 起始比例_默认 := 0.2
const 软边最小 := 75.0
const 软边比例 := 0.35
const 外扩 := 10.0
## 实心部分占半径的比例（剩下的做渐隐软边）
const 实心比例 := 0.65

## 生长时长（-1 = 跟随全局）
@export var 扩散时长: float = -1.0
## 不透明度淡入时长（-1 = 跟随全局）
@export var 淡入时长: float = -1.0
## 松开后的淡出时长（-1 = 跟随全局）
@export var 淡出时长: float = -1.0
## 最短按压时间（-1 = 跟随全局）
@export var 最小按压: float = -1.0
## 起始直径占 max(宽,高) 的比例（官方 INITIAL_ORIGIN_SCALE = 0.2）
@export_range(0.01, 1.0, 0.01) var 起始比例: float = 起始比例_默认

var _中心起: Vector2 = Vector2.ZERO
var _中心终: Vector2 = Vector2.ZERO
var _半径起: float = 0.0
var _半径终: float = 0.0
var _进度: float = 0.0
var _不透明度: float = 0.0
var _峰值: float = 0.0
var _颜色: Color = Color(0, 0, 0, 0.12)
var _活动中: bool = false
var _按下毫秒: int = 0
## 每按一次 +1；松手那边的等待靠它判断「这期间有没有又按了一次」
var _代次: int = 0
var _生长补间: Tween
var _透明补间: Tween
## 径向渐变纹理（就是官方的 radial-gradient）：实心到 65% 再渐隐到边缘
var _纹理: GradientTexture2D
var _纹色: Color = Color(0, 0, 0, 0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


# ---------------- 生效值（-1 就走全局） ----------------

func 生效扩散时长() -> float:
	return 扩散时长 if 扩散时长 >= 0.0 else M3Theme.涟漪扩散时长


func 生效淡入时长() -> float:
	return 淡入时长 if 淡入时长 >= 0.0 else M3Theme.涟漪淡入时长


func 生效淡出时长() -> float:
	return 淡出时长 if 淡出时长 >= 0.0 else M3Theme.涟漪淡出时长


func 生效最小按压() -> float:
	return 最小按压 if 最小按压 >= 0.0 else M3Theme.涟漪最小按压


# ---------------- 播放 ----------------

## 按下：从该点扩散，一边长一边移向控件中心
func 按下(位置: Vector2, 颜色: Color = Color(0, 0, 0, 0.12)) -> void:
	if Engine.is_editor_hint():
		return
	_代次 += 1
	if _生长补间 != null and _生长补间.is_valid():
		_生长补间.kill()
	if _透明补间 != null and _透明补间.is_valid():
		_透明补间.kill()

	_颜色 = 颜色
	_峰值 = 颜色.a
	_不透明度 = 0.0
	_进度 = 0.0
	_活动中 = true
	_按下毫秒 = Time.get_ticks_msec()
	_建纹理()

	# 几何：照官方 determineRippleSize()
	_中心起 = 位置
	_中心终 = size * 0.5
	var 最大边 := maxf(size.x, size.y)
	var 起始直径 := maxf(1.0, 最大边 * 起始比例)
	var 软边 := maxf(软边比例 * 最大边, M3Theme.px(软边最小))
	var 对角线 := sqrt(size.x * size.x + size.y * size.y)
	var 最大半径 := 对角线 + M3Theme.px(外扩)
	_半径起 = 起始直径 * 0.5
	_半径终 = _半径起 * ((最大半径 + 软边) / 起始直径)
	# 官方公式在又大又扁的按钮上盖不满四角：软边从 65% 半径就开始渐隐，
	# 而四角在对角线的一半处，正好落在渐隐区里 —— 我们的涟漪比官方强得多，
	# 四角就会看出一圈「缺角」。所以再兜一层：保证实心部分至少够到对角线。
	_半径终 = maxf(_半径终, 对角线 * 0.5 / 实心比例 * 1.02)

	# 生长只动位置和大小（官方 keyframes 就是这样拆的），透明度单独一条
	_生长补间 = create_tween()
	_生长补间.tween_method(_设生长, 0.0, 1.0, 生效扩散时长())
	_透明补间 = create_tween()
	_透明补间.tween_method(_设不透明度, 0.0, _峰值, 生效淡入时长())
	queue_redraw()


## 松开：按官方 endPressAnimation —— 已经按够 225ms 就立刻淡出，
## 否则等满 225ms 再淡出（等待期间生长照跑，不受影响）
func 松开() -> void:
	if not _活动中:
		return
	var 已按秒 := float(Time.get_ticks_msec() - _按下毫秒) / 1000.0
	var 需等 := 生效最小按压() - 已按秒
	var 代 := _代次
	if 需等 > 0.0:
		await get_tree().create_timer(需等).timeout
		if 代 != _代次 or not is_instance_valid(self):
			return
	_淡出()


func _淡出() -> void:
	if not _活动中:
		return
	if _透明补间 != null and _透明补间.is_valid():
		_透明补间.kill()
	_透明补间 = create_tween()
	_透明补间.tween_method(_设不透明度, _不透明度, 0.0, 生效淡出时长())
	_透明补间.tween_callback(_结束)


## 兼容旧调用：按下后自动松开
func 播放(位置: Vector2, 颜色: Color = Color(0, 0, 0, 0.12)) -> void:
	按下(位置, 颜色)
	var 定时 := get_tree().create_timer(生效最小按压())
	定时.timeout.connect(松开)


# ---------------- 动画驱动 ----------------

## 生长用 standard 缓动（官方 EASING.STANDARD）
func _设生长(t: float) -> void:
	_进度 = M3Motion.标准(t)
	queue_redraw()


func _设不透明度(值: float) -> void:
	_不透明度 = clampf(值, 0.0, 1.0)
	queue_redraw()


func _结束() -> void:
	_活动中 = false
	_进度 = 0.0
	_不透明度 = 0.0
	queue_redraw()


# ---------------- 绘制 ----------------

func _draw() -> void:
	if not _活动中 or _不透明度 <= 0.001 or _纹理 == null:
		return
	var 中心 := _中心起.lerp(_中心终, _进度)
	var 半径 := lerpf(_半径起, _半径终, _进度)
	if 半径 <= 0.5:
		return
	# 一张径向渐变贴图搞定：圆心实心、到 65% 半径开始渐隐、边缘全透
	draw_texture_rect(_纹理,
		Rect2(中心 - Vector2(半径, 半径), Vector2(半径 * 2.0, 半径 * 2.0)),
		false, Color(1, 1, 1, _不透明度))


## 按涟漪颜色造一张径向渐变贴图（等价官方的 radial-gradient）
func _建纹理() -> void:
	if _纹色.is_equal_approx(_颜色) and _纹理 != null:
		return
	var 实 := Color(_颜色.r, _颜色.g, _颜色.b, 1.0)
	var 透 := Color(_颜色.r, _颜色.g, _颜色.b, 0.0)
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 实心比例, 1.0])
	g.colors = PackedColorArray([实, 实, 透])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	_纹理 = t
	_纹色 = _颜色
