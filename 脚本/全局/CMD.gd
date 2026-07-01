class_name CMD extends Node
# ==========================================
# 1. 快捷传送指令 (tp)
# ==========================================
static func tp(arg1: Variant, arg2: Variant = null, arg3: Variant = null) -> void:
	if arg1 is Node and (arg2 is int or arg2 is float) and (arg3 is int or arg3 is float):
		_set_node_position(arg1, Vector2(arg2, arg3))
	elif arg1 is Node and arg2 is Node:
		var target_pos = Vector2.ZERO
		if "global_position" in arg2:
			target_pos = arg2.global_position
		elif "position" in arg2:
			target_pos = arg2.position
		_set_node_position(arg1, target_pos)

static func _set_node_position(node: Node, pos: Vector2) -> void:
	if "global_position" in node:
		node.global_position = pos
	elif "position" in node:
		node.position = pos

# ==========================================
# 快捷销毁指令 (kill)
# ==========================================
# 用法：
#   CMD.kill(self)                     # 销毁自身
#   CMD.kill(node1, node2)              # 销毁多个节点
#   CMD.kill(node1, [node2, node3])     # 混合单个节点和数组
#   CMD.kill([nodeA, nodeB, nodeC])     # 直接传入一个数组
static func kill(...arguments) -> void:          # 修正点：使用 ...arguments
	for target in arguments:
		_process_target(target)

# 内部递归处理函数（支持嵌套数组）——必须也是静态的
static func _process_target(target) -> void:     # 修正点：添加 static
	if target == null:
		return
	
	if target is Array:
		for item in target:
			_process_target(item)
		return
	
	if target is Node and is_instance_valid(target):
		target.queue_free()
	# 其他类型忽略

# ==========================================
# 快捷等待指令 (sleep)
# ==========================================
# 用法：await CMD.sleep(秒数)
# 例如：await CMD.sleep(1.5)  等待 1.5 秒
static func sleep(seconds: float) -> Signal:      # 修正点：添加 static
	return Engine.get_main_loop().create_timer(seconds).timeout
