extends Resource
## CaseData - Chapter structure, scene locations, and case flow data.
class_name CaseData

static func get_chapter_data(chapter: int) -> Dictionary:
	var chapters := {
		1: {
			"title": "失蹤的記憶",
			"description": "一個神秘女子委託你尋找失蹤的弟弟——記憶技師林浩然。",
			"action_points": 20,
			"starting_location": "detective_office",
			"locations": {
				"detective_office": {
					"name": "偵探辦公室",
					"description": "你的辦公室，位於九龍延伸區的一棟老舊大樓裡。",
					"connections": ["mei_ling_apartment", "abyss_bar", "east_district_street"],
					"initial_dialogue": "ch1_mei_ling_intro",
					"hotspots": ["desk", "evidence_board", "window", "phone"]
				},
				"mei_ling_apartment": {
					"name": "林美玲的公寓",
					"description": "美玲和浩然合住的公寓。浩然的房間裡可能有線索。",
					"connections": ["detective_office", "east_district_street"],
					"story_actions": [
						{
							"id": "inspect_hao_ran_drawer",
							"title": "調查浩然上鎖抽屜",
							"dialogue": "ch1_hao_ran_drawer_search",
							"story_cg": "cg_mei_ling_apartment_memory_trace",
							"requires_evidence": "commission_letter"
						},
						{
							"id": "inspect_original_backup_album",
							"title": "檢視家庭相簿與原始備份提示",
							"dialogue": "ch1_original_backup_album",
							"story_cg": "cg_mei_ling_apartment_memory_trace",
							"requires_evidence": "hao_ran_drawer_note"
						},
						{
							"id": "review_family_memory_clip",
							"title": "回放家庭記憶片段",
							"dialogue": "ch1_family_memory_clip",
							"story_cg": "cg_family_memory_clip",
							"requires_evidence": "commission_letter"
						},
						{
							"id": "scan_broken_memory_player",
							"title": "掃描損壞記憶播放器",
							"dialogue": "ch1_kai_eye_glitch_scan",
							"requires_evidence": "commission_letter"
						},
						{
							"id": "inspect_eleven_pm_call_log",
							"title": "查閱浩然最後一通電話",
							"dialogue": "ch1_eleven_pm_call_log",
							"requires_evidence": "commission_letter"
						}
					],
					"hotspots": ["hao_ran_room", "computer", "bookshelf", "drawer"]
				},
				"abyss_bar": {
					"name": "深淵酒吧",
					"description": "東區地下三層的酒吧，霓虹紫色燈光和合成音樂。",
					"connections": ["detective_office", "east_district_street", "abyss_bar_backroom"],
					"initial_dialogue": "ch1_abyss_bar_enter",
					"story_actions": [
						{"id": "scan_ajie_receipt", "title": "核對酒吧時間戳", "dialogue": "ch1_eye_ajie_statement", "requires_evidence": "abyss_receipt", "scan_flag": "eye_ajie_receipt_scanned", "scan_summary": "收據列印與結帳相差七分鐘。終端延遲可核對，阿傑緊張或被迫說出的名字不能單獨證明誰到過現場。", "scan_cost": 20.0, "scan_position": [0.21, 0.49], "hide_after_flag": "ajie_statement_resolved"},
						{"id": "retract_ajie_statement", "title": "向阿傑更正指認", "dialogue": "ch1_ajie_retraction", "requires_decisions": {"ajie_statement": "coerced"}, "hide_after_flag": "ajie_statement_retracted"},
						{
							"id": "meet_snake_information_broker",
							"title": "與蛇女探口風",
							"dialogue": "ch1_snake_encounter",
							"requires_evidence": "abyss_receipt",
							"hide_after_flag": "snake_broker_met"
						},
						{
							"id": "negotiate_snake_data_chip",
							"title": "與蛇女談資料晶片交易",
							"dialogue": "ch1_snake_data_chip_choice",
							"story_cg": "cg_ch1_snake_trade_choice",
							"requires_evidence": "data_chip",
							"hide_after_flag": "snake_data_chip_choice_resolved"
						}
					],
					"hotspots": ["bar_counter", "booth", "snake_corner", "back_door"]
				},
				"hao_ran_workshop": {
					"name": "浩然的工作室",
					"description": "東區第七街地下的「永恆記憶」工作室。門鎖被破壞。",
					"connections": ["east_district_street"],
					"initial_dialogue": "ch1_workshop_enter",
					"story_actions": [
						{
							"id": "decode_eye_signature",
							"title": "比對鷹眼異常訊號",
							"dialogue": "ch1_eye_signature_decode",
							"requires_flag": "deduced_eye_echo_signature",
							"requires_evidence": "data_chip"
						},
						{
							"id": "reconstruct_hao_ran_motive",
							"title": "還原浩然的家庭動機",
							"dialogue": "ch1_hao_ran_family_motive",
							"requires_flag": "deduced_hao_ran_family_motive",
							"requires_evidence": "family_memory_clip"
						},
						{
							"id": "decode_hao_ran_last_message",
							"title": "解讀浩然留給美玲的加密留言",
							"dialogue": "ch1_hao_ran_encrypted_message",
							"story_cg": "cg_hao_ran_encrypted_message",
							"requires_evidence": "original_backup_hint"
						},
						{
							"id": "consult_dr_chen_eye_warning",
							"title": "聯絡 Dr. 陳解讀播放器協定",
							"dialogue": "ch1_dr_chen_eye_warning",
							"requires_flag": "deduced_player_echo_codec",
							"requires_evidence": "kai_eye_glitch_log"
						},
						{
							"id": "compile_ch1_three_evidence_inference",
							"title": "整理家庭備份、義眼握手與黑市入口",
							"dialogue": "ch1_three_evidence_inference",
							"story_cg": "cg_ch1_three_evidence_inference",
							"requires_flag": "deduced_ch1_three_evidence_gate",
							"requires_evidence": "family_memory_clip"
						}
					],
					"hotspots": ["memory_device", "desk_workshop", "data_chip_spot", "broken_lock"],
					"requires_flag": "knows_workshop_location"
				},
				"east_district_street": {
					"name": "東區街道",
					"description": "雨中的東區街道。霓虹招牌照亮濕漉漉的路面。",
					"connections": ["detective_office", "mei_ling_apartment", "abyss_bar", "hao_ran_workshop", "old_city_police_outpost", "dr_chen_clinic"],
					"story_actions": [
						{"id": "scan_grid_clock", "title": "比對配電箱與監控時鐘", "dialogue": "ch1_scan_grid", "scan_flag": "eye_grid_scanned", "scan_summary": "市電與備援監控使用不同時鐘，停電沒有覆蓋全部錄影缺口。人為刪片仍是假設，需要獨立回執核對。", "scan_cost": 20.0, "scan_position": [0.2, 0.57], "hide_after_flag": "grid_review_resolved"},
						{
							"id": "review_east_district_camera_gap",
							"title": "比對東區監控空窗",
							"dialogue": "ch1_street_camera_gap",
							"story_cg": "cg_ch1_street_camera_gap",
							"requires_evidence": "rejected_missing_person_report"
						}
					]
				},
				"old_city_police_outpost": {
					"name": "舊城警署前哨",
					"description": "燈光刺眼、流程清楚，卻把美玲恐懼排成號碼的城市執法節點。",
					"connections": ["east_district_street"],
					"initial_dialogue": "ch1_old_city_police_outpost_enter",
					"story_actions": [
						{
							"id": "inspect_old_city_queue_ticket",
							"title": "檢視濕掉的等候號碼單",
							"dialogue": "ch1_old_city_queue_ticket",
							"requires_evidence": "eleven_pm_call_log",
							"set_flag": "old_city_queue_ticket_collected",
							"hide_after_flag": "old_city_queue_ticket_collected"
						},
						{
							"id": "visit_old_city_police_outpost",
							"title": "查詢美玲被退回的報案",
							"dialogue": "ch1_old_city_police_outpost",
							"story_cg": "cg_ch1_police_report_rejection",
							"requires_evidence": "eleven_pm_call_log",
							"set_flag": "old_city_police_outpost_reviewed",
							"hide_after_flag": "old_city_police_outpost_reviewed"
						}
					],
					"hotspots": ["front_counter", "case_terminal", "queue_machine", "corporate_window"],
					"requires_evidence": "eleven_pm_call_log"
				},
				"dr_chen_clinic": {
					"name": "Dr. 陳診所",
					"description": "消毒燈太亮的小型義體診所，承接那些不能進正式病歷的記憶傷口。",
					"connections": ["east_district_street"],
					"initial_dialogue": "ch1_dr_chen_encounter",
					"story_actions": [
						{
							"id": "inspect_clinic_anonymous_case_note",
							"title": "翻查匿名記憶污染病歷",
							"dialogue": "ch1_clinic_anonymous_case_note",
							"requires_evidence": "kai_eye_glitch_log",
							"set_flag": "clinic_anonymous_case_note_collected",
							"hide_after_flag": "clinic_anonymous_case_note_collected"
						},
						{
							"id": "visit_dr_chen_clinic",
							"title": "請 Dr. 陳解讀義眼握手",
							"dialogue": "ch1_dr_chen_clinic_followup",
							"story_cg": "cg_ch1_dr_chen_warning",
							"requires_evidence": "kai_eye_glitch_log",
							"set_flag": "dr_chen_clinic_warning_reviewed",
							"hide_after_flag": "dr_chen_clinic_warning_reviewed"
						}
					],
					"hotspots": ["waiting_room", "case_cabinet", "eye_calibration_unit", "offline_records"],
					"requires_evidence": "kai_eye_glitch_log"
				},
				"abyss_bar_backroom": {
					"name": "深淵酒吧後室",
					"description": "包廂監控、隔音牆與清場紀錄都指向同一個事實：有人付錢讓浩然消失在沉默裡。",
					"connections": ["abyss_bar"],
					"initial_dialogue": "ch1_abyss_bar_backroom_enter",
					"story_actions": [
						{
							"id": "inspect_abyss_surveillance_delay",
							"title": "調閱包廂監控延遲紀錄",
							"dialogue": "ch1_abyss_surveillance_delay_log",
							"requires_evidence": "stranger_photo",
							"set_flag": "abyss_surveillance_delay_log_collected",
							"hide_after_flag": "abyss_surveillance_delay_log_collected"
						},
						{
							"id": "investigate_abyss_backroom",
							"title": "調查遮罩客戶包廂紀錄",
							"dialogue": "ch1_abyss_backroom_investigation",
							"story_cg": "cg_ch1_snake_trade_choice",
							"requires_evidence": "stranger_photo",
							"set_flag": "abyss_backroom_investigated",
							"hide_after_flag": "abyss_backroom_investigated"
						}
					],
					"hotspots": ["booth_terminal", "surveillance_panel", "service_corridor", "soundproof_door"],
					"requires_evidence": "stranger_photo"
				}
			},
		},

		2: {
			"title": "記憶黑市",
			"description": "追蹤回聲網路的線索，潛入記憶黑市。",
			"action_points": 20,
			"starting_location": "bitstorm_cafe",
			"locations": {
				"bitstorm_cafe": {
					"name": "比特風暴網咖",
					"description": "駭客聚集的地下網咖，三排老舊電腦散發著藍光。",
					"connections": ["memory_black_market", "zhengtek_exterior", "sewer_passage", "civic_archive", "referral_waiting_station"],
					"initial_dialogue": "ch2_opening",
					"story_actions": [
{"id": "branch_direction", "title": "整理第二章方向／換路", "dialogue": "ch2_branch_direction", "requires_missing_flags": ["ch2_branch_complete", "chapter_2_complete"]},
						{"id": "scan_unsent_backup", "title": "核對未寄出備份", "dialogue": "ch2_eye_unsent_backup", "requires_flag": "warehouse_investigated", "requires_evidences": ["original_backup_hint", "hao_ran_diary"], "scan_flag": "eye_backup_scanned", "scan_summary": "封包標頭分出家庭修復、實驗摘要與追蹤路由；辨認用途不等於獲准閱讀私人內容。", "scan_cost": 20.0, "scan_position": [0.78, 0.53], "hide_after_flag": "backup_handling_resolved"},
						{"id": "talk_to_kid", "title": "詢問小鬼", "dialogue": "ch2_kid_encounter", "hide_after_flag": "has_fake_id"},
						{"id": "call_mei_ling", "title": "回撥美玲，說明倉庫調查結果", "dialogue": "ch2_family_update", "requires_flag": "warehouse_investigated", "requires_evidence": "victim_list", "hide_after_flag": "family_update_resolved"},
						{"id": "conclude_chapter_2", "requires_branch_complete": true, "title": "確認回聲總部的進入路線", "dialogue": "ch2_conclude_investigation", "requires_flags": ["warehouse_investigated", "ch2_investigation_complete"], "hide_after_flag": "chapter_2_complete"}
					],
					"hotspots": ["kid_corner", "bulletin_board", "terminal"]
				},
				"memory_black_market": {
					"name": "記憶黑市",
					"description": "隱藏在廢棄地鐵站的地下市場。各種非法記憶在這裡交易。",
					"connections": ["bitstorm_cafe", "sewer_passage", "auction_handover_room"],
					"requires_flag": "has_fake_id",
					"initial_dialogue": "ch2_memory_market_enter",
					"story_actions": [
						{"id": "scan_market_claim", "title": "核對市場追討權", "dialogue": "ch2_eye_market_claim", "requires_flag": "market_trade_resolved", "scan_flag": "eye_market_claim_scanned", "scan_summary": "市場報價權與第一章晶片交易分開。買過樣本才有原報價權；沒有簽約者不會憑空產生舊債。", "scan_cost": 20.0, "scan_position": [0.77, 0.57], "hide_after_flag": "market_claim_resolved"},
						{"id": "meet_ghost", "title": "尋找幽靈", "dialogue": "ch2_ghost_encounter", "requires_flag": "entered_market", "hide_after_flag": "ghost_encounter_resolved"},
						{"id": "choose_memory_trade", "title": "決定記憶交易方式與代價", "dialogue": "ch2_memory_trade_choice", "requires_flag": "entered_market", "hide_after_flag": "market_trade_resolved"}
					],
					"hotspots": ["mask_merchant", "memory_stall", "ghost_meeting", "exit_tunnel"]
				},
				"abandoned_warehouse": {
					"name": "廢棄倉庫",
					"description": "回聲網路的據點之一。裡面堆滿了記憶提取設備。",
					"connections": ["sewer_passage"],
					"initial_dialogue": "ch2_warehouse_explore",
					"story_actions": [
						{"id": "scan_warehouse_batch", "title": "掃描設備底座的維修批號", "dialogue": "ch2_scan_warehouse_batch", "requires_flag": "warehouse_investigated", "scan_flag": "eye_batch_scanned", "scan_summary": "多台設備底座具有相同維修批號。接收代碼可用於查詢照護去向，運送封條可用於追查設備流轉。", "scan_cost": 20.0, "scan_position": [0.75, 0.6], "hide_after_flag": "warehouse_batch_resolved"}
					],
					"hotspots": ["equipment", "desk_warehouse", "hidden_room", "diary_spot"]
				},
				"zhengtek_exterior": {
					"name": "正和科技大樓外圍",
					"description": "正和科技總部的後門區域。趙明在這裡等你。",
					"connections": ["bitstorm_cafe", "sewer_passage", "civic_archive"],
					"initial_dialogue": "ch2_zhao_ming_meeting",
					"story_actions": [
						{"id": "scan_dispatch_clock", "title": "掃描後門出貨滾輪", "dialogue": "ch2_scan_dispatch_clock", "requires_evidence": "zhengtek_memo", "scan_flag": "eye_dispatch_scanned", "scan_summary": "備忘錄標示停用之後，同批設備仍有出貨。停用方案與停止搬運不是同一件事，簽收者仍須核對。", "scan_cost": 20.0, "scan_position": [0.52, 0.53], "hide_after_flag": "dispatch_record_resolved"},
						{"id": "verify_zhengtek_memo", "title": "核對倉庫紀錄與正和備忘錄", "dialogue": "ch2_verify_zhengtek_memo", "requires_flag": "warehouse_investigated", "requires_evidences": ["zhengtek_memo", "hao_ran_diary", "victim_list"], "hide_after_flag": "ch2_investigation_complete"}
					],
					"hotspots": ["back_entrance", "zhao_meeting_spot", "surveillance_camera"]
				},
				"referral_waiting_station": {
    "name": "離線轉介等候站",
    "description": "網咖附近的離線接收窗口。先查空白簽收，再到市政檔案室核對改派。",
    "connections": [
      "bitstorm_cafe",
      "civic_archive"
    ],
    "requires_chapter_route": "clinic",
    "initial_dialogue": "ch2_referral_enter",
    "story_actions": [
      {
        "id": "referral_number",
        "title": "掃描叫號紙與接收簿",
        "dialogue": "ch2_referral_number",
        "requires_chapter_route": "clinic",
        "scan_flag": "eye_referral_scanned",
        "scan_summary": "R-17 重印退件，簽收欄仍空白；R-71 的簽名屬於別案，不可移用。",
        "scan_cost": 20.0,
        "scan_position": [
          0.3,
          0.48
        ],
        "hide_after_flag": "referral_number_checked",
        "requires_missing_flags": [
          "ch2_branch_complete"
        ]
      },
      {
        "id": "referral_priority",
        "title": "交接接收查詢／整批改派紀錄",
        "dialogue": "ch2_referral_priority",
        "requires_chapter_route": "clinic",
        "requires_flag": "referral_reroute_checked",
        "requires_evidences": [
          "hao_ran_diary",
          "victim_list"
        ],
        "hide_after_flag": "ch2_branch_complete"
      }
    ]
  },
  "auction_handover_room": {
    "name": "拍賣交割後室",
    "description": "黑市前台後方的樣本交割區。只讀封條，不需要打開他人的私人記憶。",
    "connections": [
      "memory_black_market",
      "sewer_passage"
    ],
    "requires_chapter_route": "black_market",
    "initial_dialogue": "ch2_auction_enter",
    "story_actions": [
      {
        "id": "auction_batch",
        "title": "掃描交割銅扣與新舊標籤",
        "dialogue": "ch2_auction_batch",
        "requires_chapter_route": "black_market",
        "scan_flag": "eye_auction_scanned",
        "scan_summary": "新標籤覆蓋同批舊維修壓痕；商品名與批號不能直接指認受害者身份。",
        "scan_cost": 20.0,
        "scan_position": [
          0.7,
          0.48
        ],
        "hide_after_flag": "auction_batch_checked",
        "requires_missing_flags": [
          "ch2_branch_complete"
        ]
      },
      {
        "id": "auction_access",
        "title": "決定交割表的查閱方式",
        "dialogue": "ch2_auction_access",
        "requires_chapter_route": "black_market",
        "requires_flag": "auction_batch_checked",
        "hide_after_flag": "auction_access_resolved",
        "requires_missing_flags": [
          "ch2_branch_complete"
        ]
      },
      {
        "id": "auction_priority",
        "title": "交接批次帳目／設備去向",
        "dialogue": "ch2_auction_priority",
        "requires_chapter_route": "black_market",
        "requires_flag": "auction_access_resolved",
        "requires_evidences": [
          "hao_ran_diary",
          "victim_list"
        ],
        "hide_after_flag": "ch2_branch_complete"
      }
    ]
  },
"civic_archive": {
					"name": "市政離線檔案室",
					"description": "仍保留紙本回執與磁帶的市政閱覽室。調查撤回申請被送往何處。",
					"connections": ["bitstorm_cafe", "zhengtek_exterior", "referral_waiting_station"],
					"initial_dialogue": "ch2_civic_archive_enter",
					"story_actions": [
{"id": "referral_reassigned", "title": "比對轉介站與市政改派回條", "dialogue": "ch2_referral_reassigned", "requires_chapter_route": "clinic", "requires_flags": ["referral_number_checked", "eye_withdrawal_scanned"], "hide_after_flag": "referral_reroute_checked", "requires_missing_flags": ["ch2_branch_complete"]},
						{"id": "check_returned_index", "title": "核對退件推車的公開索引", "dialogue": "ch2_archive_returned_index", "hide_after_flag": "archive_index_checked"},
						{"id": "scan_withdrawal_queue", "title": "讀取撤回申請的壓印回執", "dialogue": "ch2_scan_withdrawal_queue", "scan_flag": "eye_withdrawal_scanned", "scan_summary": "R-17 撤回申請於 21:14 受理，21:21 被送入正和的治療佇列。紙本送出不等於實驗室已閱讀，還需接收與操作紀錄。", "scan_cost": 20.0, "scan_position": [0.295, 0.385], "hide_after_flag": "archive_route_resolved"}
					]
				},
				"sewer_passage": {
					"name": "下水道通道",
					"description": "連接各個地下場所的秘密通道。潮濕、黑暗，偶爾有老鼠經過。",
					"connections": ["bitstorm_cafe", "memory_black_market", "abandoned_warehouse", "zhengtek_exterior", "auction_handover_room"],
					"story_actions": [
						{"id": "compare_ghost_identity_trace", "title": "比對幽靈的採樣時間與身份使用紀錄", "dialogue": "ch2_ghost_trace", "requires_flag": "warehouse_investigated", "requires_evidence": "victim_list", "hide_after_flag": "ghost_trace_verified"},
						{"id": "follow_up_ghost", "title": "回到離線頻道，處理對幽靈的承諾", "dialogue": "ch2_ghost_followup", "requires_flags": ["ghost_identity_resolved", "ghost_trace_verified"], "hide_after_flag": "ghost_followup_resolved"},
						{"id": "uncover_ghost_identity", "title": "核對幽靈的舊身份，決定是否保護他", "dialogue": "ch2_ghost_identity_reveal", "requires_flag": "warehouse_investigated", "requires_evidence": "victim_list", "hide_after_flag": "ghost_identity_resolved"}
					]
				}
			}
		},

		3: {
			"title": "回聲深處",
			"description": "深入回聲網路總部，面對真相。",
			"action_points": 20,
			"starting_location": "echo_network_hq",
			"locations": {
				"echo_network_hq": {
					"name": "回聲網路總部",
					"description": "地下第十層的高科技設施。冰冷的白色走廊和嗡嗡作響的伺服器。",
					"connections": ["secret_lab", "memory_space"],
					"initial_dialogue": "ch3_opening",
					"story_actions": [
						{"id": "choose_hq_entry", "title": "在前室選擇進入總部的方式", "dialogue": "ch3_hq_entry", "hide_after_flag": "hq_entry_resolved"},
						{"id": "align_memory_corridor", "title": "比對記憶錯位走廊與授權紀錄", "dialogue": "ch3_memory_corridor", "requires_flag": "hq_entry_resolved", "hide_after_flag": "memory_corridor_aligned"},
						{"id": "secure_core_evidence", "title": "封存伺服器的核心證據", "dialogue": "ch3_secure_core_evidence", "requires_flag": "memory_corridor_aligned", "hide_after_flag": "core_evidence_secured"},
						{"id": "verify_public_sources", "title": "核對三份原件與獨立稽核紀錄", "dialogue": "ch3_verify_public_sources", "requires_flags": ["core_evidence_secured", "xiao_confronted", "trusted_zhao_ming"], "requires_evidences": ["overwrite_report", "zhengtek_funding", "authorization_order"], "hide_after_flag": "public_sources_verified"},
						{"id": "review_public_record", "title": "確認或更新自己的行動紀錄", "dialogue": "ch3_review_public_record", "requires_flags": ["public_sources_verified", "trusted_zhao_ming"], "requires_missing_flags": ["final_choice_resolved", "case_resolved"]},
						{"id": "prepare_whistleblower_package", "title": "與趙明製作保護證人身份的舉報包", "dialogue": "ch3_zhao_whistleblower", "requires_flags": ["trusted_zhao_ming", "core_evidence_secured"], "requires_evidences": ["overwrite_report", "zhengtek_funding", "authorization_order"], "hide_after_flag": "zhao_whistleblower_package"}
					],
					"hotspots": ["server_room", "control_panel", "corridor", "locked_door"]
				},
				"secret_lab": {
					"name": "正和科技秘密實驗室",
					"description": "記憶覆寫技術的核心實驗室。蕭博士的領地。",
					"connections": ["echo_network_hq", "rooftop", "recovery_annex"],
					"initial_dialogue": "ch3_dr_xiao_confrontation",
					"requires_flag": "memory_corridor_aligned",
					"story_actions": [
						{"id": "scan_override_console", "title": "掃描覆核站的本地簽章", "dialogue": "ch3_scan_override_console", "requires_flag": "xiao_confronted", "scan_flag": "eye_override_scanned", "scan_summary": "R-17 在本地已接收，之後有人簽章維持寫入排程。維持生命與繼續改寫有獨立控制，須與市政回執核對。", "scan_cost": 20.0, "scan_position": [0.22, 0.49], "hide_after_flag": "override_console_reviewed", "set_flag": "override_console_reviewed"},
						{"id": "challenge_xiao_records", "title": "拿紀錄追問蕭博士", "dialogue": "ch3_xiao_record_challenge", "requires_flag": "eye_override_scanned", "hide_after_flag": "xiao_record_challenge_resolved", "requires_missing_flags": ["final_choice_resolved", "case_resolved"]},
						{"id": "find_hao_ran", "title": "搜尋浩然", "dialogue": "ch3_hao_ran_found", "requires_flag": "xiao_confronted", "hide_after_flag": "hao_ran_located"},
						{"id": "rescue_hao_ran", "title": "隔離覆寫裝置並救出浩然", "dialogue": "ch3_rescue_hao_ran", "requires_flag": "hao_ran_located", "requires_evidence": "overwrite_report", "hide_after_flag": "hao_ran_rescued"},
						{"id": "ask_backup_permission", "title": "讓浩然決定備份用途", "dialogue": "ch3_backup_permission", "requires_flags": ["hao_ran_rescued", "backup_handling_resolved"], "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "hide_after_flag": "backup_custody_resolved"}
					],
					"hotspots": ["overwrite_device", "dr_xiao_desk", "hao_ran_chair", "ai_terminal"]
				},
				"memory_space": {
					"name": "凱的記憶空間",
					"description": "鷹眼觸發的內心空間。碎片化的記憶在這裡漂浮。",
					"connections": ["echo_network_hq"],
					"initial_dialogue": "ch3_echo_ai",
					"requires_flag": "memory_corridor_aligned",
					"story_actions": [
						{"id": "scan_memory_anchor", "title": "掃描記憶時間標記，留下甦醒紀錄", "dialogue": "ch3_scan_memory_anchor", "requires_flags": ["kai_memory_truth_reviewed", "hao_ran_rescued"], "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "scan_flag": "eye_anchor_scanned", "scan_summary": "片段匯入時間與事件發生日期不同。外部生活紀錄或私信可以提供核對線索，都不能保證恢復後記得今天。", "scan_cost": 20.0, "scan_position": [0.18, 0.54], "hide_after_flag": "memory_anchor_resolved"},
						{"id": "review_kai_fragment_1", "title": "記憶一：與趙明的內部調查", "dialogue": "ch3_kai_fragment_1", "hide_after_flag": "kai_memory_1_seen"},
						{"id": "review_kai_fragment_2", "title": "記憶二：與蕭博士的覆寫原型", "dialogue": "ch3_kai_fragment_2", "requires_flag": "kai_memory_1_seen", "hide_after_flag": "kai_memory_2_seen"},
						{"id": "review_kai_fragment_3", "title": "記憶三：核對測試者的同意紀錄", "dialogue": "ch3_kai_fragment_3", "requires_flags": ["kai_memory_2_seen", "xiao_confronted", "core_evidence_secured"], "hide_after_flag": "kai_memory_3_seen"},
						{"id": "decide_echo_fate", "title": "回應迴響的要求與記憶恢復代價", "dialogue": "ch3_echo_release_choice", "requires_flag": "kai_memory_truth_reviewed", "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "hide_after_flag": "echo_choice_resolved"}
					],
					"hotspots": ["memory_fragment_1", "memory_fragment_2", "memory_fragment_3"]
				},
				"rooftop": {
					"name": "屋頂",
					"description": "正和科技大樓的屋頂。風雨交加。城市的霓虹燈在遠處閃爍。",
					"connections": ["secret_lab", "office_epilogue", "recovery_annex"],
					"story_actions": [
						{"id": "check_hao_ran_aftercare", "title": "到避難間確認浩然的意願", "dialogue": "ch3_hao_ran_aftercare", "requires_flag": "hao_ran_rescued", "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "hide_after_flag": "hao_ran_aftercare_resolved"},
						{"id": "negotiate_grey_care", "title": "談妥交易的照護條款", "dialogue": "ch3_grey_care_terms", "requires_flags": ["hao_ran_rescued", "market_claim_resolved"], "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "hide_after_flag": "grey_care_terms_resolved"},
						{
							"id": "choose_case_resolution",
							"title": "確認結局條件並作出最後決定",
							"dialogue": "ch3_rooftop_choice",
							"show_ending_requirements": true,
							"hide_after_flag": "final_choice_resolved"
						},
						{
							"id": "resolve_case",
							"title": "執行最後決定，迎向結局",
							"requires_flag": "final_choice_resolved",
							"hide_after_flag": "case_resolved",
							"use_calculated_ending": true,
							"ending_dialogues": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]
						}
					],
					"hotspots": ["city_view", "confrontation_spot"]
				},
				"recovery_annex": {
					"name": "復健轉運間",
					"description": "實驗室旁暫時停用的復健空間。浩然救援後，可在此核對接收設備與回診資料。",
					"connections": ["secret_lab", "rooftop"],
					"requires_flag": "hao_ran_rescued",
					"initial_dialogue": "ch3_recovery_annex_enter",
					"story_actions": [
						{"id": "sit_with_hao_ran", "title": "暫停調查，問浩然現在需要什麼", "dialogue": "ch3_recovery_quiet", "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "hide_after_flag": "recovery_quiet_resolved"},
						{"id": "scan_recovery_route", "title": "核對轉運終端的待送收件者", "dialogue": "ch3_scan_recovery_route", "requires_missing_flags": ["final_choice_resolved", "case_resolved"], "scan_flag": "eye_recovery_scanned", "scan_summary": "待送的回診資料預設包含設備承包商收件者。可選離線紙本交接，或由本人確認後僅送指定醫師。", "scan_cost": 20.0, "scan_position": [0.855, 0.32], "hide_after_flag": "recovery_route_resolved"}
					]
				},
				"office_epilogue": {
					"name": "偵探辦公室（尾聲）",
					"description": "一切結束後。你的辦公室，雨還在下。",
					"requires_flag": "case_resolved",
					"initial_dialogue": "ch3_epilogue_family",
					"story_actions": [
						{"id": "read_case_aftermath", "title": "查看案件之後的未讀訊息", "dialogue": "ch3_epilogue_contacts", "requires_flag": "case_resolved", "hide_after_flag": "epilogue_contacts_read"},
						{
							"id": "resolve_case_epilogue",
							"title": "回顧案件",
							"use_calculated_ending": true,
							"ending_dialogues": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"]
						}
					],
					"connections": []
				}
			}
		},
	}
	return chapters.get(chapter, {})
