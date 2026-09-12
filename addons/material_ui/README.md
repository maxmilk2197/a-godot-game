# Material 3 UI Kit（GDScript 版）

Godot 4 的 Material Design 3 组件库，**纯 GDScript**，不需要 .NET / Mono。
是 [`rnewquist/godot_material3`](https://github.com/rnewquist/godot_material3)（C# 版）的 GDScript 移植版。

- 目录：`addons/material_ui/`
- 启用插件后会自动注册 `M3ThemeManager` 单例（可选，不用也行）

## 组件一览

| 类名 | 继承 | 说明 |
|---|---|---|
| `M3Button` | Button | Filled / Tonal / Outlined / Text / Elevated，自带涟漪 |
| `M3Card` | PanelContainer | Elevated / Filled / Outlined 卡片容器 |
| `M3Switch` | BaseButton | 开关（`button_pressed`） |
| `M3Checkbox` | BaseButton | 复选框（`button_pressed`） |
| `M3RadioButton` | BaseButton | 单选按钮（`button_pressed`） |
| `M3Slider` | HSlider | 滑块 |
| `M3TextField` | LineEdit | 输入框（Filled / Outlined） |
| `M3ProgressIndicator` | Control | 线性 / 圆形进度，支持不确定动画 |
| `M3Divider` | Control | 分隔线（水平 / 垂直） |
| `M3Badge` | Label | 徽标 / 小红点 |
| `M3Tab` | Button | 单个标签页 |
| `M3TabBar` | HBoxContainer | 标签栏（互斥选中，`切换(索引)`） |
| `M3NavigationBar` | PanelContainer | 底部导航栏（自动生成按钮，`切换(索引)`） |
| `M3NavigationRail` | PanelContainer | 侧边导航栏（竖向，`切换(索引)`） |
| `M3NavigationDrawer` | PanelContainer | 抽屉导航（左滑出，`打开()`/`关闭()`/`开关()`） |
| `M3Tooltip` | PanelContainer | 提示气泡（`弹出()` / `收起()`） |
| `M3Ripple` | Control | 涟漪效果（按钮内部用） |
| `M3Surface` | Panel | 主题驱动的背景条（选「角色」，跟随 M3Theme） |
| `M3ScrollStretch` | Node | 拖动滚动 + MD3 过度滚动拉长回弹 |

## 用法

组件通过 `class_name` 注册，**在编辑器里就能像普通节点一样添加**（节点类型里搜 M3）。
也可以用代码：

```gdscript
var 按钮 := M3Button.new()
按钮.text = "开始"
按钮.样式类型 = M3Button.按钮样式.TONAL
按钮.pressed.connect(_on_pressed)
add_child(按钮)
```

## 主题 / 配色

颜色令牌集中在 `M3Theme`（静态类，不需要 autoload）：

```gdscript
M3Theme.primary = Color(0, 0.349, 0.78)
M3Theme.应用种子(Color("0b57d0"))   # 按种子色派生整套令牌
M3Theme.scale = 1.5                 # 整套组件整体放大
```

`M3Theme.应用种子()` 内部走 **`M3Palette`**：在 **CIELAB** 空间里以 L\*（就是 MD3 里 tone 的定义）取各级色调，
固定色相/彩度、超出 sRGB 色域时自动降彩度，比 HSV 插值准得多。
各令牌的取法遵循 MD3 映射（primary=tone40、primaryContainer=tone90、surface=tone98、outline=neutralVariant tone50 …）。

颜色角色是**完整 37 个**（primary / secondary / tertiary / error / background / surface /
surface container lowest…highest / surface dim / surface bright / inverse / outline / shadow / scrim），
其中 `background`、`on_background`、`scrim` 是做 dialog / drawer / snackbar 的必需品。
surface container 的 tone 取值（浅色 100/96/94/92/90，深色 4/10/12/17/22）来自 mdui 的实测实现。

`M3Button` 的状态层 / 涟漪有两条变体相关的规则（见 `状态色()` 与 `涟漪峰值()`）：

- **色调（TONAL）按钮**的状态色用 `on_secondary_container` 而不是 `secondary_container`——
  它的底色本身就是 `secondary_container`，叠同色等于没有反馈。
- **填充（FILLED）和色调按钮**的涟漪峰值会被压低（×0.32 / ×0.22）——
  涟漪色与底色明度差大，按 `涟漪不透明度` 全量叠上去会把整颗按钮冲淡或压黑，文字对比度跟着掉。

## 动效令牌（`M3Motion`）

数值对齐 **m3e（Material 3 Expressive）** 与 **mdui 2** 的官方 sys token，全部是静态常量 / 静态函数，直接拿来用：

```gdscript
# 时长
M3Motion.短4          # 0.20s   —— 状态层、小图标
M3Motion.中3          # 0.35s
M3Motion.长2          # 0.50s

# 弹簧（M3 Expressive 的空间位移曲线，y 会略微超过 1，带一点点过冲）
M3Motion.弹簧_快_时长  # 0.35s
M3Motion.弹簧_快(t)    # cubic-bezier(0.27, 1.06, 0.18, 1)
M3Motion.弹簧_默认_效果(t)  # 颜色/透明度用，不过冲

# 缓动（真·三次贝塞尔，等价 CSS cubic-bezier）
M3Motion.强调减速(t)   # cubic-bezier(0.05, 0.7, 0.1, 1) —— 进场
M3Motion.强调加速(t)   # cubic-bezier(0.3, 0, 0.8, 0.15) —— 退场

# 状态层不透明度
M3Motion.状态_悬停 / 状态_聚焦 / 状态_按下 / 状态_拖动
```

`M3Motion.三次贝塞尔(进度, x1, y1, x2, y2)` 是共用的 CSS 等价求解器，要自定义曲线时用它。

## 形状令牌（`M3Shape`）

```gdscript
M3Shape.特小   # 4
M3Shape.小     # 8
M3Shape.中     # 12
M3Shape.大     # 16
M3Shape.大加强 # 20
M3Shape.特大   # 28
M3Shape.特大加强 # 32
M3Shape.超特大 # 48
M3Shape.全圆   # 9999（药丸）
```

配合 `M3Theme.样式(色, M3Shape.大)` 使用；组件的 `圆角` 导出属性默认值就是这些令牌。

## 和项目现有的 1920×1080 缩放

项目已经有「1920 渲染 + 窗口缩放」，所以 `M3ThemeManager.自动缩放` **默认关闭**，
避免双重缩放。想用它的缩放再打开即可。
