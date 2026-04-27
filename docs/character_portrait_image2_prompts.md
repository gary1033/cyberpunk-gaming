# 角色立繪 image2.0 重新生成提示詞

目的：重新生成 `assets/sprites/characters/` 內所有角色表情立繪，解決舊圖切割後白邊、殘留背景、邊緣不乾淨的問題。

## 統一生成規格

- 模型：image2.0 / gpt-image-2，`background=opaque`
- 來源輸出格式：PNG，完全均一的 `#00ff00` chroma-key 背景，用於後處理去背
- 最終驗收格式：PNG，透明背景，保留 alpha channel
- 建議來源尺寸：1024x1536，後處理後可再縮放為遊戲 runtime 需要的立繪尺寸
- 構圖：胸像到半身，角色置中，完整頭髮與肩線不要被裁切
- 風格：cyberpunk noir anime portrait, cel-shaded, high detail, clean game character sprite
- 邊緣要求：角色與 `#00ff00` 背景清楚分離，後處理後需 clean alpha cutout、crisp silhouette、no white outline、no background residue
- 色彩限制：角色本體不可使用 `#00ff00`，避免去背誤刪
- 光影：可保留角色身上的霓虹光，但不可生成背景、光暈底圖、陰影或白色底
- 檔名策略：先輸出到 `assets/generated/characters/transparent_regen/`，驗收後再覆蓋 `assets/sprites/characters/`
- 參考圖：可使用 `assets/generated/characters/reference_sheets/` 中對應角色 reference sheet 作為角色一致性參考
- 批次生成來源：以 `assets/generated/prompts/image2_character_portraits.jsonl` 為準；下方表格保留角色設計文字，JSONL 會追加 chroma-key 去背指令。

## 通用負面提示詞

```text
white background, black background, gradient background, scenery, city background, room background, non-uniform green background, green tint on character, green clothing or accessories matching #00ff00, frame, border, white outline, halo outline, jagged edges, rough cutout, background residue, cropped hair, cropped shoulders, cut off head, full body, chibi, deformed hands, extra fingers, extra limbs, blurry, low resolution, watermark, logo, text, signature
```

## 生成檢查清單

- alpha 透明背景是否存在，而不是白底或黑底。
- 頭髮尖端、衣領、手指、面具邊緣沒有白邊。
- 同一角色的髮型、服裝、義體或配件與 reference sheet 一致。
- 表情變化只改臉部情緒與姿態，不改角色身份設計。
- Godot 匯入後不提交 `.import` 檔案，除非需要重新匯入設定。

## Kai Kawasaki / 凱·川崎

