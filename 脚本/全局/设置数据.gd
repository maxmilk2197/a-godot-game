extends Node
## ============================================================
## 设置数据（全局唯一，autoload 注册名：Settings）
## 存放各可微调开关/选项，持久化到 user://game_settings.cfg。
## 用法（脚本里读/写都会自动保存）：
##   Settings.显示对方头像 = false
##   Settings.文字速度 = 1   # 0 慢 / 1 中 / 2 快
##   Settings.自动继续 = true
## ============================================================

const 设置路径 := "user://game_settings.cfg"

## 文字速度分档（0=慢 1=中 2=快）对应的 letter_speed（逐字间隔秒）
const 文字速度档位 := {
	0: 0.045,
	1: 0.02,
	2: 0.008,
}

## 聊天界面里是否显示「对方」消息旁的头像
var 显示对方头像: bool = true:
	set(值):
		显示对方头像 = 值
		保存()

## 对话文字速度分档（0=慢 1=中 2=快）
var 文字速度: int = 1:
	set(值):
		文字速度 = clampi(值, 0, 2)
		保存()

## 是否自动继续对话（逐句前进，不用每次点击）
var 自动继续: bool = false:
	set(值):
		自动继续 = 值
		保存()

## 临时导航标志：从“设置/关于”返回主菜单时，跳过一次性的主菜单 logo 动画（不持久化）
var 跳过主菜单logo: bool = false


func _ready() -> void:
	读取()


## 从配置文件恢复所有设置项
func 读取() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(设置路径) != OK:
		return
	显示对方头像 = cfg.get_value("聊天", "显示对方头像", true)
	文字速度 = cfg.get_value("对话", "文字速度", 1)
	自动继续 = cfg.get_value("对话", "自动继续", false)


## 把当前所有设置项写入配置文件
func 保存() -> void:
	var cfg := ConfigFile.new()
	cfg.load(设置路径)
	cfg.set_value("聊天", "显示对方头像", 显示对方头像)
	cfg.set_value("对话", "文字速度", 文字速度)
	cfg.set_value("对话", "自动继续", 自动继续)
	cfg.save(设置路径)


## 把当前文字速度/自动继续应用到 Dialogic（运行时即时生效）。
func 应用对话设置() -> void:
	# 文字逐字速度：立即刷新所有文本节点
	Dialogic.Text.update_text_speed(文字速度档位[文字速度])
	# 自动继续：直接控制 autoadvance（改 ProjectSettings 不生效，必须改 flag）
	Dialogic.Inputs.auto_advance.enabled_forced = 自动继续
