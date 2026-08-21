extends Control
## ============================================================
## 更多设置脚本。对应场景：res://场景/主菜单/更多设置.tscn
## 集中放各种小开关。全静态节点，这里只做 @onready 引用 + 接线。
## ============================================================

@onready var 头像开关: CheckButton = $"开关区/头像行/头像开关"
@onready var 自动继续开关: CheckButton = $"开关区/自动继续行/自动继续开关"
@onready var 慢按钮: Button = $"速度区/速度行/慢"
@onready var 中按钮: Button = $"速度区/速度行/中"
@onready var 快按钮: Button = $"速度区/速度行/快"


func _ready() -> void:
	刷新UI()


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


## 高亮当前选中的速度档位按钮
func _刷新速度高亮() -> void:
	var 当前 := Settings.文字速度
	var 高亮 := Color(0.95, 0.62, 0.68, 1)
	慢按钮.modulate = 高亮 if 当前 == 0 else Color(1, 1, 1, 1)
	中按钮.modulate = 高亮 if 当前 == 1 else Color(1, 1, 1, 1)
	快按钮.modulate = 高亮 if 当前 == 2 else Color(1, 1, 1, 1)


# =========================
# 返回（弹层：直接关闭自己，露出下层设置/主界面）
# =========================
func _返回设置() -> void:
	queue_free()
