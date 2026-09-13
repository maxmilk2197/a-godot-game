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
## 图标名（Material Design Icons 的名字，比如 "message" / "account" / "compass"）。
## 设了它就用字体字形画 —— **比 图标 贴图更好**：字形直接跟着前景色走，
## 不像贴图要靠 modulate 相乘（有色 SVG 乘深色前景会变黑）。
## 名字去哪查：编辑器菜单 工具 → Find Material Icon。
## 两个都设时以 图标名 为准；插件没装则自动退回用 图标。
@export var 图标名: String = "":
	set(值):
		图标名 = 值
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

## 官方的指示器变色过渡是 short2 = 100ms
const 过渡时长 := 0.12

var _按下中: bool = false
## 实际画出来的颜色（往目标色过渡，就是「点击对应的动画」）
var _实指示: Color = Color(0, 0, 0, 0)
var _实前景: Color = Color(0, 0, 0, 0)


func _ready() -> void:
	toggle_mode = true
	if not button_down.is_connected(_按下):
		button_down.connect(_按下)
	if not button_up.is_connected(_松开):
		button_up.connect(_松开)
	if not mouse_entered.is_connected(_进):
		mouse_entered.connect(_进)
	if not mouse_exited.is_connected(_出):
		mouse_exited.connect(_出)
	if not toggled.is_connected(_选中变了):
		toggled.connect(_选中变了)
	_实指示 = 指示器色()
	_实前景 = 前景色()
	_refresh()


func _按下() -> void:
	_按下中 = true
	_启动过渡()


func _松开() -> void:
	_按下中 = false
	_启动过渡()


func _进() -> void:
	_启动过渡()


func _出() -> void:
	_启动过渡()


func _选中变了(按下: bool) -> void:
	# 自己在编辑器里被点开时，也要把同一轨道里其它项目取消掉，
	# 否则一排放下来会好几个都亮着
	if 按下:
		_通知父级()
	_启动过渡()


## 告诉最近的 M3NavigationRail 把选中项切到自己
func _通知父级() -> void:
	var 上 := get_parent()
	while 上 != null:
		if 上 is M3NavigationRail:
			上.call("选中项目", self)
			return
		上 = 上.get_parent()


## 启动颜色过渡（每帧往目标色靠，到位就停）
func _启动过渡() -> void:
	if Engine.is_editor_hint() or not is_inside_tree():
		_实指示 = 指示器色()
		_实前景 = 前景色()
		queue_redraw()
		return
	set_process(true)


## 外部（比如轨道用 set_pressed_no_signal 改了选中）改了状态后要调一下这个，
## 否则缓存色不会更新 —— set_pressed_no_signal 不发信号，项目自己不知道。
func 刷新外观() -> void:
	_启动过渡()


## 实际画出来用的指示器色：
## 过渡中用它当前的插值，不在过渡就直接用目标色 ——
## 这样即使有人绕过信号改了状态，也不会留下「旧胶囊」。
func 当前指示色() -> Color:
	return _实指示 if is_processing() else 指示器色()


func 当前前景色() -> Color:
	return _实前景 if is_processing() else 前景色()


func _process(增量: float) -> void:
	var 目标 := 指示器色()
	var 目标前 := 前景色()
	var k := clampf(增量 / 过渡时长, 0.0, 1.0)
	_实指示 = _混色(_实指示, 目标, k)
	_实前景 = _混色(_实前景, 目标前, k)
	if _实指示.is_equal_approx(目标) and _实前景.is_equal_approx(目标前):
		_实指示 = 目标
		_实前景 = 目标前
		set_process(false)
	queue_redraw()


