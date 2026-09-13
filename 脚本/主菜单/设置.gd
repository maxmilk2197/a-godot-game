extends Control
## ============================================================
## 设置弹层脚本。对应场景：res://场景/主菜单/设置.tscn
## 以“叠加弹层”方式盖在当前主界面上（不切场景、不销毁主界面，音乐不断）。
## 打开子页：把子页弹层叠加到当前场景顶层，自己不关（可返回）。
## 返回：queue_free 关闭自己，露出下层。
## ============================================================

@onready var 音乐滑块: HSlider = $"音量区/音乐行/音量滑块"
@onready var 音效滑块: HSlider = $"音量区/音效行/音量滑块"
@onready var 小按钮: Button = $"屏幕设置区/大小行/小"
@onready var 中按钮: Button = $"屏幕设置区/大小行/中"
@onready var 大按钮: Button = $"屏幕设置区/大小行/大"
@onready var 超大按钮: Button = $"屏幕设置区/大小行/超大"
@onready var 全屏开关: Button = $"屏幕设置区/全屏行/全屏开关"


func _ready() -> void:
	_套用M3外观()
	# 把当前音量同步到滑块的显示位置（改动滑块才触发保存）
	音乐滑块.set_value_no_signal(Audio.音乐音量)
	音效滑块.set_value_no_signal(Audio.音效音量)
	# 把当前屏幕设置同步到控件（改动才触发保存）
	# 全屏开关现在是 M3Switch，状态看拨杆就行，不用再写「开/关」文字
	全屏开关.set_pressed_no_signal(Settings.全屏)
	_刷新大小高亮()
	_行点击切换($"屏幕设置区/全屏行", 全屏开关)


## 颜色统一走 M3Theme 令牌，这样换种子色时设置页会跟着变
func _套用M3外观() -> void:
	for 路径 in ["标题", "音量区/标题", "屏幕设置区/标题"]:
		_染色(get_node_or_null(路径), M3Theme.on_surface)
	for 路径 in ["音量区/音乐行/音乐标签", "音量区/音效行/音效标签",
			"屏幕设置区/大小行/大小标签", "屏幕设置区/全屏行/全屏标签"]:
		_染色(get_node_or_null(路径), M3Theme.on_surface_variant)
	var 背 := get_node_or_null("背景")
	if 背 is ColorRect:
		(背 as ColorRect).color = M3Theme.surface


func _染色(节点: Node, 色: Color) -> void:
	if 节点 is Label:
		(节点 as Label).add_theme_color_override("font_color", 色)


# =========================
# 音量滑块（拖动即生效并保存）
# =========================
func _音乐滑块_changed(值: float) -> void:
	Audio.音乐音量 = 值


func _音效滑块_changed(值: float) -> void:
	Audio.音效音量 = 值


# =========================
# 屏幕大小 / 全屏（改动即生效并保存）
# =========================
func _屏幕小_pressed() -> void:
	Settings.窗口缩放 = Settings.窗口缩放档位[0]
	Settings.应用显示设置()
	_刷新大小高亮()


func _屏幕中_pressed() -> void:
	Settings.窗口缩放 = Settings.窗口缩放档位[1]
	Settings.应用显示设置()
	_刷新大小高亮()


func _屏幕大_pressed() -> void:
	Settings.窗口缩放 = Settings.窗口缩放档位[2]
	Settings.应用显示设置()
	_刷新大小高亮()


func _屏幕超大_pressed() -> void:
	Settings.窗口缩放 = Settings.窗口缩放档位[3]
	Settings.应用显示设置()
	_刷新大小高亮()


func _全屏开关_toggled(开: bool) -> void:
	Settings.全屏 = 开
	Settings.应用显示设置()


## 高亮当前选中的屏幕大小按钮。
## 以前是用 modulate 调亮，现在这 4 个是 M3Button + 同一个 ButtonGroup 的开关按钮，
## 直接设 button_pressed，选中态由组件自己画（secondary_container 底）。
func _刷新大小高亮() -> void:
	var 当前 := Settings.窗口缩放
	小按钮.set_pressed_no_signal(is_equal_approx(当前, Settings.窗口缩放档位[0]))
	中按钮.set_pressed_no_signal(is_equal_approx(当前, Settings.窗口缩放档位[1]))
	大按钮.set_pressed_no_signal(is_equal_approx(当前, Settings.窗口缩放档位[2]))
	超大按钮.set_pressed_no_signal(is_equal_approx(当前, Settings.窗口缩放档位[3]))


## 点标签或行内空白也能切换（点开关本体时按钮自己处理，不会到这里）
func _行点击切换(行: Control, 开关: Button) -> void:
	行.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	行.gui_input.connect(_on_行点击.bind(开关))


func _on_行点击(事件: InputEvent, 开关: Button) -> void:
	if 事件 is InputEventMouseButton and 事件.pressed and 事件.button_index == MOUSE_BUTTON_LEFT:
		开关.set_pressed(not 开关.button_pressed)


# =========================
# 导航（弹层叠加，不切场景）
# =========================
## 打开一个新弹层并叠加到当前场景顶层（当前弹层保留）
func _打开弹层(场景: PackedScene) -> void:
	var 实例 = 场景.instantiate()
	get_tree().current_scene.add_child(实例)


func _开更多设置() -> void:
	_打开弹层(SceneNav.更多设置)


func _开关于() -> void:
	_打开弹层(SceneNav.关于)


func _返回主菜单() -> void:
	queue_free()
