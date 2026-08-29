extends Control

## ============================================================
## 家场景的养成面板
## 控制左上属性显示、下方行动栏，以及更新养成属性的逻辑。
## 前提：Raise（autoload）已注册，里面存着所有养成员属性。
## ============================================================

@onready var 心情_label: Label = $属性面板/数值栏/心情数值
@onready var 好感_label: Label = $属性面板/数值栏/好感数值
@onready var 体力_label: Label = $属性面板/数值栏/体力数值
@onready var 金币_label: Label = $属性面板/数值栏/金币数值
@onready var 天数_label: Label = $属性面板/数值栏/天数数值
@onready var 时段_label: Label = $属性面板/数值栏/时段数值
@onready var 行动点_label: Label = $属性面板/数值栏/行动点数值
@onready var 结果_label: Label = $行动栏/结果提示

@onready var 交流按钮: Button = $行动栏/交流
@onready var 摸摸按钮: Button = $行动栏/摸摸
@onready var 做家务按钮: Button = $行动栏/做家务
@onready var 睡觉按钮: Button = $行动栏/睡觉
@onready var 离开按钮: Button = $行动栏/离开

const 交流对话 := "res://对话/养成_交流.dtl"
const 摸摸对话 := "res://对话/养成_摸摸.dtl"

var 对话中: bool = false          # 对话没结束时，防止重复点行动按钮
var 本次对话变化: String = ""     # 攒着对话里改的数值，结束时显示出来


func _ready() -> void:
	Raise.初始化()                    # 无存档就开始新档，有存档就读取
	同步数值到对话变量()              # 把养成数值写进 Dialogic 变量
	刷新显示()
	# 监听对话里对养成属性的修改，自动同步回养成管理器
	if not Dialogic.VAR.variable_was_set.is_connected(_因对话修改属性):
		Dialogic.VAR.variable_was_set.connect(_因对话修改属性)
	if not Dialogic.timeline_ended.is_connected(_对话结束):
		Dialogic.timeline_ended.connect(_对话结束)


## 把养成数值写进 Dialogic 变量。
## 不写的话，对话里 set {好感} += 3 会从 0 起算，把存档值覆盖掉。
func 同步数值到对话变量() -> void:
	Dialogic.VAR.set_variable("心情", Raise.心情)
	Dialogic.VAR.set_variable("好感", Raise.好感)
	Dialogic.VAR.set_variable("体力", Raise.体力)
	Dialogic.VAR.set_variable("金币", Raise.金币)


## 把养成管理器的数值刷新到界面
func 刷新显示() -> void:
	心情_label.text = "心情：" + str(Raise.心情)
	好感_label.text = "好感：" + str(Raise.好感)
	体力_label.text = "体力：" + str(Raise.体力)
	金币_label.text = "金币：" + str(Raise.金币)
	天数_label.text = "第 " + str(Raise.游玩天数) + " 天"
	时段_label.text = "时段：" + Raise.时段
	行动点_label.text = "剩余行动：" + str(Raise.剩余行动点)
	_更新按钮可用与否()


## 行动点不够 / 体力不够 / 对话进行中时，把对应按钮禁用
func _更新按钮可用与否() -> void:
	var 还可以行动 := Raise.剩余行动点 > 0 and not 对话中
	交流按钮.disabled = not 还可以行动
	摸摸按钮.disabled = not 还可以行动
	做家务按钮.disabled = not 还可以行动 or Raise.体力 < 15
	睡觉按钮.disabled = 对话中
	离开按钮.disabled = 对话中


## 显示一条结果提示（比如做家务、睡觉的结果）
func 显示结果(文字: String) -> void:
	结果_label.text = 文字


## ---- 行动按钮 ----

func _on_交流_pressed() -> void:
	_开始对话(交流对话)


func _on_摸摸_pressed() -> void:
	_开始对话(摸摸对话)


## 开始一段养成对话：扣 1 行动点，然后播放对话
func _开始对话(对话路径: String) -> void:
	if 对话中:
		return
	if not Raise.消耗行动点():
		显示结果("今天已经很累了，做不了这么多事")
		return
	刷新显示()
	本次对话变化 = ""
	对话中 = true
	_更新按钮可用与否()
	Dialogic.start(对话路径)


func _on_做家务_pressed() -> void:
	if 对话中:
		return
	if not Raise.消耗行动点():
		显示结果("今天已经很累了，做不了这么多事")
		return
	var 体力损失 := randi_range(12, 18)
	var 赚到金币 := randi_range(15, 25)
	Raise.变化体力(-体力损失)
	Raise.增加金币(赚到金币)
	显示结果("帮忙做了家务，赚到 %d 金币，但有点累了。" % 赚到金币)
	刷新显示()


func _on_睡觉_pressed() -> void:
	if 对话中:
		return
	Raise.睡觉翻天()
	var 家 = get_parent()
	if 家 and 家.has_method("设置背景"):
		家.设置背景(Raise.时段)
#	if Raise.时段 == "早上":
#		$"../第二日时间过度".show()
#		$"../第二日时间过度".播放()
	$"../第二日时间过度".show()
	$"../第二日时间过度".播放()
	显示结果(Raise.时段 + "到了，行动点已重置。")
	刷新显示()


func _on_离开_pressed() -> void:
	if 对话中:
		return
	get_tree().change_scene_to_file("res://场景/屋外/世界.tscn")


## ---- 处理对话里对养成属性的修改 ----
## 对话里用 Dialogic 变量，比如 set {好感} += 3。
## 这里收到变化量，加上 ±2 随机后应用到养成管理器。
func _因对话修改属性(信息: Dictionary) -> void:
	var 变量名 = 信息.get("variable", "")
	var 原值 = int(信息.get("orig_value", 0))
	var 新值 = int(信息.get("new_value", 0))
	var 变化量 = 新值 - 原值
	if 变化量 == 0:
		return
	var 实际变化 := Raise.随机浮动(变化量)
	match 变量名:
		"心情":
			Raise.增加心情(实际变化)
		"好感":
			Raise.增加好感(实际变化)
		"体力":
			Raise.变化体力(实际变化)
		"金币":
			Raise.增加金币(实际变化)
		_:
			return
	# 攒起来，对话结束时显示
	if not 本次对话变化.is_empty():
		本次对话变化 += "，"
	本次对话变化 += 变量名 + " " + ("+" if 实际变化 > 0 else "") + str(实际变化)
	刷新显示()


## 对话结束时，把攒下来的数值变化显示在结果栏
func _对话结束() -> void:
	对话中 = false
	# 把养成管理器实际数值写回 Dialogic 变量，
	# 避免下次对话 set {好感} += 3 从旧基准继续累加导致漂移
	同步数值到对话变量()
	_更新按钮可用与否()
	if not 本次对话变化.is_empty():
		显示结果("本次：" + 本次对话变化)
	本次对话变化 = ""