角色鎖定：28 歲亞洲男性私家偵探，凌亂銀白色帶淡藍髮絲，左眼鋼藍、右眼發光青色義眼，右太陽穴淡疤，右耳小型義體耳機，深海軍藍長外套、立領、青色霓虹縫線，黑色 V 領內搭，疲憊但銳利。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `kai_default.png` | default | Cyberpunk noir anime game character portrait of Kai Kawasaki, young Asian male detective age 28, messy silver-white hair with faint blue tint, side-swept spiky bangs, left eye steel blue, right eye glowing cyan cybernetic hawk-eye implant, faint scar near right temple, small right ear cyber implant with tiny LED lights, light tan skin, dark navy long coat with popped collar and cyan neon stitching, black V-neck undershirt, tired sharp neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kai_serious.png` | serious | Cyberpunk noir anime game character portrait of Kai Kawasaki, same character design and outfit, silver-white messy hair, glowing cyan cybernetic right eye, steel blue left eye, dark navy coat with cyan accents, black undershirt, stern serious expression with narrowed eyes and tense jaw, slightly forward detective posture, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kai_surprised.png` | surprised | Cyberpunk noir anime game character portrait of Kai Kawasaki, same silver-white hair, heterochromia with glowing cyan cybernetic right eye, dark navy coat with cyan neon trim, black V-neck undershirt, surprised expression, widened eyes, slightly raised brows, mouth slightly open as if discovering a clue, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kai_thoughtful.png` | thoughtful | Cyberpunk noir anime game character portrait of Kai Kawasaki, same detective design, messy silver-white hair, glowing cyan right eye implant, steel blue left eye, right ear cyber implant, dark navy coat with popped collar and cyan stitching, black undershirt, thoughtful expression, one hand resting against chin, analytical narrowed gaze, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Mei Ling Lin / 林美玲

角色鎖定：26 歲亞洲女性委託人，瓷白膚色，黑長直髮帶暗紫挑染，幾何厚瀏海，深棕眼，右耳粉紅發光科技耳環，深色結構外套、銳利翻領、桃紅霓虹飾邊，外表鎮定但焦慮。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `mei_ling_default.png` | default | Cyberpunk noir anime game character portrait of Mei Ling Lin, young Asian woman age 26, long straight jet black hair with subtle dark purple highlights, chunky geometric bangs, deep brown guarded eyes, fair porcelain skin, dark structured jacket with sharp lapels, hot pink neon accent trim and circuit patterns on shoulders, small glowing pink tech earring, composed neutral expression with restrained tension, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mei_ling_worried.png` | worried | Cyberpunk noir anime game character portrait of Mei Ling Lin, same black hair with purple highlights, geometric bangs, dark structured jacket with hot pink trim, glowing pink tech earring, worried expression with furrowed brows and tight lips, eyes looking slightly downward as if hiding fear for her brother, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mei_ling_nervous.png` | nervous | Cyberpunk noir anime game character portrait of Mei Ling Lin, same cyberpunk client design, long black hair, hot pink earring, dark jacket with pink neon accents, nervous expression, tense jaw, anxious eyes, shoulders slightly raised, one hand close to chest or collar, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mei_ling_relieved.png` | relieved | Cyberpunk noir anime game character portrait of Mei Ling Lin, same outfit and hair, deep brown eyes, glowing pink tech earring, relieved expression with softened brows and a small fragile smile, posture easing after pressure, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mei_ling_frightened.png` | frightened | Cyberpunk noir anime game character portrait of Mei Ling Lin, same black and purple hair, dark structured jacket with hot pink neon trim, glowing pink earring, frightened expression, wide eyes, parted lips, face slightly pale, shoulders tense as if hearing dangerous news, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Ajie / 阿傑

角色鎖定：35 歲壯碩亞洲男性酒保，古銅膚色，兩側剃短深棕 buzz cut，方下巴厚頸，雙臂橘色發光電路刺青，無袖黑背心、重型科技護腕，粗獷但觀察力敏銳。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `ajie_default.png` | default | Cyberpunk noir anime game character portrait of Ajie, muscular Asian male bartender age 35, shaved sides with dark brown buzz cut, tanned bronze skin, square jaw, thick neck, sharp observant dark eyes, glowing orange circuit tattoos covering both muscular arms, sleeveless black vest, heavy-duty tech wristbands, bartender towel over shoulder, calm watchful neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ajie_suspicious.png` | suspicious | Cyberpunk noir anime game character portrait of Ajie, same muscular bartender design, orange glowing circuit tattoos, sleeveless black vest, tech wristbands, suspicious expression, one eyebrow lowered, eyes narrowed sideways as if judging a lie, jaw clenched, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ajie_nervous.png` | nervous | Cyberpunk noir anime game character portrait of Ajie, same broad-shouldered cyberpunk bartender, buzz cut, glowing orange arm tattoos, sleeveless black vest, nervous expression, uneasy eyes, tense mouth, one hand near neck or towel as if hiding information, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ajie_angry.png` | angry | Cyberpunk noir anime game character portrait of Ajie, same muscular bartender design, orange circuit tattoos glowing brighter, sleeveless black vest, angry expression, brows deeply furrowed, teeth clenched, shoulders squared, intimidating but controlled, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ajie_cooperative.png` | cooperative | Cyberpunk noir anime game character portrait of Ajie, same cyberpunk bartender, orange glowing tattoos, sleeveless black vest, cooperative expression with softened eyes and restrained helpful half-smile, posture slightly open as if deciding to share information, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Snake / 蛇女

角色鎖定：神秘女性情報販子，外表約 20 多歲後段，蒼白發光膚色，深綠黑長髮，金琥珀直立瞳，蛇形上半臉面具，暗色旗袍式高領服裝，綠色蛇鱗刺繡，蛇牙耳環發綠光。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `snake_default.png` | default | Cyberpunk noir anime game character portrait of Snake, mysterious female information broker, very long dark green-black flowing hair, pale luminous skin, golden amber eyes with vertical slit pupils, ornate snake-shaped half mask covering upper face, snake fang earrings glowing green, form-fitting dark qipao-inspired dress with high mandarin collar and subtle green snake scale embroidery, enigmatic neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `snake_amused.png` | amused | Cyberpunk noir anime game character portrait of Snake, same snake mask, long dark green-black hair, amber slit pupils, dark qipao dress with green scale embroidery, amused expression with half-lidded eyes and knowing smirk, head slightly tilted as if enjoying a secret, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `snake_serious.png` | serious | Cyberpunk noir anime game character portrait of Snake, same cyberpunk information broker design, ornate snake half mask, glowing green earrings, dark qipao with scale embroidery, serious expression, eyes sharp and cold behind mask, lips flat, posture still and controlled, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `snake_threatening.png` | threatening | Cyberpunk noir anime game character portrait of Snake, same mysterious woman with snake half mask, amber slit eyes, long dark green-black hair, green glowing earrings, dark qipao, threatening expression, predatory narrowed eyes, dangerous smile, green neon accents slightly intensified on mask and earrings, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Dr. Chen / Dr. 陳

角色鎖定：32 歲亞洲男性記憶技師，瘦削過勞，蒼白膚色，凌亂深棕中長髮，黑眼圈，線框 AR 眼鏡帶淡藍 HUD，皺白實驗袍、深藍高領毛衣、胸前識別證。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `dr_chen_default.png` | default | Cyberpunk noir anime game character portrait of Dr. Chen, young Asian male memory technician age 32, messy medium dark brown hair pushed back but falling forward, tired brown eyes with dark circles, wire-frame AR smart glasses with faint blue HUD glow, pale overworked skin, wrinkled white lab coat over dark navy turtleneck sweater, ID badge clipped to coat, pen in pocket, uneasy neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_chen_nervous.png` | nervous | Cyberpunk noir anime game character portrait of Dr. Chen, same overworked scientist design, messy dark brown hair, AR smart glasses, white lab coat over navy turtleneck, nervous expression, darting eyes, mouth tight, one hand pushing glasses up, hunched shoulders, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_chen_frightened.png` | frightened | Cyberpunk noir anime game character portrait of Dr. Chen, same memory technician outfit, wire-frame AR glasses with blue HUD, wrinkled lab coat, frightened expression, wide eyes behind glasses, open tense mouth, shoulders recoiling as if threatened, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_chen_relieved.png` | relieved | Cyberpunk noir anime game character portrait of Dr. Chen, same messy hair, AR glasses, white lab coat, navy turtleneck, relieved expression, exhaling softly, brows relaxed, small exhausted smile, posture less hunched, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Ghost / 幽靈

