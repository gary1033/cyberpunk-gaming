# NEON MEMORIES image2.0 Asset Prompts

These prompts are generated from game data and are intended for image2.0-style batch generation.

## Generation Defaults

- Backgrounds: generate at `1280x720`, output to `assets/sprites/locations/*.png`.
- Evidence items: generate at `1024x1024` on opaque image2-compatible backgrounds, then downscale/crop to `512x512` if needed.
- UI references: generate on opaque image2-compatible canvases, output to `assets/sprites/ui/*.png`.
- Runtime loaders prefer PNG and keep existing SVG as fallback.
- Local fallback renderer: `python tools\render_generated_assets.py` creates deterministic PNGs from these manifests when image2 credentials are unavailable.

## Backgrounds

### detective_office - 偵探辦公室

- Output: `assets/sprites/locations/detective_office.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '偵探辦公室' (detective_office): 你的辦公室，位於九龍延伸區的一棟老舊大樓裡。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### mei_ling_apartment - 林美玲的公寓

- Output: `assets/sprites/locations/mei_ling_apartment.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '林美玲的公寓' (mei_ling_apartment): 美玲和浩然合住的公寓。浩然的房間裡可能有線索。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### abyss_bar - 深淵酒吧

- Output: `assets/sprites/locations/abyss_bar.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '深淵酒吧' (abyss_bar): 東區地下三層的酒吧，霓虹紫色燈光和合成音樂。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### hao_ran_workshop - 浩然的工作室

- Output: `assets/sprites/locations/hao_ran_workshop.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '浩然的工作室' (hao_ran_workshop): 東區第七街地下的「永恆記憶」工作室。門鎖被破壞。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### east_district_street - 東區街道

- Output: `assets/sprites/locations/east_district_street.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '東區街道' (east_district_street): 雨中的東區街道。霓虹招牌照亮濕漉漉的路面。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### bitstorm_cafe - 比特風暴網咖

- Output: `assets/sprites/locations/bitstorm_cafe.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '比特風暴網咖' (bitstorm_cafe): 駭客聚集的地下網咖，三排老舊電腦散發著藍光。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### memory_black_market - 記憶黑市

- Output: `assets/sprites/locations/memory_black_market.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '記憶黑市' (memory_black_market): 隱藏在廢棄地鐵站的地下市場。各種非法記憶在這裡交易。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### abandoned_warehouse - 廢棄倉庫

- Output: `assets/sprites/locations/abandoned_warehouse.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '廢棄倉庫' (abandoned_warehouse): 回聲網路的據點之一。裡面堆滿了記憶提取設備。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### zhengtek_exterior - 正和科技大樓外圍

- Output: `assets/sprites/locations/zhengtek_exterior.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '正和科技大樓外圍' (zhengtek_exterior): 正和科技總部的後門區域。趙明在這裡等你。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### sewer_passage - 下水道通道

- Output: `assets/sprites/locations/sewer_passage.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '下水道通道' (sewer_passage): 連接各個地下場所的秘密通道。潮濕、黑暗，偶爾有老鼠經過。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### echo_network_hq - 回聲網路總部

- Output: `assets/sprites/locations/echo_network_hq.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '回聲網路總部' (echo_network_hq): 地下第十層的高科技設施。冰冷的白色走廊和嗡嗡作響的伺服器。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### secret_lab - 正和科技秘密實驗室

- Output: `assets/sprites/locations/secret_lab.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '正和科技秘密實驗室' (secret_lab): 記憶覆寫技術的核心實驗室。蕭博士的領地。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### memory_space - 凱的記憶空間

- Output: `assets/sprites/locations/memory_space.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '凱的記憶空間' (memory_space): 鷹眼觸發的內心空間。碎片化的記憶在這裡漂浮。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### rooftop - 屋頂

- Output: `assets/sprites/locations/rooftop.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '屋頂' (rooftop): 正和科技大樓的屋頂。風雨交加。城市的霓虹燈在遠處閃爍。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### office_epilogue - 偵探辦公室（尾聲）

- Output: `assets/sprites/locations/office_epilogue.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Full-screen parallax-ready background for location '偵探辦公室（尾聲）' (office_epilogue): 一切結束後。你的辦公室，雨還在下。. Wide establishing shot, empty playable scene, clear foreground/midground/background layers, soft rain reflections, subtle investigative hotspots implied by lighting, leave lower 25 percent readable for UI.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

## Evidence Items

### commission_letter - 美玲的委託信

- Output: `assets/sprites/items/commission_letter.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '美玲的委託信' (commission_letter): 林美玲寫的委託書，詳述弟弟林浩然三天前失蹤的情況。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### work_id - 浩然的工作證

