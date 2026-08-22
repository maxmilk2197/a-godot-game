extends Node
## ============================================================
## 临时对话截图工具（用完即删）
## 播放一段真实对话并截图，用于检查对话框/名字牌样式。
## ============================================================

func _ready() -> void:
	Dialogic.start("res://对话/初次见面.dtl")
	# 等开场黑屏文本出现
	await get_tree().create_timer(3.0).timeout
	_截图("对话1")
	# 推进几句话到有人名的台词（parse_input_event 产生真实输入事件）
	for i in 8:
		var 事件 := InputEventAction.new()
		事件.action = "ui_accept"
		事件.pressed = true
		Input.parse_input_event(事件)
		await get_tree().create_timer(0.12).timeout
		var 松开 := InputEventAction.new()
		松开.action = "ui_accept"
		松开.pressed = false
		Input.parse_input_event(松开)
		await get_tree().create_timer(0.5).timeout
	_截图("对话2")
	get_tree().quit()


func _截图(名字: String) -> void:
	await get_tree().process_frame
	var 图 = get_viewport().get_texture().get_image()
	图.save_png("res://.tmp_shots/%s.png" % 名字)
