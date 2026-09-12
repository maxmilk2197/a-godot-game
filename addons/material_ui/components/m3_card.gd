@tool
class_name M3Card
extends PanelContainer
## ============================================================
## Material 3 卡片容器。把内容放进去即可，圆角/底色/海拔自动套用。
## ============================================================

enum 卡片类型 { ELEVATED, FILLED, OUTLINED }

@export var 类型: 卡片类型 = 卡片类型.ELEVATED:
	set(值):
		类型 = 值
		_刷新样式()
@export var 圆角: int = 16:
	set(值):
		圆角 = 值
		_刷新样式()
@export var 海拔: int = 1:
	set(值):
		海拔 = 值
		_刷新样式()
@export var 内边距: int = 16:
	set(值):
		内边距 = 值
		_刷新样式()


func _ready() -> void:
	_刷新样式()


func _刷新样式() -> void:
	if not is_inside_tree():
		return
	var 圆角值 := int(round(圆角 * M3Theme.scale))
	var sb: StyleBoxFlat
	match 类型:
		卡片类型.FILLED:
			sb = M3Theme.样式(M3Theme.surface_container, 圆角值)
		卡片类型.OUTLINED:
			sb = M3Theme.描边样式(M3Theme.outline_variant, 圆角值)
		_:
			sb = M3Theme.海拔样式(M3Theme.surface_container_low, 圆角值, 海拔)

	sb.content_margin_left = M3Theme.px(内边距)
	sb.content_margin_right = M3Theme.px(内边距)
	sb.content_margin_top = M3Theme.px(内边距)
	sb.content_margin_bottom = M3Theme.px(内边距)
	add_theme_stylebox_override("panel", sb)