- Output: `assets/sprites/items/work_id.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '浩然的工作證' (work_id): 林浩然的記憶技師執照，隸屬於「永恆記憶」工作室。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### receipt - 深淵酒吧的收據

- Output: `assets/sprites/items/receipt.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '深淵酒吧的收據' (abyss_receipt): 三天前在深淵酒吧的消費收據，有一間包廂的預約紀錄。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### data_chip - 加密的數據晶片

- Output: `assets/sprites/items/data_chip.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '加密的數據晶片' (data_chip): 在浩然工作室中找到的加密晶片，內容無法直接讀取。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### photo - 陌生人的全息照片

- Output: `assets/sprites/items/photo.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '陌生人的全息照片' (stranger_photo): 酒吧監控截圖，一個戴著全息面具的人與浩然會面。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### log - 記憶提取設備使用紀錄

- Output: `assets/sprites/items/log.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '記憶提取設備使用紀錄' (memory_device_log): 浩然工作室的設備日誌，顯示近期大量非授權的記憶提取操作。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### recording - 損壞的通訊錄音

- Output: `assets/sprites/items/recording.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '損壞的通訊錄音' (comm_recording): 一段部分損壞的加密通話錄音，能隱約聽到「回聲」和「交貨」等字眼。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### schedule - Dr. 陳的預約紀錄

- Output: `assets/sprites/items/schedule.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for 'Dr. 陳的預約紀錄' (dr_chen_schedule): 浩然同事 Dr. 陳的診所預約表，顯示浩然最後一天有一個「特殊客戶」預約。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### symbol - 回聲網路標記符號

- Output: `assets/sprites/items/symbol.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '回聲網路標記符號' (echo_symbol): 回聲網路的識別標記——一個螺旋形的音波圖案。在多個地下場所的牆上都見過。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### memory_capsule - 記憶樣本

- Output: `assets/sprites/items/memory_capsule.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '記憶樣本' (memory_sample): 一個記憶樣本膠囊，裝著某人的一段記憶。用鷹眼可以預覽片段。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### map - 廢棄倉庫位置地圖

- Output: `assets/sprites/items/map.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '廢棄倉庫位置地圖' (warehouse_map): 標記了回聲網路在東區廢棄倉庫據點位置的地圖。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### diary - 浩然的個人日記

- Output: `assets/sprites/items/diary.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '浩然的個人日記' (hao_ran_diary): 部分加密的電子日記，記錄了浩然加入回聲網路的經過和越來越深的不安。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### ledger - 交易帳本副本

- Output: `assets/sprites/items/ledger.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '交易帳本副本' (trade_ledger): 記憶黑市的交易記錄副本，記載了大量記憶買賣的細節和金額。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### memo - 正和科技內部備忘錄

- Output: `assets/sprites/items/memo.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '正和科技內部備忘錄' (zhengtek_memo): 正和科技關於「回聲計畫」的內部備忘錄，提到了記憶技術的「特殊應用」。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### list - 受害者名單

- Output: `assets/sprites/items/list.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '受害者名單' (victim_list): 被提取記憶的受害者名單，有些人標記為「已完全提取」。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### frequency - 回聲網路通訊頻率

- Output: `assets/sprites/items/frequency.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '回聲網路通訊頻率' (comm_frequency): 回聲網路內部通訊的加密頻率，可用於追蹤他們的活動。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### key - 生鏽的電子鑰匙

- Output: `assets/sprites/items/key.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '生鏽的電子鑰匙' (rusty_key): 在廢棄倉庫裡找到的電子鑰匙，上面刻著一個序號。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### id_chip - 偽造的身份晶片

- Output: `assets/sprites/items/id_chip.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '偽造的身份晶片' (fake_id_chip): 小鬼製作的偽造身份晶片，身份為記憶收藏家「張偉」。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### report - 覆寫技術研究報告

- Output: `assets/sprites/items/report.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '覆寫技術研究報告' (overwrite_report): 蕭博士的記憶覆寫技術完整研究報告，詳述如何覆寫一個人的記憶和人格。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### funding - 正和科技資金流向

- Output: `assets/sprites/items/funding.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '正和科技資金流向' (zhengtek_funding): 正和科技向回聲網路秘密轉移資金的文件，證明了公司的直接參與。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### journal - 蕭博士個人日誌

- Output: `assets/sprites/items/journal.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '蕭博士個人日誌' (dr_xiao_journal): 蕭博士的個人日誌，記錄了他從理想主義神經科學家到瘋狂研究者的心路歷程。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### sos - 浩然的求救訊息

