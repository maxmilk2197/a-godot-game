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
| `M3Slider` | HSlider | 滑块（M3 Expressive：竖条手柄 + 胶囊轨道 + 可选离散刻度） |
| `M3TextField` | LineEdit | 输入框（Filled / Outlined） |
| `M3ProgressIndicator` | Control | 线性 / 圆形进度，支持不确定动画 |
| `M3LoadingIndicator` | Control | M3 Expressive 的 **Loading Morph**：7 个形状弹簧变形 + 匀速自转 |
| `M3Divider` | Control | 分隔线（水平 / 垂直） |
| `M3Badge` | Label | 徽标 / 小红点 |
| `M3Tab` | Button | 单个标签页 |
| `M3TabBar` | HBoxContainer | 标签栏（互斥选中，`切换(索引)`） |
| `M3NavigationBar` | PanelContainer | 底部导航栏（图标名 + 文字 + 胶囊指示器，`切换(索引)`；项目就是 `M3NavigationRailItem`） |
| `M3NavigationRail` | PanelContainer | 侧边导航轨道（`切换(索引)`；可自动生成，也可自己往里放项目） |
| `M3NavigationRailItem` | BaseButton | 轨道 / 底栏里的单个项目（胶囊指示器 + 图标 + 文字） |
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

### 编辑器里的样子

每个组件都带 `@tool` 和 `@icon()`，所以**不用运行游戏就能看到效果**：

- 场景 → 右键 → 添加节点 → 搜 `M3`，列表里每个组件都有自己的图标（和原生节点一样）；
- 因为继承自原生控件（`Button` / `PanelContainer` / `LineEdit` …），搜 `Button` 之类的原生名字也能搜到对应组件；
- 拖进场景立刻按 M3 主题渲染，改导出属性（样式类型 / 圆角 / 字号…）即时刷新；
- 图标在 `addons/material_ui/icons/`，用的是 **Godot 节点图标的那个绿 `#6aff7c`**
  （从编辑器里量出来的：场景树里所有节点图标都是这个色；蓝色那批是下面「文件系统」面板的文件夹）；
  导入参数开了 `editor/scale_with_editor_scale`，会跟着编辑器缩放。
- ⚠️ `editor/convert_colors_with_editor_theme` 是**关掉**的。实测它确实会按编辑器主题改色
  （源文件写 `#6aff7c`，导入后变成 `#32ff56`），而原来源文件里的 `#e0e0e0` 又不在它的映射表里，
  所以一直保持灰色 —— 这正是「图标跟原生节点颜色不一致」的原因。关掉它颜色才精确可控。
- 🔴 **带 `static var` 的类必须加 `@tool`，否则编辑器里静态初始化不执行。**
  Godot 在编辑器里只会跑 `@tool` 脚本的 `static var` 初始化；不加的话那些变量全是零值 ——
  `M3Theme.primary` 变黑、`M3Theme.scale` 变 `0`，结果是**所有 M3 组件在编辑器里渲染成黑块或干脆不渲染**
  （运行时又是好的，所以很容易漏掉）。
  目前带 `static var` 的是 `M3Theme` 和 `M3MaterialShapes`，两个都加了 `@tool`。
  以后新增这类类时记得跟上。

`M3LoadingIndicator` 默认在编辑器里也播放动画（`编辑器预览 = true`），节点多了可以关掉。

## Loading Morph（`M3LoadingIndicator`）

一个形状在 7 个 MaterialShapes 之间弹簧式变形，同时整体匀速自转，每变一次形状额外转 90°。
参数对齐 AndroidX `LoadingIndicator.kt`：

| 项 | 值 |
|---|---|
| 容器 | 48dp，全圆角 |
| 活动形状 | 容器的 0.66 倍 |
| 整体自转 | 4666ms 一圈（匀速） |
| 变形间隔 | 650ms |
| 变形弹簧 | dampingRatio 0.6 / stiffness 200（欠阻尼，过冲约 9.5%） |

