extends Control
## ============================================================
## 设置首页脚本。对应的场景：res://场景/主菜单/设置.tscn
## 所有 UI 节点都在场景里静态建好，这里只用 @onready 引用。
## 场景跳转统一走 SceneNav（preload，单向依赖，避免循环引用）。
## ============================================================

@onready var 音乐滑块: HSlider = $"音量区/音乐行/音量滑块"
@onready var 音效滑块: HSlider = $"音量区/音效行/音量滑块"


func _ready() -> void:
	# 把当前音量同步到滑块的显示位置（改动滑块才触发保存）
	音乐滑块.set_value_no_signal(Audio.音乐音量)
	音效滑块.set_value_no_signal(Audio.音效音量)


# =========================
# 音量滑块（首页顶部直接放，拖动即生效并保存）
# =========================
func _音乐滑块_changed(值: float) -> void:
	Audio.音乐音量 = 值


func _音效滑块_changed(值: float) -> void:
	Audio.音效音量 = 值


# =========================
# 导航（静态场景跳转）
# =========================
func _开更多设置() -> void:
	get_tree().change_scene_to_packed(SceneNav.更多设置)


func _开关于() -> void:
	get_tree().change_scene_to_packed(SceneNav.关于)


func _返回主菜单() -> void:
	# 返回主菜单时跳过 logo 动画
	Settings.跳过主菜单logo = true
	get_tree().change_scene_to_packed(SceneNav.主界面)
