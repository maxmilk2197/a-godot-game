extends Control
## ============================================================
## 设置弹层脚本。对应场景：res://场景/主菜单/设置.tscn
## 以“叠加弹层”方式盖在当前主界面上（不切场景、不销毁主界面，音乐不断）。
## 打开子页：把子页弹层叠加到当前场景顶层，自己不关（可返回）。
## 返回：queue_free 关闭自己，露出下层。
## ============================================================

@onready var 音乐滑块: HSlider = $"音量区/音乐行/音量滑块"
@onready var 音效滑块: HSlider = $"音量区/音效行/音量滑块"


func _ready() -> void:
	# 把当前音量同步到滑块的显示位置（改动滑块才触发保存）
	音乐滑块.set_value_no_signal(Audio.音乐音量)
	音效滑块.set_value_no_signal(Audio.音效音量)


# =========================
# 音量滑块（拖动即生效并保存）
# =========================
func _音乐滑块_changed(值: float) -> void:
	Audio.音乐音量 = 值


func _音效滑块_changed(值: float) -> void:
	Audio.音效音量 = 值


# =========================
# 导航（弹层叠加，不切场景）
# =========================
## 打开一个新弹层并叠加到当前场景顶层（当前弹层保留）
func _打开弹层(场景: PackedScene) -> void:
	var 实例 = 场景.instantiate()
	get_tree().current_scene.add_child(实例)


func _开更多设置() -> void:
	_打开弹层(SceneNav.更多设置)


func _开关于() -> void:
	_打开弹层(SceneNav.关于)


func _返回主菜单() -> void:
	queue_free()
