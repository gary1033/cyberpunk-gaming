# 2026-09-08 素材保存、路徑核對與程式碼重構

> 後續清理已完成：426 個舊檔已移至資源回收筒。下文保留清理前的核對與阻擋紀錄，現況以 C:/Projects/cyberpunk-gaming/docs/cleanup_completed_2026_09_08.md 為準。

## 完成結果

目前 149 張 PNG 與 3 首已採用配樂均有可找到的來源副本／原始下載，SHA-256 與遊戲使用檔一致。所有腳本／場景中的固定資源路徑，除下列已知可選音效缺口外均存在；HTML 預覽的固定本機連結通過核對。JavaScript 動態產生的預覽路徑不由字串掃描推斷，角色預覽改用現有 canonical source，50 張角色圖片由素材清單核對。

| 資料 | 正確位置與用途 |
|---|---|
| 專案入口 | C:/Projects/cyberpunk-gaming/project.godot |
| 遊戲實際圖片 | assets/sprites/characters、locations、items、cg、ui |
| 處理後來源 | assets/generated/characters、backgrounds、items、cg、ui；物品使用 ch1_ 前綴，背景來源叫 backgrounds，遊戲端叫 locations，這些命名差異有明確對照 |
| 生成原圖 | 現行角色的 unified_2026_09_08_*_raw.png，以及本輪保存的各分類 raw/ 子目錄；不依賴 Codex 外部資料夾才能取得已記錄原圖 |
| 完整提示詞與追溯 | assets/generated/prompts/；現行角色採 consolidated unification JSONL |
| 正式配樂與授權紀錄 | assets/audio/bgm/：原始 OGG 直接供遊戲使用，manifest.json 與 LICENSE.md 均保留 |
| 全部檔案對照 | assets/asset_manifest.json：152 筆相對路徑、來源、SHA-256、原圖和授權記錄 |
| 開發與驗證 | docs/；驗證日誌與畫面在 docs/verification/ |
| 玩家存檔 | user://saves/；本機實際解析為 C:/Users/gary1/AppData/Roaming/Godot/app_userdata/NEON MEMORIES/saves/，不放在專案或素材目錄 |
| Obsidian | C:/Users/gary1/OneDrive/桌面/obsidian/project開發/NEON MEMORIES |

路徑均以 C:/Projects/cyberpunk-gaming 為相對基準（表中明列絕對位置者除外）。可用 `python tools/audit_assets.py --report docs/verification/asset_storage_2026_09_08.json` 重跑核對。

## 保存與尚未補齊的來源

- 已從現有 Codex 圖片資料夾保存 81 份早期生成原圖，涵蓋現行素材與保留中的歷史版本，並把保存路徑及 SHA-256 寫回提示詞紀錄。
- 固定能量框使用的舊參考輸入另存於 assets/generated/ui/raw/energy_hud_reference.png，使參考輸入不依賴預計清理的舊 runtime 能量圖。
- 117 張圖片有獨立原圖追溯紀錄；另外 32 張（主要背景、部分 CG 與主選單背景）有處理後來源與遊戲檔，但現有紀錄沒有可核對的獨立生成原圖。未把來源副本假稱為完整原始輸出。
- 四個可選音效缺口：family_memory_fragment.ogg 是 55 bytes 佔位檔；broken_player_scan.ogg、eagle_eye_glitch_sting.ogg、memory_signature_reveal.ogg 尚不存在。音效呼叫會安全略過，沒有用被否決的試聽檔替補。
- 本輪核對的是已保存的音樂授權紀錄與檔案指紋，沒有重新作網路授權調查。

## 程式碼重構

- 將七份重複圖片載入器集中到 scripts/core/runtime_assets.gd，固定能量框也共用它；沒有新增 autoload 或外部套件。
- 優先由 Godot 載入匯入資源並重用內建資源快取，避免每次對話重新解碼同一 PNG。
- 修正打包後只有資源映射、沒有原始 PNG 時被 FileAccess 誤擋的問題；尚未匯入的 PNG 使用檔案 bytes 解碼，也可從 PCK 載入，不依賴絕對磁碟圖片路徑。
- 可選音效同樣接受已匯入的打包資源，保留原始 OGG 的短檔頭檢查以略過既有佔位檔。
- assets/generated/.gdignore 與 docs/.gdignore 讓 Godot 略過開發原圖與驗證圖片，不把它們當遊戲資源掃描；Git 仍保留原圖。Python 快取則由 .gitignore 排除。
- README 同步 37 件正式證據、18 個章節地點及本輪實測的 Godot 4.6.1 路徑；未接入的舊審訊原型不再當作已可玩的功能宣傳。

## 驗證

- 完整資料與 Godot 整合檢查：961 通過、0 失敗、0 警告，包含三條完整通關與 27 種家人尾聲組合。
- 新增實際 PCK 回歸：22 項通過，覆蓋原始 PNG／OGG 不存在時的資源映射、未匯入 PNG、空路徑、缺少檔案、錯誤類型與內建快取。
- Godot 4.6.1 編輯器匯入與腳本解析通過；桌面／兩種手機尺寸對話 GPU 驗證 36 項通過。
- 能量 GPU 驗證 357 項通過，各狀態外框與圖示區域像素不變；調整測試退出等待後無資源殘留錯誤。
- `git diff --check` 通過。沒有匯出範本，PCK 測試不等同已完成 Windows／手機／網頁正式發行包驗收。

## 清理尚未執行

使用者已要求刪除不用的檔案。已確認 421 個候選檔，約 305.9 MiB，包含舊能量圖、被否決的四段合成試聽、舊角色來源與重複中間檔、未接入或已被取代的腳本，以及對應快取／匯入 sidecar。

完整逐檔清單、理由、大小與指紋：docs/verification/cleanup_2026_09_08.json。這是待核對與執行的清單，不是已刪除清單；刪除時還必須同步移除相關舊測試要求與歷史清單引用。

**實際刪除數為 0。** 整批 PowerShell 刪除與縮小到三個明列完整路徑的刪除，都遭工具自動審核拒絕，回報 blocked by policy，沒有提供更具體原因。沒有改用其他方式繞過限制；已讓素材清單、場景映射與提示詞紀錄重新對齊仍存在的檔案。

下一步是解除工具刪除限制後完成清理並重跑測試；另需補上 32 張獨立原圖追溯與四個正式短音效。未 commit 或 push。
