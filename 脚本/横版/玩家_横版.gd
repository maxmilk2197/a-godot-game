extends CharacterBody2D
## ============================================================
## 横版平台跳跃玩家
##
## 手感关键三件套：
##   · 土狼时间（coyote time）—— 刚走出平台边缘还能跳
##   · 跳跃缓冲（jump buffer）—— 落地前就按下跳，落地立刻起跳
##   · 可变跳跃高度 —— 松开跳跃键提前截断上升
##
## 输入：move_left / move_right / jump（空格、W、↑）
## ============================================================

@export var 移动速度: float = 320.0
@export var 加速度: float = 2600.0
@export var 减速度: float = 3200.0
@export var 跳跃初速: float = -640.0
@export var 重力: float = 1750.0
@export var 最大下落速度: float = 1000.0
## 走出平台边缘后还能跳的宽限时间
@export var 土狼时间: float = 0.12
## 落地前提前按跳的缓冲时间
@export var 跳跃缓冲: float = 0.12
## 松开跳跃键时上升速度保留的比例（0.5 = 截断一半，跳得矮）
@export var 松手截断: float = 0.45

var _土狼计时: float = 0.0
var _缓冲计时: float = 0.0


func _physics_process(增量: float) -> void:
	# ---- 重力 ----
	if not is_on_floor():
		velocity.y = minf(velocity.y + 重力 * 增量, 最大下落速度)

	# ---- 跳跃缓冲：落地前按下也算 ----
	if Input.is_action_just_pressed("jump"):
		_缓冲计时 = 跳跃缓冲
	else:
		_缓冲计时 = maxf(_缓冲计时 - 增量, 0.0)

	# ---- 土狼时间：刚离地还能跳 ----
	if is_on_floor():
		_土狼计时 = 土狼时间
	else:
		_土狼计时 = maxf(_土狼计时 - 增量, 0.0)

	# ---- 起跳 ----
	if _缓冲计时 > 0.0 and _土狼计时 > 0.0:
		velocity.y = 跳跃初速
		_缓冲计时 = 0.0
		_土狼计时 = 0.0

	# ---- 可变跳跃高度：松开就截断上升 ----
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 松手截断

	# ---- 左右 ----
	var 方向 := Input.get_axis("move_left", "move_right")
	if absf(方向) > 0.01:
		velocity.x = move_toward(velocity.x, 方向 * 移动速度, 加速度 * 增量)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 减速度 * 增量)

	move_and_slide()
