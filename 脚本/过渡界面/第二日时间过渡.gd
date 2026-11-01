extends Control
## ============================================================
## 第二日时间过渡 —— 睡觉翻天后的过场
## 在这里掷「今天」的天气：预报说什么，出门就是什么。
## ============================================================

@export var Day: Label

## 天气权重池：眠冬镇雪多晴少
const 天气池: Array[String] = ["雪", "雪", "雪", "阴", "阴", "雨", "雾", "晴"]

## 天气短名 → 预报用的全称
const 天气全名 := {
	"晴": "晴天",
	"阴": "阴天",
	"雨": "雨天",
	"雪": "雪天",
	"雾": "雾天",
}


func 播放() -> void:
	Day.text = "第 " + str(Raise.游玩天数) + " 天"

	# 每天掷一次天气，存进全局，屋外世界直接读这个值
	Raise.天气 = 天气池[randi() % 天气池.size()]
	Raise.保存()

	var 短名 := Raise.天气
	var 全名 := str(天气全名.get(短名, 短名))

	var 天气标签 := $"VBoxContainer/天气"

	$AnimationPlayer.play("默认")
	await $AnimationPlayer.animation_finished
	await CMD.sleep(0.1)
	天气标签.text = 短名
	await CMD.sleep(0.1)
	天气标签.text = 全名
	await CMD.sleep(1)
	天气标签.text = 短名
	await CMD.sleep(0.1)
	天气标签.text = ""
	await CMD.sleep(1)
	$AnimationPlayer.play("结束")
	await $AnimationPlayer.animation_finished
	await CMD.sleep(0.1)
	self.hide()
