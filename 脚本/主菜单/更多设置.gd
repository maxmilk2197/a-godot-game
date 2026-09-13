extends Control
## ============================================================
## 更多设置脚本。对应场景：res://场景/主菜单/更多设置.tscn
## 集中放各种小开关。全静态节点，这里只做 @onready 引用 + 接线。
## 开关用主题化 Button（toggle_mode）而非默认灰色 CheckButton，
## 文字直接显示「开 / 关」，点整行（标签或空白处）也能切换。
## ============================================================

@onready var 头像开关: Button = $"开关区/头像行/头像开关"
@onready var 自动继续开关: Button = $"开关区/自动继续行/自动继续开关"
@onready var 慢按钮: Button = $"速度区/速度行/慢"
@onready var 中按钮: Button = $"速度区/速度行/中"
@onready var 快按钮: Button = $"速度区/速度行/快"


func _ready() -> void:
	_套用M3外观()
	_行点击切换($"开关区/头像行", 头像开关)
	_行点击切换($"开关区/自动继续行", 自动继续开关)
	刷新UI()


## 颜色统一走 M3Theme 令牌（换种子色时跟着变）
func _套用M3外观() -> void:
	_染色(get_node_or_null("标题"), M3Theme.on_surface)
	_染色(get_node_or_null("速度区/速度标题"), M3Theme.on_surface)
	for 路径 in ["开关区/头像行/头像标签", "开关区/自动继续行/自动继续标签"]:
		_染色(get_node_or_null(路径), M3Theme.on_surface_variant)
	var 背 := get_node_or_null("背景")
	if 背 is ColorRect:
		(背 as ColorRect).color = M3Theme.surface


func _染色(节点: Node, 色: Color) -> void:
	if 节点 is Label:
		(节点 as Label).add_theme_color_override("font_color", 色)


## 把当前设置值反映到控件上（不会触发信号回调）
func 刷新UI() -> void:
	头像开关.set_pressed_no_signal(Settings.显示对方头像)
	自动继续开关.set_pressed_no_signal(Settings.自动继续)
	_刷新速度高亮()


# =========================
# 开关
# =========================
func _头像开关_toggled(开: bool) -> void:
	Settings.显示对方头像 = 开


func _自动继续开关_toggled(开: bool) -> void:
	Settings.自动继续 = 开
	Settings.应用对话设置()


## 点标签或行内空白也能切换（点开关本体时按钮自己处理，不会到这里）
func _行点击切换(行: Control, 开关: Button) -> void:
	行.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	行.gui_input.connect(_on_行点击.bind(开关))


func _on_行点击(事件: InputEvent, 开关: Button) -> void:
	if 事件 is InputEventMouseButton and 事件.pressed and 事件.button_index == MOUSE_BUTTON_LEFT:
		开关.set_pressed(not 开关.button_pressed)


# =========================
# 文字速度（慢/中/快）
# =========================
func _慢_pressed() -> void:
	Settings.文字速度 = 0
	_刷新速度高亮()
	Settings.应用对话设置()


func _中_pressed() -> void:
	Settings.文字速度 = 1
	_刷新速度高亮()
	Settings.应用对话设置()


func _快_pressed() -> void:
	Settings.文字速度 = 2
	_刷新速度高亮()
	Settings.应用对话设置()


## 高亮当前选中的速度档位按钮。
## 以前是用 modulate 调亮，现在这 3 个是 M3Button + 同一个 ButtonGroup 的开关按钮，
## 直接设 button_pressed，选中态（secondary_container 底）由组件自己画。
func _刷新速度高亮() -> void:
	var 当前 := Settings.文字速度
	慢按钮.set_pressed_no_signal(当前 == 0)
	中按钮.set_pressed_no_signal(当前 == 1)
	快按钮.set_pressed_no_signal(当前 == 2)


# =========================
# 返回 / 打开测试页
# =========================
func _返回设置() -> void:
	queue_free()


## 打开 MD3 组件测试页（当弹层叠上来，不切场景）。
## 它会自己盖一层 M3Surface 背景，所以不会露出下面的设置页；
## 页面里会自己加一个「返回」按钮（只在当弹层打开时出现）。
func _开M3测试() -> void:
	var 场景 := load("res://场景/测试/M3组件测试.tscn") as PackedScene
	if 场景 == null:
		push_warning("加载不到 res://场景/测试/M3组件测试.tscn")
		return
	var 层 := 场景.instantiate()
	get_tree().current_scene.add_child(层)
