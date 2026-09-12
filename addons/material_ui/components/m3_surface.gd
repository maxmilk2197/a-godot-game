@tool
class_name M3Surface
extends Panel
## ============================================================
## Material 3 表面容器（背景条 / 底栏 / 卡片底等）。
## 底色取自 M3 主题令牌的「角色」，会跟着 M3Theme 变化，
## 不像场景里写死的颜色那样改主题后不跟。
## ============================================================

enum 表面角色 {
	SURFACE,
	SURFACE_CONTAINER_LOW,
	SURFACE_CONTAINER,
	SURFACE_CONTAINER_HIGH,
	SURFACE_VARIANT,
	PRIMARY,
	SECONDARY_CONTAINER,
	ERROR_CONTAINER,
}

@export var 角色: 表面角色 = 表面角色.SURFACE_CONTAINER_LOW:
	set(值):
		角色 = 值
		_刷新()
@export var 圆角: int = 24:
	set(值):
		圆角 = 值
		_刷新()
@export var 圆上: bool = true:
	set(值):
		圆上 = 值
		_刷新()
@export var 圆下: bool = true:
	set(值):
		圆下 = 值
		_刷新()


func _ready() -> void:
	_刷新()


## 当前角色对应的颜色
func 取色() -> Color:
	match 角色:
		表面角色.SURFACE:
			return M3Theme.surface
		表面角色.SURFACE_CONTAINER:
			return M3Theme.surface_container
		表面角色.SURFACE_CONTAINER_HIGH:
			return M3Theme.surface_container_high
		表面角色.SURFACE_VARIANT:
			return M3Theme.surface_variant
		表面角色.PRIMARY:
			return M3Theme.primary
		表面角色.SECONDARY_CONTAINER:
			return M3Theme.secondary_container
		表面角色.ERROR_CONTAINER:
			return M3Theme.error_container
	return M3Theme.surface_container_low


func _刷新() -> void:
	if not is_inside_tree():
		return
	var 半径 := int(round(圆角 * M3Theme.scale))
	var sb := M3Theme.样式(取色(), 半径)
	if not 圆上:
		sb.corner_radius_top_left = 0
		sb.corner_radius_top_right = 0
	if not 圆下:
		sb.corner_radius_bottom_left = 0
		sb.corner_radius_bottom_right = 0
	add_theme_stylebox_override("panel", sb)