```gdscript
var 转圈 := M3LoadingIndicator.new()
转圈.尺寸 = 48
转圈.变体 = M3LoadingIndicator.显示变体.容器   # 独立（透明底）/ 容器（primary_container 圆底）

# 定量模式：把 进度 设成 0~1，形状从「圆」补间到「软爆」
var 定量 := M3LoadingIndicator.new()
定量.进度 = 0.4
```

形状数据在 `M3MaterialShapes`（7 个不定量形状 + 定量用的「圆」）。
每个形状都绕中心星形凸，所以按 **128 等分角存半径**就够了 —— 点 = r(θ)·(cosθ, sinθ)，
比存 x/y 省一半空间，还原误差 &lt; 7e-5。

### 尺寸：跟着控件走

图形按**控件的实际大小**画，取短边（保持正方形），再乘 `活动比例`：

| 控件尺寸 | 图形边长 |
|---|---|
| 48×48（默认） | 48 × 0.66 = 31.7 |
| 200×200 | 200 × 0.66 = 132 |
| 777×428 | **428** × 0.66 = 282 |

`尺寸` 只是**默认 / 最小尺寸**（写进 `custom_minimum_size`）——在编辑器里把节点拉大，
图形会跟着放大；想让形状占满短边就把 `活动比例` 调到 `1.0`。

## 环形加载（`M3ProgressIndicator` 的圆形不定量）

照 mdui / MDC 的 `circular-progress` 做的，是**双半圆遮罩**方案：两个 clipper 各露出一半圆环，
里面的 `<circle>` 用 `stroke-dasharray=周长` + `stroke-dashoffset=周长/2` **只画半圈**，
再各自被 `left-spin` / `right-spin` 反向旋转。把两半在屏幕上的可见部分并起来，等价于一整段弧：

```
起始角 = 容器自转 + 图层旋转 + 钳口角
扫过角 = 540° − 2 × 钳口角
```

| 项 | 值 | 缓动 |
|---|---|---|
| 容器整圈自转 | 1568ms，360° | linear |
| 图层旋转 | 5332ms，1080°（8 段 × 135°） | standard（每段各缓动一次） |
| 半圆钳口伸缩 | 1333ms，265° ↔ 130° | standard |

于是弧长在 **10° ~ 280°** 之间伸缩，一个图层周期里正好 4 轮。

**关键性质**：图层每段 666.5ms，与钳口半周期同长、同缓动，两者叠加后
**两个端点全程都只前进、不会有一端倒着缩**；而且一段里一端恒速 229.6°/s、
另一端甩到约 1870°/s，下一段互换——这就是 Material 环形进度那种「一头稳稳走、一头追上去」的手感。

> 早期版本用的是自创的「尾钉住、头往前跑」两段式，实测头速会到 **−874°/s**（倒缩 29°）、
> 尾速从 162 跳到 704°/s。现在这套实测：两端倒退帧数 **0**，跨所有周期边界速度连续。

确定进度的弧长变化是 500ms + `standard` 的过渡（mdui 的 long2）。

## 滑块（`M3Slider`）

M3 Expressive 的滑块：**胶囊轨道 + 竖条手柄**，不是传统圆钮。用法和 `HSlider` 完全一样
（`value` / `value_changed` / `min_value` / `max_value` / `step` 全都在）。

几何取自 md3e 的 `<md-slider>`：

| 部件 | 规格 |
|---|---|
| 轨道 | 16dp 高、全圆角；底轨 `secondary_container`，已选段 `primary` |
| 手柄 | 44dp 高；静止 **4dp** 宽、悬停 **6dp**、按下/聚焦 **2dp** 且 `scale(1.15, 0.95)` |
| 刻度点 | 4dp 圆点；已经过的 `on_primary`@0.7，还没到的 `on_secondary_container`@0.5 |
| 手柄宽度过渡 | 200ms（expressive 空间弹簧） |
| 数值气泡 | `inverse_surface` 底 + `inverse_on_surface` 字、8dp 圆角；按住或悬停时出现，**底边正好压在轨道上沿**（md3e 的 `bottom:32px` 换算过来就是这个位置），手柄竖条上半截藏进气泡里 |

