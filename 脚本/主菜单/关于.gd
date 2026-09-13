extends Control
## ============================================================
## 关于页脚本。对应场景：res://场景/主菜单/关于.tscn
## ============================================================

## 标题用 on_surface、正文用 on_surface_variant，全走 M3Theme 令牌
const 标题类 := ["标题", "游戏名"]
const 正文类 := ["版本", "感谢以下所有人", "程序", "程序人员", "音乐", "程序人员2", "程序人员3", "致谢"]


func _ready() -> void:
	_套用M3外观()


func _套用M3外观() -> void:
	_染色(get_node_or_null("标题"), M3Theme.on_surface)
	for 名 in 标题类:
		_染色(_找(名), M3Theme.on_surface)
	for 名 in 正文类:
		_染色(_找(名), M3Theme.on_surface_variant)
	var 背 := get_node_or_null("背景")
	if 背 is ColorRect:
		(背 as ColorRect).color = M3Theme.surface


## 名字可能在根下，也可能在 VBoxContainer 里
func _找(名: String) -> Node:
	var 直 := get_node_or_null(名)
	if 直 != null:
		return 直
	var 盒 := get_node_or_null("VBoxContainer")
	if 盒 != null:
		return 盒.get_node_or_null(名)
	return null


func _染色(节点: Node, 色: Color) -> void:
	if 节点 is Label:
		(节点 as Label).add_theme_color_override("font_color", 色)


func _返回() -> void:
	queue_free()
