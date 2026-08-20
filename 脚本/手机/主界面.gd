extends Control

var 当前应用: Control = null
var 正在编辑时间: bool = false

@onready var 时间标签 = $"屏幕显示/状态栏/时间"
@onready var 时间输入 = $"屏幕显示/状态栏/时间输入"
@onready var app容器 = $"屏幕显示/App容器"


func _ready() -> void:
	app容器.hide()
	时间输入.visible = false
	时间输入.text = _当前时段时间()
	# 信号：点时间标签开始编辑；回车提交；失焦提交
	时间标签.gui_input.connect(_时间标签_点击)
	时间输入.text_submitted.connect(func(_t): _提交时间())
	时间输入.focus_exited.connect(func():
		if 正在编辑时间:
			_提交时间()
	)
	_刷新时间()
	# 每 0.5 秒检查一次时段是否变化，跟随时段自动更新
	var 检查定时器 := Timer.new()
	检查定时器.wait_time = 0.5
	检查定时器.autostart = true
	检查定时器.timeout.connect(_刷新时间)
	add_child(检查定时器)


## 当前是白天还是晚上（养成管理器的时段）
func _时段() -> String:
	return Raise.时段 if Raise else "白天"


## 当前时段要显示的时间（来自可编辑设置）
func _当前时段时间() -> String:
	return Settings.晚上时间 if _时段() == "晚上" else Settings.白天时间


func _刷新时间() -> void:
	if not 正在编辑时间:
		时间标签.text = _当前时段时间()


func _时间标签_点击(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_开始编辑时间()
		get_viewport().set_input_as_handled()


## 点时间标签 => 弹出可编辑输入框
func _开始编辑时间() -> void:
	if 正在编辑时间:
		return
	正在编辑时间 = true
	时间输入.text = 时间标签.text
	时间输入.visible = true
	时间标签.visible = false
	时间输入.grab_focus()
	时间输入.select_all()


## 保存编辑的时间到当前时段（白天/晚上）并持久化
func _提交时间() -> void:
	正在编辑时间 = false
	var 文本 := 时间输入.text.strip_edges()
	文本 = _规范化时间(文本)
	if _时段() == "晚上":
		Settings.晚上时间 = 文本
	else:
		Settings.白天时间 = 文本
	时间输入.visible = false
	时间标签.visible = true
	_刷新时间()


func _规范化时间(文本: String) -> String:
	var 正则 := RegEx.new()
	正则.compile("(\\d{1,2}):(\\d{1,2})")
	var 匹配 := 正则.search(文本)
	if 匹配:
		var 时 := clampi(int(匹配.get_string(1)), 0, 23)
		var 分 := clampi(int(匹配.get_string(2)), 0, 59)
		return "%02d:%02d" % [时, 分]
	return _当前时段时间()


func _取消编辑时间() -> void:
	正在编辑时间 = false
	时间输入.visible = false
	时间标签.visible = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if 正在编辑时间:
			_取消编辑时间()
			get_viewport().set_input_as_handled()
			return
		_关闭手机()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_关闭手机()
		get_viewport().set_input_as_handled()


func _关闭手机() -> void:
	queue_free()


func _打开聊天() -> void:
	if 当前应用:
		当前应用.queue_free()
	var 聊天场景 = load("res://场景/手机/聊天界面.tscn")
	当前应用 = 聊天场景.instantiate()
	app容器.add_child(当前应用)
	app容器.show()


func 关闭当前应用() -> void:
	if 当前应用:
		当前应用.queue_free()
		当前应用 = null
	app容器.hide()