```gdscript
var 滑 := M3Slider.new()
滑.min_value = 0; 滑.max_value = 100; 滑.step = 10; 滑.value = 60
滑.显示刻度 = true     # 画离散刻度点（按 step 自动算，>40 个就不画）
滑.刻度数 = 0          # 想手动指定刻度段数就设这里
滑.显示数值 = true     # 按住/悬停时手柄上方出现数值气泡
滑.气泡字号 = 20       # 在 1920 画布下 14 太小，按需调大
```

设置页的两条音量滑块已经开了 `显示数值`、`气泡字号 = 20`（那里标签字号是 26，14 会显得很小）。

### 一个容易踩的坑：`has_focus()` ≠ `:focus-visible`

参考实现里手柄变细用的是 CSS 的 `:focus-visible`（**只有键盘切过来的焦点**才算）。
Godot 没有对应概念，直接用 `Control.has_focus()` 会出事：**鼠标点一下滑块也会给它焦点**，
于是手柄被永久锁在按下宽度（2dp），之后再怎么悬停都不会放大，移开也不回弹。

所以这里自己判：`focus_entered` 时看 `Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)`——
按着鼠标拿到的焦点是点出来的，不算；`drag_started` 时也直接清掉这个标记。

轨道两端各留出手柄一半，所以 0% 和 100% 时手柄不会探出控件外。

> 实现方式：把 `slider` / `grabber_area` / `grabber` 等内建 StyleBox 全部换成
> `StyleBoxEmpty`，所有绘制改由 `_draw()` 完成 —— 这样既保留了 `HSlider` 的取值、
> 拖动和信号，外观又能完全自己控制。

## 底部导航栏（`M3NavigationBar`）

官方规格（`m3.material.io/components/navigation-bar`）：容器 **80dp 高**、`surface_container` 底；
项目指示器 **64×32dp 胶囊**、图标 24dp、文字 label-medium。

**项目的解剖结构和侧边轨道一模一样**（图标在上、文字在下、胶囊指示器），
所以底栏的项目**直接复用 `M3NavigationRailItem`** —— 一并拿到了指示器颜色过渡、
预乘 alpha 淡入淡出（不会闪黑）、图标名字形、悬停/按下状态层。

```gdscript
底栏.项目 = PackedStringArray(["消息", "通讯录", "发现", "我"])
底栏.图标名 = PackedStringArray(["message", "account-multiple", "compass", "account"])
底栏.切换.connect(func(索引): ...)
```

| 导出 | 默认 | 说明 |
|---|---|---|
| `项目` / `图标名` | 消息/通讯录/发现/我 | 自动生成用；`图标名` 可以比 `项目` 短 |
| `当前索引` | 0 | |
| `字号` | 20 | |
| `指示器尺寸` | `Vector2i(64, 32)` | 官方胶囊尺寸 |
| `图标大小` | 24 | |
| `项目最小尺寸` | `Vector2i(64, 64)` | |

也可以自己往里放 `M3NavigationRailItem` 子节点（放了就不按 `项目` 生成）。
不是 `M3NavigationRailItem` 的普通按钮会走兜底套色（老用法）。

## 侧边导航轨道（`M3NavigationRail` / `M3NavigationRailItem`）

外观照官方规格（`m3.material.io/components/navigation-rail/specs`）：

