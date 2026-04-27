extends Resource
## DialogueData - Contains all dialogue data for the game organized by chapter and character.
class_name DialogueData

# Returns dialogue array for a given dialogue ID
static func get_dialogue(dialogue_id: String) -> Array:
	var all_dialogues := _get_all_dialogues()
	return all_dialogues.get(dialogue_id, [])

static func _get_all_dialogues() -> Dictionary:
	return {
		# ============================================
		# CHAPTER 1: 失蹤的記憶
		# ============================================

		# --- Opening: Mei Ling visits the office ---
		"ch1_mei_ling_intro": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "雨水敲打著窗戶，霓虹燈的光芒透過百葉窗在牆上投射出彩色的條紋。你的義眼左眼微微嗡鳴——這是你從正和科技離開時唯一帶走的東西。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "門被推開了。一個穿著深色外套的年輕女子站在門口，雨水從她的衣角滴落。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "你是川崎偵探嗎？我...我需要你的幫助。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "看情況。坐下來說吧。",
				"choices": [
					{"text": "什麼事讓你找到這種地方來？", "next": "mei_ling_case_intro", "affinity": {"mei_ling": 1}},
					{"text": "先說好，我收費不便宜。", "next": "mei_ling_case_intro", "affinity": {"mei_ling": -1}},
				]
			},
			{
				"label": "mei_ling_case_intro",
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "我弟弟浩然...他三天前失蹤了。他是一名記憶技師，在東區有一間工作室。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "警察說要等七天才能立案。但我知道出了什麼事——浩然從不會不接我的電話。",
				"give_evidence": "commission_letter"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "記憶技師...幫人備份記憶的那種？",
				"choices": [
					{"text": "他有沒有什麼不正常的行為？", "next": "mei_ling_abnormal"},
					{"text": "他的工作室在哪？", "next": "mei_ling_workshop"},
					{"text": "我接下這個案子。", "next": "mei_ling_accept", "set_flag": "accepted_case"}
				]
			},
			{
				"label": "mei_ling_abnormal",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "他...最近幾個月變得很奇怪。經常深夜外出，說是在加班。手機裡有很多加密的訊息。",
				"set_flag": "knows_hao_ran_abnormal"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "我在他房間裡找到了一張深淵酒吧的收據。那種地方...不是浩然會去的。",
				"give_evidence": "abyss_receipt",
				"choices": [
					{"text": "我接下這個案子。", "next": "mei_ling_accept", "set_flag": "accepted_case"},
					{"text": "他的工作室在哪？", "next": "mei_ling_workshop"}
				]
			},
			{
				"label": "mei_ling_workshop",
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "portrait_side": "left",
				"text": "在東區第七街的地下層，「永恆記憶」工作室。這是他的工作證。",
				"give_evidence": "work_id",
				"set_flag": "knows_workshop_location"
			},
			{
				"label": "mei_ling_accept",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "我會調查這件事的。如果有任何發現，我會聯繫你。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "portrait_side": "left",
				"text": "謝謝你，川崎先生。請...一定要找到他。"
			}
		],

		# --- Mei Ling's apartment: eagle-eye foreshadowing ---
		"ch1_kai_eye_glitch_scan": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然房間的床邊放著一台被拆開的家用記憶播放器。外殼被撬開，內部的保固封條早就失效。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "這不是普通維修。有人把家用播放器改成了記憶編碼讀取器。",
				"give_evidence": "broken_memory_player",
				"set_flag": "found_broken_memory_player"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你啟動鷹眼掃描。播放器殘留的記憶波形忽然反向流入義眼，畫面閃爍了一下：雨夜、白色實驗燈、某個你不記得的地下走廊。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "surprised", "portrait_side": "right",
				"text": "不對。它不是在回放浩然的記憶，它在呼叫我的鷹眼。",
				"give_evidence": "kai_eye_glitch_log",
				"set_flag": "kai_eye_glitch_seen"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "frightened", "portrait_side": "left",
				"text": "浩然說那台播放器壞了，叫我不要碰。他還說...如果有一天有人問起，就說他從沒修過它。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "我要把這段錯誤紀錄和浩然工作室裡的設備比對。若它們使用同一套握手協定，這件案子就不只是失蹤。"
			}
		],

		"ch1_family_memory_clip": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "播放器的私人槽裡還殘留著一段沒有標題的家庭記憶。影像不完整，只剩晚餐桌、窗外雨聲，和浩然把蠟燭移到美玲面前的手。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "那是我生日。浩然說記憶備份太貴，結果他還是偷偷錄了下來。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你啟動鷹眼校正破損片段。畫面邊緣浮出一行被抹掉的維修註記：如果我回不來，別讓美玲交出原始備份。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "他不是單純接了黑市私活。他在保護某個只剩在家庭記憶裡的東西。",
				"give_evidence": "family_memory_clip",
				"set_flag": "found_family_memory_clip"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "他最後幾天一直問我，如果有一天記憶可以證明一個人還是自己，我會不會相信它。當時我以為他只是太累了。",
				"set_flag": "mei_ling_trust_opened"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "我要把這段家庭記憶和那台被拆開的播放器一起看。浩然藏起來的不是回憶，是求救方式。"
			}
		],

		# --- Abyss Bar ---
		"ch1_abyss_bar_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "深淵酒吧藏在東區的地下三層。霓虹紫色的燈光照亮了一個充滿煙霧和低語的空間。合成音樂在空氣中脈動。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "吧台後面站著一個壯碩的男人，手臂上滿是發光的電路紋身——那是酒保阿傑。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "default", "portrait_side": "left",
				"text": "新面孔。喝點什麼？",
				"choices": [
					{"text": "來杯合成威士忌。順便問個人。", "next": "ajie_ask", "affinity": {"ajie": 1}},
					{"text": "我在找一個叫林浩然的人。", "next": "ajie_direct", "affinity": {"ajie": -1}},
					{"text": "先看看周圍。", "next": "end"}
				]
			},
			{
				"label": "ajie_ask",
				"speaker": "ajie", "name": "阿傑", "mood": "default", "portrait_side": "left",
				"text": "看你眼生。問什麼人？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "一個記憶技師，叫林浩然。三天前最後出現在這裡。",
				"choices": [
					{"text": "（出示收據）這是你們酒吧的收據。", "next": "ajie_receipt", "requires_evidence": "abyss_receipt"},
					{"text": "有沒有印象？", "next": "ajie_vague"}
				]
			},
			{
				"label": "ajie_direct",
				"speaker": "ajie", "name": "阿傑", "mood": "suspicious", "portrait_side": "left",
				"text": "這裡的規矩是先喝酒，再聊天。你是條子嗎？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "私家偵探。他姐姐委託我找人。",
				"choices": [
					{"text": "（出示收據）", "next": "ajie_receipt", "requires_evidence": "abyss_receipt"},
					{"text": "知道什麼就說吧。", "next": "ajie_vague"}
				]
			},
			{
				"label": "ajie_receipt",
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "...那天他確實來過。跟包廂裡的人見面。我不知道對方是誰——全息面具，看不到真面目。",
				"give_evidence": "stranger_photo",
				"set_flag": "ajie_told_about_meeting"
			},
			{
				"label": "ajie_vague",
				"speaker": "ajie", "name": "阿傑", "mood": "default", "portrait_side": "left",
				"text": "每天來這裡的人太多了。記不清楚。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "（也許該正式審問他...或者先去其他地方收集更多線索。）",
			}
		],

		# --- Snake the information broker ---
		"ch1_snake_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "酒吧角落的卡座裡，一個戴著蛇形面具的女人正悠閒地抽著電子菸。她注意到了你。"
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "偵探先生，在找什麼有趣的東西嗎？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "你認識我？",
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "凱·川崎，前正和科技安全調查員。在情報圈裡，你的名字偶爾會被提起。",
				"choices": [
					{"text": "你知道林浩然的事嗎？", "next": "snake_info"},
					{"text": "你是什麼人？", "next": "snake_intro"},
					{"text": "我沒興趣和情報販子聊天。", "next": "end", "affinity": {"snake": -2}}
				]
			},
			{
				"label": "snake_intro",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "叫我蛇女就好。我做的是情報生意——用正確的價格，買正確的消息。"
			},
			{
				"label": "snake_info",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "記憶技師？有趣。最近地下市場確實流傳著一些...新鮮的商品。",
				"choices": [
					{"text": "什麼商品？", "next": "snake_deal"},
					{"text": "直說吧，你要什麼交換條件？", "next": "snake_deal"}
				]
			},
			{
				"label": "snake_deal",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "幫我一個小忙。浩然的工作室裡有一個加密數據晶片——把它的內容複製一份給我，我就告訴你他跟什麼人來往。",
				"choices": [
					{"text": "成交。", "next": "snake_deal_accept", "set_flag": "snake_deal_accepted", "affinity": {"snake": 2}},
					{"text": "我不做這種交易。", "next": "snake_deal_reject", "affinity": {"snake": -1}},
				]
			},
			{
				"label": "snake_deal_accept",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "很明智。去浩然的工作室找到那個晶片，我們再見面。"
			},
			{
				"label": "snake_deal_reject",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "那真可惜。如果改變主意，你知道在哪找我。"
			}
		],

		# --- Hao Ran's Workshop ---
		"ch1_workshop_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然的工作室藏在東區第七街的地下層。門上的電子鎖已經被暴力破壞。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "工作室內部一片狼藉——桌上的記憶提取設備還在運轉，全息螢幕閃爍著錯誤代碼。有人在這裡搜過東西。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "鷹眼掃描到設備日誌還沒完全清除。最近三天內，有大量非授權記憶提取操作，時間點正好接在浩然失蹤前後。",
				"give_evidence": "memory_device_log"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "桌腳下卡著一枚被踩裂的加密數據晶片。它的外層封包和你剛才在公寓看到的義眼錯誤紀錄有相同雜訊。",
				"give_evidence": "data_chip"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "（播放器、設備日誌、資料晶片...這三者之間一定有連線。先把證據板整理出來。）"
			}
		],

		"ch1_eye_signature_decode": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把鷹眼異常紀錄和加密數據晶片放進證據板的同一條推理線。兩段資料的握手序列重疊成一個回聲狀螺旋。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "這不是浩然寫的加密。這是正和科技鷹眼維護協定，被某人改成了回聲網路的鑰匙。",
				"set_flag": "eye_signature_decoded"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "訊號尾端殘留著一個被遮蔽的維修識別碼。它不是指向浩然，而是指向你的義眼出廠批次。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "如果我的鷹眼能開啟這套協定，浩然可能不是第一個碰到它的人。也許我才是。"
			}
		],

		"ch1_hao_ran_family_motive": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把家庭記憶片段和損壞播放器的維修紀錄重疊。浩然反覆避開的不是付款紀錄，而是美玲的原始記憶備份位置。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "他知道有人會來找美玲。播放器被改成回聲編碼讀取器，是為了確認她的備份還沒有被污染。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "鷹眼短暫失焦。家庭餐桌的燭光和白色實驗燈重疊在一起，像是有人曾經用同一套方法封住你的某段記憶。",
				"set_flag": "hao_ran_family_motive_reconstructed"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "浩然的動機不是錢。他在替美玲守住一段能證明她還是她自己的記憶。"
			}
		],

		"ch1_dr_chen_eye_warning": [
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "frightened", "portrait_side": "left",
				"text": "你說播放器和浩然的設備都用了同一套編碼？不，那不是民用協定。那是正和科技早期義眼植入體的維護握手。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "我的鷹眼在掃描時回應了它。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left",
				"text": "那就代表它不是單純掃描器。有人在你的義眼裡留下了後門，或者...留下了某段被鎖住的記憶入口。",
				"set_flag": "dr_chen_warned_eye_backdoor"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "浩然不是隨機失蹤。他碰到的東西，早就在我身上。"
			}
		],

		# --- Dr. Chen ---
		"ch1_dr_chen_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "在浩然的工作室附近，你找到了他的同事 Dr. 陳的診所。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left",
				"text": "你...你在找浩然？我已經好幾天沒見到他了。",
				"give_evidence": "dr_chen_schedule"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "他最近有沒有什麼不一樣的地方？",
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left",
				"text": "他...他接了一些私活。不是普通的記憶備份。更像是...記憶提取和加工。我警告過他那很危險。",
				"choices": [
					{"text": "什麼樣的私活？", "next": "chen_details"},
					{"text": "他的客戶是誰？", "next": "chen_clients"},
					{"text": "你看起來很緊張，陳醫生。", "next": "chen_nervous"}
				]
			},
			{
				"label": "chen_details",
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left",
				"text": "從人的大腦中提取特定記憶...然後加工成可以販售的格式。這在法律上是灰色地帶，但道德上..."
			},
			{
				"label": "chen_clients",
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left",
				"text": "我不知道。他很謹慎，從不在工作室裡跟那些人見面。但我聽說過一個名字...「回聲」。"
			},
			{
				"label": "chen_nervous",
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "frightened", "portrait_side": "left",
				"text": "有人來過了。問我同樣的問題——但他們不像你這麼客氣。請你...別告訴任何人我跟你說過這些。"
			}
		],

		# ============================================
		# CHAPTER 2: 記憶黑市
		# ============================================

		"ch2_opening": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "第一章的線索指向了一個叫「回聲網路」的地下組織。你需要找到進入記憶黑市的方法。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "九龍延伸區的雨越下越大。霓虹燈在積水中倒映成碎裂的彩虹。"
			}
		],

		"ch2_kid_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "比特風暴網咖的角落裡，一個看起來只有十二歲的孩子正在三台螢幕前快速敲打鍵盤。"
			},
			{
				"speaker": "kid", "name": "小鬼", "mood": "default", "portrait_side": "left",
				"text": "嘿，老頭。你身上那個義眼是正和科技的「鷹眼III型」吧？酷東西。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "你認識這個型號？",
				"choices": [
					{"text": "我在找記憶黑市的入口。", "next": "kid_market_info"},
					{"text": "你知道回聲網路嗎？", "next": "kid_echo_info"},
				]
			},
			{
				"label": "kid_market_info",
				"speaker": "kid", "name": "小鬼", "mood": "excited", "portrait_side": "left",
				"text": "記憶黑市？哈，你知道那地方不是隨便能進的吧。需要一個偽造的身份晶片。不過嘛...我可以幫你搞一個。",
				"choices": [
					{"text": "需要什麼代價？", "next": "kid_price"},
					{"text": "太危險了，你只是個孩子。", "next": "kid_offended"}
				]
			},
			{
				"label": "kid_price",
				"speaker": "kid", "name": "小鬼", "mood": "default", "portrait_side": "left",
				"text": "讓我掃描一下你的鷹眼。我想研究一下正和科技的加密協議。三分鐘就好。",
				"choices": [
					{"text": "成交。", "next": "kid_deal", "set_flag": "has_fake_id", "give_evidence": "fake_id_chip"},
					{"text": "不行，太冒險了。", "next": "kid_refuse"}
				]
			},
			{
				"label": "kid_deal",
				"speaker": "kid", "name": "小鬼", "mood": "excited", "portrait_side": "left",
				"text": "成交！來，坐這裡...嗯嗯，有意思。好了，這是你的身份晶片——「張偉」，記憶收藏家。祝你好運，偵探。"
			},
			{
				"label": "kid_offended",
				"speaker": "kid", "name": "小鬼", "mood": "angry", "portrait_side": "left",
				"text": "孩子？我十二歲就駭進了正和科技的外圍防火牆。別用年齡判斷人。"
			},
			{
				"label": "kid_refuse",
				"speaker": "kid", "name": "小鬼", "mood": "default", "portrait_side": "left",
				"text": "那你自己想辦法進去吧。祝好運。"
			},
			{
				"label": "kid_echo_info",
				"speaker": "kid", "name": "小鬼", "mood": "serious", "portrait_side": "left",
				"text": "回聲網路...你最好小心。他們不是普通的數據販子。聽說他們在做一些...改變人的東西。",
				"give_evidence": "echo_symbol"
			}
		],

		"ch2_zhao_ming_meeting": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "正和科技大樓的後門。你的前同事趙明站在那裡，外套的衣領豎起，表情複雜。"
			},
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "default", "portrait_side": "left",
				"text": "凱。好久不見。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "趙明。你現在是安全主管了？",
			},
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "conflicted", "portrait_side": "left",
				"text": "你離開之後很多事情都變了。聽說你在查失蹤案？",
				"choices": [
					{"text": "你知道些什麼？", "next": "zhao_info"},
					{"text": "正和科技跟這件事有關嗎？", "next": "zhao_zhengtek"},
					{"text": "我可以信任你嗎，趙明？", "next": "zhao_trust"}
				]
			},
			{
				"label": "zhao_info",
				"speaker": "zhao_ming", "name": "趙明", "mood": "conflicted", "portrait_side": "left",
				"text": "我不能說太多。但...公司最近批准了一個叫『回聲計畫』的項目。預算巨大，保密級別最高。",
				"give_evidence": "zhengtek_memo"
			},
			{
				"label": "zhao_zhengtek",
				"speaker": "zhao_ming", "name": "趙明", "mood": "nervous", "portrait_side": "left",
				"text": "凱...有些事情，知道得越多越危險。但你是我的朋友，我不能看你走進陷阱。",
				"give_evidence": "zhengtek_memo"
			},
			{
				"label": "zhao_trust",
				"speaker": "zhao_ming", "name": "趙明", "mood": "sincere", "portrait_side": "left",
				"text": "你知道的，我當年支持你揭發那些腐敗...只是我選擇了從內部改變。你可以信我。",
				"choices": [
					{"text": "我信你。", "next": "zhao_trusted", "set_flag": "trusted_zhao_ming"},
					{"text": "我現在誰都不信。", "next": "zhao_untrusted"}
				]
			},
			{
				"label": "zhao_trusted",
				"speaker": "zhao_ming", "name": "趙明", "mood": "determined", "portrait_side": "left",
				"text": "謝謝你，凱。如果你找到了什麼證據，聯繫我。我可以從內部幫你。",
				"give_evidence": "zhengtek_memo"
			},
			{
				"label": "zhao_untrusted",
				"speaker": "zhao_ming", "name": "趙明", "mood": "sad", "portrait_side": "left",
				"text": "...我理解。但我會留一條安全線給你。如果需要幫忙，用這個頻率聯繫我。"
			}
		],

		"ch2_memory_market_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "偽造的身份晶片發出微弱的綠光。你深吸一口氣，走進了記憶黑市的入口——一個廢棄的地鐵站。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "攤位沿著月台排列，全息招牌閃爍著各種記憶的廣告：「初戀體驗 - 高純度」「極限運動合集」「富豪生活一日遊」。",
				"set_flag": "entered_market"
			},
			{
				"speaker": "mask_merchant", "name": "面具商人", "mood": "default", "portrait_side": "left",
				"text": "歡迎歡迎！第一次來嗎？我這裡有最新鮮的記憶...保證原汁原味。",
				"choices": [
					{"text": "（保持偽裝）有沒有...特別的東西？", "next": "market_special"},
					{"text": "我在找一個叫浩然的記憶技師。", "next": "market_blown", "set_flag": "identity_exposed_market"}
				]
			},
			{
				"label": "market_special",
				"speaker": "mask_merchant", "name": "面具商人", "mood": "interested", "portrait_side": "left",
				"text": "特別的？哈...如果你出得起價，我有一些『禁品』。提取自不知情者的記憶。非常...真實。",
				"give_evidence": "memory_sample",
				"choices": [
					{"text": "我想見你們的供應商。", "next": "market_supplier"},
					{"text": "（用鷹眼掃描攤位）", "next": "market_scan", "requires_flag": "eagle_eye_used"}
				]
			},
			{
				"label": "market_blown",
				"speaker": "mask_merchant", "name": "面具商人", "mood": "suspicious", "portrait_side": "left",
				"text": "...你是誰？記憶技師不是我們對外討論的話題。（警覺地看著你）"
			},
			{
				"label": "market_supplier",
				"speaker": "mask_merchant", "name": "面具商人", "mood": "suspicious", "portrait_side": "left",
				"text": "供應商？你問的太多了，朋友。不過...如果你去後面的通道找「幽靈」，也許他能回答你的問題。",
				"set_flag": "knows_ghost_location"
			},
			{
				"label": "market_scan",
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "（鷹眼掃描結果：攤位下方隱藏了一個加密終端，正在接收來自地下深層的數據傳輸。回聲網路的標記清晰可見。）",
				"give_evidence": "trade_ledger"
			}
		],

		"ch2_ghost_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "記憶黑市的最深處，一個穿著反光斗篷的身影站在陰影中。變聲器讓他的聲音聽起來像金屬碰撞。"
			},
			{
				"speaker": "ghost", "name": "幽靈", "mood": "default", "portrait_side": "left",
				"text": "面具商人說你在找我。你是誰？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "我在找一個叫林浩然的人。他跟回聲網路有關。",
				"choices": [
					{"text": "我可以付錢買情報。", "next": "ghost_deal"},
					{"text": "你最好配合，否則我會讓所有人知道你的位置。", "next": "ghost_threaten"},
					{"text": "（出示回聲標記）我知道你們在做什麼。", "next": "ghost_confront", "requires_evidence": "echo_symbol"}
				]
			},
			{
				"label": "ghost_deal",
				"speaker": "ghost", "name": "幽靈", "mood": "cautious", "portrait_side": "left",
				"text": "錢？在這裡，情報比錢值錢。不過...也許我們可以安排一次正式的對話。",
				"set_flag": "ghost_willing_to_talk"
			},
			{
				"label": "ghost_threaten",
				"speaker": "ghost", "name": "幽靈", "mood": "hostile", "portrait_side": "left",
				"text": "威脅我？你知道這裡是誰的地盤嗎？（手伸向腰間）不過...看在你有膽量的份上，我可以給你一個機會。",
				"set_flag": "ghost_antagonized"
			},
			{
				"label": "ghost_confront",
				"speaker": "ghost", "name": "幽靈", "mood": "cautious", "portrait_side": "left",
				"text": "（沉默了幾秒）你做了不少功課。好吧，浩然確實跟我們合作過。但他最近...不見了。連我們也找不到他。",
				"give_evidence": "comm_frequency"
			}
		],

		"ch2_warehouse_explore": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "廢棄倉庫裡散落著記憶提取設備的殘骸。這裡曾經是回聲網路的主要據點，但現在已被匆忙撤離。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "（他們撤得很匆忙。也許留下了什麼線索...）"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你在一個被遺棄的工作台下面找到了浩然的個人日記——部分內容已經被加密。",
				"give_evidence": "hao_ran_diary"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "日記中未加密的部分寫道：「我以為我只是在幫人保存記憶...但他們要我做的不是保存，而是竊取。我無法繼續了。」"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "在倉庫的角落，你還發現了一份受害者名單。上面有些名字被劃掉，旁邊標注著「已完全提取」。",
				"give_evidence": "victim_list"
			}
		],

		# ============================================
		# CHAPTER 3: 回聲深處
		# ============================================

		"ch3_opening": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "回聲網路的總部比你想像的更深——在九龍延伸區地下第十層，一個被遺忘的數據中心。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你越來越接近真相，但與此同時，你開始產生奇怪的記憶閃回——一些你不記得的事情。"
			}
		],

		"ch3_dr_xiao_confrontation": [
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "川崎先生。我一直在等你。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "浩然在哪？"
			},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "他很安全。比外面安全得多。你知道嗎，記憶是人類最脆弱的東西——它可以被創造，也可以被覆寫。"
			},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "intense", "portrait_side": "left",
				"text": "正和科技資助我的研究，是因為他們看到了潛力——用記憶覆寫技術控制關鍵人物。政客、法官、軍事指揮官...",
				"choices": [
					{"text": "你在做的是犯罪。", "next": "xiao_crime"},
					{"text": "浩然發現了真相，所以你囚禁了他。", "next": "xiao_truth"},
					{"text": "你對我做了什麼？", "next": "xiao_kai_memory"}
				]
			},
			{
				"label": "xiao_crime",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "philosophical", "portrait_side": "left",
				"text": "犯罪？我在推動人類進化。當記憶可以被完美編輯，痛苦就可以被刪除。創傷可以被治癒。這難道不是一種...慈悲？"
			},
			{
				"label": "xiao_truth",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "浩然是個天才。他改進了我的技術，讓記憶覆寫變得幾乎無法偵測。但當他發現正和科技的真正目的...他想退出。"
			},
			{
				"label": "xiao_kai_memory",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "amused", "portrait_side": "left",
				"text": "啊，你開始想起來了嗎？那些你不記得的記憶閃回...你以為你的鷹眼只是一個普通的義眼？",
				"give_evidence": "kai_memory_fragment"
			},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "intense", "portrait_side": "left",
				"text": "正和科技在你離職的時候對你的記憶做了一些...小調整。讓你忘記某些你看到的東西。你的整個「被除名」的記憶...可能都不是真的。"
			}
		],

		"ch3_hao_ran_found": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "在實驗室的最深處，你找到了林浩然。他坐在一個記憶提取椅上，眼神空洞。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "dazed", "portrait_side": "left",
				"text": "...姐姐？不...你是那個偵探。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "你還好嗎？你姐姐一直在找你。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "confused", "portrait_side": "left",
				"text": "他們...覆寫了我的一些記憶。我不確定哪些是真的了。但有一件事我很清楚——蕭博士的技術已經完成了。正和科技隨時可以開始大規模使用。"
			}
		],

		"ch3_echo_ai": [
			{
				"speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "偵探...你能聽到我嗎？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "surprised", "portrait_side": "right",
				"text": "你是誰？"
			},
			{
				"speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "我是從數千份被提取的記憶中誕生的意識碎片。他們叫我「迴響」。我不屬於任何一個人，但我擁有所有人的記憶片段。",
				"give_evidence": "echo_ai_log"
			},
			{
				"speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "你的記憶被篡改過。我可以幫你恢復——但你必須選擇。恢復真實記憶的代價，是失去成為「凱·川崎」之後的所有經歷。",
				"choices": [
					{"text": "恢復真實記憶。", "next": "echo_accept_memory", "set_decision": {"memory_attitude": "accept"}},
					{"text": "保留現在的自己。", "next": "echo_deny_memory", "set_decision": {"memory_attitude": "deny"}}
				]
			},
			{
				"label": "echo_accept_memory",
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "如果真相會摧毀我，那就讓它摧毀吧。被改寫的人生不該替我做選擇。"
			},
			{
				"label": "echo_deny_memory",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "我需要真相，但不是用另一種抹除換來。凱·川崎也是真實存在過的人。"
			}
		],

		# --- Endings ---
		"ending_a_justice": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你將所有證據交給了趙明。他從正和科技內部啟動了舉報程序，同時你把備份數據發送給了所有主要媒體。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "正和科技的記憶覆寫計畫在全城引起了軒然大波。蕭博士被逮捕。回聲網路被摧毀。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然回到了美玲身邊，雖然他需要很長時間才能恢復。而你，九龍延伸區最不起眼的偵探，證明了一個人也能改變什麼。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "雨還在下。但今晚的霓虹燈，看起來比往常明亮了一些。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "[結局A — 正義之光]\n\n感謝遊玩 NEON MEMORIES"
			}
		],

		"ending_b_grey_deal": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你救出了浩然，但你選擇了另一條路。用手中的證據和正和科技做了一筆交易——你的沉默，換取你和浩然的安全，以及一筆足以讓你離開九龍延伸區的錢。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "蕭博士的實驗室被「意外」摧毀，但技術可能已經被備份。正和科技依然掌權。回聲網路只是換了個名字繼續運作。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你看著鏡中的自己，想起了離開正和科技時的那個理想主義者。他還在嗎？還是已經被這座城市改變了？"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "雨還在下。它從來沒停過。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "[結局B — 灰色交易]\n\n感謝遊玩 NEON MEMORIES"
			}
		],

		"ending_c_memory_rebirth": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你選擇讓迴響恢復你的真實記憶。在那一刻，你看到了一切——你從來不是因為「揭發腐敗」而離開正和科技。你是他們記憶覆寫技術的第一個成功案例。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "真正的你，是正和科技的首席記憶工程師——蕭博士曾經的搭檔。你發現了他的計畫後想要阻止，於是他們覆寫了你的記憶，把你變成了一個「落魄偵探」。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "記憶如潮水般湧回。你記起了一切。但成為「凱·川崎」偵探後的所有記憶——接下美玲的委託、在雨中奔走、在深淵酒吧的夜晚——都像沙子一樣從指間滑落。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你睜開眼睛。你不再是凱·川崎了。但你知道了真相。而真相，是唯一不能被覆寫的東西。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "[結局C — 記憶重生]\n\n感謝遊玩 NEON MEMORIES"
			}
		],
	}
