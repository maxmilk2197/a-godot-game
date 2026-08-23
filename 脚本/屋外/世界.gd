extends Node2D

## ============================================================
## 屋外世界场景脚本
## 地图 + 「回家」「便利店」出入口。
## ============================================================

func _on_回家按钮_pressed() -> void:
	get_tree().change_scene_to_file("res://场景/家/家.tscn")


func _on_便利店按钮_pressed() -> void:
	get_tree().change_scene_to_file("res://场景/屋外/便利店.tscn")
