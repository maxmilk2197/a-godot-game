extends "res://脚本/存档界面/存档窗口基类.gd"
## ============================================================
## 存档保存界面
## 继承公共基类（翻页/动画/滚轮），这里只保留保存逻辑。
## ============================================================

# 填充单个按钮的槽位数据（刷新与轮播克隆屏共用）
func 填充单个按钮(按钮: Button, 槽位: int) -> void:
	var 标签 = 按钮.get_node("标签") as Label
	var 主标签 = 按钮.get_node("主标签") as Label

	# 槽位 0 是自动存档档：禁止覆盖
	if 槽位 == 0:
		标签.text = "自动存档"
		主标签.text = "禁止覆盖"
		按钮.disabled = true
		return

	标签.text = "存档 " + str(槽位)
	主标签.text = "空"
	按钮.disabled = false

	# 若该槽位已有存档，则显示存档信息
	if save.检查槽位有无存档(槽位):
		var d = save.加载指定槽位(槽位)
		# JSON 读档后数字是 float，天数显示前转回整数
		主标签.text = "第 " + str(int(d.get("游玩天数", 0))) + " 天 · " + str(d.get("最后游玩时间", "占"))


# =========================
# 点击存档
# =========================
func 按下_保存加载按钮1() -> void:
	_保存到槽位(当前页数 * 3)


func 按下_保存加载按钮2() -> void:
	_保存到槽位(当前页数 * 3 + 1)


func 按下_保存加载按钮3() -> void:
	_保存到槽位(当前页数 * 3 + 2)


func _保存到槽位(槽位: int) -> void:
	if 槽位 == 0:
		return

	var 当前时间字典 = Time.get_datetime_dict_from_system()
	var 月 = 当前时间字典.month
	var 日 = 当前时间字典.day
	var 时 = 当前时间字典.hour
	var 分 = 当前时间字典.minute

	var 当前场景路径 = get_tree().current_scene.scene_file_path

	# 存档里带上养成数据（心情/好感/体力/金币/时段/行动点），
	# 这样读档时养成进度能完整恢复
	var 数据 = {
		"游玩天数": Raise.游玩天数,
		"最后游玩时间": "%d月%d日 %02d:%02d" % [月, 日, 时, 分],
		"最后游玩场景": 当前场景路径,
		"上次存档": 槽位,
		"心情": Raise.心情,
		"好感": Raise.好感,
		"体力": Raise.体力,
		"金币": Raise.金币,
		"时段": Raise.时段,
		"剩余行动点": Raise.剩余行动点,
	}
	save.保存指定槽位(槽位, 数据)

	聊天数据.复制到槽位(槽位)

	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.show()
	var tween = create_tween().bind_node(遮罩)
	tween.tween_property(遮罩, "modulate", Color.WHITE, 0.15)
	await tween.finished
	遮罩.modulate = Color(0, 0, 0, 0)
	遮罩.hide()

	刷新存档显示()