# 角色立繪一致化（2026-09-08）

狀態：已完成並接入遊戲。範圍為 CharacterData 已使用的 12 位角色、50 個表情；表情 ID 與劇情維持既有設定。本輪生成原始檔與既有 Kai 六表情候選均保留。

## 共同美術規格

- 參考：`assets/generated/characters/kai_hard_edge_sixpack/kai_default.png`。硬邊賽博龐克黑色漫畫風，清晰墨線、有限分階陰影、自然成人五官；小鬼維持 12 歲。
- 固定打光：畫面左上方中性偏冷主光、右側細窄青色輪廓光，鼻影向畫面右下方；保留膚色，不用整面青色或紫色染光。
- 統一輸出：1024×1536 PNG RGBA，胸至上腰半身，完整頭髮與雙肩。去背後將人物包圍盒等比縮放至畫布寬高的 90% 以內並置中，四周留透明安全距離；同角色各表情固定構圖。
- 同一角色的各表情固定臉型、年齡、髮型、髮流、義體左右、衣服、配件、視角和尺度；只改眉眼嘴及必要的細微表情。
- Kai：銀白髮朝畫面左側流動，義眼與耳部裝置固定畫面右側。以畫面座標避免左右眼文字矛盾。
- 禁止：翻轉圖、換臉、換衣服、手遮臉、新道具、文字、浮水印、背景場景、底板、棋盤格假透明、白邊、發光霧邊。
- 背景：要求真透明；若工具未輸出 alpha，僅接受純色 #00FF00 底並在本地去背。不得將不透明圖接入 runtime。

## 檔案與驗收

- 原始生成檔：`assets/generated/characters/unified_2026_09_08_<角色>_<表情>_raw.png`（保留，不作遊戲引用）。
- 可重試 prompt：`assets/generated/prompts/image_gen_character_unification_2026_09_08.jsonl`。
- 完成立繪：`assets/generated/characters/<角色>_<表情>.png` 與 `assets/sprites/characters/` 同名檔；全部 50 組 SHA256 相同。帶本輪日期前綴的透明成品亦保留，供本輪外觀追溯。
- 驗收：RGBA、1024×1536、四角 alpha=0、存在透明及不透明像素、完整頭髮與雙肩。半身下擺允許原圖底裁，使用 `-AllowBottomCrop` 後仍有完整透明邊界。
- 最終逐張統計：`assets/generated/prompts/character_unification_2026_09_08_validation.json`；最終 50 筆主 manifest 記錄完整 prompt、原始工具來源、raw/source/runtime 路徑、雜湊與驗收結果。各 group/retry JSONL 是生成當時紀錄，最終狀態以主 manifest 為準。
- 舊 runtime 身分參考圖取自 Git `406022105671fe931e93469db67dc22b2c6b51ec`；後續表情使用本輪保留的 default 原圖，避免換臉與衣服漂移。
- 可直接開啟 `docs/character_portrait_review_2026_09_08.html`，切換表情、深淺底或展開並排比較；預設讀取正式 runtime 圖片。

## 製作紀錄

- 盤點：既有 runtime 50 張，個別尺寸不一致。本輪統一尺寸與同角色表情輪廓。
- 原有未提交 Kai 候選與 style demo 刪除狀態保留；不納入本輪清理。
- 完成數：Kai 4、美玲 5、阿傑 5、蛇女 4、Dr. 陳 4、幽靈 4、趙明 6、小鬼 4、面具商人 3、蕭博士 6、浩然 4、迴響 1，共 50 張。逐張使用 built-in image_gen，保留重試原圖及 prompt。
- 修正：Kai 初次假透明、部分人物下擺／光向、Dr. 陳年齡，以及幽靈戒備／面具商人感興趣的辨識度。綠幕去背只在邊緣處理綠色溢光，保留蛇女等角色的合法深綠服裝。
- `python tests/test_data_integrity.py`：947 passed、0 failed、0 warnings；新增全角色真透明／尺寸檢查及去背助手回歸自測。
- Godot 4.6.1：50 張均透過 `DialogueSystem._load_character_portrait()` 載入成功、尺寸正確；第一章偵探事務所 headless 場景啟動通過。這是素材與載入驗收，未代表全劇情通關測試。
- 視覺驗收：全角色與同角色各表情已檢視，並以淺色背景檢查去背；同角色臉型、服裝與光向一致。部分收斂表情差異較細，美玲陰影相對柔和，均保留角色特性。
- 下一步：在實際桌面／手機對話框尺寸下做玩家視覺驗收，按回饋微調表情強度；浩然與姐姐設定中的年齡文字矛盾留待故事設定核對。
