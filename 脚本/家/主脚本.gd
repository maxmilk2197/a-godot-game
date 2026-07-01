extends Control

func _ready() -> void:
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.start("res://对话/卧室.dtl")
	设置背景("白天")

func _on_signal_event(argument: Variant):
	if argument == "进入玄关":
		get_tree().change_scene_to_file("res://场景/游戏/家/玄关.tscn")
	if argument == "等到晚上":
		设置背景("晚上")
	if argument == "睡觉":
			设置背景("白天")
	
	
func 设置背景(背景: String) -> void:
	if 背景 == "白天":
		$"背景".texture = load("res://资源/图片/家/白天.png")
	elif 背景 == "晚上":
		$"背景".texture = load("res://资源/图片/家/晚上.png")

	