角色鎖定：性別不明的回聲網路中間人，全身包裹反光全息斗篷與深兜帽，臉藏在陰影中，只露白藍微光雙眼，斗篷表面呈銀、藍、紫液態金屬反射。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `ghost_default.png` | default | Cyberpunk noir anime game character portrait of Ghost, androgynous mysterious figure fully wrapped in reflective holographic cloak with deep hood, face hidden in shadow, only faint white-blue glowing eyes visible, cloak surface shifting silver blue and purple like liquid metal, voice modulator at collar, signal scrambler on wrist, enigmatic still neutral presence, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ghost_hostile.png` | hostile | Cyberpunk noir anime game character portrait of Ghost, same hooded reflective holographic cloak, hidden face, glowing white-blue eyes, hostile expression implied by sharper eye glow and aggressive forward posture, cloak edges angular and tense, one hand slightly raised under cloak, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ghost_cautious.png` | cautious | Cyberpunk noir anime game character portrait of Ghost, same androgynous hooded figure in shifting silver-blue-purple holographic cloak, face hidden, faint glowing eyes, cautious expression implied by narrowed eye glow and guarded turned posture, cloak pulled close as if avoiding detection, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `ghost_revealed.png` | revealed | Cyberpunk noir anime game character portrait of Ghost, same reflective holographic cloak and deep hood, partially revealed face still mostly shadowed, a hint of human features visible under digital distortion, white-blue eyes glowing with vulnerability, cloak shimmer destabilizing with glitch-like fragments but no background, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Zhao Ming / 趙明

