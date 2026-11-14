# Swap Bros 联机分支

- 本目录是 `GJKen/SwapBros` 的独立 fork，以子模块接入 Broforce-Mods；上游为 `alexneargarder/BroforceMods`，许可证保留 GPL-3.0。
- 本任务只修改 `Swap Bros Mod/` 及本分支入口文档；不得顺带修改上游其它插件。
- 说明、构建与验收入口见 [README.multiplayer.md](README.multiplayer.md)。
- 本地控制器编号用于读取按键；联机玩家编号用于生成角色和保存运行中的选角状态。换人操作必须由玩家拥有端发起。
- 构建产物和编译工具放在 `Swap Bros Mod/bin/`，任务证据放在 `Swap Bros Mod/docs/evidence/`；不把游戏 DLL 纳入 Git。
- 部署前先关闭两端游戏并确认进程退出；保留原有键位和设置文件，不新增重复安装目录。
- 修复部署后等待用户手动验收；按反馈最小调整，再请用户验收。未得到明确通过前不得把 issue 标为完成。
- `Swap Bros Mod/issues/` 与 `Swap Bros Mod/docs/` 同级，只保存问题记录；独立 PR 回执放在 `Swap Bros Mod/docs/publication/`，保留原有本地材料不推送的范围。
- 验收通过后清理本任务临时文件、备份和运行时对象，保留必要的 issue 与验证记录。