## 按「预乘 alpha」插值。
## 直接 Color.lerp 从 Color(0,0,0,0) 插到淡紫，RGB 会一路经过黑色 ——
## 表现就是淡入/淡出时中间闪一层深灰（点下一个时新旧两项都会闪）。
## 预乘之后色相保持不变，只有透明度在变。
func _混色(当前: Color, 目标: Color, k: float) -> Color:
	var a := lerpf(当前.a, 目标.a, k)
	if a <= 0.0001:
		return Color(目标.r, 目标.g, 目标.b, 0.0)
	var pr := lerpf(当前.r * 当前.a, 目标.r * 目标.a, k) / a
	var pg := lerpf(当前.g * 当前.a, 目标.g * 目标.a, k) / a
	var pb := lerpf(当前.b * 当前.a, 目标.b * 目标.a, k) / a
	return Color(pr, pg, pb, a)


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
	# 按下就等于「马上要选中」：直接按选中态算。
	# 否则 button_down 比 toggled 早，会先闪一层深灰再变淡紫 —— 官网上没这一下。
	var 当作选中 := 选中 or _按下中
	if 当作选中:
		if _按下中:
			return M3Theme.secondary_container.lerp(M3Theme.on_secondary_container, 0.12)
		if 悬停:
			return M3Theme.secondary_container.lerp(M3Theme.on_secondary_container, 0.08)
		return M3Theme.secondary_container
	# 未选中：只有悬停会给一层淡状态层（官网 Home 悬停时就是这种灰米色胶囊）
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

	# 没设图标就退化成「胶囊包文字」—— 否则选中时是个空胶囊，很难看
	if not _有图标():
		_画纯文字(字, 字号值, 指示宽, 指示高)
		return

	var 文高 := 0.0
	if 字 != null and not 文字.is_empty():
		文高 = 字.get_height(字号值)

	# 指示器 + 文字整体垂直居中
	var 总高 := 指示高 + (间距 + 文高 if 文高 > 0.0 else 0.0)
	var 顶 := (size.y - 总高) * 0.5
	var 指示中心 := Vector2(size.x * 0.5, 顶 + 指示高 * 0.5)

	# 指示器（胶囊）—— 悬停/按下/选中的底色都画在这一层
	draw_style_box(
		M3Theme.样式(当前指示色(), int(round(minf(指示宽, 指示高) * 0.5))),
		Rect2(指示中心 - Vector2(指示宽, 指示高) * 0.5, Vector2(指示宽, 指示高)))

	# 图标
	var 色 := 当前前景色()
	_画图标(指示中心, 图标边, 色)

	# 文字
	if 字 != null and not 文字.is_empty():
		var 文宽 := 字.get_string_size(文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值).x
		draw_string(字,
			Vector2(size.x * 0.5 - 文宽 * 0.5, 顶 + 指示高 + 间距 + 字.get_ascent(字号值)),
			文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值, 色)


## 有没有图标可用（图标名字形优先，其次贴图）
func _有图标() -> bool:
	if not 图标名.is_empty() and M3Icons.可用() and M3Icons.有(图标名):
		return true
	return 图标 != null


## 在 中心 画一个边长 边 的图标。
## 字形是 draw_string 画的，颜色直接传进去，不存在 modulate 相乘变黑的问题。
func _画图标(中心: Vector2, 边: float, 色: Color) -> void:
	if not 图标名.is_empty() and M3Icons.可用():
		var 字模 := M3Icons.字体()
		var 单 := M3Icons.取字符(图标名)
		if 字模 != null and not 单.is_empty():
			var 尺寸 := int(round(边))
			var 宽 := 字模.get_string_size(单, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 尺寸).x
			var 基线 := 中心.y + (字模.get_ascent(尺寸) - 字模.get_descent(尺寸)) * 0.5
			draw_string(字模, Vector2(中心.x - 宽 * 0.5, 基线),
				单, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 尺寸, 色)
			return
	if 图标 != null:
		draw_texture_rect(图标, Rect2(中心 - Vector2(边, 边) * 0.5, Vector2(边, 边)), false, 色)


## 没有图标时的样子：胶囊按文字宽度撑开，文字居中在胶囊里
func _画纯文字(字: Font, 字号值: int, 指示宽: float, 指示高: float) -> void:
	var 中心 := size * 0.5
	var 文宽 := 0.0
	if 字 != null and not 文字.is_empty():
		文宽 = 字.get_string_size(文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值).x
	var 胶囊宽 := maxf(指示宽, 文宽 + M3Theme.px(32.0))
	draw_style_box(
		M3Theme.样式(当前指示色(), int(round(minf(胶囊宽, 指示高) * 0.5))),
		Rect2(中心 - Vector2(胶囊宽, 指示高) * 0.5, Vector2(胶囊宽, 指示高)))
	if 字 == null or 文字.is_empty():
		return
	# 文字在胶囊里垂直居中
	var 基线 := 中心.y + (字.get_ascent(字号值) - 字.get_descent(字号值)) * 0.5
	draw_string(字, Vector2(中心.x - 文宽 * 0.5, 基线),
		文字, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 字号值, 当前前景色())
