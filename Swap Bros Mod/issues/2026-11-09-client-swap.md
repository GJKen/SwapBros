# 联机加入方无法使用 Swap Bros 切换角色

## 状态

首轮 2.1.6 修复已部署，用户反馈本机 UMM 面板不显示角色按钮。已定位为菜单错误地按原始控制器编号分组，2.1.7 最小修正已编译并部署到双端。用户随后明确确认联机中房主、加入方切换自定义角色均正常，修复按该范围验收通过。英文上游 PR 与本地记录见 [PR 独立记录](../docs/publication/2026-11-09-client-swap-pr/README.md)，本地 issue 和证据不推送。

## 现象与根因

房主能够通过 Swap Bros 换人，加入方使用相同操作不能正常切换。此前现场读到加入方本地玩家 `playerNum=1`、`controllerNum=0`、`IsMine=True`，而快捷键只配置在本地 Player 0。

上游 `Player.GetInput` 补丁错误地使用联机 `playerNum` 查询本地按键，菜单也直接把本地选项序号当作联机玩家序号；同时没有限制换人入口只操作本机拥有的玩家。游戏 `Player.InstantiateHero` 本身只允许拥有端生成角色。

## 范围与实现

- 从上游 `alexneargarder/BroforceMods` 创建 `GJKen/SwapBros` fork，并作为 `SwapBrosMultiplayer` 子模块引入；基线提交为 `822239f8a2141a5fa04e2601d1a92cb19f5566a9`。
- 按 `controllerNum` 读取键位；2.1.7 菜单按本机拥有的玩家顺序映射到运行中的 `playerNum`，键位编辑对应其真实控制器，选角和换人标记继续按联机玩家保存。
- 输入、生成设置补丁、冷却更新和公开换人 API 只处理本机拥有的玩家；无角色时不进入输入和冷却逻辑。
- 保留 `Main.GetSelectedBroHeroType(int)` 给当前 CustomMapMultiplayer 使用，远端玩家返回 `HeroType.None`，避免读取本机选角覆盖远端。
- 首轮版本为 2.1.6，当前菜单修正版本为 2.1.7；保留原 Mod Id、程序集名称、键位和配置路径。
- 不修改 BroMaker、RocketLib、CustomMapMultiplayer 或 Aquabro，不引入新的角色生成协议。

## 验证与部署

- 编译：Roslyn 4.8.0、.NET 3.5，最终编译成功且无警告/错误；产物 29,696 字节。修正了构建脚本将 `/noconfig` 放在响应文件内导致默认框架引用重复的问题。
- 2026-11-09 01:58 +08:00 部署到本机和 5700G 各自原有的 `UMM/Mods/AlexN-Swap_Bros/Swap Bros Mod/`，没有新增重复安装。操作前通过本机 CIM、远端 WMI 确认两端 Broforce 进程均为零；未启动游戏或创建运行时对象。
- 两端 DLL 的文件版本均为 2.1.6.0、Info.json 均为 2.1.6，文件大小正确；各自旧的 `Swap Bros Mod.dll.63487.cache` 已移至任务备份，不会继续加载旧缓存。原 DLL 和 Info.json 已分别备份，未修改用户键位和设置。
- [部署回执](../docs/evidence/client-swap-2026-11-09/deployment.json) 保存确认结果和两端备份路径。远端 `tasklist /S` 因认证失败未用于放行，最终以远端 WMI 查询确认为准。
- 首轮交付时用户手动验收待进行；后续 2.1.7 的用户通过结论见顶部及 PR 独立记录。

2026-11-09 04:14 用户进入游戏后反馈角色异常。当前本机 Aquabro 在出生初始化中被禁用，实际根因为另一项水墙修复的 Aquabro DLL 误用 .NET 4 反射 API；本轮未继续修改 Swap Bros。04:22 仅修正 Aquabro 构建并更新双端，本机离线初始化和移动通过，Swap Bros 联机切换仍待用户复验。对应记录位于 Broforce-Mods 的 `CustomBro/Aquabro/issues/2026-11-09-狂潮水墙联机挡停不同步.md`。

## 用户手动验收

