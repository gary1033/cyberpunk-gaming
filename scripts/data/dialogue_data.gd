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
				"show_cg": "cg_kai_office_prologue",
				"text": "雨水敲打著九龍延伸區的窗。你的辦公室只剩一盞壞掉的檯燈、一台過期咖啡機，以及牆上還沒拆掉的正和科技安全調查員識別框。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "上一件案子剛結束：走失的仿生寵物、拖欠三週的尾款、以及一名客戶堅持把你叫成「前企業狗」。你沒有反駁。那是履歷上最接近事實的形容。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "（正和科技留下的義眼又在低鳴。不是疼痛，比較像有人在門外測試舊鎖。）",
				"choices": [
					{"text": "按掉義眼警示，整理委託紀錄。", "next": "kai_office_after_warning", "set_flag": "kai_suppressed_eye_warning"},
					{"text": "讓鷹眼掃過辦公室一次。", "next": "kai_office_after_warning", "set_flag": "kai_checked_office_with_eagle_eye"}
				]
			},
			{
				"label": "kai_office_after_warning",
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把舊案照片翻面，讓桌面看起來像一個還能營業的地方。抽屜裡的止痛藥瓶碰到金屬義眼維護盒，發出細小的聲響。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "敲門聲在第三下才變得急促。來人很克制，但克制不是平靜；那是把恐懼折好，藏進濕透外套裡的聲音。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"clear_cg": true,
				"text": "你是川崎凱嗎？我在舊城警署外面等了四個小時，他們叫我回家等通知。可是我不能再等了。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "失蹤案？警署不立案通常有兩種原因：時間太短，或者他們不想碰。",
				"choices": [
					{"text": "先坐下，把你知道的照順序說。", "next": "mei_ling_case_intro", "affinity": {"mei_ling": 1}},
					{"text": "如果只是家人失聯，我不一定接。", "next": "mei_ling_prove_case", "affinity": {"mei_ling": -1}},
					{"text": "你怎麼知道該來找我？", "next": "mei_ling_found_kai"}
				]
			},
			{
				"label": "mei_ling_case_intro",
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "我弟弟浩然三天前失蹤。他是一名記憶技師，在東區經營「永恆記憶」工作室。警察說成年人三天不回家不算失蹤。"
			},
			{
				"label": "mei_ling_prove_case",
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "浩然不是會消失的人。他每天晚上十一點會打給我，確認我有沒有吃藥，有沒有關掉窗邊的漏電燈。失蹤那晚，電話只響了一聲就被切掉。",
				"give_evidence": "commission_letter"
			},
			{
				"label": "mei_ling_found_kai",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "浩然以前提過你。他說如果有一天他出事，不要找警察，找那個被正和科技趕出去、但還知道怎麼看記憶傷口的人。",
				"give_evidence": "commission_letter"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "他知道我的名字，卻從沒找過我。這通常代表他怕我也在某張名單上。",
				"choices": [
					{"text": "他失蹤前有沒有反常行為？", "next": "mei_ling_abnormal"},
					{"text": "他的工作室在哪？", "next": "mei_ling_workshop"},
					{"text": "你還沒說為什麼信任我。", "next": "mei_ling_trust_test"}
				]
			},
			{
				"label": "mei_ling_abnormal",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "他最近幾個月變得很奇怪。經常深夜外出，說是在加班。手機裡有很多加密訊息，還把家裡那台舊記憶播放器鎖進房間。",
				"set_flag": "knows_hao_ran_abnormal"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "我在他房間裡找到了一張深淵酒吧的收據。那種地方不是浩然會去的。他怕吵，怕人群，連生日都只肯在家裡吃飯。",
				"give_evidence": "abyss_receipt",
				"choices": [
					{"text": "我接下這個案子。", "next": "mei_ling_accept", "set_flag": "accepted_case", "affinity": {"mei_ling": 1}},
					{"text": "先給我他的工作室地址。", "next": "mei_ling_workshop"}
				]
			},
			{
				"label": "mei_ling_workshop",
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "portrait_side": "left",
				"text": "在東區第七街的地下層，「永恆記憶」工作室。這是他的工作證。我沒有鑰匙，但他房間裡也許還有備份。",
				"give_evidence": "work_id",
				"set_flag": "knows_workshop_location"
			},
			{
				"label": "mei_ling_trust_test",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "我不確定我能信任你。但浩然說你討厭正和科技，卻不會把被害者當籌碼。這句話我記得很清楚。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "那他對我的評價比大部分人好。把地址和你找到的東西留下，我會先去你們公寓。"
			},
			{
				"label": "mei_ling_accept",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "我接下這個案子。但你也要配合：不要交出任何備份，不要回撥陌生號碼，不要讓警署把你的東西帶走。",
				"give_evidence": "work_id",
				"set_flag": "knows_workshop_location"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "portrait_side": "left",
				"text": "謝謝你，川崎先生。請一定要找到他。如果浩然真的留下了什麼，我想親耳聽見。"
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

		"ch1_hao_ran_drawer_search": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然房間的抽屜上有兩道鎖。一道是便宜的機械鎖，另一道藏在把手內側，會在開啟時刪除夾層裡的資料晶片。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "他不是防小偷，是防熟人。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "我試過打開。浩然以前不會對我鎖東西，至少不會鎖得像在防公司稽核。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "抽屜底部貼著一張維修便條：播放器校正失敗時，不要重啟，不要連網，把原始備份藏回相簿。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "這不是遺言，但已經很接近了。浩然把下一步調查留在你家裡，而不是工作室。",
				"give_evidence": "hao_ran_drawer_note",
				"set_flag": "found_hao_ran_drawer_note"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "原始備份...他是說我的？為什麼有人會想要我的記憶？"
			}
		],

		"ch1_original_backup_album": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "家庭相簿被放在書架最普通的位置，普通到像是刻意要讓它看起來不重要。封底夾層裡嵌著一枚薄到幾乎透明的備份標籤。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "那本相簿是媽媽留下來的。浩然說實體照片比較安全，不會被雲端服務拿去訓練什麼情感模型。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "他把原始備份提示藏在這裡，是因為你一定會保留它。浩然很了解你。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "他一直說我太念舊。可如果他真的在保護我的記憶，那我是不是害他被盯上了？",
				"choices": [
					{"text": "不是你害他，是有人盯上你們。", "next": "backup_reassure", "affinity": {"mei_ling": 2}},
					{"text": "現在先別下結論，證據還不夠。", "next": "backup_cautious", "affinity": {"mei_ling": 1}}
				]
			},
			{
				"label": "backup_reassure",
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "責任在拿記憶當貨物的人身上。浩然留下線索，是因為他相信你會活著把它交給對的人。"
			},
			{
				"label": "backup_cautious",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "愧疚會讓人漏看細節。先把它當作線索，不要急著把自己放進罪名裡。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把備份標籤掃進證據板。它不包含完整記憶，只保留一串座標式雜訊，像是等著和另一段留言拼合。",
				"give_evidence": "original_backup_hint",
				"set_flag": "mei_ling_trust_deepened"
			}
		],

		"ch1_eleven_pm_call_log": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "美玲家的終端機還亮著未讀通話紀錄。浩然失蹤那晚，十一點整有一通只響了一聲的來電，來源被抹成公共節點。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "我以為那只是騷擾電話。可是浩然以前說過，如果有一天他只打一聲就掛，表示他被人盯上，不能留下聲音。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "這不是騷擾電話。來電路由被切斷得太乾淨，像有人不想讓警署留下通報時間。",
				"give_evidence": "eleven_pm_call_log",
				"set_flag": "found_eleven_pm_call_log"
			}
		],

		"ch1_old_city_police_outpost_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "舊城警署前哨的白燈亮得刺眼。排隊號碼、企業協調窗口與自動受理機排成一條冷冰冰的動線，像是每個人都能說自己只是照程序辦事。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "美玲不是沒找過人。她只是被這套系統慢慢推出門外。"
			}
		],

		"ch1_old_city_queue_ticket": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "自動受理機旁的失物盒裡，夾著一張濕掉的等候號碼單。紙面被雨水泡開，背面仍印著美玲報案當晚的時間戳。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "四小時。她坐在這裡，看著號碼跳過企業協調、義體事故、身份晶片糾紛，最後只換到一張退案章。",
				"give_evidence": "old_city_queue_ticket",
				"set_flag": "old_city_queue_ticket_found"
			}
		],

		"ch1_old_city_police_outpost": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "舊城警署前哨只有一盞壞掉的藍燈。值班窗口後方堆著未處理案件，螢幕上卻優先跳出企業風險分類。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "林美玲的報案紀錄在哪裡？"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "窗口吐出一張薄薄的紙。上面蓋著「成年人自願離開，暫不受理」。鷹眼掃過印泥，底層還有一個被遮住的企業風險碼。",
				"give_evidence": "rejected_missing_person_report",
				"set_flag": "police_report_seen"
			}
		],

		"ch1_street_camera_gap": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "東區街口的監控桿在雨裡發出低鳴。公共查詢端只顯示一行故障紀錄：23:04 到 23:11，整段街區同步掉線。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "七分鐘。剛好能讓一個人從公寓外被帶走，也剛好能讓一通電話失去來源。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "鷹眼補出封包節奏。這不是設備老化，而是遠端遮蔽；指令沒有署名，只留下一種像回音般重複的節拍。",
				"give_evidence": "street_camera_gap",
				"set_flag": "street_camera_gap_found"
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

		"ch1_abyss_bar_backroom_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "深淵酒吧後室比前場安靜得多。隔音牆把音樂壓成低頻心跳，包廂門上的感應燈一明一滅，像在替每段沉默計價。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "你要看的都在裡面。但有些紀錄不是消失，是有人付錢讓它慢一點出現。"
			}
		],

		"ch1_abyss_backroom_investigation": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "阿傑把包廂紀錄推到吧台邊緣，手指沒有離開紙面。那不是交出證據的姿勢，比較像在確認自己還能不能反悔。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "浩然那晚不是一個人來。他見的人戴全息面具，用的是臨時 hash。這種客人我通常不問名字，也最好不要記得臉。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "你不是忘了，是有人付錢讓你忘。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "包廂紀錄裡只剩遮罩客戶的付款殘影。鷹眼讀到黑市預約格式，卻同時閃過一段不屬於酒吧的白色走廊。",
				"give_evidence": "masked_client_receipt",
				"set_flag": "masked_client_receipt_found"
			}
		],

		"ch1_abyss_surveillance_delay_log": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "後室監控終端還保留著一段無人認領的維護紀錄。浩然進入二號包廂後，附近三支鏡頭被手動延遲三分鐘，理由欄只剩「清場」。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "我收過錢讓那一段安靜一點。這件事我認。但我沒收過錢，把一個發抖的小子送去死。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "沉默不一定是共犯，但有人很懂怎麼把沉默做成服務。",
				"give_evidence": "abyss_surveillance_delay_log",
				"set_flag": "abyss_surveillance_delay_log_found"
			}
		],

		"ch1_snake_data_chip_choice": [
			{
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "你手上的晶片聞起來像回聲網路。我要一份副本，給你一條入口。拒絕也可以，只是你得用自己的眼睛慢慢找。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "副本會流到哪裡？"
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "情報從來不免費。你現在要買的是速度，代價是誰先知道你在查這件事。",
				"choices": [
					{"text": "交出晶片副本，換黑市拍賣入口。", "next": "snake_trade_accept", "requires_missing_flags": ["rejected_snake_deal"], "set_flag": "accepted_snake_deal", "set_flags": ["snake_data_chip_choice_resolved"], "set_decision": {"accepted_snake_deal": true, "black_market_route_opened": true, "black_market_compromise_count": 1}, "affinity": {"snake": 2}},
					{"text": "拒絕交易，改走診所與義眼追查。", "next": "snake_trade_reject", "requires_missing_flags": ["accepted_snake_deal"], "set_flag": "rejected_snake_deal", "set_flags": ["snake_data_chip_choice_resolved"], "set_decision": {"rejected_snake_deal": true, "clinic_route_opened": true}, "affinity": {"snake": -1}}
				]
			},
			{
				"label": "snake_trade_accept",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "聰明。第二章你會收到拍賣邀請。記得，拍賣場賣的不是物品，是人們以為自己還擁有的過去。",
				"set_flag": "black_market_route_opened"
			},
			{
				"label": "snake_trade_reject",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "也行。去找會替義眼擦血的人吧。只是診所能告訴你的，通常是你已經受傷之後的事。",
				"set_flag": "clinic_route_opened"
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
				"text": "幫我一個小忙。浩然的工作室裡有一個加密數據晶片。等你真的拿到它，再來談你願意用什麼代價換入口。",
				"choices": [
					{"text": "我會先找到晶片，再決定要不要交易。", "next": "snake_deal_accept", "set_flags": ["snake_broker_met", "snake_requested_data_chip"], "affinity": {"snake": 1}},
					{"text": "我不替情報販子跑腿。", "next": "snake_deal_reject", "set_flag": "snake_broker_met", "affinity": {"snake": -1}},
				]
			},
			{
				"label": "snake_deal_accept",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "謹慎比忠誠值錢。去浩然的工作室找到那個晶片，我們再見面；到時候你會知道自己想買的是速度，還是乾淨。"
			},
			{
				"label": "snake_deal_reject",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "那真可惜。不過拒絕第一次報價的人，通常只是還沒看見時間多貴。如果改變主意，你知道在哪找我。"
			}
		],

		"ch1_dr_chen_clinic_followup": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "Dr. 陳的診所藏在東區招牌後方。門口沒有診療科別，只有一行褪色字：義體維修，現金優先。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "worried", "portrait_side": "left",
				"text": "我看過這種握手協定。鄭泰早期義眼維修用的，後來被禁掉，因為外部設備可以把它叫醒。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "也就是說，浩然留下的播放器不是線索，是鑰匙孔。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "default", "portrait_side": "left",
				"text": "鑰匙孔，或者後門。凱，你每次開鷹眼，不只是在看別人的秘密，也可能是在讓別人看見你。",
				"give_evidence": "clinic_eye_warning_log",
				"set_flag": "clinic_eye_warning_seen"
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

		"ch1_hao_ran_encrypted_message": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把原始備份提示接到浩然工作室的離線終端。螢幕沒有連上網路，卻像被人從另一端喚醒，逐行吐出破碎的加密留言。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "他用美玲的備份提示當解鎖鑰匙。這封留言不是給我，是給她。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "留言被刻意切成不完整片段：不要相信回聲網路的買家。不要把原始備份交出去。如果我回不來，就讓凱看到播放器。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "他知道我的鷹眼會回應播放器。浩然不是偶然把我拖進來，他在用自己失蹤後唯一能控制的方式選擇調查者。",
				"give_evidence": "hao_ran_encrypted_message",
				"set_flag": "hao_ran_message_decoded"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "frightened", "portrait_side": "left",
				"text": "所以他早就知道自己可能回不來？他為什麼不直接告訴我？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "因為知道的人越少，你活下來的機率越高。現在我們要做的是把這段留言和原始備份提示連起來，找出他真正藏起來的位置。"
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

		"ch1_three_evidence_inference": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "證據板上三條線終於交會：家庭備份證明浩然想保護美玲，義眼握手證明他知道凱能讀懂訊號，遮罩客戶紀錄則把失蹤案推向記憶黑市。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "浩然不是單純求救。他把線索留給會看見第二層的人。問題是，他把我當偵探，還是當鑰匙？"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "鷹眼在資料晶片、診所警告與家庭記憶之間標出同一種回聲式節拍。它沒有說話，只留下痕跡。",
				"give_evidence": "black_market_entry_hint",
				"set_flag": "echo_trust_axis_seeded"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "第一章的答案不是浩然在哪裡，而是浩然為什麼選我。第二章，入口已經分岔。",
				"choices": [
					{"text": "追查蛇女提供的黑市拍賣入口。", "next": "route_black_market", "requires_flag": "accepted_snake_deal"},
					{"text": "沿著 Dr. 陳的義眼警告追查。", "next": "route_clinic", "requires_flag": "rejected_snake_deal"},
					{"text": "先回深淵酒吧處理蛇女的交易條件。", "next": "route_unresolved", "requires_missing_flags": ["accepted_snake_deal", "rejected_snake_deal"]}
				]
			},
			{
				"label": "route_black_market",
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "蛇女的訊息在終端亮起：拍賣會只認副本，不認名字。你已經買到速度，也把自己的調查交給黑市聞到。",
				"set_flags": ["chapter_1_complete", "chapter_1_route_chosen"],
				"set_decision": {"chapter_1_complete": true, "chapter_1_route_chosen": "black_market"}
			},
			{
				"label": "route_clinic",
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "Dr. 陳留下的診所通道仍然開著。你沒有把晶片交出去，但接下來每一步都得靠義眼讀取更深，也承擔更深的失真。",
				"set_flags": ["chapter_1_complete", "chapter_1_route_chosen"],
				"set_decision": {"chapter_1_complete": true, "chapter_1_route_chosen": "clinic"}
			},
			{
				"label": "route_unresolved",
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "路線還沒分岔。資料晶片要不要交給蛇女，必須先在深淵酒吧做決定；否則第二章只是另一個沒有出口的走廊。"
			}
		],

		# --- Dr. Chen ---
		"ch1_dr_chen_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "Dr. 陳診所的候診區亮著過白的消毒燈。幾名義體工人低頭避開你的視線，像是每個人都怕自己的病歷被寫進正式系統。"
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

		"ch1_clinic_anonymous_case_note": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "離線病歷櫃裡有幾份被遮去姓名的病例。症狀欄反覆出現同一句話：記憶回放後短暫看見白色走廊，義眼或神經接口回報不明握手。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "frightened", "portrait_side": "left",
				"text": "那些人不是浩然的客戶。至少不是同一批。但症狀太像了，所以我把它們留在離線櫃，沒有上傳。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "你不是第一次看見這種握手。只是第一次有人把它留在我的義眼裡。",
				"give_evidence": "clinic_anonymous_case_note",
				"set_flag": "clinic_anonymous_case_note_found"
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
