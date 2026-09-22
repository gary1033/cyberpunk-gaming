# Windows 試玩版匯出紀錄

日期：2026-09-09。

## 交付

- ZIP：C:/GameBuilds/NEON-MEMORIES-Windows-2026-09-09.zip
- 解壓後執行 NEON-MEMORIES.exe；保留 .pck 與附屬文件，玩家不需要安裝 Godot。
- ZIP 大小：188,487,877 bytes（約 188 MB／179.8 MiB）。
- SHA256：A096251FC0CF2BC39A4378A615FA583F955B0B69716B63CC4787A2B7ACE9D896
- 附繁中試玩說明、Godot 與第三方授權、現有音樂來源紀錄；沒有開發者存檔。
- 使用現有工作目錄內容匯出，包含尚未提交的最新第二章分流內容；未提交或推送 Git。

## 設定

Godot 4.6.1 官方 Windows x86_64 release，Compatibility renderer，獨立 exe + PCK。新增本機 export_presets.cfg；它沿用既有 .gitignore 規則而未納入追蹤，備份位於驗證資料夾。匯出全部遊戲資源，排除 tests、tools、docs、assets/generated。未修改劇情、程式或圖片。

官方範本下載自 https://github.com/godotengine/godot-builds/releases/tag/4.6.1-stable ，與該版 SHA512-SUMS.txt 比對通過。Windows x86_64 範本安裝於使用者 AppData/Roaming/Godot/export_templates/4.6.1.stable；完整下載保留 C:/GameBuilds/template-cache。

## 驗證

- tests/test_data_integrity.py：941 通過，0 失敗，0 警告，含七條新遊戲路線與存讀檔檢查。
- Godot 匯入與正式匯出 exit 0，匯出紀錄無 ERROR／WARNING。
- ZIP 重新解壓縮，每個檔案 SHA256 與匯出資料夾一致。
- 使用同版 Godot 引擎載入重新解壓的正式 PCK，再執行既有通關測試：七條路線及負向／存讀檔檢查通過，exit 0。此為封包資源驗證，不宣稱 release exe 執行了測試腳本；官方 release 的命令列覆寫受到限制。
- Windows release exe 原生啟動成功，使用 RTX 3060 Ti／OpenGL 3.3。以 --quit-after 自動強制結束時 exit 0，但出現 ObjectDB 與 2 resources still in use 的清理訊息；保留 launch.log 追蹤。尚未完成另一台電腦的真人試玩或正常視窗關閉驗證。
- 完整記錄與匯出設定備份：C:/GameBuilds/verification-2026-09-09。

## 剩餘缺口與下一步

把 ZIP 交給 Windows 玩家，確認新遊戲、字體／畫面、音樂、存檔後重啟續玩。回報版本、地點、操作步驟、截圖與能否重現。後續追蹤關閉時資源清理訊息；第三章深化分流、既有四段短音效與介面缺口維持原進度，不屬本輪新增內容。
