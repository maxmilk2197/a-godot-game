extends CharacterBody2D
## ============================================================
## 俯视 2D 玩家（走动底座的占位实现）
## 外观是纯色方块 + 描边，先验证手感；美术定调后换成 Sprite2D 即可。
##
## 输入只有一套：InputMap 的 move_up / move_down / move_left / move_right
##   · 键盘：W A S D 或 方向键
##   · 触屏：场景里的 VirtualJoystick 节点会把摇杆输入写进同样这几个动作
## 所以这里不需要区分平台。
## ============================================================

@export var 移动速度: float = 260.0
## 起步加速度（越大越跟手，越小越滑）
@export var 加速度: float = 2400.0
## 松开按键后的减速度
@export var 减速度: float = 3000.0


func _physics_process(增量: float) -> void:
	var 方向 := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if 方向 == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, 减速度 * 增量)
	else:
		velocity = velocity.move_toward(方向 * 移动速度, 加速度 * 增量)

	move_and_slide()
