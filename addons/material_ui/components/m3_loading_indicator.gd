@tool
@icon("res://addons/material_ui/icons/loading_indicator.svg")
class_name M3LoadingIndicator
extends Control
## ============================================================
## Material 3 Expressive 加载指示器（Loading Morph）。
##
## 一个形状在 7 个 MaterialShapes 之间「弹簧式」地变形，同时整体匀速自转，
## 每变一次形状额外多转 90°。参数对齐 AndroidX LoadingIndicator.kt：
##
##   容器 48dp / 全圆角、活动形状是容器的 0.66 倍
##   整体自转 4666ms 一圈（匀速）
##   每 650ms 换一个形状
##   换形状用弹簧：dampingRatio 0.6 / stiffness 200（欠阻尼，会过冲）
##
## 两种模式：
##   不定量：形状无限循环变形（默认）
##   定量  ：把 进度 设成 0~1，形状从「圆」补间到「软爆」
##
## 尺寸：图形按**控件的实际大小**画（取短边，保持正方形）。
## 尺寸 只是「默认 / 最小尺寸」—— 在编辑器里把节点拉大，图形会跟着放大。
## ============================================================

enum 显示变体 {
	独立,   ## 只有形状本身
	容器,   ## 形状外面加一个 primary_container 圆底
}

## 默认 / 最小尺寸；控件被拉大时图形按控件短边画
@export var 尺寸: int = 48:
	set(值):
		尺寸 = maxi(8, 值)
		_刷新()
## 独立 = 透明底；容器 = 圆底（Dialog / 按钮里用这种）
@export var 变体: 显示变体 = 显示变体.独立:
	set(值):
		变体 = 值
		_刷新()

## 形状颜色（alpha 为 0 时按变体自动取主题色）
@export var 颜色: Color = Color(0, 0, 0, 0):
	set(值):
		颜色 = 值
		_刷新()

## 容器底色（alpha 为 0 时取 primary_container；只有 变体=容器 时用得上）
@export var 容器色: Color = Color(0, 0, 0, 0):
	set(值):
		容器色 = 值
		_刷新()

## 整体自转一圈的时长
@export var 自转周期: float = 4.666:
	set(值):
		自转周期 = maxf(0.1, 值)

## 多久换一次形状
@export var 变形间隔: float = 0.65:
	set(值):
		变形间隔 = maxf(0.05, 值)

## 活动形状相对容器的比例
@export_range(0.1, 1.0, 0.01) var 活动比例: float = 0.66

## 运行时是否播放
@export var 运行中: bool = true:
	set(值):
		运行中 = 值
		_刷新()

## 在编辑器里也播放（方便直接看到效果；节点多了可以关掉省性能）
@export var 编辑器预览: bool = true:
	set(值):
		编辑器预览 = 值
		_刷新()

## 定量进度：0~1；小于 0 表示不定量（一直变形）
@export_range(-1.0, 1.0, 0.01) var 进度: float = -1.0:
	set(值):
		进度 = 值
		queue_redraw()

var _累计: float = 0.0
var _步计时: float = 0.0
var _索引: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 图形按控件大小画，所以大小一变就得重画
	if not resized.is_connected(queue_redraw):
		resized.connect(queue_redraw)
	_刷新()


func _刷新() -> void:
	var 边 := M3Theme.px(float(尺寸))
	custom_minimum_size = Vector2(边, 边)
	set_process(_该播放())
	queue_redraw()


## 图形用多大 —— 跟控件实际大小走（取短边保持正方形）。
## 控件还没布局好（短边为 0）时退回 尺寸。
func 图形边长() -> float:
	var 短边 := minf(size.x, size.y)
	if 短边 <= 0.0:
		return M3Theme.px(float(尺寸))
	return 短边


func _该播放() -> bool:
	if Engine.is_editor_hint():
		return 编辑器预览
	return 运行中


func 是否定量() -> bool:
	return 进度 >= 0.0


func _process(增量: float) -> void:
	if 是否定量():
		return
	_累计 += 增量
	_步计时 += 增量
	if _步计时 >= 变形间隔:
		_步计时 -= 变形间隔
		_索引 = (_索引 + 1) % M3MaterialShapes.不定量名称.size()
	queue_redraw()


# ---------------- 取值 ----------------

func 活动色() -> Color:
	if 颜色.a > 0.0:
		return 颜色
	if 变体 == 显示变体.容器:
		return M3Theme.on_primary_container
	return M3Theme.primary


func 底色() -> Color:
	if 容器色.a > 0.0:
		return 容器色
	return M3Theme.primary_container


## 当前这一帧的形状轮廓（已按弹簧进度插值）
func 当前形状() -> PackedVector2Array:
	if 是否定量():
		var p := clampf(进度, 0.0, 1.0)
		return M3MaterialShapes.插值(
			M3MaterialShapes.取(M3MaterialShapes.定量名称[0]),
			M3MaterialShapes.取(M3MaterialShapes.定量名称[1]), p)
	var 名表 := M3MaterialShapes.不定量名称
	var 甲 := M3MaterialShapes.取(名表[_索引])
	var 乙 := M3MaterialShapes.取(名表[(_索引 + 1) % 名表.size()])
	# 弹簧会过冲（略大于 1），这正是 M3 Expressive 的手感，所以不夹紧
	var 弹簧 := M3Motion.弹簧解(_步计时, M3Motion.变形_阻尼比, M3Motion.变形_刚度)
	return M3MaterialShapes.插值(甲, 乙, 弹簧)


## 当前这一帧的旋转角（弧度）
func 当前角度() -> float:
	if 是否定量():
		var p := clampf(进度, 0.0, 1.0)
		return p * TAU + p * PI * 0.5
	if 自转周期 <= 0.0:
		return 0.0
	var 全局 := fmod(_累计, 自转周期) / 自转周期 * TAU
	var 弹簧 := M3Motion.弹簧解(_步计时, M3Motion.变形_阻尼比, M3Motion.变形_刚度)
	return 全局 + float(_索引) * PI * 0.5 + 弹簧 * PI * 0.5


func _draw() -> void:
	var 边 := 图形边长()
	if 边 <= 0.0 or size.x <= 0.0 or size.y <= 0.0:
		return
	var 中心 := size * 0.5
	if 变体 == 显示变体.容器:
		draw_circle(中心, 边 * 0.5, 底色(), true, -1.0, true)

	var 轮廓 := 当前形状()
	if 轮廓.is_empty():
		return
	var 半径 := 边 * 0.5 * 活动比例
	var 角 := 当前角度()
	var 点 := PackedVector2Array()
	点.resize(轮廓.size())
	for i in range(轮廓.size()):
		点[i] = 中心 + (轮廓[i] * 半径).rotated(角)
	draw_colored_polygon(点, 活动色())
