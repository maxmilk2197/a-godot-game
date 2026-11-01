extends Node2D
## ============================================================
## 横版关卡（占位色块版）
##
## 场景层：地面 / 平台 / 墙 / 玩家 / 相机
## UI 层 ：CanvasLayer（操作说明 + 提示）
##
## 相机只跟横向，垂直锁死在 相机的Y。
## 掉出关卡会送回出生点。
## ============================================================

@onready var 玩家: CharacterBody2D = $玩家_横版
@onready var 相机: Camera2D = $相机
@onready var 提示: Label = $UI/提示

## 相机垂直方向固定在这个高度（关卡高 1080，取中线）
@export var 相机的Y: float = 540.0
## 掉到这个 y 以下就重生
@export var 掉落线: float = 1500.0

var _出生点: Vector2 = Vector2.ZERO


func _ready() -> void:
	if 玩家 != null:
		_出生点 = 玩家.global_position
	if 相机 != null:
		相机.make_current()
		_同步相机()


func _physics_process(_增量: float) -> void:
	_同步相机()

	if 玩家 != null and 玩家.global_position.y > 掉落线:
		_重生()


## 相机只跟横向，垂直固定
func _同步相机() -> void:
	if 相机 == null or 玩家 == null:
		return
	相机.global_position = Vector2(玩家.global_position.x, 相机的Y)


func _重生() -> void:
	玩家.global_position = _出生点
	玩家.velocity = Vector2.ZERO
	提示.text = "掉下去了，回到起点"
	提示.visible = true
	await get_tree().create_timer(1.2).timeout
	提示.visible = false
