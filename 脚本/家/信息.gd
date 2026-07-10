extends Control
var 折叠 := false

func _ready() -> void:
	save.加载()





func 切换显示() -> void:
	if 折叠 :
		折叠 = false
		var 隐藏 = create_tween()
		隐藏.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		隐藏.tween_property(self, "position",Vector2(0, 0), 0.2)
	else :
		折叠 = true
		var 展开 = create_tween()
		展开.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		展开.tween_property(self, "position",Vector2(-316.0, 0), 0.2)