1. 两端重新启动游戏，确认 UMM 中 Swap Bros 版本为 2.1.7。展开 `Local Player 1 Options` 应能看到角色按钮，键位编辑对应当前本地玩家的实际控制器；保留已有配置，不按联机 P2/P3 编号配置键位。
2. 本机当房主、5700G 加入：分别用快捷键左右切换，并由加入方打开 `Local Player 1 Options` 点击一个不同角色。
3. 确认只切换操作者自己的角色；两端看到的角色一致，房主角色不被加入方菜单或按键影响。
4. 交换房主和加入方重试；如使用自定义角色，分别试一次原版→自定义→原版。
5. 如常用 `Always spawn as chosen bro`，确认启用后死亡重生或重开关卡仍符合选择。离线快捷键和菜单也应继续正常。

记录用户结果后，只针对失败项做最小修改，再请用户验收。不得将编译成功或用户暂未回复视为验收通过。

## 2.1.7：本机 UMM 角色按钮不显示

用户澄清：角色本体并未消失，是 UMM 的角色选择按钮不显示。2026-11-09 04:37 读取当前双人游戏：本机 `playerNum=0`、`controllerNum=1`、`IsMine=True`；队友 `playerNum=1`、`controllerNum=0`、`IsMine=False`。Swap Bros 已有 58 个角色，`creatingBroList=False`，只有第一组选项展开。首轮 `GetLocalPlayerNum(0)` 返回 -1、`GetLocalPlayerNum(1)` 返回 0，截图中第一组仅显示 `Join this local player to choose a bro.`，角色列表被放到折叠的第二组。已确认是 2.1.6 菜单映射回归，与 Aquabro 水墙无关。

最小修正：菜单按本机拥有的玩家顺序分组，第一组始终对应本机第一个已加入的玩家；键位编辑继续使用该玩家真实的 `controllerNum`。选角和换人标记仍使用 `playerNum`；保留只有拥有端能换人的限制。无玩家的离线菜单继续使用原有预选项。没有修改角色生成、同步协议或用户配置文件。

2026-11-09 04:40 本轮编译成功，无警告或错误；DLL 29,696 字节，目标 `v2.0.50727`，MVID `87ec5967-7daf-48d3-bbe9-36e2500f5e1e`。04:41:32 双端 OS 确认零游戏进程后更新原安装目录 DLL / Info.json，读回版本均为 2.1.7、DLL 字节一致；仅将相应旧加载缓存移入本任务备份。Swap Bros 与 RocketLib 设置文件前后内容一致。远端 MCP 曾报告关闭成功但仍有 PID 16172，核对精确 EXE 路径后通过 WMI 终止，再次确认退出才部署。

证据：[修改前的菜单与玩家映射](../docs/evidence/client-swap-2026-11-09/menu-before.json)、[修改前截图](../docs/evidence/client-swap-2026-11-09/menu-before.png)、[编译日志](../docs/evidence/client-swap-2026-11-09/menu-build.log)、[部署回执](../docs/evidence/client-swap-2026-11-09/menu-deployment.json)。本轮未新增运行时脚本、补丁或输入保持；部署后两端游戏均关闭，未代替用户进行新版菜单和换人验收。用户通过前保留回退备份与工具，未提交或推送 Git。

## 清理

用户已确认通过，英文 [PR #6](https://github.com/alexneargarder/BroforceMods/pull/6) 已创建，仅上传三个相关源码文件。本 issue、独立 PR 记录及证据均未上传。首次批量强制删除被工具层以 `blocked by policy` 拒绝；2026-11-09 05:03 重新核对范围后，逐项使用不带 `Force` 的删除命令成功清理本任务 `bin/tooling/`、`bin/Release/build.rsp`、`bin/pr-check/` 和当时位于 `docs/issues/evidence/client-swap-2026-11-09/backups/` 的备份目录。四处读回均不存在，清理完成，实际结果见 [PR 清理记录](../docs/publication/2026-11-09-client-swap-pr/cleanup.json)。正式 DLL、源码和必要文档证据保留，当前未创建游戏运行时测试对象，不根据用户未提供的细节补写逐项验收。
