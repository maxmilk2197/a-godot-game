extends Control

var 当前应用: Control = null

@onready var 时间标签 = $"屏幕显示/状态栏/时间"
@onready var app容器 = $"屏幕显示/App容器"


func _ready() -> void:
	_更新时间()
	app容器.hide()


func _process(_delta: float) -> void:
	_更新时间()


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
