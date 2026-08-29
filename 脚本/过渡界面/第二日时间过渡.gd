extends Control
@export var Day : Label


func 播放() -> void:
	Day.text = "第 " + str(Raise.游玩天数) + " 天"
	$AnimationPlayer.play("默认")
	await $AnimationPlayer.animation_finished
	await CMD.sleep(0.1)
	#天气获取之后再做
	$"VBoxContainer/天气".text = "晴"
	await CMD.sleep(0.1)
	$"VBoxContainer/天气".text = "晴天"
	await CMD.sleep(1)
	$"VBoxContainer/天气".text = "晴"
	await CMD.sleep(0.1)
	$"VBoxContainer/天气".text = ""
	await CMD.sleep(1)
	$AnimationPlayer.play("结束")
	await $AnimationPlayer.animation_finished
	await CMD.sleep(0.1)
	self.hide()
