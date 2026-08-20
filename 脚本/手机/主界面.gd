extends Control

var 当前应用: Control = null

@onready var 时间标签 = $"屏幕显示/状态栏/时间"
@onready var app容器 = $"屏幕显示/App容器"


func _ready() -> void:
	_更新时间()
	app容器.hide()
	# 每分钟刷新一次时间即可，不必每帧刷
	var 时间定时器 := Timer.new()
	时间定时器.wait_time = 60.0
	时间定时器.autostart = true
	时间定时器.timeout.connect(_更新时间)
	add_child(时间定时器)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_关闭手机()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_关闭手机()
		get_viewport().set_input_as_handled()


func _关闭手机() -> void:
	queue_free()


func _更新时间() -> void:
	var d = Time.get_datetime_dict_from_system()
	时间标签.text = "%02d:%02d" % [d.hour, d.minute]


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
