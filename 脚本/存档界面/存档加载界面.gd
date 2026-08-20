extends "res://脚本/存档界面/存档窗口基类.gd"
## ============================================================
## 存档加载界面
## 继承公共基类（翻页/动画/滚轮），这里只保留加载逻辑。
## ============================================================

# 填充单个按钮的槽位数据（刷新与轮播克隆屏共用）
func 填充单个按钮(按钮: Button, 槽位: int) -> void:
	var 标签 = 按钮.get_node("标签") as Label
	var 主标签 = 按钮.get_node("主标签") as Label

	# 先重置为默认空状态
	按钮.disabled = true
	主标签.text = "没有存档"
	if 槽位 == 0:
		标签.text = "自动存档"
	else:
		标签.text = "存档 " + str(槽位)

	# 若该槽位有存档，则启用按钮并显示存档信息
	if save.检查槽位有无存档(槽位):
		var d = save.加载指定槽位(槽位)
		按钮.disabled = false
		# JSON 读档后数字是 float，天数显示前转回整数
		主标签.text = "第 " + str(int(d.get("游玩天数", 0))) + " 天 · " + str(d.get("最后游玩时间", "未知时间"))


# =========================
# 点击存档
# =========================
func 按下_保存加载按钮1() -> void:
	读取存档(当前页数 * 3)


func 按下_保存加载按钮2() -> void:
	读取存档(当前页数 * 3 + 1)


func 按下_保存加载按钮3() -> void:
	读取存档(当前页数 * 3 + 2)


func 读取存档(槽位: int) -> void:
	if not save.检查槽位有无存档(槽位):
		return
	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.BLACK, 0.2)
	await tween.finished

	save.切换槽位(槽位)
	聊天数据.初始化(槽位)
	var 数据字典 = save.加载()
	if 数据字典.is_empty():
		printerr("加载的存档为空或无效")
		return
	get_tree().change_scene_to_file(数据字典["最后游玩场景"])