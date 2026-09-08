extends Resource
## EvidenceData - All evidence item definitions.
class_name EvidenceData

static func get_evidence(evidence_id: String) -> Dictionary:
	var all_evidence := get_all_evidence()
	return all_evidence.get(evidence_id, {})

static func get_all_evidence() -> Dictionary:
	return {
		"ghost_identity_trace": {"name": "身份轉用核對紀錄", "description": "比對採樣時間與兩台終端的簽署摘要，證明同一身份出現在矛盾的位置；不能單憑編號指認使用者。", "chapter": 2, "icon": "ghost_identity_trace"},
		"ghost_relay_token": {"name": "幽靈的離線接應器", "description": "一次性接應的實體信物。三號維修門、排水停機後回送短脈衝。它是通行協助，不是原諒或作證同意。", "chapter": 2, "icon": "ghost_relay_token"},
		# ============================================
		# CHAPTER 1: 失蹤的記憶
		# ============================================
		"commission_letter": {
			"name": "美玲的委託信",
			"description": "林美玲寫的委託書，詳述弟弟林浩然三天前失蹤的情況。",
			"chapter": 1,
			"icon": "commission_letter",
			"eye_reading": "鷹眼讀到被反覆刪改的壓痕：美玲曾寫下「浩然在替非法客戶修記憶」，又把那行刪掉。核心資訊可信，但文字邊緣混入凱記憶缺口造成的雨夜殘影。",
			"eye_flags": ["eagle_eye_overuse_count", "echo_trust_axis_seeded"]
		},
		"work_id": {
			"name": "浩然的工作證",
			"description": "林浩然的記憶技師執照，隸屬於「永恆記憶」工作室。",
			"chapter": 1,
			"icon": "work_id"
		},
		"abyss_receipt": {
			"name": "深淵酒吧的收據",
			"description": "三天前在深淵酒吧的消費收據，有一間包廂的預約紀錄。",
			"chapter": 1,
			"icon": "receipt",
			"eye_reading": "鷹眼從熱感墨水殘留中補出一段包廂 hash。付款人身份被面具協定遮蔽，但路由格式接近記憶黑市的預約系統。"
		},
		"data_chip": {
			"name": "加密的數據晶片",
			"description": "在浩然工作室中找到的加密晶片，內容無法直接讀取。",
			"chapter": 1,
			"icon": "data_chip",
			"eagle_eye_only": true,
			"eye_reading": "晶片外層不是一般加密，而是回聲網路常用的螺旋簽章。義眼能讀到方向，卻會把簽章短暫投射成凱不認得的白色診療燈。"
		},
		"stranger_photo": {
			"name": "陌生人的全息照片",
			"description": "酒吧監控截圖，一個戴著全息面具的人與浩然會面。",
			"chapter": 1,
			"icon": "photo"
		},
		"memory_device_log": {
			"name": "記憶提取設備使用紀錄",
			"description": "浩然工作室的設備日誌，顯示近期大量非授權的記憶提取操作。",
			"chapter": 1,
			"icon": "log",
			"eagle_eye_only": true
		},
		"comm_recording": {
			"name": "損壞的通訊錄音",
			"description": "一段部分損壞的加密通話錄音，能隱約聽到「回聲」和「交貨」等字眼。",
			"chapter": 1,
			"icon": "recording"
		},
		"dr_chen_schedule": {
			"name": "Dr. 陳的預約紀錄",
			"description": "浩然同事 Dr. 陳的診所預約表，顯示浩然最後一天有一個「特殊客戶」預約。",
			"chapter": 1,
			"icon": "schedule"
		},
		"family_memory_clip": {
			"name": "家庭記憶片段",
			"description": "美玲公寓播放器中殘留的家庭記憶。浩然把一段晚餐與雨聲備份藏在機器深層，像是在提醒美玲自己不是自願失蹤。",
			"chapter": 1,
			"icon": "memory_capsule",
			"preferred_icon": "family_memory_clip",
			"eye_reading": "晚餐記憶中有一幀不屬於公寓的白色實驗室燈光。義眼標記它為真實異常，但畫面裡凱的視角明顯被污染。"
		},
		"hao_ran_drawer_note": {
			"name": "浩然抽屜裡的維修便條",
			"description": "浩然藏在上鎖抽屜裡的便條，反覆記下美玲原始備份的位置與播放器校正步驟。紙角被雨水浸濕，像是曾被匆忙帶出又塞回去。",
			"chapter": 1,
			"icon": "memo",
			"preferred_icon": "hao_ran_drawer_note"
		},
		"original_backup_hint": {
			"name": "原始記憶備份提示",
			"description": "家庭相簿夾層裡的備份提示，指向美玲一段未被壓縮、未被交易市場污染的原始記憶。浩然把它和家庭照片放在一起，像是在替她留下身份錨點。",
			"chapter": 1,
			"icon": "memory_capsule",
			"preferred_icon": "original_backup_hint"
		},
		"hao_ran_encrypted_message": {
			"name": "浩然留給美玲的加密留言",
			"description": "在浩然工作室中解出的短留言。它沒有直接說明浩然去了哪裡，只警告凱不要讓任何人拿走美玲的原始備份。",
			"chapter": 1,
			"icon": "log",
			"preferred_icon": "log"
		},
		"broken_memory_player": {
			"name": "損壞的記憶播放器",
			"description": "美玲公寓中被浩然拆開的家用記憶播放器，內部韌體被改成能讀取回聲網路的記憶編碼。",
			"chapter": 1,
			"icon": "memory_capsule",
			"preferred_icon": "broken_memory_player",
			"eye_reading": "播放器殘留一段鄭泰早期義眼維修握手協定。它不像使用紀錄，更像是浩然故意留下的鑰匙孔。"
		},
		"kai_eye_glitch_log": {
			"name": "凱的鷹眼異常紀錄",
			"description": "掃描損壞播放器時自動生成的鷹眼錯誤紀錄，顯示義眼與播放器短暫交換了同源加密握手。",
			"chapter": 1,
			"icon": "log",
			"preferred_icon": "kai_eye_glitch_log",
			"eagle_eye_only": true,
			"eye_reading": "錯誤紀錄顯示握手協定曾被手動喚醒。浩然不是隨機留下線索，他知道凱的義眼能讀到這一層。"
		},
		"eleven_pm_call_log": {
			"name": "十一點未接來電紀錄",
			"description": "美玲家用終端裡的通話紀錄。浩然失蹤前最後一通電話只響了一聲，隨即被遠端切斷。",
			"chapter": 1,
			"icon": "eleven_pm_call_log",
			"eye_reading": "鷹眼補出來電路由：通話曾經過舊城警署附近的公共節點，又在東區監控空窗開始前被強制終止。",
			"eye_reveals": ["rejected_missing_person_report"],
			"eye_flags": ["echo_trust_axis_seeded"]
		},
		"rejected_missing_person_report": {
			"name": "被退回的失蹤通報",
			"description": "舊城警署前哨退回美玲通報的文件，上面蓋著「成年人自願離開，暫不受理」的章。",
			"chapter": 1,
			"icon": "rejected_missing_person_report",
			"eye_reading": "義眼在文件底層讀到企業風險分類碼。警署不是沒看見案件，而是把它放進不碰的抽屜。",
			"eye_reveals": ["street_camera_gap"]
		},
		"street_camera_gap": {
			"name": "東區監控空窗",
			"description": "東區街道監控在 23:04 到 23:11 之間同時失去畫面，時間正好包住浩然最後一通電話。",
			"chapter": 1,
			"icon": "street_camera_gap",
			"eye_reading": "空窗不是設備故障，而是被遠端下達的同步遮蔽命令。指令格式沒有署名，只留下回聲式的封包節奏。"
		},
		"masked_client_receipt": {
			"name": "遮罩客戶包廂紀錄",
			"description": "深淵酒吧包廂系統殘留的匿名付款紀錄。客戶身份被全息面具協定覆蓋，只剩一段黑市預約 hash。",
			"chapter": 1,
			"icon": "masked_client_receipt",
			"eye_reading": "鷹眼能讀出 hash 的前綴：它不是一般黑市帳號，而是被回聲網路轉介過的臨時身份。"
		},
		"clinic_eye_warning_log": {
			"name": "Dr. 陳的義眼警告紀錄",
			"description": "Dr. 陳診所裡被刪除的維修紀錄，標記凱的義眼仍保留鄭泰早期維修握手協定。",
			"chapter": 1,
			"icon": "clinic_eye_warning_log",
			"eye_reading": "紀錄裡有一行被覆寫的警告：握手協定可由外部播放器喚醒。凱的義眼既是鑰匙，也可能是後門。"
		},
		"old_city_queue_ticket": {
			"name": "舊城警署等候號碼單",
			"description": "美玲在舊城警署前哨等候時拿到的濕掉號碼單。紙面只剩半個號碼，背面印著自動受理系統的案件分類流程。",
			"chapter": 1,
			"icon": "old_city_queue_ticket",
			"eye_reading": "號碼單底層殘留四小時的排隊時間戳。系統不是沒有收到美玲的恐懼，而是把它排進一串永遠輪不到人工審查的序列。"
		},
		"clinic_anonymous_case_note": {
			"name": "匿名記憶污染病歷",
			"description": "Dr. 陳離線病歷櫃裡的匿名病例摘要，記錄多名患者在記憶回放後出現同源眩暈、白光殘影與義眼握手錯誤。",
			"chapter": 1,
			"icon": "clinic_anonymous_case_note",
			"eye_reading": "病例姓名被遮掉，但症狀時間線和凱的義眼錯誤紀錄重疊。這不是單一故障，而是一批被制度外診所悄悄接住的傷口。"
		},
		"abyss_surveillance_delay_log": {
			"name": "深淵酒吧監控延遲紀錄",
			"description": "深淵酒吧後室終端殘留的監控延遲紀錄。二號包廂附近在浩然會面當晚被手動延遲三分鐘，理由欄只寫著「清場」。",
			"chapter": 1,
			"icon": "abyss_surveillance_delay_log",
			"eye_reading": "延遲命令不是事故，而是付費服務。鷹眼讀到阿傑的權限碼和一組黑市臨時 hash 同時出現，像兩個人一起把燈調暗。"
		},
		"black_market_entry_hint": {
			"name": "記憶黑市入口提示",
			"description": "由家庭備份、義眼握手與遮罩客戶紀錄交叉後整理出的入口線索。接受蛇女交易會指向黑市拍賣，拒絕交易則指向診所與義眼追查。",
			"chapter": 1,
			"icon": "black_market_entry_hint",
			"eye_reading": "提示本身不等於真相。義眼只能證明有人把浩然、凱與回聲格式接在同一條線上，不能證明迴響可信或不可信。"
		},

		# ============================================
		# CHAPTER 2: 記憶黑市 (10 items)
		# ============================================
		"echo_symbol": {
			"name": "回聲網路標記符號",
			"description": "回聲網路的識別標記——一個螺旋形的音波圖案。在多個地下場所的牆上都見過。",
			"chapter": 2,
			"icon": "symbol"
		},
		"memory_sample": {
			"name": "記憶樣本",
			"description": "一個記憶樣本膠囊，裝著某人的一段記憶。用鷹眼可以預覽片段。",
			"chapter": 2,
			"icon": "memory_capsule"
		},
		"warehouse_map": {
			"name": "廢棄倉庫位置地圖",
			"description": "標記了回聲網路在東區廢棄倉庫據點位置的地圖。",
			"chapter": 2,
			"icon": "map",
			"eye_reading": "維修動線通往同一組接收設備。位置圖只能引路，設備底座批號才可核對是否同一批器材。"
		},
		"hao_ran_diary": {
			"name": "浩然的個人日記",
			"description": "部分加密的電子日記，記錄了浩然加入回聲網路的經過和越來越深的不安。",
			"chapter": 2,
			"icon": "diary",
			"eye_reading": "段落的修改時間晚於建立時間。浩然補寫了撤回申請，不能把早期加入計畫的意願當成永久同意。"
		},
		"trade_ledger": {
			"name": "交易帳本副本",
			"description": "記憶黑市的交易記錄副本，記載了大量記憶買賣的細節和金額。",
			"chapter": 2,
			"icon": "ledger",
			"eye_reading": "報價時間與實際交貨時間分列。先有報價不代表交易完成，也不能由同名帳戶直接推定同一個人。"
		},
		"zhengtek_memo": {
			"name": "正和科技內部備忘錄",
			"description": "正和科技關於「回聲計畫」的內部備忘錄，提到了記憶技術的「特殊應用」。",
			"chapter": 2,
			"icon": "memo",
			"eye_reading": "停用欄位只指測試方案，沒有宣告停止出貨。後門滾輪保留的簽收計數可以檢查企業是否仍在移動設備。"
		},
		"victim_list": {
			"name": "受害者名單",
			"description": "被提取記憶的受害者名單，有些人標記為「已完全提取」。",
			"chapter": 2,
			"icon": "list",
			"eye_reading": "接收代碼與姓名是分開儲存的欄位。可先核對照護去向，無須將受害者私人資料一起傳出。"
		},
		"comm_frequency": {
			"name": "回聲網路通訊頻率",
			"description": "回聲網路內部通訊的加密頻率，可用於追蹤他們的活動。",
			"chapter": 2,
			"icon": "frequency",
			"eye_reading": "這是訊息抵達的通道，不是接收者已閱讀的證明。送達、覆核與實際操作應分別核對。"
		},
		"rusty_key": {
			"name": "生鏽的電子鑰匙",
			"description": "在廢棄倉庫裡找到的電子鑰匙，上面刻著一個序號。",
			"chapter": 2,
			"icon": "key",
			"eagle_eye_only": true
		},
		"fake_id_chip": {
			"name": "偽造的身份晶片",
			"description": "小鬼製作的偽造身份晶片，身份為記憶收藏家「張偉」。",
			"chapter": 2,
			"icon": "id_chip"
		},

		# ============================================
		# CHAPTER 3: 回聲深處 (10 items)
		# ============================================
		"overwrite_report": {
			"name": "覆寫技術研究報告",
			"description": "蕭博士的記憶覆寫技術完整研究報告，詳述如何覆寫一個人的記憶和人格。",
			"chapter": 3,
			"icon": "report",
			"eye_reading": "維持生命與記憶寫入有獨立控制欄位。停止寫入不等於直接拔除維持設備，救援仍需依照隔離程序。"
		},
		"zhengtek_funding": {
			"name": "正和科技資金流向",
			"description": "正和科技向回聲網路秘密轉移資金的文件，證明了公司的直接參與。",
			"chapter": 3,
			"icon": "funding",
			"eye_reading": "付款方與操作簽章並非同一欄。資金流向證明企業參與，不能替代誰在何時按下繼續的紀錄。"
		},
		"dr_xiao_journal": {
			"name": "蕭博士個人日誌",
			"description": "蕭博士的個人日誌，記錄了他從理想主義神經科學家到瘋狂研究者的心路歷程。",
			"chapter": 3,
			"icon": "journal",
			"eye_reading": "日誌裡的「待覆核」被重複套用。真正的接收與繼續寫入時間，要回到實驗室終端找本地簽章。"
		},
		"hao_ran_sos": {
			"name": "浩然的求救訊息",
			"description": "隱藏在記憶樣本中的求救訊息：「他們要覆寫我的記憶，救救我」。",
			"chapter": 3,
			"icon": "sos"
		},
		"lab_keycard": {
			"name": "實驗室門禁卡",
			"description": "正和科技秘密實驗室的門禁卡，最高安全級別。",
			"chapter": 3,
			"icon": "keycard"
		},
		"overwritten_profiles": {
			"name": "被覆寫者前後對比",
			"description": "數份被覆寫記憶的受害者資料，包含覆寫前後的人格對比。令人不寒而慄。",
			"chapter": 3,
			"icon": "profiles",
			"eye_reading": "比較表略去了測量時間與撤回紀錄。人格分數的變動不等於本人同意，也不是治療成功的完整證明。"
		},
		"echo_ai_log": {
			"name": "AI迴響對話紀錄",
			"description": "實驗室中覺醒的人工智慧「迴響」與研究人員的對話紀錄。它聲稱擁有數千人的記憶碎片。",
			"chapter": 3,
			"icon": "ai_log",
			"eye_reading": "迴響保留匯入順序，未必保留事件發生順序。將某段記憶放在較前的位置，不能自動證明那是較早的自己。"
		},
		"kai_memory_fragment": {
			"name": "凱的記憶碎片",
			"description": "屬於凱·川崎的被篡改記憶碎片。你的過去可能不是你以為的那樣。",
			"chapter": 3,
			"icon": "memory_fragment",
			"eagle_eye_only": true,
			"eye_reading": "匯入標記與工單日期相差一天。可以核對時間來源，不能靠清晰度或熟悉感決定真偽。"
		},
		"authorization_order": {
			"name": "正和科技授權令",
			"description": "正和科技高層簽署的「回聲計畫」正式授權令，蓋有最高執行長印章。",
			"chapter": 3,
			"icon": "authorization",
			"eye_reading": "企業層級授權與個人同意分屬不同簽章。上級允許計畫執行，不代表能覆蓋當事人的撤回。"
		},
		"dr_xiao_comms": {
			"name": "蕭博士與高層通訊",
			"description": "蕭博士與正和科技高層的加密通訊紀錄，討論記憶覆寫技術的「目標名單」。",
			"chapter": 3,
			"icon": "comms",
			"eye_reading": "訊息標為已送達後，仍有一段人工覆核空窗。市政紙本回執、終端接收與本地簽章能拼成三段時間線。"
		},
	}