角色鎖定：30 歲亞洲男性正和科技安全主管，黑髮整齊側分，健康中等膚色，強下巴，深棕眼有矛盾感，深色企業西裝，白襯衫，略鬆金色領帶，正和科技徽章，金色智能錶。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `zhao_ming_default.png` | default | Cyberpunk noir anime game character portrait of Zhao Ming, young Asian male corporate security chief age 30, neatly styled black hair with clean side part, intense dark brown eyes, healthy medium skin tone, strong jawline, subtle worry lines between brows, sharp dark corporate suit with Zhengtek insignia on lapel, white dress shirt, slightly loosened gold tie, gold-accented smart watch, corporate badge, controlled neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `zhao_ming_conflicted.png` | conflicted | Cyberpunk noir anime game character portrait of Zhao Ming, same corporate security design, neat black side-part hair, dark suit, white shirt, loosened gold tie, Zhengtek badge, conflicted expression, brows drawn together, eyes torn between duty and guilt, lips pressed tight, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `zhao_ming_nervous.png` | nervous | Cyberpunk noir anime game character portrait of Zhao Ming, same dark corporate suit and gold tie, professional grooming, nervous expression, tense eyes, slight sweat, jaw tightened, one hand near tie or badge as if under interrogation, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `zhao_ming_determined.png` | determined | Cyberpunk noir anime game character portrait of Zhao Ming, same corporate security chief design, neat black hair, dark suit, gold tie, Zhengtek badge, determined expression, eyes focused forward, brows firm, shoulders squared, inner conflict resolved into action, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `zhao_ming_sincere.png` | sincere | Cyberpunk noir anime game character portrait of Zhao Ming, same outfit and grooming, dark corporate suit, loosened gold tie, sincere expression, softened eyes, slight apologetic smile, posture open but still formal, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `zhao_ming_sad.png` | sad | Cyberpunk noir anime game character portrait of Zhao Ming, same corporate security design, black side-part hair, dark suit, white shirt, gold tie, sad expression, lowered eyes, brows heavy, mouth faintly downturned, corporate-perfect exterior visibly cracking, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Kid / 小鬼

角色鎖定：12 歲亞洲街頭駭客，身形小而精瘦，電藍染髮帶黑髮根，短髮亂翹，亮榛綠眼，大耳機掛脖，過大帽 T 滿是徽章貼片，露指手套有外露電路，掛繩上多個 USB。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `kid_default.png` | default | Cyberpunk noir anime game character portrait of Kid, young Asian child hacker age 12, small wiry build, wild messy short electric blue dyed hair with dark roots, bright hazel-green alert eyes, light slightly tanned skin, oversized hoodie covered in patches and pins with sleeves too long, large pro headphones around neck, fingerless gloves with exposed circuitry, USB drives on lanyard, mischievous neutral grin, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kid_excited.png` | excited | Cyberpunk noir anime game character portrait of Kid, same child hacker design, electric blue messy hair, oversized patched hoodie, headphones around neck, fingerless circuit gloves, excited expression, sparkling wide eyes, huge cocky grin, energetic raised shoulders, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kid_serious.png` | serious | Cyberpunk noir anime game character portrait of Kid, same street hacker outfit, electric blue hair with dark roots, headphones, USB lanyard, serious expression, focused narrowed eyes, mouth set firm, playful energy replaced by technical concentration, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `kid_angry.png` | angry | Cyberpunk noir anime game character portrait of Kid, same young hacker design, messy electric blue hair, oversized hoodie with patches, headphones around neck, angry expression, brows lowered, cheeks tense, mouth open as if protesting, small body full of defiant energy, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Mask Merchant / 面具商人

