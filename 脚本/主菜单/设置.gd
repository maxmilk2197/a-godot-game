extends Control

@onready var 音乐滑条: HSlider = $面板/音乐行/音乐滑条
@onready var 音乐数值: Label = $面板/音乐行/音乐数值
@onready var 音效滑条: HSlider = $面板/音效行/音效滑条
@onready var 音效数值: Label = $面板/音效行/音效数值
@onready var 关于遮罩: ColorRect = $关于遮罩
@onready var 遮罩: ColorRect = $遮罩


func _ready() -> void:
	音乐滑条.value = Audio.音乐音量 * 100.0
	音效滑条.value = Audio.音效音量 * 100.0
	刷新音乐数值()
	刷新音效数值()


func _on_音乐滑条_value_changed(值: float) -> void:
	Audio.音乐音量 = 值 / 100.0
	刷新音乐数值()


func _on_音效滑条_value_changed(值: float) -> void:
	Audio.音效音量 = 值 / 100.0
	刷新音效数值()


func 刷新音乐数值() -> void:
	音乐数值.text = "%d%%" % roundi(Audio.音乐音量 * 100.0)


func 刷新音效数值() -> void:
	音效数值.text = "%d%%" % roundi(Audio.音效音量 * 100.0)


func _on_关于按钮_pressed() -> void:
	关于遮罩.show()


func _on_关闭按钮_pressed() -> void:
	关于遮罩.hide()


func _on_返回按钮_pressed() -> void:
	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.show()
	var 补间 := create_tween()
	补间.tween_property(遮罩, "modulate", Color.BLACK, 0.25)
	await 补间.finished
	get_tree().change_scene_to_file("res://场景/主菜单/主界面.tscn")