| 部件 | 规格 |
|---|---|
| 容器 | 96dp 宽（窄版 80dp）、`surface_container_low` 底、**16dp 圆角**、`outline_variant` 细描边、内边距 16×8dp |
| 项目 | 最小 **48×64dp**，指示器与文字间距 8dp |
| 指示器 | **56×32dp 胶囊**（CornerFull）；选中 `secondary_container`，未选透明 |
| 图标 | **24dp**；未选 `on_surface_variant` / 选中 `on_secondary_container` |
| 文字 | label-medium（官方 12sp，这里默认 18 以适配 1920 画布），居中在指示器下方 |
| 悬停 | `on_secondary_container` @8%（按下按选中态算，见下）；选中项悬停是两者混合 |

**图标推荐用「图标名」（字体字形），别用贴图。**
项目里装了 [Godot-Material-Icons](https://github.com/rakugoteam/Godot-Material-Icons)
（`addons/material-design-icons/`），轨道项目加了 `图标名` 属性：

```gdscript
轨.图标名 = PackedStringArray(["message", "account-multiple", "compass", "account"])
项.图标名 = "home"          # 手动模式时逐个设
```

字形是 `draw_string` 画的、颜色直接传进去，所以：

- **跟着前景色走**（未选 `on_surface_variant` / 选中 `on_secondary_container`），不用管图标本身什么颜色；
- 不像贴图那样要靠 `modulate` **相乘** —— 贴图如果本身是 `#6aff7c` 这类有色图标，
  乘上深色前景就会**变黑**（这个坑踩过）。非要用贴图的话，图标必须是白色单色。

名字去哪查：编辑器菜单 **工具 → Find Material Icon**（插件装的，能搜能预览）。
实现在 `core/m3_icons.gd` —— 它自己读字体和 `icons.json`，
**不依赖**插件注册的 `MaterialIconsDB` 自动加载（那个是编辑器插件装的，导出时不一定在）。
插件没装也不会炸：`M3Icons.可用()` 返回 false，自动退回 `图标` 贴图、再退回纯文字胶囊。

**两种用法：**

```gdscript
# ① 自动生成：填数组就行
轨.项目 = PackedStringArray(["消息", "通讯录", "发现", "我"])
轨.图标名 = PackedStringArray(["message", "account-multiple", "compass", "account"])
# 也还能用贴图：轨.图标 = [图1, 图2, 图3, 图4]（可留空，或比 项目 短）

# ② 自己往里放：在编辑器里把 M3NavigationRailItem 加成轨道的子节点，
#    然后把 手动项目 打开。顺序 = 场景树顺序。
轨.手动项目 = true
```

- `手动项目 = false`（默认）时，轨道会用内部 VBoxContainer 按 `项目` 生成；
- `手动项目 = true` 时，轨道**不动你的节点**，只接手它们的选中状态、颜色和排版：
  - 直接放轨道里的 `BaseButton` 由**轨道自己排版**（固定 64dp 高、整体居中，不拉伸）；
  - 先放一个 `VBoxContainer` 再把项目塞进去也行——那就交给容器排版（想用 GridContainer 之类也随便）。
- **没设图标会自动退化成「胶囊包文字」**，不会出现一个空胶囊。

### 两个已经踩过的坑（都跟「点下一个时新旧两项一起闪一下」有关）

**坑 1：过渡不能用 `Color.lerp` 从透明黑插值。**
`Color(0,0,0,0)` 的 RGB 是**黑**，直接 `lerp` 到淡紫 `dbe2f9`，中间会经过

```
(0,0,0,0) ──lerp──> (0.86,0.89,0.98,1)
        中点 ≈ (0.43,0.44,0.49,0.5)   ← 深灰
```

新项淡入、旧项淡出**都要穿过黑色**，看起来就是「两个按钮都闪一下暗的」。
所以 `_混色()` 改成**按预乘 alpha 插值**（色相不变、只有透明度在变）：

```gdscript
var a := lerpf(当前.a, 目标.a, k)
var pr := lerpf(当前.r * 当前.a, 目标.r * 目标.a, k) / a
# g、b 同理
```

**坑 2：按下时不要先给一层独立的状态层。**
`button_down` 比 `toggled` 早，如果未选中项按下时先画
`on_secondary_container @12%` 的深灰层，就会「先闪深灰再变淡紫」。
轨道项目按下即选中，所以 `指示器色()` 里把 `_按下中` 直接**按选中态算**。

`M3NavigationRailItem` 也能单独当开关按钮用（`button_pressed` / `toggled`）。

### 悬停态不能重新生成样式box

按钮的 `normal` / `hover` / `pressed` 三个样式box要**形状一致、只换底色**。
早期 `hover` 是直接 `M3Theme.状态层(底色, 叠加色, 圆角, 0.08)` 生成的 ——
那会造出一个**全新的、没有描边也没有阴影**的样式box，于是：

- 描边按钮一悬停，**黑边就没了**；
- 抬升按钮一悬停，**阴影就没了**。

正确写法是先 `duplicate()` 普通态，再只改 `bg_color`：

```gdscript
var 悬停: StyleBoxFlat = 普通.duplicate() as StyleBoxFlat
悬停.bg_color = M3Theme.状态层色(_底色(), 状态叠加, M3Motion.状态_悬停)
```

`M3Theme.状态层色()` 是只算颜色的版本（`状态层()` 会顺手生成样式box，
需要保留描边/阴影时别用那个）。

### 涟漪为什么要单独一层遮罩

`M3Button` 的涟漪不是直接加到按钮上的，而是放在一层 **`Panel` 遮罩**里：

```gdscript
_涟漪层 = Panel.new()
_涟漪层.clip_children = CanvasItem.CLIP_CHILDREN_ONLY   # 只拿它裁剪，不显示它
_涟漪层.add_theme_stylebox_override("panel", M3Theme.样式(Color(1,1,1,1), 圆角值))
_涟漪 = M3Ripple.new()
_涟漪层.add_child(_涟漪)
```

两种走不通的做法，都踩过：

| 做法 | 结果 |
|---|---|
| 只 `clip_contents = true` | 只按**矩形**裁 —— 涟漪铺满时圆角外面那四块也被染色，**看起来是个方块** |
| `clip_children = CLIP_CHILDREN_AND_DRAW`（拿按钮自己画的当遮罩） | 描边/文字按钮本身是透明的，只画了一圈边框和文字，**涟漪被裁得只剩边框** |

遮罩层用 `CLIP_CHILDREN_ONLY`：它画的圆角矩形**只用于裁剪、不会被显示**，
涟漪就正好被裁进圆角里。圆角改了要在 `_刷新样式()` 里同步（`_同步涟漪遮罩()`）。

### 开关（`M3Switch`）

- **`toggle_mode` 必须在 `_init()` 里设**，不能放 `_ready()`。
  Godot 的 `BaseButton.set_pressed()` 在 `!toggle_mode` 时**直接 return**，
  而场景里存的 `button_pressed = true` 是在 `_ready` **之前**应用的 ——
  放 `_ready` 就晚了，那个 `true` 会被丢掉，开关永远显示成关。
- **静默改状态（`set_pressed_no_signal`）要靠 `_process` 轮询补动画，不能靠 `_draw` 兜。**
  `set_pressed_no_signal()` **不发信号**，`_进度` 只在 `toggled` 里更新，于是设置页那种
  `全屏开关.set_pressed_no_signal(Settings.全屏)` 会出现：**开关开着却画成关；
  点一下真的把它关掉时，因为本来就画在 0，看起来"没反应、还是关的样子"**。

  ⚠️ 修的时候**别**图省事在 `_draw`/取值函数里写「没在跑补间就直接读 `button_pressed`」——
  `button_pressed` 是**先变状态、后发 `toggled`** 的，`_动画到()` 里读到的已经是新值，
  起点和终点相同 => **从 1 动画到 1，开关就不动了**（这个坑也踩过）。
  正确做法：
  - `_进度` 始终是**唯一真相**，`_draw` 只看它；
  - `_动画到()` 的起点用 `_起值 = _进度`（上次真正画出来的值）；
  - 另开一个 `_上次按下`，在 `_process` 里每帧比一下 `button_pressed`，
    发现被静默改了就补一次 `_动画到()`。
- **要清掉自带样式box**：场景里的节点类型常常还是 `Button`（只是换了脚本），
  那样 Godot 的 `Button` 本体照样会画 `normal`/`hover` 底色 —— 开关后面就会多一块方背景。
  `_ready()` 里 `_清空样式()` 把这几个样式box全换成透明。
- **不能直接用 `size` 画轨道**：放进 `HBoxContainer` 会被纵向拉伸，轨道一高半径就跟着变大，
  胶囊会变成圆角方块、拇指也跑到中间。所以按 `轨道宽/轨道高` 画，并在给定矩形里居中。

### 一个容易踩的坑：缓存色 + `set_pressed_no_signal`

项目为了做「指示器颜色过渡」缓存了一份 `_实指示`（每帧往目标色靠）。但轨道切换选中用的是
**`set_pressed_no_signal()`** —— 它**不发信号**，项目自己不知道状态变了，缓存色就留在原地，
表现为「**两个甚至三个胶囊同时亮着**」（悬停过的那一项缓存正好收敛成了选中色，再点别人它就赖着不走）。

三处一起修：
1. 轨道 `_刷新选中()` 里对每一项显式调 `刷新外观()`，强制刷新缓存；
2. 项目新增 `当前指示色()` / `当前前景色()`：**补间中**用插值、**不在补间**就直接用目标色 ——
   即使有人绕过信号改了状态，也不会留下旧胶囊；
3. `_draw()` 改用这两个取值。

> 这类「缓存了派生状态、又用不发信号的方式改源状态」的组合很容易出问题，
> 以后再加类似过渡动画时记得同步刷新。

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

`M3Button` 的状态层 / 涟漪颜色**默认用浅色 `secondary_container`（`dbe2f9`）**：

| 变体 | 状态层颜色 | 峰值不透明度 | 满铺后的实际色 |
|---|---|---|---|
| Filled | `secondary_container` | `0.55 × 0.32` = 0.176 | `#2771d0` |
| Tonal | `on_secondary_container` | `0.55 × 0.22` = 0.121 | `#c3cae0` |
| Outlined / Text / Elevated | `secondary_container` | 0.55 | `#ebedfc` |

**为什么不直接用官方的 0.12？** 官方每个变体取的是 `on-primary` / `on-secondary-container` /
`primary` 这类**深色**状态层色，本身就是按 `pressed-state-layer-opacity = 0.12` 配的。
换成浅色 `dbe2f9` 之后 0.12 铺在浅底上几乎看不见，所以基准抬到 0.55 再按变体压。
两套都记在这里，想切回官方：

```gdscript
M3Theme.涟漪颜色 = Color(0, 0, 0, 0)   # 0 = 按变体自动（官方映射）
M3Theme.涟漪不透明度 = 0.12
```
（单个按钮想单独设就用它的 `点击颜色` / `涟漪不透明度`。）

> ⚠️ 场景里如果**存了旧的覆盖值**，会盖掉这里的全局设置。
> 比如 `测试.tscn` 曾经存过 `"涟漪不透明度" = 0.55`，配上官方的白色状态层
> 就会变成「整颗按钮发白」——排查这类问题时先看场景里有没有存过值。

### 涟漪（`M3Ripple`）—— 照 Material Web 官方实现

参数取自 Google 官方 Web 组件库 [`material-components/material-web`](https://github.com/material-components/material-web)
的 `ripple/internal/ripple.ts`，不是 mdui 那套近似：

| 官方常量 | 值 | 含义 |
|---|---|---|
| `PRESS_GROW_MS` | **450ms** | 生长时长，`standard` 缓动 |
| `MINIMUM_PRESS_MS` | **225ms** | 按住不足这么久，松手也要等满再淡出 |
| `INITIAL_ORIGIN_SCALE` | **0.2** | 起始直径 = `max(宽,高) × 0.2` |
| `PADDING` | **10px** | 最大半径 = 对角线 + 10 |
| `SOFT_EDGE_MINIMUM_SIZE` / `SOFT_EDGE_CONTAINER_RATIO` | **75px / 0.35** | 软边宽度 = `max(0.35 × max(宽,高), 75)` |
| 淡入 / 淡出 | **105ms / 375ms** | 都是 linear |

**两条和旧实现最重要的差别：**

1. **从点击点一边长一边移到元素中心**（官方 keyframes 就是 `translate(点击点) → translate(元素中心)`）；
2. **涟漪是径向渐变软边**（实心到半径 65%，再渐隐到边缘），不是硬边实心圆。
   这一条是「点下去像一块方块」的根因：硬边实心圆铺满后就是一整片色块，
   而软边铺满时看起来仍然是一圈波。实现上直接用 `GradientTexture2D` 的
   `FILL_RADIAL`，等价官方的 `radial-gradient(closest-side, ...)`。

> 顺带修掉的另一处：**按下态不再叠状态层**。MD3 里涟漪就是按下状态层，
> 两者叠起来会到 `0.10 + 0.12 ≈ 0.22`，整个按钮变成实心色。
> 现在按下态直接用普通底，反馈交给涟漪。

**四角覆盖兜底**：官方公式算出来的半径，在又大又扁的按钮上软边盖不满四角
（软边从 65% 半径就开始渐隐，而四角在对角线的一半处，正好落在渐隐区里）。
我们的涟漪比官方强得多，四角就会看出一圈「缺角」。所以额外兜一层：

```gdscript
_半径终 = maxf(_半径终, 对角线 × 0.5 / 实心比例 × 1.02)
```

实测（把涟漪冻结在满进度，采样中心 / 四角 / 上下中点）：

| 按钮 | 中心 · 四角 · 边中点 |
|---|---|
| 850×374 | 全部 `#236fcf` ✓ |
| 220×96 | 全部 `#2771d0` ✓ |
| 200×200 | 全部 `#2771d0` ✓ |

**怎么核对的**：除了读源码，还用无头 Edge 把官方 `@material/web` 组件真跑起来，
劫持 `Element.prototype.animate` 抓住涟漪动画本体并冻结到指定相位截图 ——
抓到的是 `target=div pseudo=::after dur=450`（每个按钮一条），
和这里的 `PRESS_GROW_MS = 450`、`::after` 径向渐变一致。
对照图在 `D:\临时\官方涟漪_*.png`。

**时长可以三层配置，从全局到单个按钮：**

| 层 | 在哪改 | 作用范围 |
|---|---|---|
| ① 全局（推荐） | **项目设置 → `m3/ripple`** | 整个项目所有按钮，不用改代码 |
| ① 全局（代码） | `M3Theme.涟漪扩散时长` 等静态变量 | 同上，程序里随时改 |
| ② 单个按钮 | 按钮检视器里的 **「涟漪」分组** | 只影响这一个按钮 |

按钮上的涟漪导出属性**默认都是 `-1` = 跟随全局**；设成 `0` 或正数才单独覆盖。
涟漪实例（`M3Ripple`）自己的那几个时长同理，也是 `-1` 跟随全局。

```gdscript
# 全局：一行改完，所有按钮都跟着变
M3Theme.涟漪扩散时长 = 0.8

# 单个按钮：只让这一颗慢慢铺开
按钮.涟漪扩散时长 = 1.5
```

| 项 | 全局变量 | 项目设置键 | 默认（官方） |
|---|---|---|---|
| 起始不透明度 | `M3Theme.涟漪不透明度` | `m3/ripple/opacity` | **0.12** |
| 生长时长 | `M3Theme.涟漪扩散时长` | `m3/ripple/grow_duration` | 0.45s |
| 淡入时长 | `M3Theme.涟漪淡入时长` | `m3/ripple/fade_in_duration` | 0.105s |
| 淡出时长 | `M3Theme.涟漪淡出时长` | `m3/ripple/fade_out_duration` | 0.375s |
| 最短按压 | `M3Theme.涟漪最小按压` | `m3/ripple/minimum_press` | 0.225s |
| 涟漪颜色 | `M3Theme.涟漪颜色` | — | 透明（按变体自动） |

> 项目设置里那几项由 `plugin.gd` 在 `_enter_tree` 时登记，
> 再由 `M3ThemeManager` 单例在启动时读进 `M3Theme`。
> 插件没启用、或没设过，就保持 `M3Theme` 里的默认值。

**实测时序**（96×215 的按钮）：

| 操作 | 实测 |
|---|---|
| 起始直径 | 43（= 215 × 0.2） |
| 最终半径 | 160（= 对角线 235 + 10 + 软边 75，再按比例缩放） |
| 生长 0→满 | 434ms |
| 轻点 | 225ms（补满最短按压）+ 375ms 淡出 ≈ 600ms |
| 按 300ms 松手 | 684ms 结束 |
| 按 800ms 松手 | 1185ms 结束 |

### 松手事件被吃掉时的兜底

`M3Button` 除了监听 `button_up`，按住期间还会用 `_process` 盯一下
`Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)`，松开了就自己收掉涟漪。

原因是：`M3ScrollStretch` 在拖拽滚动时会 `set_input_as_handled()` 把松手事件吃掉
（这是为了让「拖动 = 滚动，不算点击」），而 Godot 里 `_input` 比 GUI 派发**更早**，
于是按钮永远收不到 `button_up`，涟漪就一直停在满格——看起来就是「松手了还高亮着」。

触摸会模拟成鼠标左键（Godot 默认 `emulate_mouse_from_touch`），所以这一条同时覆盖鼠标和手指。
键盘激活（没有指针按下）时不会开这个兜底。

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

### 真·弹簧（Compose MotionScheme）

上面那组 `弹簧_*` 是「看起来像弹簧」的贝塞尔曲线。需要**真的弹**的时候用这一组，
它是二阶阻尼谐振子的**解析解**，数值取自 AndroidX Compose 的 `MotionScheme`：

```gdscript
# 预设：[阻尼比, 刚度, 质量]
M3Motion.弹簧方案["表现_空间_中"]   # 0.70 / 450 —— M3 Expressive 默认的空间位移
M3Motion.弹簧方案["标准_空间_中"]   # 1.00 / 700 —— 不过冲的标准方案

M3Motion.弹簧解(0.2, 0.7, 450.0)          # 自定义：t 秒时的位置（0→1，欠阻尼会 >1）
M3Motion.弹簧按预设(0.2, "表现_空间_中")   # 按预设名
M3Motion.弹簧时长(0.7, 450.0)             # 算稳定时间，用来决定 tween 跑多久
```

| 预设 | 阻尼比 | 刚度 | 过冲 | 稳定 |
|---|---|---|---|---|
| 表现_空间_慢 | 0.70 | 250 | 4.6% | 0.81s |
| 表现_空间_中 | 0.70 | 450 | 4.6% | 0.61s |
| 表现_空间_快 | 0.75 | 800 | 2.8% | 0.48s |
| 表现_效果_慢/快 | 1.00 | 800 / 1400 | 无 | 0.45 / 0.35s |
| 标准_空间_慢/中/快 | 1.00 | 300 / 700 / 1400 | 无 | 0.71 / 0.48 / 0.35s |

用 `tween_method` 驱动时把归一化时间乘回秒数即可，例如

```gdscript
补间.tween_method(
	func(t: float) -> void: 控件.scale = Vector2.ONE * lerpf(0.9, 1.0, M3Motion.弹簧按预设(t * 0.6, "表现_空间_中")),
	0.0, 1.0, 0.6)
```

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