角色鎖定：神秘矮壯黑市攤主，年齡不明外表約 40 多歲，頭纏深色布，戴不斷變換的全息面具，只見發光眼點，厚重深色長袍、多層暗袋，腰帶掛多個面具，紫色全息光。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `mask_merchant_default.png` | default | Cyberpunk noir anime game character portrait of Mask Merchant, mysterious stocky figure, dark cloth head wrap, constantly shifting holographic face mask with glowing eye dots, heavy layered dark robes with many hidden pockets, multiple ornate masks hanging from belt and sash, purple holographic accents, theatrical neutral merchant presence, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mask_merchant_interested.png` | interested | Cyberpunk noir anime game character portrait of Mask Merchant, same stocky masked black market vendor, holographic mask glowing purple, dark head wrap, layered robes and mask belt, interested expression shown by mask forming a curious smile and tilted head, hands half hidden in sleeves as if evaluating a deal, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `mask_merchant_suspicious.png` | suspicious | Cyberpunk noir anime game character portrait of Mask Merchant, same dark robes, shifting holographic face mask, glowing eye dots, masks hanging from belt, suspicious expression shown by mask narrowing its glowing eyes and crooked mouth, head lowered slightly, sleeves guarding hidden merchandise, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Dr. Xiao / 蕭博士

角色鎖定：55 歲亞洲男性前神經科學家，瘦削優雅，白銀後梳髮，鋼灰眼，高顴骨，薄框紅色鏡片眼鏡，左太陽穴神經介面，潔白實驗袍帶紅色滾邊，黑色立領內衫，冷靜但狂熱。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `dr_xiao_default.png` | default | Cyberpunk noir anime game character portrait of Dr. Xiao, older Asian male scientist age 55, swept-back white-silver hair touching collar, steel grey focused eyes with crow's feet, pale papery skin, high cheekbones, elegant thin face, thin-framed red-tinted glasses, neural interface port at left temple, pristine white lab coat with red accent piping over black mandarin-collar shirt, calm unsettling neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_xiao_calm.png` | calm | Cyberpunk noir anime game character portrait of Dr. Xiao, same white-silver swept hair, red-tinted glasses, neural interface port, pristine white lab coat with red piping, calm expression, relaxed mouth, unreadable steel grey eyes, perfectly controlled posture, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_xiao_intense.png` | intense | Cyberpunk noir anime game character portrait of Dr. Xiao, same older cyberpunk scientist design, white-silver hair, red glasses, red-accented lab coat, intense expression, eyes wide and focused with fanatical energy, brows sharp, red highlights slightly stronger on glasses and neural port, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_xiao_philosophical.png` | philosophical | Cyberpunk noir anime game character portrait of Dr. Xiao, same elegant scientist design, white lab coat, black mandarin collar, red-tinted glasses, philosophical expression, one hand lightly raised or near chin, distant thoughtful eyes, faint unsettling smile as if explaining human evolution, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_xiao_amused.png` | amused | Cyberpunk noir anime game character portrait of Dr. Xiao, same older scientist with swept white-silver hair, red glasses, neural port, pristine lab coat, amused expression, thin smile that does not reach the eyes, calm intellectual menace, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `dr_xiao_cracking.png` | cracking | Cyberpunk noir anime game character portrait of Dr. Xiao, same cyberpunk mad scientist design, white-silver hair, red glasses slightly askew, pristine white lab coat with red piping now subtly disturbed, cracking expression, calm facade breaking, tense smile, one eye twitching, fanatical panic showing through, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Hao Ran Lin / 林浩然

角色鎖定：24 歲亞洲男性失蹤記憶技師，瘦弱營養不良，蒼白病態膚色，凌亂深棕中長髮遮眼，深棕眼失焦，黑眼圈與凹陷臉頰，雙太陽穴神經抽取圓形疤痕，皺白病號服，頸胸有神經監測貼片。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `hao_ran_default.png` | default | Cyberpunk noir anime game character portrait of Hao Ran Lin, young Asian male memory technician victim age 24, thin fragile malnourished build, messy medium dark brown hair falling over eyes, glazed unfocused brown eyes, pale sickly skin, dark circles, hollow cheeks, small circular neural extraction scars at both temples, rumpled white hospital-like gown, neural monitoring patches on neck and chest, vacant neutral expression, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `hao_ran_dazed.png` | dazed | Cyberpunk noir anime game character portrait of Hao Ran Lin, same fragile victim design, messy dark hair, neural extraction scars, rumpled hospital gown, dazed expression, eyes unfocused and half-open, mouth slightly parted, head tilted as if memory is fragmented, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `hao_ran_confused.png` | confused | Cyberpunk noir anime game character portrait of Hao Ran Lin, same pale thin memory technician, messy hair over eyes, circular scars at temples, white hospital gown with monitoring patches, confused expression, brows drawn unevenly, eyes searching for recognition, one hand near head as if trying to remember, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
| `hao_ran_hopeful.png` | hopeful | Cyberpunk noir anime game character portrait of Hao Ran Lin, same fragile young Asian man, messy dark hair, sickly pale skin, neural scars, rumpled white hospital gown, hopeful expression, faint recognition in eyes, small fragile smile, posture slightly lifting from exhaustion, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |

## Echo AI / AI「迴響」

角色鎖定：人工意識全息人形，半透明身體由資料流與光粒組成，臉像數千張記憶面孔融合，大眼中有星雲般旋轉圖案，長髮是彩虹資料瀑布，身體內可見記憶碎片。

| 目標檔名 | 表情 | image2.0 提示詞 |
|---|---|---|
| `echo_ai_default.png` | default | Cyberpunk noir anime game character portrait of Echo AI, translucent holographic humanoid artificial consciousness made of flowing data streams and light particles, face like an amalgamation of thousands of faint remembered faces, large luminous eyes containing swirling galaxy-like patterns, long flowing hair made of cascading rainbow data particles, semi-transparent body with faint memory fragments visible within, floating data particles orbiting the form, serene alien curious expression with ancient sadness, chest-up centered sprite, cel-shaded high detail, transparent background, clean alpha cutout, crisp silhouette, no white outline. |
