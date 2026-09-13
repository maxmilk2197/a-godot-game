@tool
class_name M3Theme
extends RefCounted
## ============================================================
## Material Design 3 主题令牌与样式工具（GDScript 版）。
## 纯静态，不需要 autoload：直接 M3Theme.primary 这样用。
##
## 默认是浅色 + 蓝色种子（与项目现有配色一致）。
## 想换主题色：改这里的令牌，或调用 M3Theme.应用种子(颜色)。
##
## ⚠️ 必须带 @tool：不带的话 Godot 在编辑器里不会执行本脚本的 static var
## 初始化，所有令牌都是零值（primary 变黑色、scale 变 0），
## 于是编辑器里的 M3 组件全部不渲染 / 渲染成黑块。
## ============================================================

# ---------------- 颜色令牌（浅色） ----------------
static var primary: Color = Color(0, 0.349, 0.78)
static var on_primary: Color = Color(1, 1, 1)
static var primary_container: Color = Color(0.851, 0.886, 1)
static var on_primary_container: Color = Color(0, 0.102, 0.263)

static var secondary: Color = Color(0.341, 0.369, 0.443)
static var on_secondary: Color = Color(1, 1, 1)
static var secondary_container: Color = Color(0.859, 0.886, 0.976)
static var on_secondary_container: Color = Color(0.078, 0.106, 0.173)

static var tertiary: Color = Color(0.447, 0.333, 0.451)
static var on_tertiary: Color = Color(1, 1, 1)
static var tertiary_container: Color = Color(0.988, 0.843, 0.984)
static var on_tertiary_container: Color = Color(0.165, 0.075, 0.176)

static var error: Color = Color(0.729, 0.102, 0.102)
static var on_error: Color = Color(1, 1, 1)
static var error_container: Color = Color(1, 0.855, 0.839)
static var on_error_container: Color = Color(0.255, 0, 0.008)

static var surface: Color = Color(0.996, 0.984, 1)
static var on_surface: Color = Color(0.106, 0.106, 0.122)
static var surface_variant: Color = Color(0.882, 0.886, 0.925)
static var on_surface_variant: Color = Color(0.267, 0.275, 0.31)

static var surface_container_lowest: Color = Color(1, 1, 1)
static var surface_container_low: Color = Color(0.949, 0.953, 0.988)
static var surface_container: Color = Color(0.918, 0.933, 0.984)
static var surface_container_high: Color = Color(0.886, 0.914, 0.976)
static var surface_container_highest: Color = Color(0.882, 0.884, 0.937)

## 变暗 / 变亮的表面（大面积遮罩、抬升层用）
static var surface_dim: Color = Color(0.849, 0.851, 0.903)
static var surface_bright: Color = Color(0.975, 0.976, 1)
## 表面染色（MD3 里 = primary），用于海拔着色
static var surface_tint: Color = Color(0, 0.349, 0.78)

## 反色组：给 Snackbar / Tooltip 这类「反色浮层」用
static var inverse_surface: Color = Color(0.184, 0.187, 0.227)
static var inverse_on_surface: Color = Color(0.938, 0.94, 0.993)
static var inverse_primary: Color = Color(0.741, 0.764, 0.981)

## background / on_background 在 MD3 里与 surface 同值，保留是为了对齐规范命名
static var background: Color = Color(0.996, 0.984, 1)
static var on_background: Color = Color(0.106, 0.106, 0.122)

static var outline: Color = Color(0.459, 0.467, 0.502)
static var outline_variant: Color = Color(0.773, 0.776, 0.816)
static var shadow: Color = Color(0, 0, 0)
## 遮罩（dialog / drawer 统一用 rgba(scrim, 0.4)）
static var scrim: Color = Color(0, 0, 0)

## 全局尺寸缩放（想让整套组件整体放大/缩小时改这个）
static var scale: float = 1.0

## 默认字体大小（组件会在此基础上按 scale 缩放）
static var font_size: int = 16


# ---------------- 涟漪参数（全局默认，改这里就全局生效） ----------------
## 下面这几个就是「一个地方改、所有按钮都跟着变」的涟漪参数。
## 数值照 **Material Web** 官方 ripple（见 M3Ripple 的说明）。
## 在编辑器里也可以在 项目设置 → m3/ripple 里改（需要启用 material_ui 插件，
## 由 M3ThemeManager 单例在启动时读进来）。
##
## 按钮上还有一组同名导出属性：留 -1 表示跟随这里，设成 0 或正数则单独覆盖。
##
## 说明 涟漪不透明度：官方的 pressed-state-layer-opacity 是 0.12，但官方状态层颜色
## 是 on-primary / primary 这类深色（按变体取）。这里默认用浅色 secondary_container
## （dbe2f9），0.12 铺在浅底上几乎看不见，所以基准给 0.55；
## 组件那边再按变体压：填充 ×0.32 / 色调 ×0.22（见 M3Button.涟漪峰值）。
static var 涟漪不透明度: float = 0.55
## 涟漪 / 状态层的颜色。alpha 为 0 = 按按钮变体自动取（官方映射）；
## 设了颜色就全局都改用它 —— 想换掉官方那套色时用这个（一处分、全局生效）。
static var 涟漪颜色: Color = Color(0, 0, 0, 0)
## 生长时长（官方 PRESS_GROW_MS = 450ms）
static var 涟漪扩散时长: float = 0.45
## 不透明度淡入时长（官方 105ms）
static var 涟漪淡入时长: float = 0.105
## 松开后的淡出时长（官方 375ms）
static var 涟漪淡出时长: float = 0.375
## 最短按压时间（官方 MINIMUM_PRESS_MS = 225ms）：按住不足这么久，松手也要等满再淡出
static var 涟漪最小按压: float = 0.225


