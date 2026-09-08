# 能量條一致性修復

更新：2026-09-08。AP 與鷹眼共用同一個固定外框，十格能量只改亮暗；兩格轉橘、一格轉紅，外框及閃電圖示維持原色。

## 根因與修改

舊版每個數值都換掉整張 `energy_bar_01…10.png`，圖中的外框比例、位置、圖示與光影本來就不同。舊測試只核對尺寸、透明通道、檔案副本與幾何紀錄，未比較真正的圖片像素。

- 使用 built-in `image_gen` 生成一張空外框。第一次輸出帶棋盤底，保留原始檔後以純綠背景重試，再本地去背、等比例縮放並置中至 512×96。
- 外框正式圖片在 `assets/generated/ui/energy_hud_frame.png` 與 `assets/sprites/ui/energy_hud_frame.png`；完整提示詞、重試指令及原始來源記在 [生成紀錄](../assets/generated/prompts/image_gen_energy_hud_fixed_frame_2026_09_08.json)。
- `SegmentedEnergyBar` 用同一套幾何繪製十格。兩個 HUD 不再讀取整張狀態圖，舊圖片保留為歷史素材。
- 真正零值顯示零格；正數不足一格仍顯示一格。20 AP 使用十格，每格代表 2 AP，旁邊數字保留精確餘量。
- 修正一格鷹眼不能啟動、快速重開被舊淡出藏掉，以及開啟鷹眼換場後顯示不同步。移除整個外框的變色與閃爍。

## 驗證

- Godot 4.6.1 headless：**135 項通過**，涵蓋零到十格、AP 20→0、逐秒扣格、充能、一格啟動、快速切換和跨場景顯示。
- RTX 3060 Ti / OpenGL 實際渲染：**351 項通過**。十一張畫面都有正確亮格；所有零值基準及相鄰狀態比較，**格子外變動像素均為 0**。高能量狀態每次只改一格；進入低量警示時只改剩餘亮格的顏色。
- 正式外框：512×96 RGBA，四角 alpha 全為 0，22,422 個透明像素，source/runtime 檔案完全一致。
- 完整資料與三結局回歸：**952 通過、0 失敗、1 警告**（既有家庭記憶音效佔位檔），三條結局路線仍全部通關。鷹眼結構檢查分數維持 273；分數不代替上述畫面驗證。

[十格到零格對照圖](verification/energy_hud_2026_09_08/all_states_10_to_0.png) · [像素比較資料](verification/energy_hud_2026_09_08/pixel_comparison.json)

重跑邏輯檢查：`python tests/test_data_integrity.py`。單獨重跑畫面檢查（PowerShell，`$godot` 指向本機 Godot console 執行檔）：

```powershell
& $godot --rendering-method gl_compatibility --audio-driver Dummy --path . --script res://tests/test_energy_hud.gd -- --render-check
```

本輪未驗收手機與網頁匯出版面。短時間開關重設耗能的漏洞已於後續修正，詳見[耗能與音效紀錄](energy_drain_and_audio_2026_09_08.md)；家庭記憶正式音效仍待替換，已有四段本機合成試聽。
