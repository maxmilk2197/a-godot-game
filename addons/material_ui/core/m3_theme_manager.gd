extends Node
## ============================================================
## Material 3 主题管理单例（可选）。
## 启用插件时会被注册成 autoload（名字 M3ThemeManager）。
## 负责：把主题令牌应用到控件树、按视口做整体缩放。
##
## 注意：项目本身已经有 1920×1080 画布 + 窗口缩放，
## 所以「自动缩放」默认关闭，避免和引擎缩放叠加两次。
## ============================================================

## 是否按视口大小自动缩放整套 M3 组件
@export var 自动缩放: bool = false
## 手动缩放倍率（自动缩放关闭时生效）
@export var 手动缩放: float = 1.0


func _ready() -> void:
	M3Theme.scale = maxf(0.1, 手动缩放)
	if 自动缩放:
		_根据视口更新()
		var vp := get_viewport()
		if vp != null:
			vp.size_changed.connect(_根据视口更新)


## 换主题种子色
func 设置种子色(种子: Color) -> void:
	M3Theme.应用种子(种子)


## 手动设置整体缩放
func 设置缩放(倍率: float) -> void:
	手动缩放 = 倍率
	M3Theme.scale = maxf(0.1, 倍率)


func _根据视口更新() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var 可视 := vp.get_visible_rect().size
	if 可视.x <= 0.0 or 可视.y <= 0.0:
		return
	# 以 1920×1080 设计分辨率为基准
	var s := minf(可视.x / 1920.0, 可视.y / 1080.0)
	M3Theme.scale = clampf(s, 0.5, 3.0)