- Output: `assets/sprites/items/sos.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '浩然的求救訊息' (hao_ran_sos): 隱藏在記憶樣本中的求救訊息：「他們要覆寫我的記憶，救救我」。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### keycard - 實驗室門禁卡

- Output: `assets/sprites/items/keycard.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '實驗室門禁卡' (lab_keycard): 正和科技秘密實驗室的門禁卡，最高安全級別。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### profiles - 被覆寫者前後對比

- Output: `assets/sprites/items/profiles.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '被覆寫者前後對比' (overwritten_profiles): 數份被覆寫記憶的受害者資料，包含覆寫前後的人格對比。令人不寒而慄。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### ai_log - AI迴響對話紀錄

- Output: `assets/sprites/items/ai_log.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for 'AI迴響對話紀錄' (echo_ai_log): 實驗室中覺醒的人工智慧「迴響」與研究人員的對話紀錄。它聲稱擁有數千人的記憶碎片。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### memory_fragment - 凱的記憶碎片

- Output: `assets/sprites/items/memory_fragment.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '凱的記憶碎片' (kai_memory_fragment): 屬於凱·川崎的被篡改記憶碎片。你的過去可能不是你以為的那樣。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### authorization - 正和科技授權令

- Output: `assets/sprites/items/authorization.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '正和科技授權令' (authorization_order): 正和科技高層簽署的「回聲計畫」正式授權令，蓋有最高執行長印章。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

### comms - 蕭博士與高層通訊

- Output: `assets/sprites/items/comms.png`
- Canvas: `1024x1024`; target: `512x512`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. Opaque-background evidence item icon for '蕭博士與高層通訊' (dr_xiao_comms): 蕭博士與正和科技高層的加密通訊紀錄，討論記憶覆寫技術的「目標名單」。. Centered object, 3/4 view, crisp silhouette, cyan rim light, magenta secondary glow, game inventory icon, readable at 64px, isolated on a clean dark gunmetal studio background with a soft contact shadow.
- Negative: no characters, no readable text, no watermark, no real brand logos, no UI mockup labels, no blurry details, no low resolution, no extra frames

## UI

### dialogue_panel - Dialogue panel frame

- Output: `assets/sprites/ui/dialogue_panel.png`
- Canvas: `1536x1024`; target: `1280x240`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. UI reference asset: Dialogue panel frame (dialogue_panel), bottom dialogue box frame with portrait-safe side margins. Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset.
- Negative: no readable text, no watermark, no real brand logos, no rounded marketing cards, no fantasy ornament, no low contrast

### evidence_card - Evidence board card

- Output: `assets/sprites/ui/evidence_card.png`
- Canvas: `1024x1024`; target: `512x384`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. UI reference asset: Evidence board card (evidence_card), draggable clue card frame with cyan border and dark glass surface. Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset.
- Negative: no readable text, no watermark, no real brand logos, no rounded marketing cards, no fantasy ornament, no low contrast

### popup_panel - Map and investigation popup panel

- Output: `assets/sprites/ui/popup_panel.png`
- Canvas: `1024x1024`; target: `768x768`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. UI reference asset: Map and investigation popup panel (popup_panel), modal panel background for map and investigation choices. Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset.
- Negative: no readable text, no watermark, no real brand logos, no rounded marketing cards, no fantasy ornament, no low contrast

### toolbar_buttons - Toolbar button kit

- Output: `assets/sprites/ui/toolbar_buttons.png`
- Canvas: `1536x1024`; target: `1024x256`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. UI reference asset: Toolbar button kit (toolbar_buttons), six reusable cyberpunk button states for map, eye, evidence, investigate, hint, menu. Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset.
- Negative: no readable text, no watermark, no real brand logos, no rounded marketing cards, no fantasy ornament, no low contrast

### memory_preview_overlay - Memory preview overlay

- Output: `assets/sprites/ui/memory_preview_overlay.png`
- Canvas: `1280x720`; target: `1280x720`
- Prompt: NEON MEMORIES, cyberpunk noir detective adventure game, Hong Kong inspired Kowloon extension district, rain-soaked neon, cinematic 2D game asset, readable silhouettes, strong cyan and magenta accents, dark concrete and glass, high detail but not photorealistic, no text, no logos. UI reference asset: Memory preview overlay (memory_preview_overlay), glitchy translucent overlay for fragmented memory playback. Sleek dark translucent glass, thin cyan borders, magenta active accents, compact detective-game interface, mobile and desktop safe, arranged on a flat near-black studio background, export as clean game UI asset.
- Negative: no readable text, no watermark, no real brand logos, no rounded marketing cards, no fantasy ornament, no low contrast
