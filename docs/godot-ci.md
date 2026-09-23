# GitHub Godot CI

Push 與 PR 會在 Ubuntu 安裝 Godot 4.6.1，先以 `--headless --editor --path . --quit` 匯入資源，再執行 `bash tests/run_tests.sh`。Python 測試會找到 `/usr/local/bin/godot`，執行引擎內的通關、分支、對話與 UI 回歸。

CI 找不到 Godot 會直接失敗，不能以略過引擎測試的方式通過。測試輸出保存為 Actions 的 `godot-test-log` 附件；整個測試工作上限為 25 分鐘。`tee` 保存日誌時仍保留測試失敗的退出碼。

這些是無視窗的自動測試，不取代真人遊玩、畫面美感、GPU 或實體手機驗收。CI 測試的是推送的提交，不包含尚未提交的本機遊戲變更。
