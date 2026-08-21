extends SceneTree

func _init() -> void:
	var files := [
		"res://场景/主菜单/设置.tscn",
		"res://场景/主菜单/更多设置.tscn",
		"res://场景/主菜单/关于.tscn",
		"res://脚本/主菜单/更多设置.gd",
	]
	var failed := 0
	for f in files:
		var res := load(f)
		if res == null:
			printerr("LOAD FAIL: ", f)
			failed += 1
		else:
			print("OK: ", f)
	print("FAILED_COUNT=", failed)
	quit(0)
