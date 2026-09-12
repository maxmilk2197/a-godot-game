@tool
@icon("res://addons/material_ui/icons/navigation_rail.svg")
class_name M3NavigationRailItem
extends BaseButton
## ============================================================
## Material 3 侧边导航轨道里的「一个项目」。
##
## 外观照官方规格（m3.material.io/components/navigation-rail/specs）：
##   指示器    56×32dp 胶囊（CornerFull）；选中 secondary_container，未选透明
##   图标      24dp，居中在指示器里；未选 on_surface_variant / 选中 on_secondary_container
##   文字      label-medium，居中在指示器下方，与指示器间距 8dp
##   项目      最小 48×64dp
##   悬停      on_secondary_container @8%（按下 @10%）；选中项悬停是两者混合
##
## 想自己摆项目就直接把这个节点加进 M3NavigationRail（并把轨道的
## 「手动项目」打开），或者单独当普通开关按钮用。
## ============================================================

## 图标（留空就只有文字）
@export var 图标: Texture2D = null:
	set(值):
		图标 = 值
		queue_redraw()
## 显示文字
@export var 文字: String = "项目":
	set(值):
		文字 = 值
		queue_redraw()
## 字号（官方是 label-medium 12sp；这个项目画布是 1920，所以默认给大一点）
@export var 字号: int = 18:
	set(值):
		字号 = maxi(1, 值)
		queue_redraw()
## 指示器宽 / 高
@export var 指示器宽: int = 56:
	set(值):
		指示器宽 = maxi(1, 值)
		_refresh()
@export var 指示器高: int = 32:
	set(值):
		指示器高 = maxi(1, 值)
		_refresh()
## 图标边长
@export var 图标大小: int = 24:
	set(值):
		图标大小 = maxi(1, 值)
		_refresh()
## 指示器与文字的间距
@export var 图文间距: int = 8:
	set(值):
		图文间距 = maxi(0, 值)
		_refresh()
## 项目最小尺寸
@export var 项目最小尺寸: Vector2i = Vector2i(48, 64):
	set(值):
		项目最小尺寸 = 值
		_refresh()

## 关掉「悬停也高亮」的自动反馈也照样能用
var _按下中: bool = false


func _ready() -> void:
	toggle_mode = true
	if not button_down.is_connected(_按下):
		button_down.connect(_按下)
	if not button_up.is_connected(_松开):
		button_up.connect(_松开)
	if not mouse_entered.is_connected(queue_redraw):
		mouse_entered.connect(queue_redraw)
	if not mouse_exited.is_connected(queue_redraw):
		mouse_exited.connect(queue_redraw)
	if not toggled.is_connected(_选中变了):
		toggled.connect(_选中变了)
	_refresh()


func _按下() -> void:
	_按下中 = true
	queue_redraw()


func _松开() -> void:
	_按下中 = false
	queue_redraw()


func _选中变了(_按下: bool) -> void:
	queue_redraw()


func _refresh() -> void:
	custom_minimum_size = Vector2(
		M3Theme.px(float(项目最小尺寸.x)), M3Theme.px(float(项目最小尺寸.y)))
	queue_redraw()


# ---------------- 取值 ----------------

## 这个项目是不是当前选中项
func 已选中() -> bool:
	return button_pressed


func 指示器色() -> Color:
	var 选中 := 已选中()
	var 悬停 := is_hovered()
	if 选中:
		if 悬停 and _按下中:
			return M3Theme.secondary_container.lerp(M3Theme.on_secondary_container, 0.10)
		if 悬停:
			return M3Theme.secondary_container.lerp(M3Theme.on_secondary_container, 0.08)
		return M3Theme.secondary_container
	if _按下中:
		var c := M3Theme.on_secondary_container
		c.a = 0.10
		return c
	if 悬停:
		var c2 := M3Theme.on_secondary_container
		c2.a = 0.08
		return c2
	return Color(0, 0, 0, 0)


func 前景色() -> Color:
	if 已选中():
		return M3Theme.on_secondary_container
	return M3Theme.on_surface_variant


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var 指示宽 := M3Theme.px(float(指示器宽))
	var 指示高 := M3Theme.px(float(指示器高))
	var 图标边 := M3Theme.px(float(图标大小))
	var 间距 := M3Theme.px(float(图文间距))
	var 字号值 := M3Theme.fs(字号)
	var 字 := get_theme_font("font")
	var 文高 := 0.0
	if 字 != null and not 文字.is_empty():
		文高 = 字.get_height(字号值)

	# 指示器 + 文字整体垂直居中
	var 总高 := 指示高 + (间距 + 文高 if 文高 > 0.0 else 0.0)
	var 顶 := (size.y - 总高) * 0.5
	var 指示中心 := Vector2(size.x * 0.5, 顶 + 指示高 * 0.5)

	# 指示器（胶囊）—— 悬停/按下/选中的底色都画在这一层
	draw_style_box(
		M3Theme.样式(指示器色(), int(round(minf(指示宽, 指示高) * 0.5))),
		Rect2(指示中心 - Vector2(指示宽, 指示高) * 0.5, Vector2(指示宽, 指示高)))

	# 图标
	if 图标 != null:
		var 色 := 前景色()
		draw_texture_rect(图标,
			Rect2(指示中心 - Vector2(图标边, 图标边) * 0.5, Vector2(图标边, 图标边)),
			false, 色)

	# 文字
	if 字 != null and not 文字.is_empty():
		var 文宽 := 字.get_string_size(文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值).x
		draw_string(字,
			Vector2(size.x * 0.5 - 文宽 * 0.5, 顶 + 指示高 + 间距 + 字.get_ascent(字号值)),
			文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值, 前景色())