# ---------------- 尺寸 ----------------
## 按全局缩放换算像素
static func px(值: float) -> float:
	return 值 * scale


## 按全局缩放换算字号（至少 1）
static func fs(基准: int) -> int:
	return maxi(1, int(round(基准 * scale)))


# ---------------- 样式构造 ----------------
## 实心圆角样式
static func 样式(背景: Color, 圆角: int = 16) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = 背景
	sb.set_corner_radius_all(maxi(0, int(round(圆角 * scale))))
	return sb


## 描边样式（透明底 + 边框）
static func 描边样式(描边色: Color, 圆角: int = 16, 线宽: int = 1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.set_corner_radius_all(maxi(0, int(round(圆角 * scale))))
	sb.set_border_width_all(maxi(1, int(round(线宽 * scale))))
	sb.border_color = 描边色
	return sb


## 带阴影 / 海拔的圆角样式
static func 海拔样式(背景: Color, 圆角: int = 16, 海拔: int = 1) -> StyleBoxFlat:
	var sb := 样式(背景, 圆角)
	if 海拔 > 0:
		sb.shadow_color = Color(0, 0, 0, 0.14 + 0.04 * 海拔)
		sb.shadow_size = int(round(海拔 * 2 * scale))
		sb.shadow_offset = Vector2(0, round(海拔 * scale))
	return sb


## 状态层样式（悬停/按下时叠加的半透明色）
## 底色不透明时直接与叠加色混合；底色本身透明（描边/文字按钮）时不能混，
## 否则叠加色会被一起拉向黑色、变成灰罩，应该保留叠加色本身、只取它的透明度。
static func 状态层(底色: Color, 叠加色: Color, 圆角: int, 透明度: float) -> StyleBoxFlat:
	return 样式(状态层色(底色, 叠加色, 透明度), 圆角)


## 只算状态层的颜色（不生成样式box）。
## 需要「保留描边/阴影、只换底色」时用这个 —— 直接用 状态层() 会丢掉描边，
## 描边按钮一悬停边框就没了。
static func 状态层色(底色: Color, 叠加色: Color, 透明度: float) -> Color:
	if 底色.a <= 0.0:
		return Color(叠加色.r, 叠加色.g, 叠加色.b, 透明度)
	return 底色.lerp(叠加色, 透明度)


# ---------------- 主题色派生 ----------------
## 按一个种子色派生整套 MD3 令牌（用 CIELAB 色调板，见 M3Palette）
static func 应用种子(种子: Color) -> void:
	var 色相 := M3Palette.色相(种子)
	var 彩度 := M3Palette.彩度(种子)

	var 主彩 := clampf(彩度, 36.0, 72.0)
	var 次彩 := clampf(彩度 * 0.42, 16.0, 28.0)
	var 三彩 := clampf(彩度 * 0.62, 22.0, 40.0)
	var 三色相 := 色相 + PI / 3.0
	var 中彩 := 4.0
	var 中变彩 := 8.0
	var 错误色相 := M3Palette.色相(Color(0.729, 0.102, 0.102))

	primary = M3Palette.取色调(色相, 主彩, 40.0)
	on_primary = M3Palette.取色调(色相, 主彩, 100.0)
	primary_container = M3Palette.取色调(色相, 主彩, 90.0)
	on_primary_container = M3Palette.取色调(色相, 主彩, 10.0)

	secondary = M3Palette.取色调(色相, 次彩, 40.0)
	on_secondary = M3Palette.取色调(色相, 次彩, 100.0)
	secondary_container = M3Palette.取色调(色相, 次彩, 90.0)
	on_secondary_container = M3Palette.取色调(色相, 次彩, 10.0)

	tertiary = M3Palette.取色调(三色相, 三彩, 40.0)
	on_tertiary = M3Palette.取色调(三色相, 三彩, 100.0)
	tertiary_container = M3Palette.取色调(三色相, 三彩, 90.0)
	on_tertiary_container = M3Palette.取色调(三色相, 三彩, 10.0)

	error = M3Palette.取色调(错误色相, 84.0, 40.0)
	on_error = M3Palette.取色调(错误色相, 84.0, 100.0)
	error_container = M3Palette.取色调(错误色相, 84.0, 90.0)
	on_error_container = M3Palette.取色调(错误色相, 84.0, 10.0)

	surface = M3Palette.取色调(色相, 中彩, 98.0)
	on_surface = M3Palette.取色调(色相, 中彩, 10.0)
	surface_variant = M3Palette.取色调(色相, 中变彩, 90.0)
	on_surface_variant = M3Palette.取色调(色相, 中变彩, 30.0)
	surface_container_lowest = M3Palette.取色调(色相, 中彩, 100.0)
	surface_container_low = M3Palette.取色调(色相, 中彩, 96.0)
	surface_container = M3Palette.取色调(色相, 中彩, 94.0)
	surface_container_high = M3Palette.取色调(色相, 中彩, 92.0)
	surface_container_highest = M3Palette.取色调(色相, 中彩, 90.0)
	surface_dim = M3Palette.取色调(色相, 中彩, 87.0)
	surface_bright = M3Palette.取色调(色相, 中彩, 98.0)
	surface_tint = primary

	# 反色组：拿深色方案里的对应角色（浅色主题的「反色」= 深色表面）
	inverse_surface = M3Palette.取色调(色相, 中彩, 20.0)
	inverse_on_surface = M3Palette.取色调(色相, 中彩, 95.0)
	inverse_primary = M3Palette.取色调(色相, 主彩, 80.0)

	background = surface
	on_background = on_surface

	outline = M3Palette.取色调(色相, 中变彩, 50.0)
	outline_variant = M3Palette.取色调(色相, 中变彩, 80.0)
	shadow = Color(0, 0, 0)
	scrim = Color(0, 0, 0)
