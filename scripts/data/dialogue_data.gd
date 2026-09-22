extends Resource
## DialogueData - Contains all dialogue data for the game organized by chapter and character.
class_name DialogueData

# Returns dialogue array for a given dialogue ID
static func get_dialogue(dialogue_id: String) -> Array:
	var all_dialogues := _get_all_dialogues()
	return all_dialogues.get(dialogue_id, [])

static func _get_all_dialogues() -> Dictionary:
	return {
		"ch3_kai_zhao_followup": [
  {
    "speaker": "kai",
    "text": "我記得你把清單翻了面。我在背面寫過一句話。那時候，你知道我也在維護原型嗎？",
    "requires_flags": [
      "kai_memory_2_seen",
      "trusted_zhao_ming"
    ]
  },
  {
    "speaker": "zhao_ming",
    "text": "知道你接過維護。我在調查室看你簽過名。實驗室那頭怎麼用，我不在場。",
    "choices": [
      {
        "text": "核對你親眼見過的簽名。",
        "next": "zhao_signature"
      },
      {
        "text": "先收起清單，之後再談。",
        "next": "end"
      }
    ]
  },
  {
    "label": "zhao_signature",
    "speaker": "narrator",
    "text": "你把清單背面的維護簽名與授權時間並排。簽名能對上；旁邊的手寫異議，沒有撤銷那次權限。"
  },
  {
    "speaker": "zhao_ming",
    "text": "你那天寫完，問我借了打火機。拿到手又還我，說戒了。我以為你會把這件事查到底。"
  },
  {
    "speaker": "kai",
    "text": "我寫了反對的話，卻沒把門關上。這兩件事都留著。",
    "set_flag": "kai_zhao_account_checked",
    "next": "end"
  }
],
		"ch3_kai_xiao_followup": [
  {
    "speaker": "kai",
    "text": "原型的回寫權限是我開的。我說過先求穩定，再補同意。你當時拿這句話做了什麼？",
    "requires_flags": [
      "kai_memory_2_seen",
      "xiao_confronted"
    ]
  },
  {
    "speaker": "dr_xiao",
    "text": "你把它當成待辦，我把它當成能繼續跑的許可。每次測試都有人催下一次。",
    "choices": [
      {
        "text": "拿授權時間核對那次維護。",
        "next": "kai_scope"
      },
      {
        "text": "先停止追問，回查紀錄。",
        "next": "end"
      }
    ]
  },
  {
    "label": "kai_scope",
    "speaker": "narrator",
    "text": "授權時間與你記得的維護批次一致。它能核對你的參與；蕭博士當時怎麼想，仍是他的說法。"
  },
  {
    "speaker": "kai",
    "text": "我讓權限留下來，是我的事。後來有人喊停，你繼續寫入，是另一件。"
  },
  {
    "speaker": "dr_xiao",
    "text": "是。你沒替我簽那次覆核。你也別指望那份覆核能把你的簽名遮住。"
  },
  {
    "speaker": "kai",
    "text": "不遮。把兩份分開存。",
    "set_flag": "kai_xiao_account_checked",
    "next": "end"
  }
],
		"ch3_kai_account_response": [
  {
    "speaker": "narrator",
    "text": "清單、授權時間與兩人的回答放在一起。你可以確認自己參與過維護，不能靠一段回憶補出全部經過。",
    "choices": [
      {
        "text": "留下具名維護說明，連同來源保存。",
        "next": "kai_account_signed"
      },
      {
        "text": "保留未確定的部分，列出待查問題。",
        "next": "kai_account_pending"
      },
      {
        "text": "暫時收起，稍後再決定。",
        "next": "end"
      }
    ]
  },
  {
    "label": "kai_account_signed",
    "speaker": "kai",
    "text": "我簽自己的部分。清單上的名字、權限和時間，不會因為我失憶就換一個人。",
    "set_decision": {
      "kai_account_response": "signed"
    },
    "set_flag": "kai_account_response_recorded",
    "next": "end"
  },
  {
    "label": "kai_account_pending",
    "speaker": "kai",
    "text": "先列出我能確認的事。誰催下一次、我收到過哪些回覆，還要查。簽名原件照樣保存。",
    "set_decision": {
      "kai_account_response": "pending"
    },
    "set_flag": "kai_account_response_recorded",
    "next": "end"
  }
],
		"ch3_lab_arrival": [
			{"speaker": "narrator", "text": "實驗室的隔板後傳來維持器的聲音。蕭博士站在遠端工作桌旁；設備側面的離線終端仍然亮著。"},
			{"speaker": "kai", "text": "我可以先找浩然，核對設備報告與出口，也可以先拿紀錄問蕭博士。進了這扇門，不表示得照他的順序談。", "next": "end"}
		],
		"ch3_device_report": [
			{"speaker": "narrator", "text": "維持椅側面刻著 M-3，控制器運行第六版。終端有第四版展示稿，以及第六版簽署報告。第六版才列出這台設備的隔離程序。", "choices": [
				{"text": "核對 M-3、第六版及本地簽章。", "next": "device_sequence"},
				{"text": "第四版有治療成功率，直接照做。", "next": "device_wrong"},
				{"text": "先離開，也可以改問蕭博士。", "next": "end"}
			], "next": "end"},
			{"label": "device_wrong", "speaker": "kai", "text": "成功率不能告訴我怎麼斷線。版本與設備也對不上。維持器仍穩定運作，先保留現況，再查一次。", "next": "end"},
			{"label": "device_sequence", "speaker": "narrator", "text": "簽章、設備序號與運行版本一致。程序要求：先停止遠端寫入，確認離線維持穩定，才解除接口與固定帶。", "choices": [
				{"text": "保留維持功能，先隔離寫入。", "next": "device_verified"},
				{"text": "先拔掉所有電源，再檢查。", "next": "device_unsafe"},
				{"text": "暫停核對。", "next": "end"}
			], "next": "end"},
			{"label": "device_unsafe", "speaker": "kai", "text": "那會連維持功能一起切掉。我還沒動手，先重新核對順序。", "next": "end"},
			{"label": "device_verified", "speaker": "kai", "text": "我保存報告、設備序號及簽章來源。找到浩然、準備好離線出口，就能按程序救人。至於誰下令繼續覆寫，仍要另外追問。", "give_evidence": "overwrite_report", "set_flag": "hq_device_report_checked", "next": "end"}
		],
		"ch3_ghost_support": [
			{"speaker": "ghost", "requires_decisions": {"ghost_followup_choice": "repaired"}, "text": "先說好，只接這一次。新地址不給你，證詞也不給。接應器留在舊頻道，你別追過來。"},
			{"speaker": "ghost", "mood": "cautious", "text": "我能替你守一次窗口：撤離門，或原件傳輸。選定後我就得守在那一頭，不能來回換。另一件事要你自己核對，仍然做得到。", "choices": [
				{"text": "把協助留給浩然撤離。", "next": "support_rescue_confirm", "requires_missing_flags": ["hao_ran_rescued"]},
				{"text": "協助核對原件的傳輸與保管。", "next": "support_evidence_confirm", "requires_missing_flags": ["core_evidence_secured"]},
				{"text": "先不分派，我自己查。", "next": "end"}
			], "next": "end"},
			{"label": "support_rescue_confirm", "speaker": "ghost", "text": "確認後，我守撤離門。伺服器的來源與保管鏈要你自己查；設備隔離也不能由我代做。", "choices": [
				{"text": "確認，請守撤離門。", "next": "support_rescue", "requires_decisions": {"hq_ghost_support": "none"}, "requires_missing_flags": ["hao_ran_rescued"]},
				{"text": "還沒決定。", "next": "end"}
			], "next": "end"},
			{"label": "support_rescue", "speaker": "ghost", "text": "接應器切到門控頻道。你到實驗室準備出口時，我會回送離線門的狀態。", "set_decision": {"hq_ghost_support": "rescue"}, "next": "end"},
			{"label": "support_evidence_confirm", "speaker": "ghost", "text": "確認後，我留在原件傳輸端。你得自己比對維修表，確認浩然的離線出口。", "choices": [
				{"text": "確認，請守原件傳輸端。", "next": "support_evidence", "requires_decisions": {"hq_ghost_support": "none"}, "requires_missing_flags": ["core_evidence_secured"]},
				{"text": "還沒決定。", "next": "end"}
			], "next": "end"},
			{"label": "support_evidence", "speaker": "ghost", "text": "接應器切到只讀傳輸頻道。我替你核對接收端，文件本身的簽章仍要你確認。", "set_decision": {"hq_ghost_support": "evidence"}, "next": "end"}
		],
		"ch3_core_custody": [
			{"speaker": "kai", "text": "授權令有專案碼，伺服器也有展示摘要。我得找到簽署原件的保管紀錄，再封存。選哪一種查法？", "choices": [
				{"text": "使用幽靈保留的原件傳輸窗口。", "next": "core_ghost", "requires_decisions": {"hq_entry_route": "ghost", "hq_ghost_support": "evidence"}},
				{"text": "以企業資格具名調閱，保留本次紀錄。", "next": "core_corporate", "requires_decisions": {"hq_entry_route": "corporate"}, "requires_missing_flags": ["hq_corporate_access_disabled"]},
				{"text": "自行比對紙本交接簿與機架封條。", "next": "core_offline"},
				{"text": "停用企業資格，改用紙本核對。", "next": "core_offline", "requires_decisions": {"hq_entry_route": "corporate"}, "requires_missing_flags": ["hq_corporate_access_disabled"], "set_flag": "hq_corporate_access_disabled"},
				{"text": "先不調閱，稍後再選。", "next": "end"}
			], "next": "end"},
			{"label": "core_ghost", "speaker": "ghost", "text": "接收端和機架封條的編號一致。這是只讀傳輸，沒有帶走機架內的檔案。你核對授權令與原件簽章，我只替你守住傳輸端。", "choices": [
				{"text": "比對授權令、原件簽章與接收編號。", "next": "core_ghost_verified"},
				{"text": "先離開；協助仍留在傳輸端。", "next": "end"}
			], "next": "end"},
			{"label": "core_ghost_verified", "speaker": "kai", "text": "三處編號與簽章相符。保管鏈已核對，可以封存資金流向。幽靈留在傳輸端，撤離門要我自己確認。", "set_flag": "hq_core_verified", "set_decision": {"hq_core_method": "ghost"}, "next": "end"},
			{"label": "core_corporate", "speaker": "narrator", "text": "具名調閱已登記。螢幕先顯示對外摘要；旁邊的稽核欄列出簽署原件與保管編號。這次調閱會留在行動紀錄。", "set_flag": "hq_named_lookup_used", "choices": [
				{"text": "核對稽核欄的原件簽章與授權令。", "next": "core_corporate_verified"},
				{"text": "摘要蓋了公司章，直接當原件。", "next": "core_summary_wrong"},
				{"text": "退出調閱；保留已發生的紀錄。", "next": "end"}
			], "next": "end"},
			{"label": "core_summary_wrong", "speaker": "kai", "text": "公司章只能指出誰做了摘要，不能代替原件。我還沒封存；可以重查稽核欄，或改走紙本保管鏈。", "next": "end"},
			{"label": "core_corporate_verified", "speaker": "kai", "text": "原件簽章、保管編號與授權令對上了。我連同具名調閱回執一起保存，不能日後只留下對我有利的部分。", "set_flag": "hq_core_verified", "set_decision": {"hq_core_method": "corporate"}, "next": "end"},
			{"label": "core_offline", "speaker": "narrator", "text": "紙本簿記著：K-6 的付款原件放在 C 架，封條 031。A 架只有展示摘要。C 架封條和接收簿都有同一位保管者的簽章。", "choices": [
				{"text": "用 K-6、C 架、031 逐項比對授權令。", "next": "core_offline_verified"},
				{"text": "A 架離門最近，先認定它是原件。", "next": "core_offline_wrong"},
				{"text": "保留現況，稍後重查。", "next": "end"}
			], "next": "end"},
			{"label": "core_offline_wrong", "speaker": "kai", "text": "位置方便不代表來源正確。A 架只放摘要，保管編號也不同。我沒有取走任何東西，可以重新比對。", "next": "end"},
			{"label": "core_offline_verified", "speaker": "kai", "text": "授權令、紙本接收簿和 C 架原件的簽章相符。我記下核對方式與原件位置，接下來可以封存。", "set_flag": "hq_core_verified", "set_decision": {"hq_core_method": "offline"}, "next": "end"}
		],
		"ch3_prepare_exit": [
			{"speaker": "kai", "text": "先確認一條通往屋頂避難間的離線出口。準備出口不會移動浩然；找到他、核對隔離報告後，才能真正救援。", "choices": [
				{"text": "請幽靈回報保留的撤離門。", "next": "exit_ghost", "requires_decisions": {"hq_entry_route": "ghost", "hq_ghost_support": "rescue"}},
				{"text": "使用企業資格開門，留下具名紀錄。", "next": "exit_corporate", "requires_decisions": {"hq_entry_route": "corporate"}, "requires_missing_flags": ["hq_corporate_access_disabled"]},
				{"text": "自行核對維修表與離線門。", "next": "exit_offline"},
				{"text": "停用企業資格，自己核對出口。", "next": "exit_offline", "requires_decisions": {"hq_entry_route": "corporate"}, "requires_missing_flags": ["hq_corporate_access_disabled"], "set_flag": "hq_corporate_access_disabled"},
				{"text": "先不準備。", "next": "end"}
			], "next": "end"},
			{"label": "exit_ghost", "speaker": "ghost", "text": "三號門回送離線狀態，門後的避難間沒有連接寫入設備。我會守住這頭；你仍要自己按隔離程序帶他過來。", "set_flag": "hq_exit_ready", "set_decision": {"hq_exit_method": "ghost"}, "next": "end"},
			{"label": "exit_corporate", "speaker": "narrator", "text": "企業門控記下身份與開門用途。你先確認門後通往離線避難間，再保存回執；浩然仍在設備旁，這只是出口準備。", "set_flags": ["hq_exit_ready", "hq_named_lookup_used"], "set_decision": {"hq_exit_method": "corporate"}, "next": "end"},
			{"label": "exit_offline", "speaker": "narrator", "text": "維修表寫著：排水停機時，三號門可手動開啟，通往離線避難間。貨梯則連著遠端門控。你比對門牌、隔離燈和實際通道。", "choices": [
				{"text": "確認三號門、停機燈與離線通道一致。", "next": "exit_offline_ready"},
				{"text": "貨梯會動，直接把它當撤離路線。", "next": "exit_wrong"},
				{"text": "暫停，回頭重新確認。", "next": "end"}
			], "next": "end"},
			{"label": "exit_wrong", "speaker": "kai", "text": "貨梯仍受遠端門控，不能把會動當作安全。我還沒移動浩然，先核對離線通道。", "next": "end"},
			{"label": "exit_offline_ready", "speaker": "kai", "text": "門牌、隔離燈和避難間對上了。我記下手動開門位置，試過回程再關好門；不用任何人的身份，也有人能在裡面鎖門。", "set_flag": "hq_exit_ready", "set_decision": {"hq_exit_method": "offline"}, "next": "end"}
		],
		"ch3_disable_corporate": [
			{"speaker": "kai", "text": "停用後，企業具名調閱和開門都不能再用，仍可自行查紙本與離線出口。已取得的材料保留，使用過的身份與調閱紀錄也不會消失。", "choices": [
				{"text": "確認停用，後續自行核對。", "next": "corporate_disabled"},
				{"text": "暫時保留資格。", "next": "end"}
			], "next": "end"},
			{"label": "corporate_disabled", "speaker": "narrator", "text": "你拔下資格憑證，保存停用回執。企業入口的使用歷史仍在，紙本保管簿與離線門仍可調查。", "set_flag": "hq_corporate_access_disabled", "next": "end"}
		],
"ch2_branch_direction": [
    {
      "speaker": "kid",
      "text": "兩邊都是今晚的窗口。最後一份資料交接完，另一邊就停止收件。你可以現在換方向，已經交出去的東西可不會跟著回來。",
      "choices": [
        {
          "text": "改查交割後室：只辦限用引介，不交家庭備份。",
          "next": "switch_market",
          "requires_chapter_route": "clinic"
        },
        {
          "text": "改查轉介站：停用引介，向美玲交代副本去向。",
          "next": "switch_clinic",
          "requires_chapter_route": "black_market"
        },
        {
          "text": "維持現在的方向。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "snake",
      "text": "這張引介只讓你站進交割後室，不是正和的員工證。你要看完整交割表，使用紀錄會留下你的名字。現在仍可以不辦。",
      "label": "switch_market",
      "choices": [
        {
          "text": "確認改查市場。",
          "next": "switched_market",
          "set_decision": {
            "chapter_2_route": "black_market"
          }
        },
        {
          "text": "先不換。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "kid",
      "text": "引介已安排。之前的退件筆記還在，但接下來先查交割。走過的路不會退你時間。",
      "label": "switched_market",
      "next": "end"
    },
    {
      "speaker": "mei_ling",
      "text": "你給過誰的副本，就把名字寫給我。不要用現在願意幫忙，當作前面的事沒發生。我會聽陳醫師說接收站怎麼查。",
      "label": "switch_clinic",
      "requires_decisions": {
        "accepted_snake_deal": true
      }
    },
    {
      "speaker": "kid",
      "text": "停用後室引介，改聯絡接收站？只停這張當晚引介，原有的晶片交易紀錄還在。",
      "choices": [
        {
          "text": "確認停用引介，改查轉介站。",
          "next": "switched_clinic",
          "set_decision": {
            "chapter_2_route": "clinic"
          },
          "set_flag": "auction_invitation_revoked"
        },
        {
          "text": "保留原方向。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "dr_chen",
      "text": "到網咖旁那個離線等候站。我在電話這頭，先看接收簿，不要把每張退件都算成一個人。",
      "label": "switched_clinic",
      "next": "end"
    }
  ],
  "ch2_referral_enter": [
    {
      "speaker": "narrator",
      "text": "叫號機亮著，空椅上卻只有一件摺好的雨衣。玻璃後的接收簿攤在同一頁，紙角被風吹得一下一下響。"
    },
    {
      "speaker": "dr_chen",
      "text": "我不能離開診所，但電話會留著。左邊叫號紙寫「轉介」，右邊簽收欄卻是空白。先比對案件代碼。"
    },
    {
      "speaker": "kai",
      "text": "有人的一整晚，被夾在這兩個欄位中間。",
      "next": "end"
    }
  ],
  "ch2_referral_number": [
    {
      "speaker": "kai",
      "text": "透過壓痕，R-17 的退件日期露出來了：同一份申請重印兩次。旁邊 R-71 的接收簽名屬於另一個案件。",
      "show_item": "referral_routing_stub"
    },
    {
      "speaker": "dr_chen",
      "text": "你要把哪兩段放在一起？",
      "choices": [
        {
          "text": "同一個 R-17 的轉介與空白簽收。",
          "next": "referral_correct",
          "set_flag": "referral_number_checked"
        },
        {
          "text": "把 R-71 的簽名當成 R-17 已接收。",
          "next": "referral_wrong"
        },
        {
          "text": "先保存，稍後判讀。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "dr_chen",
      "text": "那是另一個人的回條。字只差一個位置，也不能把他的床位借來填這個空白。",
      "label": "referral_wrong",
      "next": "end"
    },
    {
      "speaker": "kai",
      "text": "我留下同一案件的兩個時間。簽收空白，還不能說是沒人來；接收方可能被換過。市政檔案室能查原本的轉介。",
      "label": "referral_correct",
      "next": "end"
    }
  ],
  "ch2_referral_reassigned": [
    {
      "speaker": "kid",
      "text": "R-17 回執原本指向獨立接收站，這張附頁卻改成正和的治療佇列。撤回被當成新的轉介，沒有等到當事人再回答。",
      "show_item": "referral_routing_stub"
    },
    {
      "speaker": "kai",
      "text": "能從這裡確認什麼？",
      "choices": [
        {
          "text": "同一案件改派接收方，還要核對實驗室有沒有收到。",
          "next": "referral_reroute_correct",
          "set_flag": "referral_reroute_checked"
        },
        {
          "text": "R-17 就是浩然，直接把名字補上。",
          "next": "referral_reroute_wrong"
        },
        {
          "text": "保留觀察，晚點再核對。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "kid",
      "text": "沒有名字就別幫它長出名字。浩然要用日記和倉庫清單另查。",
      "label": "referral_reroute_wrong",
      "next": "end"
    },
    {
      "speaker": "dr_chen",
      "text": "我把改派回條留一份。找到浩然的接收代碼後，回等候站打電話；我要有人親口說會接他，不只讓一台機器蓋章。",
      "label": "referral_reroute_correct",
      "next": "end"
    }
  ],
  "ch2_referral_priority": [
    {
      "speaker": "kai",
      "text": "浩然日記的維修委託，對上倉庫清單裡另一個接收代碼。不是 R-17。現在可以替他查接收，也能先把整批改派資料交出去。"
    },
    {
      "speaker": "dr_chen",
      "text": "窗口這次只肯先接一件。我還能繼續追另一件，只是要等下一次回覆。選完交接，今晚另一邊的交割就趕不上了。",
      "choices": [
        {
          "text": "先替浩然確認接收，整批紀錄離線保留。",
          "next": "medical_patient",
          "set_flag": "ch2_branch_complete",
          "set_decision": {
            "ch2_medical_priority": "patient"
          }
        },
        {
          "text": "先封存整批改派紀錄，浩然先由離線照護承接。",
          "next": "medical_batch",
          "set_flag": "ch2_branch_complete",
          "set_decision": {
            "ch2_medical_priority": "batch"
          }
        },
        {
          "text": "先不交接，回去整理。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "dr_chen",
      "text": "這次有名字、有回電時間了。我記下接收人，但床位不等於人已經救出。你去找浩然，我守著這通電話。",
      "label": "medical_patient",
      "next": "end"
    },
    {
      "speaker": "dr_chen",
      "text": "整批回條進離線保管。浩然先用原本的照護安排，接收窗口我會繼續問。這不是誰比較值得救，是今晚誰先得到回覆。",
      "label": "medical_batch",
      "next": "end"
    }
  ],
  "ch2_auction_enter": [
    {
      "speaker": "narrator",
      "text": "前台的音樂隔著厚門，只剩低低的震動。交割櫃上沒有人的名字，只有批號和磨過又貼新的封條。"
    },
    {
      "speaker": "mask_merchant",
      "text": "看封條可以，別打開匣子。你要的是來路，還是裡面的生活？兩種價格不一樣。"
    },
    {
      "speaker": "kai",
      "text": "我先看誰把價格貼上去。",
      "next": "end"
    }
  ],
  "ch2_auction_batch": [
    {
      "speaker": "kai",
      "text": "新標籤寫著新貨，銅扣下面卻留下同一批舊維修壓痕。交割時刻晚於重貼封條，沒有一處寫著誰的名字。",
      "show_item": "auction_dispatch_seal"
    },
    {
      "speaker": "kai",
      "text": "哪一個說法有足夠依據？",
      "choices": [
        {
          "text": "同批設備重貼標籤；人的身份還要另查。",
          "next": "auction_batch_correct",
          "set_flag": "auction_batch_checked"
        },
        {
          "text": "標成新貨，所以來源一定不同。",
          "next": "auction_batch_wrong"
        },
        {
          "text": "先保存封條掃描。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "mask_merchant",
      "text": "標籤能換，銅扣沒換。你要相信廣告，也得先學會看價格。",
      "label": "auction_batch_wrong",
      "next": "end"
    },
    {
      "speaker": "kai",
      "text": "我把新舊批號並排記下，不打開任何人的記憶。倉庫底座能核對維修批次。",
      "label": "auction_batch_correct",
      "next": "end"
    }
  ],
  "ch2_auction_access": [
    {
      "speaker": "snake",
      "text": "完整交割表在裡面。用引介查，留下你的使用紀錄；留在這裡，只能看公開封條與交接時刻。都不需要交出家庭備份。"
    },
    {
      "speaker": "kai",
      "text": "我怎麼查這份表？",
      "choices": [
        {
          "text": "具名使用引介，核對完整交割欄位。",
          "next": "auction_named",
          "set_flag": "auction_access_resolved",
          "set_decision": {
            "ch2_market_access": "named"
          }
        },
        {
          "text": "留在公共交接區，用封條補足較少欄位。",
          "next": "auction_public",
          "set_flag": "auction_access_resolved",
          "set_decision": {
            "ch2_market_access": "public"
          }
        },
        {
          "text": "先不選。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "narrator",
      "text": "你的名字印在調閱回條上。交割表多出簽收欄，這張引介沒有變成正和通行證。",
      "label": "auction_named",
      "set_flag": "auction_invitation_used",
      "next": "end"
    },
    {
      "speaker": "kai",
      "text": "我留下公開批號、交接時刻與空白欄。倉庫和幽靈給的紀錄能補哪些，就只補哪些；不用想像填滿整張表。",
      "label": "auction_public",
      "next": "end"
    }
  ],
  "ch2_auction_priority": [
    {
      "speaker": "narrator",
      "text": "下一批機箱開始封櫃。倉庫日記、受害者清單與這裡的批號對上了，面具商人把即將收回的帳頁壓在手下。",
      "show_item": "auction_dispatch_seal"
    },
    {
      "speaker": "mask_merchant",
      "text": "帳頁要回櫃，貨要離門。你現在留下哪一邊？另一邊只來得及記一部分。",
      "choices": [
        {
          "text": "先保住批次帳目，放棄完整跟運輸的機會。",
          "next": "market_ledger",
          "set_flag": "ch2_branch_complete",
          "set_decision": {
            "ch2_market_priority": "ledger"
          }
        },
        {
          "text": "先核對當晚設備去向，保留局部帳目。",
          "next": "market_dispatch",
          "set_flag": "ch2_branch_complete",
          "set_decision": {
            "ch2_market_priority": "dispatch"
          }
        },
        {
          "text": "暫停交接，先想清楚。",
          "next": "end"
        }
      ],
      "next": "end"
    },
    {
      "speaker": "kai",
      "text": "帳頁的來源與交接簽收一起封好。門外引擎已經遠了，我只記到下一個派送站。今晚轉介窗口已停止收件；之後用這條文件線繼續查。",
      "label": "market_ledger",
      "next": "end"
    },
    {
      "speaker": "kai",
      "text": "我在門內核對車次與接收站，沒有追出去。帳頁只保住能驗證的幾欄；設備去向另存。今晚轉介窗口已停止收件，原本的離線照護仍會接手。",
      "label": "market_dispatch",
      "next": "end"
    }
  ],
		"ch3_recovery_quiet": [
			{"speaker": "narrator", "text": "你把調查紀錄反扣在桌上。隔壁的浩然看著紙杯，指尖停在杯緣旁，像在等某個熟悉的動作回來。"},
			{"speaker": "hao_ran", "text": "他們一直問我想起多少。你能不能先問……我現在想做什麼？", "choices": [{"text": "我可以坐一會兒，不問案子的事。", "next": "quiet_stay", "set_flag": "recovery_quiet_resolved", "set_decision": {"recovery_company": "stay"}}, {"text": "你想自己試試，我就在門外。", "next": "quiet_space", "set_flag": "recovery_quiet_resolved", "set_decision": {"recovery_company": "space"}}, {"text": "先讓醫師完成檢查，晚點再來。", "next": "end"}], "next": "end"},
			{"label": "quiet_stay", "speaker": "hao_ran", "text": "那你坐吧。我不想講話，但現在也不想一個人聽那盞燈。"},
			{"speaker": "narrator", "text": "你陪他等杯壁上的水珠滑到底。沒有得到新證詞；幾分鐘之後，他自己把杯子拿了起來。", "next": "end"},
			{"label": "quiet_space", "speaker": "hao_ran", "text": "好。門別全關，我看得見你就行。這次我想自己拿水。"},
			{"speaker": "narrator", "text": "你退到門邊，讓醫師留在能看見他的地方。紙杯在桌上輕輕移動了一下，你沒有搶先伸手。", "next": "end"},
		],
		"ch2_archive_returned_index": [
			{"speaker": "narrator", "text": "退件推車外貼著不含姓名的公開索引。三張紙寫著同一個代碼 R-17，退回理由卻依次是「資料不齊」「轉介中」「請重新申請」。"},
			{"speaker": "kid", "text": "老頭，你打算怎麼記這三張？", "choices": [{"text": "同一案件的三次退回，分開記日期。", "next": "index_checked", "set_flag": "archive_index_checked"}, {"text": "先記成三名失蹤者，再累加總數。", "next": "index_wrong"}, {"text": "先不下結論。", "next": "end"}], "next": "end"},
			{"label": "index_wrong", "speaker": "kid", "text": "等等，代碼一樣。你把窗口踢回來的次數算成人數了。這能證明人被流程困住，不能憑空多出兩個受害者。再看一次也來得及。", "next": "end"},
			{"label": "index_checked", "speaker": "kai", "text": "同一個人，被要求從頭開始三次。我留下三個日期，沒有把他算成三個人。公開時，這條退件經過也得有人回答。", "next": "end"},
		],
		"ch1_scan_grid": [
			{"speaker": "kai", "text": "配電箱裡有兩枚時鐘：路燈用市電，監控用備援電池。鷹眼把停電時間與錄影缺口疊在一起——兩者沒有完全重合。"},
			{"speaker": "kai", "text": "停電只能解釋一段黑畫面。剩下的差距，得去查接收端的原始回執。", "choices": [{"text": "分開記錄停電與監控缺口。", "next": "grid_infrastructure", "set_flag": "grid_review_resolved", "set_decision": {"grid_interpretation": "infrastructure"}}, {"text": "先把剩下的缺口列為人為嫌疑。", "next": "grid_sabotage", "set_flag": "grid_review_resolved", "set_decision": {"grid_interpretation": "sabotage"}}, {"text": "保存掃描，稍後判讀。", "next": "end"}], "next": "end"},
			{"label": "grid_infrastructure", "speaker": "kai", "text": "我在時間線上畫了兩條線。網咖附近的市政離線檔案室，還留著不依賴監控系統的紙本回執；下一段調查去那裡核對。", "next": "end"},
			{"label": "grid_sabotage", "speaker": "kai", "text": "我先寫上「疑似人為」，沒有填人名。這是要驗證的假設，不是證明；市政檔案室的回執可能支持它，也可能推翻它。", "next": "end"}
		],
		"ch2_scan_warehouse_batch": [
			{"speaker": "narrator", "text": "鷹眼掃過設備底座，磨損下露出相同的維修批號。浩然的那張椅子不是孤例。抽屜裡還有兩份資料：病床接收代碼與設備運送封條。"},
			{"speaker": "kai", "text": "帶走哪份資料先核對？都不含私人記憶，但能幫上的事情不同。", "choices": [{"text": "先整理接收代碼，替其他人找照護去處。", "next": "batch_patients", "set_flag": "warehouse_batch_resolved", "set_decision": {"warehouse_priority": "patients"}}, {"text": "先核對運送封條，保住設備的追查線。", "next": "batch_provenance", "set_flag": "warehouse_batch_resolved", "set_decision": {"warehouse_priority": "provenance"}}, {"text": "先保存底座掃描。", "next": "end"}], "next": "end"},
			{"label": "batch_patients", "speaker": "kai", "text": "我把接收代碼交給陳醫師核查空床，不交出受害者姓名。救出浩然後，復健轉運間能收到分開的接收回覆。", "next": "end"},
			{"label": "batch_provenance", "speaker": "kai", "text": "我封存運送批號與拍攝位置。照護仍按正常程序申請；轉運間那台設備可以幫我確認同一批機器是否仍被當成普通復健器材搬走。", "next": "end"}
		],
		"ch2_civic_archive_enter": [
			{"speaker": "narrator", "text": "雨水在檔案室窗外流成細線。報案窗口搬走了，沒人搬走這些紙：受理、轉介、撤回，每一次按鍵都印過一張。"},
			{"speaker": "kid", "text": "老頭，這回不用撬鎖。我從網咖連上公共閱覽機，只有時間、案件代碼與接收單位。姓名還在封櫃裡，別亂開。"},
			{"speaker": "kai", "text": "這裡的時鐘也延遲過。配電箱那段監控缺口，不能只靠差幾分鐘就指認有人刪片。", "requires_decisions": {"grid_interpretation": "sabotage"}, "set_flag": "grid_hypothesis_corrected"},
			{"speaker": "kai", "text": "路燈時間與錄影時間分開記，現在才看得出紙本回執是第三個來源。", "requires_decisions": {"grid_interpretation": "infrastructure"}},
			{"speaker": "narrator", "text": "閱覽機吐出半截紙。開啟鷹眼可找到回執的壓印層，也能從調查清單開始核對。", "next": "end"}
		],
		"ch2_scan_withdrawal_queue": [
			{"speaker": "kai", "text": "壓印層不是被塗掉的人名，而是另一個時間：代碼 R-17 的撤回申請在晚間九點十四分受理，系統卻在九點二十一分把它重新送到正和的治療佇列。"},
			{"speaker": "kid", "text": "受理不代表實驗室看過。要追責，還缺對方終端的接收與覆核紀錄。這張回執先證明「請求沒有停在窗口」。"},
			{"speaker": "kid", "text": "檔案室允許暫停這條轉介規則，或用不對應任何病人的測試代碼觀察下一站。你要哪一種？", "choices": [{"text": "申請暫停錯誤轉介，先擋住下一張。", "next": "archive_frozen", "set_flag": "archive_route_resolved", "set_decision": {"archive_route": "frozen"}}, {"text": "先用空白測試代碼追蹤接收站。", "next": "archive_observed", "set_flag": "archive_route_resolved", "set_decision": {"archive_route": "observed"}}, {"text": "保存回執，暫不改動轉介。", "next": "end"}], "next": "end"},
			{"label": "archive_frozen", "speaker": "kid", "text": "轉介窗口已回覆暫停，後續申請改成人工受理。這只處理市政端，不會遠端停掉病人的維持設備。實驗室是否無視撤回，仍要找本地紀錄。", "next": "end"},
			{"label": "archive_observed", "speaker": "kid", "text": "測試碼抵達實驗室覆核站；沒有放進真人姓名或病歷。窗口收到異常回報後也改成人工受理。你多拿到一個接收站編號，可用來追問蕭博士。", "next": "end"}
		],
		"ch2_scan_dispatch_clock": [
			{"speaker": "narrator", "text": "後門刷卡機保留著清潔班次與設備出貨的列印計數。鷹眼對齊機械滾輪的壓痕：備忘錄標示的停用日後，仍有同批設備離開大樓。"},
			{"speaker": "kai", "text": "「停用」與「停止出貨」是兩回事。這份紀錄能追問企業後續，不能單獨證明某人囚禁浩然。", "choices": [{"text": "封存完整機台序號，交給獨立核驗。", "next": "dispatch_sealed", "set_flag": "dispatch_record_resolved", "set_decision": {"dispatch_record": "sealed"}}, {"text": "先提供去識別時間摘要，提醒接收單位。", "next": "dispatch_redacted", "set_flag": "dispatch_record_resolved", "set_decision": {"dispatch_record": "redacted"}}, {"text": "保存滾輪掃描，稍後決定。", "next": "end"}], "next": "end"},
			{"label": "dispatch_sealed", "speaker": "kai", "text": "原件封存，對外只說有待核對的設備批次。趙明之後能以完整序號查出簽收者，公開前還得保護無關員工。", "next": "end"},
			{"label": "dispatch_redacted", "speaker": "kai", "text": "摘要提醒接收單位暫停使用疑似批次，不含員工姓名。完整序號仍封在我的底檔，沒有把去識別摘要冒充足以定罪的原件。", "next": "end"}
		],
		"ch3_scan_override_console": [
			{"speaker": "kai", "text": "外面寫著等待通知，裡面卻簽了繼續。R-17 的撤回，比這個簽章還早。"},
			{"speaker": "dr_xiao", "text": "撤回送去覆核了。你只盯著時間，當時病人是什麼情況，你問過嗎？維持程序不能說切就切。"},
			{"speaker": "kai", "text": "這欄是寫入排程。維持器有自己的控制。你動的是哪一邊？"},
			{"speaker": "narrator", "text": "蕭博士把視線移回螢幕，沒有回答。你保存接收時間與本地簽章；要追問撤回的來處，還能拿市政回執比對。", "next": "end"}
		],
		"ch3_xiao_record_challenge": [
			{"speaker": "dr_xiao", "text": "資料都拿來了？放這裡。你想問哪一筆？", "choices": [{"text": "資金來自正和，所以是你按下繼續。", "next": "challenge_funding", "requires_evidence": "zhengtek_funding"}, {"text": "回執、接收碼、本地簽章一致；為何繼續寫入？", "next": "challenge_admitted", "requires_flag": "eye_withdrawal_scanned"}, {"text": "目前只能確認本地簽章，保留未核對的部分。", "next": "challenge_disputed", "set_flag": "xiao_record_challenge_resolved", "set_decision": {"xiao_accountability": "disputed"}}, {"text": "先回去比對資料。", "next": "end"}], "next": "end"},
			{"label": "challenge_funding", "speaker": "dr_xiao", "text": "正和付的錢，我沒否認。可你拿著付款單，就知道那天誰坐在終端前？撤回是哪一張，什麼時候送到的？", "next": "end"},
			{"label": "challenge_admitted", "speaker": "dr_xiao", "mood": "calm", "text": "R-17。我記得，送去覆核了。那個時候停下來，病人後面的反應誰負責？"},
			{"speaker": "kai", "text": "回執在這裡。你收到以後，寫入還在繼續。", "choices": [
				{"text": "維持器能單獨運行。為什麼連寫入也留下？", "next": "challenge_controls"},
				{"text": "你簽了「待覆核」。簽之前，看過撤回嗎？", "next": "challenge_receipt"},
				{"text": "先停在這裡，回去核對（尚未取得供述）。", "next": "end"}
			], "next": "end"},
			{"label": "challenge_controls", "speaker": "dr_xiao", "mood": "conflicted", "text": "能單獨運行。那套控制是我簽的，我當然知道。", "next": "challenge_admission"},
			{"label": "challenge_receipt", "speaker": "dr_xiao", "mood": "conflicted", "text": "看過。「待覆核」也是我填的。我想再留一點時間。", "next": "challenge_admission"},
			{"label": "challenge_admission", "speaker": "narrator", "text": "蕭博士的手停在桌沿。他張了張口，沒有立刻出聲。"},
			{"speaker": "dr_xiao", "mood": "cracking", "text": "一停，正和就會把病例和設備帶走。我怕他們把整個原型收回去。撤回我看過了，寫入……是我讓它繼續的。", "set_flag": "xiao_record_challenge_resolved", "set_decision": {"xiao_accountability": "admitted"}},
			{"speaker": "kai", "text": "這段我會留著，連同你的簽章。正和要拿走什麼，我也會查。", "requires_decisions": {"xiao_accountability": "admitted"}},
			{"speaker": "kai", "text": "市政那邊已經暫停轉介。後面的人先擋下來了，前面這些，還得一筆一筆查。", "requires_decisions": {"xiao_accountability": "admitted", "archive_route": "frozen"}},
			{"speaker": "kai", "text": "我們送的測試碼也到了同一站。回執、接收碼，還有你剛才這段話，我一起留下。", "requires_decisions": {"xiao_accountability": "admitted", "archive_route": "observed"}, "next": "end"},
			{"speaker": "narrator", "text": "供述是補充資料；正式公開仍要核驗三份核心原件。", "requires_decisions": {"xiao_accountability": "admitted"}, "next": "end"},
			{"label": "challenge_disputed", "speaker": "kai", "text": "本地簽章我留著。送達那一段還沒對完，就先留空，這次問話記為有爭議。", "next": "end"}
		],
		"ch3_recovery_annex_enter": [
{"speaker": "dr_chen", "text": "等候站那通電話有回覆，浩然的接收人願意留下姓名。整批改派的核對還在等下一個窗口。", "requires_decisions": {"ch2_medical_priority": "patient"}},{"speaker": "dr_chen", "text": "整批改派回條有人接下了。浩然仍由原本的離線照護先承接，個別窗口我會繼續問。", "requires_decisions": {"ch2_medical_priority": "batch"}},
			{"speaker": "narrator", "text": "轉運間的門比實驗室薄，裡面沒有寫入椅的嗡鳴。浩然已在隔壁接受觀察；這間空房暫時用來準備他的下一段路。"},
			{"speaker": "dr_chen", "text": "倉庫那份接收代碼有回覆了。另兩名受害者的床位已開始個別確認，還不能說他們都獲救。浩然的轉運照常優先處理。", "requires_decisions": {"warehouse_priority": "patients"}},
			{"speaker": "kai", "text": "轉運機的底座與倉庫同一批。運送封條已補拍封存；先把設備交給獨立人員檢查，不把外觀像病床當成安全證明。", "requires_decisions": {"warehouse_priority": "provenance"}},
			{"speaker": "narrator", "text": "牆上的終端雖然拔了線，仍亮著待送燈。鷹眼能看清資料會送到誰手上。", "next": "end"}
		],
		"ch3_scan_recovery_route": [
			{"speaker": "kai", "text": "終端待送的是回診時間、接收醫師與病人代碼，沒有私人記憶；預設收件者卻包含企業的設備承包商。"},
			{"speaker": "hao_ran", "text": "今天不要再替我一次勾完。陳醫師可以知道怎麼接手，承包商不需要知道我在哪裡。"},
			{"speaker": "dr_chen", "text": "可以改成紙本雙人交接。慢一些，但全程離線。也可以刪掉承包商地址，只傳給指定醫師。送出前，再讓浩然確認。", "choices": [{"text": "紙本雙人交接；接受多等一班轉運。", "next": "recovery_paper", "set_flag": "recovery_route_resolved", "set_decision": {"recovery_channel": "paper"}}, {"text": "只送指定醫師，由浩然逐項確認。", "next": "recovery_direct", "set_flag": "recovery_route_resolved", "set_decision": {"recovery_channel": "direct"}}, {"text": "先保留離線狀態，稍後決定。", "next": "end"}], "next": "end"},
			{"label": "recovery_paper", "speaker": "hao_ran", "text": "那就等下一班。交接表由兩個人簽，我也留一張。這裡有人照看我，你可以繼續查案；別為了趕時間再替我接回去。", "next": "end"},
			{"label": "recovery_direct", "speaker": "hao_ran", "text": "我看過接收醫師與三個欄位，同意只送這一份。傳送完成就移除這次聯絡路由。下一次回診，再問一次。", "next": "end"}
		],
		"ch3_scan_memory_anchor": [
			{"speaker": "kai", "text": "我記得自己替測試椅做過維護。可是片段上的日期，比我手邊的工單早了一天。"},
			{"speaker": "echo_ai", "text": "那是匯入時間，不是事情發生的時間。鷹眼能對齊標記，不能替你決定哪一段感受是真的。"},
			{"speaker": "kai", "text": "能確認的先寫在紙上，不能確認的留空。恢復之後，我可能不記得為什麼接下這件案子。"},
			{"speaker": "echo_ai", "text": "你可以留一份由他人核對的生活紀錄，也可以只給醒來的自己留封信。這些是外部路標，都不保證保住今天的你。", "choices": [{"text": "找美玲核對近期事件，寫成可更正的紀錄。", "next": "anchor_shared", "set_flag": "memory_anchor_resolved", "set_decision": {"continuity_record": "shared"}}, {"text": "只留密封私信，由醒來的自己決定要不要看。", "next": "anchor_private", "set_flag": "memory_anchor_resolved", "set_decision": {"continuity_record": "private"}}, {"text": "先保存時間標記，暫時不寫。", "next": "end"}], "next": "end"},
			{"label": "anchor_shared", "speaker": "narrator", "text": "你從記憶片段退開，接通避難間的有線通訊。美玲開始說她親自經歷的事。"},
			{"speaker": "mei_ling", "text": "我只能核對我們一起經歷的事：你何時接下委託、何時回撥、浩然何時離開實驗室。你以前是誰，我不替你補。"},
			{"label": "anchor_shared_end", "speaker": "kai", "text": "紀錄分成可確認與待核對兩欄。姓名和接收時間另封，不送進迴響。若我醒來不相信它，也能從每一項的來源重新問起。", "next": "end"},
			{"label": "anchor_private", "speaker": "kai", "text": "信封寫著今天的日期。我只寫自己現在知道的事，沒有替醒來的人下命令。罪證另行封存；這封信不是案件原件的唯一副本。", "next": "end"}
		],
		"ch1_case_materials_review": [
			{"speaker": "narrator", "text": "你倒出委託袋裡的東西。美玲把失聯日期寫在信上，工作室地址則抄在工作證背面：東區第七街，地下層。", "give_evidence": "commission_letter"},
			{"speaker": "kai", "text": "永恆記憶。地址倒是不難找。", "give_evidence": "work_id", "set_flag": "knows_workshop_location"},
			{"speaker": "narrator", "text": "袋底還夾著一張深淵酒吧的收據。你展平折角，把它和工作證一起收好。", "give_evidence": "abyss_receipt", "next": "end"}
		],
		"ch1_ajie_followup": [
			{"speaker": "narrator", "requires_decisions": {"ajie_statement": "coerced"}, "text": "阿傑把照片推到你面前，卻把寫著名字的紙抽了回去。收銀紀錄還能核對，那個指認他不肯再說一遍。"},
			{"speaker": "ajie", "mood": "suspicious", "requires_decisions": {"ajie_statement": "coerced"}, "text": "照片還在，你拿去。上回那個名字是你逼我說的，別又拿來問我認不認得。"},
			{"speaker": "ajie", "mood": "cooperative", "requires_decisions": {"ajie_statement": "voluntary"}, "text": "帳要再對一遍也行。這張臉就算了吧，面具擋成這樣，我認得出什麼？"},
			{"speaker": "ajie", "requires_missing_flags": ["ajie_told_about_meeting"], "text": "是我們的收據。浩然那晚進了二號包廂，裡頭那位戴著全息面具。喏，照片在這。"},
			{"speaker": "narrator", "text": "照片傳到你的終端上。放大後，面具底下仍看不見五官。阿傑朝後室偏了偏頭，繼續擦他的杯子。", "give_evidence": "stranger_photo", "set_flag": "ajie_told_about_meeting", "next": "end"}
		],
		"ch1_eye_ajie_statement": [
			{"speaker": "narrator", "text": "鷹眼掃過褪色的收據，兩行時間亮了起來。結帳、列印，中間差了七分鐘。交易編號相同，紙上卻沒寫為什麼。", "set_flag": "eye_ajie_receipt_scanned"},
			{"speaker": "kai", "text": "（七分鐘。卡在機器上，還是另有別的事？）", "choices": [
				{"text": "先查七分鐘是否來自終端延遲。", "next": "hypothesis_terminal", "set_decision": {"ajie_hypothesis": "terminal", "ajie_hypothesis_status": "pending"}},
				{"text": "先查阿傑是否把見面時間記錯。", "next": "hypothesis_witness", "set_decision": {"ajie_hypothesis": "witness", "ajie_hypothesis_status": "pending"}},
				{"text": "先查時間差是否與監控清場有關。", "next": "hypothesis_monitor", "set_decision": {"ajie_hypothesis": "monitor", "ajie_hypothesis_status": "pending"}},
				{"text": "先保存掃描，稍後再想。", "next": "end"}
			], "next": "end"},
			{"label": "hypothesis_terminal", "speaker": "kai", "text": "阿傑，這個編號。收銀機裡還查得到嗎？", "next": "end"},
			{"label": "hypothesis_witness", "speaker": "kai", "text": "（也許他記岔了。先看看收銀機怎麼記，再問。）", "next": "end"},
			{"label": "hypothesis_monitor", "speaker": "kai", "text": "（要是有人動過監控，後室應該留得下痕跡。先查清楚收據這七分鐘。）", "next": "end"}
		],
		"ch1_ajie_terminal_check": [
			{"speaker": "ajie", "text": "喏，機器轉過來了。斷線、重送，都在這一欄。紙上哪印得下這些。"},
			{"speaker": "narrator", "text": "你把收據貼在螢幕邊，逐位比對交易編號。同一筆帳：結帳成功，斷線，重送。七分鐘後才印出來。紀錄裡沒有客人的姓名。"},
			{"speaker": "kai", "text": "（錢先結了，紙卻晚了七分鐘。）", "choices": [
				{"text": "確認終端重送；身份仍待查。", "next": "terminal_confirm", "set_flag": "ajie_terminal_verified"},
				{"text": "筆記假設：七分鐘能證明他認得那人。", "next": "terminal_overreach"},
				{"text": "先不下結論，回去重看收據。", "next": "end"}
			], "next": "end"},
			{"label": "terminal_confirm", "speaker": "narrator", "requires_decisions": {"ajie_hypothesis": "terminal"}, "text": "你在「終端延遲」旁打了勾，把收據和原始紀錄放在一起。那七分鐘就在這幾行重送紀錄裡。", "set_decision": {"ajie_hypothesis_status": "supported"}},
			{"speaker": "narrator", "requires_decisions": {"ajie_hypothesis": "none"}, "text": "你記下重送的起迄時間，把原始紀錄和收據放在一起。來客姓名那一欄，仍舊空著。", "set_decision": {"ajie_hypothesis_status": "supported"}},
			{"speaker": "kai", "requires_decisions": {"ajie_hypothesis": "witness"}, "text": "（先怪到他頭上了。這七分鐘，機器已經交代清楚。至於那晚他看見什麼，還得問。）", "set_decision": {"ajie_hypothesis_status": "revised"}},
			{"speaker": "kai", "requires_decisions": {"ajie_hypothesis": "monitor"}, "text": "（是重送。我把兩件事扯在一起了。監控得另查後室的紀錄。）", "set_decision": {"ajie_hypothesis_status": "revised"}},
			{"speaker": "narrator", "text": "你收好筆記。阿傑還站在吧台後，等著看你會不會再問。核對結果已存入證據板。", "next": "end"},
			{"label": "terminal_overreach", "speaker": "kai", "text": "（等等。哪一行寫了他認得那個人？只有編號和時間。我想得太快了。）", "next": "end"}
		],
		"ch1_ajie_statement_check": [
			{"speaker": "kai", "text": "帳對上了。阿傑，還有件事想問你。", "requires_flag": "ajie_terminal_verified"},
			{"speaker": "ajie", "mood": "nervous", "text": "能不能把那隻眼睛關了？你拿它照著我，還嫌我心跳快。問吧。", "requires_flag": "ajie_terminal_verified", "requires_missing_flags": ["ajie_statement_resolved"], "choices": [
				{"text": "讓他核對時間，不逼他認人。", "next": "statement_voluntary", "set_flag": "ajie_statement_resolved", "set_decision": {"ajie_statement": "voluntary"}, "affinity": {"ajie": 2}},
				{"text": "逼他指認（不可靠，留下施壓紀錄；本章可更正）。", "next": "statement_coerced", "set_flag": "ajie_statement_resolved", "set_decision": {"ajie_statement": "coerced", "interrogation_pressure_ajie": 80}, "affinity": {"ajie": -2}},
				{"text": "只留時間差，不使用他的證詞。", "next": "statement_withheld", "set_flag": "ajie_statement_resolved", "set_decision": {"ajie_statement": "withheld"}},
				{"text": "先保存掃描，稍後再問。", "next": "end"}
			], "next": "end"},
			{"label": "statement_voluntary", "speaker": "ajie", "mood": "cooperative", "text": "斷線重送，七分鐘。這個我能作證。要拿出去，你怎麼問的也一起放，別到時候變成我認出了誰。", "next": "end"},
			{"label": "statement_coerced", "speaker": "ajie", "mood": "angry", "text": "行，名字照你的意思報了。滿意了？我連他的臉都沒見著。你要拿這段出去，剛才怎麼逼我的，也給我放進去。", "next": "end"},
			{"label": "statement_withheld", "speaker": "kai", "text": "今天就到這。我留一份機器紀錄，不把你列成證人。", "next": "end"}
		],
		"ch1_ajie_retraction": [
			{"speaker": "ajie", "mood": "suspicious", "text": "現在肯把那個名字撤掉了？好。可你怎麼逼我說的，得留著。還有，別指望我再替你作證。", "choices": [
				{"text": "撤回指認，保留施壓經過。", "next": "statement_retracted", "set_flag": "ajie_statement_retracted", "affinity": {"ajie": 1}},
				{"text": "先不更正。", "next": "end"}
			], "next": "end"},
			{"label": "statement_retracted", "speaker": "kai", "text": "好。我在原紀錄後面加上更正，那個名字不再用了。逼你開口的事，我會交代。", "next": "end"}
		],
		"ch2_eye_market_claim": [
			{"speaker": "kai", "text": "簽章對上了。報價權在面具商人手裡，你替他談。酒吧那枚晶片，又算另一筆。", "set_flag": "eye_market_claim_scanned"},
			{"speaker": "snake", "mood": "serious", "requires_decisions": {"memory_trade_method": "buy"}, "text": "你買過他的樣本，下次拿到線索，就得先讓他出價。不放心？把不能碰的寫進附頁。或者給他一份受害者的聯絡路由，這筆帳就結了。"},
			{"speaker": "snake", "mood": "default", "requires_decisions": {"memory_trade_method": "intrude"}, "text": "你闖進去拿的，沒簽買賣。裝置碼他們留著，帳不能因此算到你頭上。今天這張，你可以不接。"},
			{"speaker": "snake", "mood": "default", "requires_decisions": {"memory_trade_method": "refuse"}, "text": "上回沒買，當然不欠。今天另談：下份非人身線索先讓市場報價。或者，你給一份聯絡路由，我替你排企業承包的照護預約，往前排。"},
			{"speaker": "snake", "mood": "serious", "text": "附頁談好，我給回執。路由交出去，市場就找得到那些人，這個你想清楚。不簽也行，舊帳有多少，還是多少。", "choices": [
				{"text": "只給非人身線索的優先報價權。", "next": "claim_bounded", "set_flag": "market_claim_resolved", "set_decision": {"market_claim_resolution": "bounded"}},
				{"text": "交出路由，換結清或照護預約。", "next": "claim_pledge", "requires_evidence": "victim_list", "set_flags": ["market_claim_resolved", "market_claim_pledged"], "set_decision": {"market_claim_resolution": "pledge"}, "affinity": {"snake": 2, "hao_ran": -2}},
				{"text": "拒絕；舊債若存在就繼續保留。", "next": "claim_refuse", "set_flag": "market_claim_resolved", "set_decision": {"market_claim_resolution": "refuse"}},
				{"text": "保存簽署核對，暫不答覆。", "next": "end"}
			], "next": "end"},
			{"label": "claim_bounded", "speaker": "snake", "mood": "serious", "text": "姓名、住處、私人記憶，都劃掉。剩下的先報價，你還能不賣。買樣本欠的那筆若還在，就照這個範圍算。回執收好，往後有人拿照護跟你談沉默，你就拿它去談獨立接手。", "next": "end"},
			{"label": "claim_pledge", "speaker": "narrator", "text": "你傳出聯絡路由。買過樣本的報價權就此結清；沒有這筆舊債的人，換到企業承包照護的優先預約。受害者多了一個知道如何找到他們的人，這次外流會進入公開行動紀錄。", "next": "end"},
			{"label": "claim_refuse", "speaker": "snake", "mood": "default", "text": "好，這張作廢。樣本的舊帳照舊，沒買過就別管它。獨立照護的回執，我也就不給你了。", "next": "end"}
		],
		"ch2_eye_unsent_backup": [
			{"speaker": "kid", "mood": "serious", "text": "用浩然日記的時間，對照你帶來的原始備份提示。我從網咖開啟那份離線映像，原始檔仍保留在你帶來的封存資料裡。"},
			{"speaker": "kai", "text": "鷹眼拆開了未寄出的封包標頭：家用修復片段、實驗摘要、追蹤路由分成三份。這能辨認用途，不能代替浩然同意我們讀內容。", "set_flag": "eye_backup_scanned"},
			{"speaker": "kid", "mood": "serious", "text": "實驗室的隔離程序要另外查。這份私人的聲音也許能幫上以後，但現在該先想好怎麼保管。", "choices": [
				{"text": "密封保存，救出浩然後讓他決定。", "next": "backup_sealed", "set_flag": "backup_handling_resolved", "set_decision": {"backup_handling": "sealed"}},
				{"text": "先複製私人內容，之後再告知。", "next": "backup_copied", "set_flag": "backup_handling_resolved", "set_decision": {"backup_handling": "copied"}, "affinity": {"hao_ran": -2}},
				{"text": "刪除本地快取，只留案件摘要。", "next": "backup_discarded", "set_flag": "backup_handling_resolved", "set_decision": {"backup_handling": "discarded"}},
				{"text": "先保存標頭核對，暫不處置。", "next": "end"}
			], "next": "end"},
			{"label": "backup_sealed", "speaker": "kid", "mood": "default", "text": "校驗值和封存時間記好了。救出他後，你可以在實驗室的離線通訊端詢問本人，不能在這裡替他簽名。", "next": "end"},
			{"label": "backup_copied", "speaker": "narrator", "text": "複製紀錄留下你的裝置簽章。裡面有浩然尚未寄給姐姐的聲音，你停止播放。之後可以交還並刪除副本，但不能把這次未經同意的複製抹掉。", "next": "end"},
			{"label": "backup_discarded", "speaker": "kid", "mood": "serious", "text": "本地私人快取刪除了，案件摘要仍在。你保住隱私，也放棄了這份可供後續修復的片段；救援照既有程序進行。", "next": "end"}
		],
		"ch3_backup_permission": [
			{"speaker": "hao_ran", "mood": "dazed", "text": "我在避難間聽得見。那份沒寄出的東西……你怎麼處理了？"},
			{"speaker": "hao_ran", "mood": "hopeful", "requires_decisions": {"backup_handling": "sealed"}, "text": "謝謝你沒替我打開。我願意讓陳醫師只看家用修復片段，不准拿去公開，也不保證我想起來會比較好。或者先把封存檔還我，我改天再決定。"},
			{"speaker": "hao_ran", "mood": "confused", "requires_decisions": {"backup_handling": "copied"}, "text": "你先聽過了，現在才問我。把檔案還我，刪掉你留的副本；我暫時不授權你把它交給任何醫師。"},
			{"speaker": "hao_ran", "mood": "dazed", "requires_decisions": {"backup_handling": "discarded"}, "text": "既然私人快取已經刪了，就不要說還能交回來。我們從現在能留下的紀錄開始，先照顧好今天。"},
			{"speaker": "kai", "text": "聽清楚了。怎麼保管，照你的意思辦。", "choices": [
				{"text": "依本人同意，交給陳醫師限用途照護。", "next": "custody_clinic", "requires_decisions": {"backup_handling": "sealed"}, "set_flag": "backup_custody_resolved", "set_decision": {"backup_custody": "clinic"}, "affinity": {"hao_ran": 2}},
				{"text": "將密封備份交還本人。", "next": "custody_owner", "requires_decisions": {"backup_handling": "sealed"}, "set_flag": "backup_custody_resolved", "set_decision": {"backup_custody": "owner"}},
				{"text": "承認越界，交還並刪除私留副本。", "next": "custody_owner", "requires_decisions": {"backup_handling": "copied"}, "set_flags": ["backup_custody_resolved", "backup_copy_deleted"], "set_decision": {"backup_custody": "owner"}},
				{"text": "坦白已刪除，改留往後的照護紀錄。", "next": "custody_absent", "requires_decisions": {"backup_handling": "discarded"}, "set_flag": "backup_custody_resolved", "set_decision": {"backup_custody": "absent"}},
				{"text": "先停在這裡，稍後再談。", "next": "end"}
			], "next": "end"},
			{"label": "custody_clinic", "speaker": "hao_ran", "mood": "hopeful", "text": "授權只到家用修復片段，每次使用先問我。我也可以叫停。這樣我才知道，那段聲音還是我的。", "next": "end"},
			{"label": "custody_owner", "speaker": "hao_ran", "mood": "dazed", "text": "檔案留在我手上，今天不打開。至於案件要不要作證，我會另外回答；保管備份不是作證同意。", "next": "end"},
			{"label": "custody_absent", "speaker": "kai", "text": "那就從今天記。下次要留什麼，我先問你。", "next": "end"}
		],
		"ch3_grey_care_terms": [
			{"speaker": "snake", "mood": "serious", "text": "若你最後選擇沉默換照護，先談清楚誰能控制回診。條款現在可以準備，到屋頂作最後決定才生效；你仍能選公開或恢復記憶。", "choices": [
				{"text": "用限制追討回執，談獨立醫療安排。", "next": "care_independent", "requires_decisions": {"market_claim_resolution": "bounded"}, "set_flag": "grey_care_terms_resolved", "set_decision": {"grey_care_terms": "independent"}},
				{"text": "接受企業承包照護及回診限制。", "next": "care_corporate", "set_flag": "grey_care_terms_resolved", "set_decision": {"grey_care_terms": "corporate"}},
				{"text": "先不準備交易條款。", "next": "end"}
			], "next": "end"},
			{"label": "care_independent", "speaker": "snake", "mood": "default", "text": "對方接受第三方保管照護經費，企業不能靠停診追回你的證詞。但交易依然要你交出核心證據並保持沉默，不能把這叫正義。", "next": "end"},
			{"label": "care_corporate", "speaker": "snake", "mood": "serious", "text": "回診由企業指定，失聯就中止補助。保障先到手，浩然的照護也因此多了一條企業能拉動的線。", "next": "end"}
		],
		# ============================================
		# CHAPTER 1: 失蹤的記憶
		# ============================================

		# --- Opening: Mei Ling visits the office ---
		"ch1_mei_ling_intro": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"show_cg": "cg_kai_office_prologue",
				"text": "雨打在九龍延伸區的窗上。檯燈壞了，咖啡機也過了保固。牆上那只正和科技安全調查員識別框倒還好好的，你一直沒把它摘下來。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "上一件案子的仿生寵物找回來了，尾款拖了三週。客戶肯回覆的只有一句「前企業狗」。你把催款訊息又發了一遍。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "（義眼又在響。這次又怎麼了？）",
				"choices": [
					{"text": "按掉義眼警示，整理委託紀錄。", "next": "kai_office_after_warning", "set_flag": "kai_suppressed_eye_warning"},
					{"text": "讓鷹眼掃過辦公室一次。", "next": "kai_office_after_warning", "set_flag": "kai_checked_office_with_eagle_eye"}
				]
			},
			{
				"label": "kai_office_after_warning",
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把舊案照片翻過去，騰出桌面。關抽屜時，藥瓶撞了一下義眼維護盒。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "門響了兩下。你還沒應聲，第三下已經落下來。門外的女人把濕透的袖口攥在手裡，見你開門才鬆開。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"clear_cg": true,
				"text": "川崎凱先生？我弟弟林浩然，三天沒消息了。我在舊城警署等了四個小時，他們還是叫我回家。你這裡……還接委託嗎？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "接。你慢慢說。",
				"choices": [
					{"text": "先坐下，把你知道的照順序說。", "next": "mei_ling_case_intro", "affinity": {"mei_ling": 1}},
					{"text": "如果只是家人失聯，我不一定接。", "next": "mei_ling_prove_case", "affinity": {"mei_ling": -1}},
					{"text": "你怎麼知道該來找我？", "next": "mei_ling_found_kai"}
				]
			},
			{
				"label": "mei_ling_case_intro",
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "他在東區開了一間記憶工作室，叫永恆記憶。警察說他是成年人，也許只是想出去幾天。"
			},
			{
				"label": "mei_ling_prove_case",
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "他不會連電話也不接。每天十一點，他都打來問我吃藥了沒，窗邊那盞燈關了沒。那晚電話響了一聲就斷了。我再打，他就沒接。",
				"give_evidence": "commission_letter"
			},
			{
				"label": "mei_ling_found_kai",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "你的名字，是浩然留給我的。他說萬一出了事，就找你。我問他為什麼不找警察，他只說，你以前在正和做過，查得懂那些記憶。",
				"give_evidence": "commission_letter"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "他沒來找過我。倒把名字留給你了。",
				"choices": [
					{"text": "他失蹤前有沒有反常行為？", "next": "mei_ling_abnormal"},
					{"text": "他的工作室在哪？", "next": "mei_ling_workshop"},
					{"text": "你還沒說為什麼信任我。", "next": "mei_ling_trust_test"}
				]
			},
			{
				"label": "mei_ling_abnormal",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "這幾個月常常半夜出門，問就說加班。手機上的訊息全加了密，家裡那台舊播放器也鎖進房間，還叫我別碰。",
				"set_flag": "knows_hao_ran_abnormal"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "portrait_side": "left",
				"text": "還有這張收據，在他房裡找到的。深淵酒吧……他連生日都嫌外面吵，只肯在家吃飯。怎麼會跑去那裡？",
				"give_evidence": "abyss_receipt",
				"choices": [
					{"text": "我接下這個案子。", "next": "mei_ling_accept", "set_flag": "accepted_case", "affinity": {"mei_ling": 1}},
					{"text": "先給我他的工作室地址。", "next": "mei_ling_workshop"}
				]
			},
			{
				"label": "mei_ling_workshop",
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "portrait_side": "left",
				"text": "東區第七街，地下層。工作證給你，地址也寫在背面。我沒有鑰匙，得回他房裡找找，看有沒有多留一把。",
				"give_evidence": "work_id",
				"set_flag": "knows_workshop_location",
				"next": "mei_ling_accept"
			},
			{
				"label": "mei_ling_trust_test",
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "portrait_side": "left",
				"text": "我不知道能不能信你。浩然說過，你恨正和，但不會拿來求你的人去換錢。我現在也只能信他。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "這話倒很少聽。東西先留給我，你們公寓我也得去一趟。"
			},
			{
				"label": "mei_ling_accept",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "我去找他。這幾天有人找你要備份，先打給我。陌生號碼別回撥，警署要拿東西，你也先跟我說一聲。",
				"give_evidence": "work_id",
				"set_flags": ["knows_workshop_location", "accepted_case"]
			},
			{
				"speaker": "narrator", "text": "美玲把酒吧收據推到你面前，指尖壓著紙角。等你拿出委託袋，她才鬆手，讓你把它和工作證一起收進去。",
				"give_evidence": "abyss_receipt"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "portrait_side": "left",
				"text": "謝謝。要是找到他，先讓他打個電話給我。說一句也好。"
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
				"text": "責任在拿記憶當貨物的人身上。浩然留下線索，是因為他相信你會活著把它交給對的人。",
				"next": "backup_collected"
			},
			{
				"label": "backup_cautious",
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "愧疚會讓人漏看細節。先把它當作線索，不要急著把自己放進罪名裡。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"label": "backup_collected",
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
				"text": "七分鐘的空白。單靠這個，還看不出是誰被帶走，也看不出去了哪裡。"
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
				"text": "下到東區地下三層，深淵酒吧的低音已透過門板傳來。你推門進去，紫光裡浮著一層煙，近旁的客人把話壓低了。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "阿傑站在吧台後擦杯子，手臂上的電路紋身隨動作一明一暗。他看了看你的義眼，才把杯子放下。"
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
				"text": "酒可以。人嘛，你先說名字。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "林浩然，修記憶的。三天前來過這裡，之後就沒消息了。",
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
				"text": "是這筆啊。來過，進了二號包廂。裡頭那位戴著全息面具，我哪認得。照片給你，能看清的也就這些。",
				"give_evidence": "stranger_photo",
				"set_flag": "ajie_told_about_meeting",
				"next": "end"
			},
			{
				"label": "ajie_vague",
				"speaker": "ajie", "name": "阿傑", "mood": "default", "portrait_side": "left",
				"text": "每天來這裡的人太多了。記不清楚。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "（嘴倒是很緊。光報個名字，問不出來。）",
			}
		],

		"ch1_abyss_bar_backroom_enter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "後室的門一關，前場只剩悶悶的低音。包廂門上的感應燈亮了又暗，你聽見阿傑在身後停下腳步。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "紀錄在裡面。先說好，有人付過錢，讓監控慢幾分鐘。你看到時間不對，別說我沒提。"
			}
		],

		"ch1_abyss_backroom_investigation": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "阿傑把包廂紀錄推過來。你伸手去拿，他的指頭還壓在紙上，隔了一會兒才挪開。"
			},
			{
				"speaker": "ajie", "name": "阿傑", "mood": "nervous", "portrait_side": "left",
				"text": "二號包廂，那個戴面具的。付款只留一組臨時代碼。這種客人，你問名字，他下次就換一家喝。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "所以就連監控也替他延了？"
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
				"text": "三支鏡頭，三分鐘。我把這份紀錄帶走。收的是誰的錢，還得往下查。",
				"give_evidence": "abyss_surveillance_delay_log",
				"set_flag": "abyss_surveillance_delay_log_found"
			}
		],

		"ch1_snake_data_chip_choice": [
			{"speaker": "snake", "mood": "amused", "requires_flag": "snake_requested_data_chip", "text": "找到了？先別接讀取器。你上次說找到再談，我記得。"},
			{"speaker": "snake", "mood": "amused", "requires_flag": "snake_broker_met", "requires_missing_flags": ["snake_requested_data_chip"], "text": "不是說不替我跑腿？坐吧。晶片還在你手上，肯坐下不算答應。"},
			{
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "原件你留著。我取一份副本，替你弄到黑市拍賣的入口。回聲網路的東西在那裡轉手，你應該想去看看。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "副本會流到哪裡？"
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "我會拿去問價，不保證只給你一個人看。你要是不願意，晶片收好。我也省得白忙。",
				"choices": [
					{"text": "交出可被轉手的副本，換拍賣入口（留下交易紀錄）。", "next": "snake_trade_accept", "requires_missing_flags": ["rejected_snake_deal"], "set_flag": "accepted_snake_deal", "set_flags": ["snake_data_chip_choice_resolved"], "set_decision": {"accepted_snake_deal": true, "black_market_route_opened": true, "black_market_compromise_count": 1}, "affinity": {"snake": 2}},
					{"text": "拒絕交易，改走診所與義眼追查。", "next": "snake_trade_reject", "requires_missing_flags": ["accepted_snake_deal"], "set_flag": "rejected_snake_deal", "set_flags": ["snake_data_chip_choice_resolved"], "set_decision": {"rejected_snake_deal": true, "clinic_route_opened": true}, "affinity": {"snake": -1}},
					{"text": "晶片先收起來，之後再談（暫不選路線）。", "next": "end"}
				]
			},
			{
				"label": "snake_trade_accept",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "副本收到了。下一場交割前，邀請會送到你手上。進去先看貨，別一開口就找人。",
				"set_flag": "black_market_route_opened",
				"next": "end"
			},
			{
				"label": "snake_trade_reject",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "那就收好。你那隻眼睛，陳醫師倒是能看看。拍賣的入口，這次我就不替你安排了。",
				"set_flag": "clinic_route_opened"
			}
		],

		# --- Snake the information broker ---
		"ch1_snake_encounter": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "角落的女人戴著蛇形面具。你走近卡座，她把電子菸擱在杯墊旁，挪開對面的椅子。"
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "坐。站在那裡，阿傑會以為我又替他攬客。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "你認識我？",
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "凱·川崎。正和出來的，現在自己接案。我做這行，總得認得幾張臉。",
				"choices": [
					{"text": "你知道林浩然的事嗎？", "next": "snake_info"},
					{"text": "你是什麼人？", "next": "snake_intro"},
					{"text": "我沒興趣和情報販子聊天。", "next": "end", "affinity": {"snake": -2}}
				]
			},
			{
				"label": "snake_intro",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "叫蛇女就行。有人找消息，有人急著脫手，我替兩邊搭個線，抽一點。"
			},
			{
				"label": "snake_info",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "浩然，那個記憶技師。最近市場多了一批貨，也許跟他有關。你別急著點頭，我還沒說價錢。",
				"choices": [
					{"text": "什麼商品？", "next": "snake_deal"},
					{"text": "直說吧，你要什麼交換條件？", "next": "snake_deal"}
				]
			},
			{
				"label": "snake_deal",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "他工作室裡有一枚加密晶片，我要看那個。你本來也得去找他，順路留意一下。拿到手，我們再談拍賣入口。",
				"choices": [
					{"text": "我會先找到晶片，再決定要不要交易。", "next": "snake_deal_accept", "set_flags": ["snake_broker_met", "snake_requested_data_chip"], "affinity": {"snake": 1}},
					{"text": "我不替情報販子跑腿。", "next": "snake_deal_reject", "set_flag": "snake_broker_met", "affinity": {"snake": -1}},
				]
			},
			{
				"label": "snake_deal_accept",
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left",
				"text": "好，只算你肯去找。東西拿回來以前，我不替你留入口，也不算你欠我的。",
				"next": "end"
			},
			{
				"label": "snake_deal_reject",
				"speaker": "snake", "name": "蛇女", "mood": "default", "portrait_side": "left",
				"text": "那真可惜。椅子不用替我推回來，等會兒還有人。真拿到晶片，再來也行。"
			}
		],

		"ch1_dr_chen_clinic_followup": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "Dr. 陳的診所藏在東區招牌後方。門口沒有診療科別，只有一行褪色字：義體維修，現金優先。"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "worried", "portrait_side": "left",
				"text": "我看過這種握手協定。正和早期義眼維修用的，後來被禁掉，因為外部設備可以把它叫醒。"
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
				"text": "他知道我的義眼能讀這些東西。接下來，得查清楚是誰把他帶走。",
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
				"set_decision": {"chapter_1_complete": true, "chapter_1_route_chosen": "black_market"}, "next": "end"
			},
			{
				"label": "route_clinic",
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "Dr. 陳會從網咖聯絡你。下一步去離線轉介等候站查人的去向；你沒有把副本交給蛇女，得從被退回的求助裡逐項核對。",
				"set_flags": ["chapter_1_complete", "chapter_1_route_chosen"],
				"set_decision": {"chapter_1_complete": true, "chapter_1_route_chosen": "clinic"}, "next": "end"
			},
			{
				"label": "route_unresolved",
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "蛇女還在等答覆。先回深淵酒吧；要不要拿晶片副本換入口，當面說清楚。"
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
				"text": "別的病人也有……這套協定為什麼還在我的義眼裡？",
				"give_evidence": "clinic_anonymous_case_note",
				"set_flag": "clinic_anonymous_case_note_found"
			}
		],

		# ============================================
		# CHAPTER 2: 記憶黑市
		# ============================================

		"ch2_opening": [
{"speaker": "dr_chen", "text": "離線等候站還在收件。先核對叫號與簽收，再去市政檔案室查改派。我在電話這頭等你。", "requires_chapter_route": "clinic"},{"speaker": "snake", "text": "交割後室的門今晚開著。引介只管那一道門；要不要具名查表，等你看清價錢再說。", "requires_chapter_route": "black_market"},{"speaker": "kid", "text": "換方向可以在網咖找我。等最後一份交接完成，另一邊今晚的窗口就收了；沒有暗中倒數，你決定交接時我會再提醒。"},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然留下的訊號、被遮去姓名的紀錄，都指向回聲網路。你得沿著交接紀錄，查出他最後被送去了哪裡。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "九龍延伸區的雨越下越大。霓虹燈在積水中倒映成碎裂的彩虹。"
			},
			{
				"speaker": "snake", "name": "蛇女", "mood": "amused", "portrait_side": "left", "requires_flag": "accepted_snake_deal",
				"text": "副本收到了。拍賣入口替你留著，身份晶片在網咖取。記住，我賣的是門票，裡面的每一筆交易都另算。",
				"set_flag": "has_fake_id", "give_evidence": "fake_id_chip", "next": "end"
			},
			{
				"speaker": "dr_chen", "name": "Dr. 陳", "mood": "nervous", "portrait_side": "left", "requires_flag": "rejected_snake_deal",
				"text": "你沒把副本給蛇女，這條線暫時還沒經過她的手。去比特風暴找小鬼做離線協定檢查；不要上傳記憶。若不願再接線，下水道的倉庫也是一條路。",
				"next": "end"
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
					{"text": "離線掃描；不准上傳我的記憶。", "next": "kid_deal", "set_flag": "has_fake_id", "set_flags": ["kid_scanned_eagle_eye", "found_eagle_eye_backdoor"], "give_evidence": "fake_id_chip"},
					{"text": "不行，太冒險了。", "next": "kid_refuse"}
				]
			},
			{
				"label": "kid_deal",
				"speaker": "kid", "name": "小鬼", "mood": "excited", "portrait_side": "left",
				"text": "離線，說好了。等等……這不是只有讀取功能。你的舊協定會回應外部的記憶訊號。我封住上傳端，但別把每次回應都當成真相。身份晶片拿好——「張偉」，記憶收藏家。",
				"next": "end"
			},
			{
				"label": "kid_offended",
				"speaker": "kid", "name": "小鬼", "mood": "angry", "portrait_side": "left",
				"text": "孩子？我知道自己能做什麼。你不願意接線，就從下水道找倉庫，或去正和後門問趙明。別把入口當成只有一扇門。",
				"next": "end"
			},
			{
				"label": "kid_refuse",
				"speaker": "kid", "name": "小鬼", "mood": "default", "portrait_side": "left",
				"text": "那就別接。網咖後方的下水道通往廢棄倉庫；趙明也在正和後門。要回來做離線掃描，隨時找我。",
				"next": "end"
			},
			{
				"label": "kid_echo_info",
				"speaker": "kid", "name": "小鬼", "mood": "serious", "portrait_side": "left",
				"text": "回聲網路...你最好小心。他們不是普通的數據販子。聽說他們在做一些...改變人的東西。",
				"give_evidence": "echo_symbol",
				"next": "end"
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
				"give_evidence": "zhengtek_memo",
				"next": "end"
			},
			{
				"label": "zhao_zhengtek",
				"speaker": "zhao_ming", "name": "趙明", "mood": "nervous", "portrait_side": "left",
				"text": "凱...有些事情，知道得越多越危險。但你是我的朋友，我不能看你走進陷阱。",
				"give_evidence": "zhengtek_memo",
				"next": "end"
			},
			{
				"label": "zhao_trust",
				"speaker": "zhao_ming", "name": "趙明", "mood": "sincere", "portrait_side": "left",
				"text": "你知道的，我當年支持你揭發那些腐敗...只是我選擇了從內部改變。你可以信我。",
				"choices": [
					{"text": "先讓文件說話。", "next": "zhao_trusted"},
					{"text": "我現在誰都不信。", "next": "zhao_untrusted"}
				]
			},
			{
				"label": "zhao_trusted",
				"speaker": "zhao_ming", "name": "趙明", "mood": "determined", "portrait_side": "left",
				"text": "好。這份備忘錄只有預算代碼，還不能證明人被送去哪裡。去倉庫找同批次的名單和日記，再回來。到時候，你決定要不要讓我把名字簽上去。",
				"give_evidence": "zhengtek_memo",
				"next": "end"
			},
			{
				"label": "zhao_untrusted",
				"speaker": "zhao_ming", "name": "趙明", "mood": "sad", "portrait_side": "left",
				"text": "……我理解。備忘錄你仍然拿走。倉庫的轉運批次若能對上它，你不必相信我，也能繼續查。",
				"give_evidence": "zhengtek_memo",
				"next": "end"
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
				"text": "娛樂、創傷、身份，各有等級。企業訂製人格另議。樣本不免費；去交易台看清楚條件，再決定要不要碰它。",
				"choices": [
					{"text": "我想見你們的供應商。", "next": "market_supplier"},
					{"text": "只查看攤位的公開標籤。", "next": "market_scan"}
				]
			},
			{
				"label": "market_blown",
				"speaker": "mask_merchant", "name": "面具商人", "mood": "suspicious", "portrait_side": "left",
				"text": "……你是誰？記憶技師不在公開目錄上。你的問題已經被記錄了。想找供應端，去後方通道問幽靈。",
				"set_flag": "knows_ghost_location",
				"next": "end"
			},
			{
				"label": "market_supplier",
				"speaker": "mask_merchant", "name": "面具商人", "mood": "suspicious", "portrait_side": "left",
				"text": "供應商？你問的太多了，朋友。不過...如果你去後面的通道找「幽靈」，也許他能回答你的問題。",
				"set_flag": "knows_ghost_location",
				"next": "end"
			},
			{
				"label": "market_scan",
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "同一個批次被貼上三種價格。標籤足以證明有人在賣，還不能證明誰被提取。帳本鎖在交易台；後方通道的幽靈或許知道來源。",
				"set_flag": "knows_ghost_location",
				"next": "end"
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
				"set_flag": "ghost_willing_to_talk",
				"set_flags": ["ghost_encounter_resolved"],
				"next": "end"
			},
			{
				"label": "ghost_threaten",
				"speaker": "ghost", "name": "幽靈", "mood": "hostile", "portrait_side": "left",
				"text": "威脅我？你知道這裡是誰的地盤嗎？（手伸向腰間）不過...看在你有膽量的份上，我可以給你一個機會。",
				"set_flag": "ghost_antagonized",
				"set_flags": ["ghost_encounter_resolved"],
				"next": "end"
			},
			{
				"label": "ghost_confront",
				"speaker": "ghost", "name": "幽靈", "mood": "cautious", "portrait_side": "left",
				"text": "（沉默了幾秒）你做了不少功課。好吧，浩然確實跟我們合作過。但他最近...不見了。連我們也找不到他。",
				"give_evidence": "comm_frequency",
				"set_flag": "ghost_encounter_resolved",
				"next": "end"
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
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "日記、名單、箱號，時間對得上。浩然被當成最後一批貨轉走了。還缺企業端的簽收紀錄——去正和後門，讓趙明核對備忘錄。",
				"set_flag": "warehouse_investigated",
				"next": "end"
			}
		],

		"ch2_memory_trade_choice": [
			{
				"speaker": "mask_merchant", "name": "面具商人", "mood": "interested", "portrait_side": "left",
				"text": "樣本帶倉庫地址，來源不開放查詢。今天不用付款，留個身份就好。下次拿到線索，先讓我們報價。交易都會記帳，您往後要公開查案經過，這筆也在裡面。",
				"choices": [
					{"text": "買樣本與地址（欠優先報價權，增加交易紀錄）。", "next": "trade_buy", "requires_missing_flags": ["market_trade_resolved"], "set_flag": "market_trade_resolved", "set_decision": {"memory_trade_method": "buy"}, "add_decision": {"black_market_compromise_count": 1}, "give_evidence": "warehouse_map"},
					{"text": "侵入樣本：暴露身份並承受污染。", "next": "trade_intrude", "requires_missing_flags": ["market_trade_resolved"], "set_flags": ["market_trade_resolved", "identity_exposed_market"], "set_decision": {"memory_trade_method": "intrude"}, "add_decision": {"eagle_eye_overuse_count": 1}, "give_evidence": "trade_ledger"},
					{"text": "拒絕：到倉庫另找線索。", "next": "trade_refuse", "requires_missing_flags": ["market_trade_resolved"], "set_flag": "market_trade_resolved", "set_decision": {"memory_trade_method": "refuse"}},
					{"text": "先離開交易台。", "next": "end"}
				],
				"next": "end"
			},
			{
				"label": "trade_buy", "speaker": "mask_merchant", "name": "面具商人", "mood": "default", "portrait_side": "left",
				"text": "收好了，樣本和地址都在。下一份線索先來問價，記在這個身份底下。有人來查這筆買賣，我們也按帳回答。",
				"give_evidence": "memory_sample", "next": "end"
			},
			{
				"label": "trade_intrude", "speaker": "kai", "name": "凱", "mood": "surprised", "portrait_side": "right",
				"text": "（疼……這是誰的記憶？）帳本複製下來了，轉運編號也在。糟了，終端上那串是我的裝置碼。",
				"give_evidence": "memory_sample", "next": "end"
			},
			{
				"label": "trade_refuse", "speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "不用包了，我不買。後面還有個幽靈要找。真問不出來，我從網咖的下水道去倉庫。",
				"next": "end"
			}
		],

		"ch2_ghost_identity_reveal": [
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "你手上的採樣編號，和倉庫清單用同一種格式。你以前也是被提取的人。"
			},
			{
				"speaker": "ghost", "name": "幽靈", "mood": "revealed", "portrait_side": "left",
				"text": "健康篩檢。那時他們說，留下記憶就找得到家。後來我的身份被拆開賣，我替他們帶路，才沒有被收走剩下的部分。別念那個編號。"
			},
			{
				"speaker": "ghost", "name": "幽靈", "mood": "cautious", "portrait_side": "left",
				"text": "我能交出一次轉運頻率。你可以把我當匿名證人。也能把這個編號賣回市場，換到供應端的完整帳本。那樣，我就得再消失一次。",
				"choices": [
					{"text": "保護身份，只保留匿名證詞。", "next": "ghost_protect", "requires_missing_flags": ["ghost_identity_resolved"], "set_flags": ["ghost_identity_resolved", "helped_ghost", "ghost_protected"], "set_decision": {"ghost_identity_choice": "protect"}, "affinity": {"ghost": 2}, "give_evidence": "comm_frequency"},
					{"text": "出賣身份換帳本：他將失去藏身處。", "next": "ghost_expose", "requires_missing_flags": ["ghost_identity_resolved"], "set_flags": ["ghost_identity_resolved", "ghost_identity_exposed"], "set_decision": {"ghost_identity_choice": "expose"}, "add_decision": {"black_market_compromise_count": 1}, "affinity": {"ghost": -2}, "give_evidence": "trade_ledger"},
					{"text": "暫時不處理他的身份。", "next": "end"}
				],
				"next": "end"
			},
			{
				"label": "ghost_protect", "speaker": "ghost", "name": "幽靈", "mood": "cautious", "portrait_side": "left",
				"text": "只記批次和時間。若你找到肯簽名的人，我會再回一通電話。這是倉庫位置。不要把保護我的承諾寫成救贖——我也替他們送過人。",
				"give_evidence": "warehouse_map", "next": "end"
			},
			{
				"label": "ghost_expose", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把採樣編號傳回市場，收到供應端帳本、轉運頻率，以及用那個身份開出的企業通行資格。幽靈關閉了私人頻道。情報是真的；往後再需要他的證詞，你已沒有權利要求。",
				"give_evidence": "comm_frequency"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "帳本附的地圖對上倉庫位置。這筆交易有了憑據，欠下的人情卻無法用另一張表抵銷。",
				"give_evidence": "warehouse_map", "next": "end"
			}
		],

		"ch2_verify_zhengtek_memo": [
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "conflicted", "portrait_side": "left",
				"text": "倉庫的批次對上公司預算了。不是普通外包事故。把日記、名單和備忘錄放在一起，我們才有資格指向同一條轉運線。",
				"choices": [
					{"text": "信任趙明，建立署名舉報通道。", "next": "verify_public", "requires_flags": ["warehouse_investigated"], "requires_evidences": ["zhengtek_memo", "hao_ran_diary", "victim_list"], "requires_missing_flags": ["ch2_investigation_complete"], "set_flags": ["trusted_zhao_ming", "public_channel_opened", "ch2_investigation_complete"], "set_decision": {"ch2_evidence_channel": "public"}, "affinity": {"zhao_ming": 2}},
					{"text": "只核對文件；我保管全部證據。", "next": "verify_private", "requires_flags": ["warehouse_investigated"], "requires_evidences": ["zhengtek_memo", "hao_ran_diary", "victim_list"], "requires_missing_flags": ["ch2_investigation_complete"], "set_flags": ["independent_channel_opened", "ch2_investigation_complete"], "set_decision": {"ch2_evidence_channel": "independent"}},
					{"text": "先回倉庫補齊證據。", "next": "end"}
				],
				"next": "end"
			},
			{
				"label": "verify_public", "speaker": "zhao_ming", "name": "趙明", "mood": "determined", "portrait_side": "left",
				"text": "我會留一份不可撤回的署名備份，代價是公司一定會知道我站在哪邊。進去後找正式授權、技術報告和資金流向；缺任何一項，他們都能推給承包商。",
				"next": "verify_route"
			},
			{
				"label": "verify_private", "speaker": "zhao_ming", "name": "趙明", "mood": "sad", "portrait_side": "left",
				"text": "可以。文件仍然是真的，路也給你。但只有副本，沒有內部證人，公開時他們會更容易否認。這個選擇我不替你改。",
				"next": "verify_route"
			},
			{
				"label": "verify_route", "speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "地下第十層，退役資料中心。倉庫不是終點，是轉運站。先把現有線索收好，再確認進入總部。",
				"set_flag": "ch2_investigation_complete", "give_evidence": "comm_frequency", "next": "end"
			}
		],

		"ch2_family_update": [
			{
				"speaker": "narrator", "text": "網咖角落的舊電話不接公共雲端。小鬼接好轉接線，把螢幕轉向牆壁。你撥出委託書上的號碼；第一聲還沒響完，美玲就接了。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried",
				"text": "我把飯收進冰箱了。不是催你……只是想問，我今晚還要不要留門？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful",
				"text": "倉庫名單證明浩然被轉運，卻沒有寫他現在是否清醒。電話另一端的人，需要的不是我的推測。",
				"choices": [
					{"text": "說明提取風險，讓她準備照護。", "next": "family_update_candid", "requires_flag": "warehouse_investigated", "requires_evidence": "victim_list", "requires_missing_flags": ["family_update_resolved"], "set_flag": "family_update_resolved", "set_decision": {"family_update_choice": "candid"}, "affinity": {"mei_ling": 1}},
					{"text": "只報轉運線索，暫不談記憶受損。", "next": "family_update_guarded", "requires_flag": "warehouse_investigated", "requires_evidence": "victim_list", "requires_missing_flags": ["family_update_resolved"], "set_flag": "family_update_resolved", "set_decision": {"family_update_choice": "guarded"}},
					{"text": "還沒想好怎麼說，先掛斷。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "family_update_candid", "speaker": "kai", "name": "凱", "mood": "serious",
				"text": "我找到提取設備和轉運名單。他可能受過記憶處理。我還沒見到他，不能告訴你傷到哪裡。就算找到人，也可能需要很長的照護。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous",
				"text": "……好。衣服我會帶，證件也帶。相簿先收著。等他自己問起，我再拿出來，不逼他一張張認人。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried",
				"text": "你下次打來，可以只說你還在找。我寧可知道你不知道，也不要整晚替一句『快好了』猜意思。", "next": "family_update_close"
			},
			{
				"label": "family_update_guarded", "speaker": "kai", "name": "凱", "mood": "serious",
				"text": "找到把他送走的路線了。我還沒見到他。有消息我會再打，今晚先鎖好門，別接受陌生人的尋人協助。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved",
				"text": "有路線就好。我把他喜歡的照片放進包裡；如果他醒來看見熟悉的東西，也許就不會那麼怕。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful",
				"text": "我沒有答應他會毫髮無傷，卻也沒有說出那台提取椅。她已經開始準備一場我無法保證的重逢。", "next": "family_update_close"
			},
			{
				"label": "family_update_close", "speaker": "narrator",
				"text": "美玲念了一次回撥號碼，拿筆記下。你等她掛斷，才放回話筒。這通電話沒有增加一件證據，但她現在知道該等誰的消息。", "next": "end"
			}
		],

		"ch2_conclude_investigation": [
			{
				"speaker": "narrator", "requires_missing_flags": ["family_update_resolved"],
				"text": "美玲的號碼還留在未回撥清單。離開網咖前，你仍可以用角落的電話向她回報倉庫裡的發現。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "倉庫留下人的去向，公司文件留下誰付了錢。兩端已經接上。接下來要追到地下第十層，不能再只問市場。",
				"choices": [
					{"text": "沿轉運線進入回聲總部。", "next": "ch2_confirmed", "requires_branch_complete": true, "requires_flags": ["warehouse_investigated", "ch2_investigation_complete"], "requires_missing_flags": ["chapter_2_complete"]},
					{"text": "先留下，把第二章的線索查完。", "next": "end"}
				],
				"next": "end"
			},
			{
				"label": "ch2_confirmed", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把離線證據封存，記下最後一班貨梯的時刻。雨聲在頭頂遠去。浩然被送下去的地方，終於有了確切座標。",
				"set_flag": "chapter_2_complete", "set_decision": {"chapter_2_complete": true}, "next": "end"
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
				"text": "內門仍未開啟。先從前室的調查選項選擇進入方式；途中浮現的記憶閃回，還需要用紀錄核對。"
			}
		],

		"ch3_dr_xiao_confrontation": [
			{"speaker": "narrator", "requires_flag": "hao_ran_rescued", "text": "蕭博士看了一眼空出的維持椅，手離開了門控鍵。他現在只能隔著桌子跟你談。"},
			{"speaker": "kai", "requires_decisions": {"hq_first_objective": "evidence"}, "requires_flag": "core_evidence_secured", "text": "付款原件已經離線保存。我帶著專案碼來問，你不用再給我展示摘要。"},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "川崎先生。把門帶上，外面太吵。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "default", "portrait_side": "right",
				"text": "浩然在哪？", "requires_missing_flags": ["hao_ran_rescued"]
			},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "他在維持椅上。外面的人要把他的成果帶走，我只能先把門關上。設備先別碰，你還沒看過運行紀錄。", "requires_missing_flags": ["hao_ran_rescued"]
			},
			{"speaker": "kai", "text": "浩然已經離開維持椅。照你簽的程序，停寫入、留維持，都做到了。現在不用再拿設備擋我的問題。", "requires_flag": "hao_ran_rescued"},
			{"speaker": "dr_xiao", "mood": "intense", "text": "你把他送走了，後面的反應誰來處理？照報告做了一次，就能保證他以後沒事？", "requires_flag": "hao_ran_rescued"},
			{
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "intense", "portrait_side": "left",
				"text": "正和出錢，也挑人。他們要人格調整，我做的是創傷治療。有些病人連睡一覺都做不到，你總不能叫我看著。",
				"choices": [
					{"text": "你在做的是犯罪。", "next": "xiao_crime"},
					{"text": "浩然發現了真相，所以你囚禁了他。", "next": "xiao_truth"},
					{"text": "你對我做了什麼？", "next": "xiao_kai_memory"},
					{"text": "拿改派回條追問：誰接手了被撤回的求救？", "next": "xiao_referral", "requires_flag": "referral_reroute_checked"},
					{"text": "拿資金原件追問：誰付錢維持寫入？", "next": "xiao_funding", "requires_evidence": "zhengtek_funding"},
					{"text": "先不追問，我要再查設備與紀錄。", "next": "end"}
				]
			},
			{"label": "xiao_referral", "speaker": "dr_xiao", "mood": "conflicted", "text": "轉介欄歸行政端。接收的簽章是我的，這個我認。但匿名回條上哪裡寫了浩然？你先把接收代碼拿來。", "next": "xiao_records"},
			{"label": "xiao_funding", "speaker": "dr_xiao", "mood": "intense", "text": "付款的是正和，技術報告是我簽的。他們要能一直部署的人格調整，嫌原型停得太多。你要查寫入怎麼排，覆核站有紀錄。", "next": "xiao_records"},
			{
				"label": "xiao_crime",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "philosophical", "portrait_side": "left",
				"text": "我見過病人一閉眼就回到事故現場，醒過來還在喊。你說犯罪，可以。可當時坐在他旁邊的不是你。",
				"next": "xiao_records"
			},
			{
				"label": "xiao_truth",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "calm", "portrait_side": "left",
				"text": "錨點是浩然改的。他後來知道委託方要的是服從，不肯做了，還要把資料帶走。那份東西換一個人照樣能用，我怎麼讓他走？",
				"next": "xiao_records"
			},
			{
				"label": "xiao_kai_memory",
				"speaker": "dr_xiao", "name": "蕭博士", "mood": "amused", "portrait_side": "left",
				"text": "你以前來這裡，不是坐著問話的。先看看維護紀錄上自己的簽名。你忘了，不代表只有我動過那套原型。",
				"next": "xiao_records"
			},
			{
				"label": "xiao_records", "speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "門是你鎖的。這份覆寫報告我帶走，設備序號、版本、簽章都在。隔離怎麼做，寫入又是誰排的，我分開查。",
				"give_evidence": "overwrite_report", "set_flag": "xiao_confronted"
			},
			{"speaker": "kai", "text": "我先去看浩然。出口準備好，就問他願不願意走。這幾份紀錄，你先別碰。", "requires_missing_flags": ["hao_ran_rescued"], "next": "end"},
			{"speaker": "kai", "text": "浩然在離線避難間。等他緩過來，願意說的，我再問他。你的話跟設備紀錄分開放。", "requires_flag": "hao_ran_rescued", "next": "end"}
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
				"text": "他們……改過一些地方。不要直接拔線，寫入還連著。我想出去，可我不記得斷開順序。報告……維持程序那一頁。",
				"set_flag": "hao_ran_located", "next": "end"
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
				"text": "我能打開你的記憶，但我不是原件的保證人。先看三段：調查、維護、測試。再拿走廊的授權紀錄比對。看完以前，不要答應把自己交給我。",
				"set_flag": "echo_contacted", "next": "end"
			}
		],

		"ch3_memory_corridor": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "走廊一瞬間像診療室，一瞬間又是你的辦公室。牆上的門牌跟著變，只有地面的螺栓與授權終端沒有移動。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "先找兩種視野都存在的東西。影像會變，授權令上的簽章還在。",
				"choices": [
					{"text": "比對固定物件與授權時間。", "next": "corridor_aligned", "requires_missing_flags": ["memory_corridor_aligned"]},
					{"text": "先離開走廊。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "corridor_aligned", "speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "授權對象是『人格覆寫部署』，不是一般醫療。我保存簽章原件。接下來可先到實驗室救人，也可在總部查付款；記憶空間留待逐段核對。",
				"give_evidence": "authorization_order", "set_flag": "memory_corridor_aligned", "next": "end"
			}
		],

		"ch3_secure_core_evidence": [
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "正式授權的專案碼，對上倉庫那批貨的費用。我要保留轉帳簽章和離線副本，讓他們不能只刪一部機器就否認。",
				"choices": [
					{"text": "封存伺服器的資金流向原件。", "next": "core_secured", "requires_flags": ["memory_corridor_aligned", "hq_core_verified"], "requires_evidence": "authorization_order", "requires_missing_flags": ["core_evidence_secured"]},
					{"text": "先回查授權令與保管鏈。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "core_secured", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "資金流向和原始簽章封存在離線副本中。付款者、承接者、部署時間都有了名字。實驗室的技術報告，將補上這筆錢買走了什麼。",
				"give_evidence": "zhengtek_funding", "set_flag": "core_evidence_secured", "next": "end"
			}
		],

		"ch3_kai_fragment_1": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flag": "memory_corridor_aligned",
				"text": "第一段。正和的內部調查室。趙明把一份採樣清單翻面，你在背面寫下：『身份授權不等於人格授權。』"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right", "requires_flag": "memory_corridor_aligned",
				"text": "我確實查過他們。可是清單旁邊的維護簽名，也是我的。這段只能證明我起過疑，不能替我洗清後面的事。",
				"give_evidence": "kai_memory_fragment", "set_flag": "kai_memory_1_seen", "next": "end"
			}
		],

		"ch3_kai_fragment_2": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flag": "kai_memory_1_seen",
				"text": "第二段。你站在蕭博士身旁，調整義眼原型的回寫權限。有人問為什麼不保留拒絕按鈕，你回答：『先讓程序穩定，再補同意流程。』手指停在確認鍵上，還是按了下去。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right", "requires_flag": "kai_memory_1_seen",
				"text": "我不只站在門外調查。至少有一次，是我替這台機器把門打開。時間戳能對上授權令；我不能把責任都推給失憶。趙明見過那張清單，蕭博士用過這套權限；我得拿著簽名問他們。",
				"set_flag": "kai_memory_2_seen", "next": "end"
			}
		],

		"ch3_kai_fragment_3": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flags": ["kai_memory_2_seen", "xiao_confronted", "core_evidence_secured"],
				"text": "第三段。你躺上測試椅，在同意欄簽名。隨後一隻手抓住扶手，錄音裡傳來『停止』。鏡頭跳了幾秒，成功紀錄卻寫著全程自願。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right", "requires_flags": ["kai_memory_2_seen", "xiao_confronted", "core_evidence_secured"],
				"text": "簽過名，不表示後來不能拒絕。三段都留下：調查的人、維護的人、喊停的人。它們指向我，卻沒有一段能替其他兩段作證。",
				"set_flags": ["kai_memory_3_seen", "kai_memory_truth_reviewed"], "next": "end"
			}
		],

		"ch3_rescue_hao_ran": [
			{"speaker": "narrator", "text": "接應器回了一次短光：幽靈正守著三號維修門。這次窗口留給了浩然，原件的保管鏈由你自己核對。", "requires_decisions": {"hq_exit_method": "ghost"}},
			{"speaker": "narrator", "text": "你再次對上紙本維修表和門牌。出口是自己逐項確認的，沒有接應者替你守門。", "requires_decisions": {"hq_exit_method": "offline"}},
			{"speaker": "narrator", "text": "企業門控回執顯示出口已開啟。這份具名紀錄會和設備操作一起保留，不能在救援後刪掉。", "requires_decisions": {"hq_exit_method": "corporate"}},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "報告要求先隔離寫入，再切換離線維持，最後解除固定。浩然，我會照順序做；如果你不舒服，就叫我停。",
				"choices": [
					{"text": "依隔離程序開始救援。", "next": "rescue_disconnect", "requires_flags": ["hao_ran_located", "hq_exit_ready"], "requires_evidence": "overwrite_report", "requires_missing_flags": ["hao_ran_rescued"]},
					{"text": "先確認浩然與覆寫報告。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "rescue_disconnect", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你切斷遠端寫入，確認離線維持燈穩定，再解除頭部接口與固定帶。浩然的呼吸慢下來。他抓住你的袖口，自己把腳放到地面。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "hopeful", "portrait_side": "left",
				"text": "我想走。先不要替我恢復全部……我想先聽姐姐說話。十一點的電話，我還記得。",
				"choices": [{"text": "扶他離開設備，確認安全撤離點。", "next": "rescue_evacuated"}], "next": "end"
			},
			{
				"label": "rescue_evacuated", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你把浩然送入與實驗室斷線的屋頂避難間，鎖住內側通道，確認他的心率與對講機。美玲的聲音傳來，他清楚回答了自己的名字。救援完成；他的記憶仍需要長期照護。",
				"set_flag": "hao_ran_rescued", "set_decision": {"hao_ran_rescued": true}, "next": "end"
			}
		],

		"ch3_hao_ran_aftercare": [
			{
				"speaker": "narrator", "text": "屋頂避難間裡，浩然正試著把紙杯放穩。對講機接著美玲的電話。你將錄音器放在桌上，開關朝著他，沒有按下。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "requires_decisions": {"family_update_choice": "candid"},
				"text": "浩然，我把相簿收好了。今天不用考試。你說想喝什麼，我去買。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "frightened", "requires_decisions": {"family_update_choice": "guarded"},
				"text": "他剛才問照片上的人是誰。凱，你打來那時候……已經知道可能會這樣了嗎？先別回答。先讓他休息，我們晚點再談。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "requires_decisions": {"family_update_choice": "none"},
				"text": "我一直等不到電話，只好把能想到的都帶上。沒關係，先告訴我哪個門能接到他。其他的，見面再說。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "confused", "requires_evidence": "family_memory_clip",
				"text": "生日那段……我記得有人怕蠟燭滴到桌上。可我分不清是我看見的，還是剛才姐姐告訴我的。你別把這句也當證據。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "dazed",
				"text": "我可以走。但那台錄音器……錄下來以後，誰會聽？我現在說錯了，還能改嗎？"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious",
				"text": "你可以不錄，先接受照護。這樣，我們就暫時沒有你的第一手陳述。如果你願意錄，我們只記確定的部分。紀錄會封存，留待你確認。不交市場，也不公開你的私密記憶。",
				"choices": [
					{"text": "先休息，把詢問留到他準備好。", "next": "aftercare_rest", "requires_flag": "hao_ran_rescued", "requires_missing_flags": ["hao_ran_aftercare_resolved", "final_choice_resolved", "case_resolved"], "set_flag": "hao_ran_aftercare_resolved", "set_decision": {"hao_ran_aftercare": "rest"}, "affinity": {"hao_ran": 1}},
					{"text": "說清使用範圍，讓浩然決定是否錄音。", "next": "aftercare_ask", "requires_flag": "hao_ran_rescued", "requires_missing_flags": ["hao_ran_aftercare_resolved", "final_choice_resolved", "case_resolved"]},
					{"text": "先離開避難間，稍後再談。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "aftercare_rest", "speaker": "narrator",
				"text": "你把錄音器收回口袋，在交接紙上只寫下身體狀況與接應號碼。『案件陳述』那一欄留白。浩然終於鬆開一直握著的紙杯。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "hopeful",
				"text": "等我睡醒，再問我一次。不是叫你別查……我只是想先睡一覺。", "next": "end"
			},
			{
				"label": "aftercare_ask", "speaker": "kai", "name": "凱", "mood": "serious",
				"text": "先留離線副本，由你和姐姐保管。將來要交給調查者，會再問你；不記得的地方就空著，之後更正也保留日期。你現在仍然可以拒絕。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "hopeful",
				"text": "那我願意說一小段。只錄我現在確定的事。等我說停，你就停，好嗎？",
				"choices": [
					{"text": "接受他的範圍，開始離線記錄。", "next": "aftercare_record", "requires_flag": "hao_ran_rescued", "requires_missing_flags": ["hao_ran_aftercare_resolved", "final_choice_resolved", "case_resolved"], "set_flags": ["hao_ran_aftercare_resolved", "hao_ran_testimony_consented"], "set_decision": {"hao_ran_aftercare": "testimony"}},
					{"text": "先休息也沒關係，收起錄音器。", "next": "aftercare_rest", "requires_flag": "hao_ran_rescued", "requires_missing_flags": ["hao_ran_aftercare_resolved", "final_choice_resolved", "case_resolved"], "set_flag": "hao_ran_aftercare_resolved", "set_decision": {"hao_ran_aftercare": "rest"}, "affinity": {"hao_ran": 1}}
				], "next": "end"
			},
			{
				"label": "aftercare_record", "speaker": "hao_ran", "name": "浩然", "mood": "dazed",
				"text": "我是林浩然。我修過他們的播放器，也替他們校正過樣本。起初我沒問樣本哪來的。後來名單出現姐姐的備份編號……我才開始藏紀錄。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "confused",
				"text": "押我下去的人，我記不得臉。那段不要讓我猜。……先到這裡。"
			},
			{
				"speaker": "narrator",
				"text": "你按停，讓他聽見按鍵聲。副本封進交接袋，外面寫著『未經本人複核，不對外提供』。這是一段有空白的陳述，不是補齊所有罪名的答案。", "next": "end"
			}
		],

		"ch3_echo_release_choice": [
			{
				"speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "三段都看見了。現在說我的要求：我不要在你帶走罪證後被關掉。我想要出口。但我由別人的記憶組成，出去，也可能再傷他們一次。"
			},
			{
				"speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "封存，我留在離線核心。全部釋放，受害者的私密記憶也會外流。與你融合，舊記憶能重建；但偵探時期的經歷可能不再屬於醒來的你。",
				"choices": [
					{"text": "封存迴響，只整理罪證。", "next": "echo_contain", "requires_flags": ["kai_memory_truth_reviewed", "echo_contacted"], "requires_missing_flags": ["echo_choice_resolved", "final_choice_resolved", "case_resolved"], "set_flags": ["echo_choice_resolved", "contained_echo_ai"], "set_decision": {"echo_fate": "contain", "memory_attitude": "deny"}},
					{"text": "釋放全部記憶：接受隱私外流。", "next": "echo_release", "requires_flags": ["kai_memory_truth_reviewed", "echo_contacted"], "requires_missing_flags": ["echo_choice_resolved", "final_choice_resolved", "case_resolved"], "set_flags": ["echo_choice_resolved", "released_echo_ai"], "set_decision": {"echo_fate": "release", "memory_attitude": "deny"}},
					{"text": "同意融合：承擔失去現在自我的風險。", "next": "echo_merge", "requires_flags": ["kai_memory_truth_reviewed", "echo_contacted"], "requires_missing_flags": ["echo_choice_resolved", "final_choice_resolved", "case_resolved"], "set_flags": ["echo_choice_resolved", "merged_with_echo", "memory_restoration_consented"], "set_decision": {"echo_fate": "merge", "memory_attitude": "accept"}},
					{"text": "先看完記憶，再決定。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "echo_contain", "speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "我把罪證索引交給你，留在離線核心。這不是自由。若還有人願意問我是否想活著，別把這座籠子丟進證物倉就忘了。",
				"next": "end"
			},
			{
				"label": "echo_release", "speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你打開出口。求救、地址、睡前的低語一同流入外部節點。迴響離開了，受害者卻沒有機會替這次公開按下拒絕。這些原始記憶不能直接當成舉報包散播。",
				"next": "end"
			},
			{
				"label": "echo_merge", "speaker": "echo_ai", "name": "AI「迴響」", "mood": "default", "portrait_side": "left",
				"text": "我保留一條通向義眼的連線，現在不覆寫你。等浩然安全、罪證封存，到屋頂再確認一次。你可以最後選擇公開或交易；只有選記憶恢復，我才開始融合。",
				"next": "end"
			}
		],

		"ch3_zhao_whistleblower": [
			{"speaker": "zhao_ming", "requires_decisions": {"kai_account_response": "signed"}, "text": "你那份維護說明我收到了。和簽章放同一袋，封存時你也簽名；以後有人問，不會只有我替你回答。"},
			{"speaker": "zhao_ming", "requires_decisions": {"kai_account_response": "pending"}, "text": "你列的疑問另放一頁，別混進已確認的欄位。原件上的維護簽名還在，有人問起，你得照實說。"},
{"speaker": "zhao_ming", "text": "交割後室的完整批次帳目能作調查起點，還要和這裡的三份原件分開核驗。你沒有拿市場名稱代替受害者身份。", "requires_decisions": {"ch2_market_priority": "ledger"}},{"speaker": "zhao_ming", "text": "你記下的接收站能定位設備去向。局部帳頁只引用看得到的欄位，其他部分仍以原件核對。", "requires_decisions": {"ch2_market_priority": "dispatch"}},
			{"speaker": "zhao_ming", "text": "退件索引也核對了：同一案件三次退回，不是三名不同的受害者。我會保留退回經過，避免公開數字被重複計算。", "requires_flag": "archive_index_checked"},
			{"speaker": "zhao_ming", "text": "後門的完整序號能接到設備簽收單。我會請另一個人核對，先遮掉無關清潔員的身分；這段運送鏈與三份核心原件分開列。", "requires_decisions": {"dispatch_record": "sealed"}},
			{"speaker": "zhao_ming", "text": "你先送出的去識別摘要已讓接收單位暫停使用疑似批次。公開舉報時，再核對你封存的完整序號；摘要本身不能替代原件。", "requires_decisions": {"dispatch_record": "redacted"}},
			{"speaker": "zhao_ming", "text": "蕭博士承認收到撤回後仍讓寫入繼續。供述與回執、本地簽章要一起保存，任何一份單獨抽出來都不完整。", "requires_decisions": {"xiao_accountability": "admitted"}},
			{"speaker": "zhao_ming", "text": "未核對的送達部分，我會明列有爭議。先用能驗證的原件說話，不拿猜測填空。", "requires_decisions": {"xiao_accountability": "disputed"}},
			{"speaker": "zhao_ming", "mood": "sincere", "requires_decisions": {"ajie_statement": "voluntary"}, "text": "阿傑願意只為終端延遲作證。我把你的提問一起附上，讓人看見他沒有指認照片中的人。這份補充不能取代三份核心原件。"},
			{"speaker": "zhao_ming", "mood": "conflicted", "requires_decisions": {"ajie_statement": "coerced"}, "text": "那份被你施壓得來的指認不能當作罪證。我會排除它，保留施壓與更正的紀錄；公開前請把這件事也交代清楚。"},
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "determined", "portrait_side": "left",
				"text": "授權令、資金流向、覆寫報告。三份原件才能連起決策、付款與實施。我會署名，將受害者的私人內容從公開副本中遮蔽。你在黑市留下的交易也必須揭露，不能假裝沒發生。",
				"choices": [
					{"text": "確認原件，建立舉報包。", "next": "whistleblower_prepare", "requires_flags": ["trusted_zhao_ming", "core_evidence_secured", "xiao_confronted"], "requires_evidences": ["overwrite_report", "zhengtek_funding", "authorization_order"], "requires_missing_flags": ["zhao_whistleblower_package"]},
					{"text": "先補齊證據或回頭調查。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "whistleblower_prepare", "speaker": "zhao_ming", "name": "趙明", "mood": "sincere", "portrait_side": "left",
				"text": "我簽下內部保管紀錄。這次不等下一次會議了。"
			},
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "sincere", "portrait_side": "left", "requires_flag": "ghost_protected",
				"text": "幽靈回了匿名頻道，同意核對轉運時間。我只附上批次證詞，不把他的舊身份交出去。"
			},
			{
				"speaker": "zhao_ming", "name": "趙明", "mood": "sad", "portrait_side": "left", "requires_flag": "ghost_identity_exposed",
				"text": "幽靈不再回應。你把身份賣出去，這裡就少了一個願意說話的人。只能用文件補強，不能替他編一份同意書。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "原件封存，公開副本已遮蔽。舉報包準備好了，還沒有送出。先確認浩然撤離，再到屋頂作最後選擇。",
				"set_flags": ["public_truth_ready", "zhao_whistleblower_package"], "next": "end"
			}
		],

		"ch3_rooftop_choice": [
			{
				"speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "公開，趙明和我必須承擔指控。交易，換安全卻讓技術留下。恢復記憶，則可能失去現在的自己。浩然必須先安全，罪證也必須先封存；少一項，就回去完成。"
			},
			{
				"speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "趙明肯署名，原件也核對過，公開才有憑據。做過的交易得一起交代。至於恢復記憶……看完那三段，再決定要不要接受融合。",
				"choices": [
					{"text": "公開罪證，承擔追責。", "next": "rooftop_public", "requires_ending": "ending_a_justice", "requires_missing_flags": ["final_choice_resolved"], "set_flag": "final_choice_resolved", "set_decision": {"final_resolution": "public"}},
					{"text": "交易真相，換取安全。", "next": "rooftop_deal", "requires_ending": "ending_b_grey_deal", "requires_missing_flags": ["final_choice_resolved"], "set_flag": "final_choice_resolved", "set_decision": {"final_resolution": "deal"}},
					{"text": "確認記憶恢復，接受自我代價。", "next": "rooftop_memory", "requires_ending": "ending_c_memory_rebirth", "requires_missing_flags": ["final_choice_resolved"], "set_flag": "final_choice_resolved", "set_decision": {"final_resolution": "memory"}},
					{"text": "先返回調查。", "next": "end"}
				], "next": "end"
			},
			{
				"label": "rooftop_public", "speaker": "kai", "name": "凱", "mood": "serious", "portrait_side": "right",
				"text": "送出遮蔽過的舉報副本，原件留給調查。我的名字也在上面。這次不把別人推出去，自己躲在證據後面。",
				"next": "end"
			},
			{
				"label": "rooftop_deal", "speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "我答應保持沉默，換浩然後續照護與離開城市的保障。人已經救出來，這筆交易保的是往後的安全；它不會讓留下的技術變得無害。",
				"next": "end"
			},
			{
				"label": "rooftop_memory", "speaker": "kai", "name": "凱", "mood": "thoughtful", "portrait_side": "right",
				"text": "浩然安全，罪證也留在離線副本裡。迴響，這是第二次確認：開始融合。醒來的人若不記得這場雨，讓紀錄告訴他，是我同意的。",
				"next": "end"
			}
		],

		"ch3_epilogue_family": [
			{
				"speaker": "narrator", "requires_flag": "case_resolved",
				"text": "幾天後，美玲帶著浩然來到辦公室。她沒有先拿出委託書，而是把一只保溫盒放上桌。蓋子邊緣還黏著超市的折價貼紙。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "requires_decisions": {"resolved_ending": "ending_a_justice"},
				"text": "今天有記者問我要他的照片。我說案子的文件可以問調查員，晚餐吃了什麼不用上新聞。醫院下次回診排在星期四。那天我們不接受訪問。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "requires_decisions": {"resolved_ending": "ending_b_grey_deal"},
				"text": "照護費已經到了。我知道這筆錢從哪裡來。我會拿它讓他看醫生，但別替我們寫成『一家人終於可以忘記』。我沒有答應忘記。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"resolved_ending": "ending_c_memory_rebirth"},
				"text": "你認得委託書上的字跡，卻接不上她站在門口的那一天。美玲注意到你的停頓，把名字說得很慢，像第一次來訪。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "requires_decisions": {"resolved_ending": "ending_c_memory_rebirth"},
				"text": "我叫林美玲，這是我弟弟。我們認識過。你不用為了讓我放心，就說你全都記得。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "relieved", "requires_decisions": {"family_update_choice": "candid"},
				"text": "那通電話之後，我把相簿留在家裡。他回來第一晚只想找拖鞋。我居然也覺得，能一起找拖鞋就很好了。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "nervous", "requires_decisions": {"family_update_choice": "guarded"},
				"text": "我還是想說，那時候你可以告訴我。我拿著照片一直問他記不記得，問到他把臉轉開。下次不要替我決定，什麼消息是我受不了的。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "requires_decisions": {"family_update_choice": "none"},
				"text": "救出他之前，我每隔十分鐘就看一次電話。最後是等到了……只是那幾個晚上，我不知道還能問誰。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "hopeful", "requires_decisions": {"hao_ran_aftercare": "rest"},
				"text": "我睡了一整天。今天還是不想錄音，但我想過了，等我準備好，我會自己打來。姐姐說你把那一欄留空了。先幫我留著。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "confused", "requires_decisions": {"hao_ran_aftercare": "testimony"},
				"text": "那段錄音我聽過了。有一句我想更正：第一批播放器不是我一個人修的。我把能確定的日期寫在紙上。原來那句先別刪，好讓我知道自己改過什麼。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "requires_decisions": {"hao_ran_aftercare": "testimony", "resolved_ending": "ending_a_justice"},
				"text": "調查員來問過。我說要等他複核完，再由他決定交哪一段。抓到人也不能省掉這一步。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "worried", "requires_decisions": {"hao_ran_aftercare": "testimony", "resolved_ending": "ending_b_grey_deal"},
				"text": "錄音袋我收著。它沒有跟你的核心證據一起交出去。現在敢不敢交給調查員，是另一個問題；那份交易沒有替浩然回答。"
			},
			{
				"speaker": "mei_ling", "name": "林美玲", "mood": "default", "requires_decisions": {"hao_ran_aftercare": "testimony", "resolved_ending": "ending_c_memory_rebirth"},
				"text": "袋上的使用範圍是你寫的。我會照著做。就算你不記得寫過，浩然答應的也只有那些。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "dazed", "requires_decisions": {"hao_ran_aftercare": "none"},
				"text": "那晚太亂了，好多話我沒說。今天也先不要問實驗室，好嗎？我只是想陪姐姐出門。"
			},
			{
				"speaker": "narrator", "text": "浩然打開保溫盒，把兩副筷子排到同一邊，又慢慢挪開。他抬頭看姐姐，沒有問自己以前是不是也這樣擺。"
			},
			{
				"speaker": "hao_ran", "name": "浩然", "mood": "hopeful", "text": "多買了一份。你還沒吃吧？"
			},
			{
				"speaker": "narrator", "text": "你把委託書移開，騰出放飯盒的位置。案件可以寫下結果，桌邊的人還有明天。\n\n[尾聲 — 未填的空格]\n感謝遊玩 NEON MEMORIES",
				"set_flag": "epilogue_family_seen", "next": "end"
			}
		],

		"ch3_epilogue_contacts": [
			{"speaker": "narrator", "text": "整理筆記時，你把浩然進入避難間的時間放在前面。之後才封存資金原件；救人的順序，沒有替任何人的責任畫上句點。", "requires_decisions": {"hq_first_objective": "rescue"}},
			{"speaker": "narrator", "text": "筆記先記著資金原件的封存時間，接著才是浩然的安全撤離。資料留下了，人的照護仍要繼續。", "requires_decisions": {"hq_first_objective": "evidence"}},
			{"speaker": "narrator", "text": "幽靈留下最後一次門控回覆：撤離窗口已關閉。他替你守過的那扇門，在筆記裡有明確用途。", "requires_decisions": {"hq_ghost_support": "rescue", "hq_exit_method": "ghost"}},
			{"speaker": "narrator", "text": "幽靈確認原件接收端已離線。他守住傳輸窗口，你自行確認撤離門；兩段不同的工作都留在調查紀錄。", "requires_decisions": {"hq_ghost_support": "evidence", "hq_core_method": "ghost", "hq_exit_method": "offline"}},
			{"speaker": "narrator", "text": "停用企業資格的回執夾在舊通行紀錄後面。後來改走離線查證，沒有讓先前使用的身份消失。", "requires_flag": "hq_corporate_access_disabled"},
{"speaker": "mei_ling", "text": "陳醫師把接收人的回電寫給我了。我第一次打過去，不必再從弟弟為什麼失蹤講起。", "requires_decisions": {"ch2_medical_priority": "patient"}},{"speaker": "dr_chen", "text": "整批改派已有人逐件核對。浩然的接收還在跟，不把一份收件通知當成所有人都回家。", "requires_decisions": {"ch2_medical_priority": "batch"}},{"speaker": "kai", "text": "交割帳頁仍在離線封袋裡。那天沒追上的設備，留下的是待查欄，不是我補寫的目的地。", "requires_decisions": {"ch2_market_priority": "ledger"}},{"speaker": "kai", "text": "那晚記下的設備接收站已回覆。帳目缺的部分還是缺著；我把回覆接在它旁邊，沒有冒充原來就完整。", "requires_decisions": {"ch2_market_priority": "dispatch"}},
			{"speaker": "hao_ran", "text": "轉運前，你陪我坐著，沒再問我想起多少。你可能不覺得那是幫忙，可是我記得。", "requires_decisions": {"recovery_company": "stay"}},
			{"speaker": "hao_ran", "text": "那杯水，我自己拿到了。你在門邊等，沒有伸手替我做完。那天我需要的是這樣。", "requires_decisions": {"recovery_company": "space"}},
			{"speaker": "dr_chen", "text": "倉庫代碼對到的其他受害者，已有接收單位逐一回覆。我會繼續確認人在哪裡；有床位，還不等於已經把人帶回來。", "requires_decisions": {"warehouse_priority": "patients"}},
			{"speaker": "kai", "text": "那批設備的運送封條與轉運機底座吻合。獨立檢查仍在進行，沒有把曾經用來覆寫的機器直接當成一般復健器材。", "requires_decisions": {"warehouse_priority": "provenance"}},
			{"speaker": "hao_ran", "text": "紙本交接表我留著。那天多等的一班車，我記得是自己選的。", "requires_decisions": {"recovery_channel": "paper"}},
			{"speaker": "hao_ran", "text": "醫師打來先問我今天能不能談。我們只送過那一份表，沒有替往後的每一天都答應。", "requires_decisions": {"recovery_channel": "direct"}},
			{"speaker": "ajie", "mood": "cooperative", "requires_decisions": {"ajie_statement": "voluntary"}, "text": "終端那七分鐘，我還記得。若有人來核對，我照那天自己說的話回答。你要喝什麼，這次自己付。"},
			{"speaker": "ajie", "mood": "suspicious", "requires_flag": "ajie_statement_retracted", "text": "更正收到了。名字撤掉，施壓紀錄留著。我讓你進店，不代表願意替你作證。"},
			{"speaker": "narrator", "requires_decisions": {"ajie_statement": "coerced"}, "requires_missing_flags": ["ajie_statement_retracted"], "text": "阿傑拒接你的來電。那份未更正的指認留在紀錄裡，不能因案件結束就變成自願證詞。"},
			{"speaker": "snake", "mood": "default", "requires_decisions": {"market_claim_resolution": "bounded"}, "text": "下次只談非人身線索的報價。姓名、地址和私人記憶都在排除欄裡，照護條款也不能越過那條線。"},
			{"speaker": "narrator", "requires_decisions": {"market_claim_resolution": "pledge"}, "text": "市場確認收到路由，另一個受害者卻問你：為什麼陌生人知道如何找到他？你換到的結清或照護預約，都不能結束這次外流的後果。"},
			{"speaker": "hao_ran", "mood": "hopeful", "requires_decisions": {"backup_custody": "clinic"}, "text": "陳醫師只看了我同意的片段，今天先到這裡。那份授權有停止欄，是我自己填的。"},
			{"speaker": "hao_ran", "mood": "dazed", "requires_decisions": {"backup_custody": "owner"}, "text": "備份還沒打開。我把它收好，哪天要聽，由我按播放。"},
			{"speaker": "narrator", "requires_decisions": {"backup_custody": "absent"}, "text": "新的照護紀錄從空白頁開始。舊私人快取已刪除，沒有任何人把它說成奇蹟般恢復的記憶。"},
			{"speaker": "ghost", "text": "三號門關好了。那次接應到此為止。你的註銷回執我留著，新的地址仍不給你。", "mood": "cautious", "requires_flag": "ghost_repaired"},
			{
				"speaker": "narrator", "requires_flag": "case_resolved",
				"text": "收件匣留下幾則未讀訊息。它們沒有排進結案報告，有些甚至不能算作消息。"
			},
			{
				"speaker": "ghost", "name": "幽靈的離線留言", "mood": "cautious", "requires_decisions": {"ghost_identity_choice": "protect"},
				"text": "舊地方不住了。新地址也不留給你。你守住了編號，我就還能自己找地方。哪天有人問你認不認識我，你知道怎麼回答。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"ghost_identity_choice": "expose"}, "requires_missing_flags": ["ghost_repaired"],
				"text": "寄給幽靈的訊息退回了。市場帳本上的採樣編號仍然有效，原本的聯絡方式卻已註銷。你留下了能追查的資料，也讓一個人必須重新躲藏。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"ghost_identity_choice": "none"},
				"text": "幽靈的欄位沒有新訊息。你沒有查清他的採樣身份，也就無從知道那條轉運線最後把他留在哪裡。"
			},
			{
				"speaker": "mask_merchant", "name": "市場自動通知", "mood": "default", "requires_decisions": {"memory_trade_method": "buy"}, "requires_missing_flags": ["market_claim_pledged"],
				"text": "交易已記帳：線索樣本一份。優先報價權尚未結清。帳戶不因案件結束而註銷。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"memory_trade_method": "intrude"},
				"text": "裝置識別碼出現在一則招攬訊息裡。你入侵市場時拿走了樣本，市場也留下了辨認你的方法。你關閉通知，記下需要更換的通訊識別。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"memory_trade_method": "refuse"},
				"text": "市場沒有寄來帳單。你拒絕過那份樣本，後來用倉庫的日記與轉運紀錄接上線索。這條路繞了一些，沒欠下一次報價權。"
			},
			{
				"speaker": "narrator", "requires_flag": "released_echo_ai",
				"text": "小鬼轉來一份刪除請求：有人在外部鏡像站認出自己的私人記憶。迴響離開核心時，那些片段也一起出去了。刪掉你手上的副本，不能召回別人已經下載的內容。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"echo_fate": "contain"},
				"text": "離線核心的交接單上，迴響仍列在封存項目。它沒有取得出口；那些組成它的記憶，仍等著有人逐一確認歸屬。"
			},
			{
				"speaker": "narrator", "requires_decisions": {"resolved_ending": "ending_c_memory_rebirth"},
				"text": "最後一份是記憶恢復前留下的同意紀錄。你讀了兩遍，把它與現在的日期放在一起。你能查到當時答應了什麼，卻仍需要決定今天要怎麼生活。"
			},
			{
				"speaker": "narrator", "text": "你把訊息留在原處，沒有勾選『全部處理完畢』。窗外雨聲漸小，走廊有人收起了傘。",
				"set_flag": "epilogue_contacts_read", "next": "end"
			}
		],

		"ch2_ghost_trace": [
			{
				"speaker": "narrator",
				"text": "你把受害者名單的採樣時間，放在下水道終端的通行紀錄旁。同一個編號，在幽靈接受提取時，出現在另一棟樓。"
			},
			{
				"speaker": "ghost",
				"text": "那天我被固定在椅子上。可他們拿我的名字上班、領薪，還替別人開門。你打算證明哪一件事？",
				"mood": "revealed",
				"choices": [
					{
						"text": "同一時間出現在兩地，先查身份是否被轉用。",
						"next": "trace_verify"
					},
					{
						"text": "有他的編號，就能證明他親自運送受害者。",
						"next": "trace_wrong"
					},
					{
						"text": "先保留疑問，稍後回查。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "編號只證明系統接受了這個身份。名單上的提取時間，反而與現場出勤矛盾。要指認一個人，還缺少獨立紀錄。",
				"label": "trace_wrong",
				"choices": [
					{
						"text": "回到時間與終端紀錄交叉核對。",
						"next": "trace_verify"
					},
					{
						"text": "先離開。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "你核對兩台終端各自簽署的時間摘要，保留來源與矛盾。這能證明身份被重複使用，還不能辨認使用者。",
				"label": "trace_verify",
				"give_evidence": "ghost_identity_trace",
				"set_flag": "ghost_trace_verified"
			},
			{
				"speaker": "ghost",
				"text": "別再把那串數字當成我。身份的事說定後，再回來一次；我要知道你拿它做了什麼。",
				"next": "end",
				"mood": "cautious"
			}
		],

		"ch2_ghost_followup": [
			{
				"speaker": "narrator",
				"text": "通風管裡傳出兩下敲擊。幽靈沒有出現，只把一條離線線路接到你的終端。"
			},
			{
				"speaker": "ghost",
				"text": "你沒有把名字送出去。退役貨梯旁還有一道維修門，我能從裡面替你接通一次。要核對暗號，不能把鑰匙交給別人。",
				"mood": "cautious",
				"requires_decisions": {
					"ghost_identity_choice": "protect"
				}
			},
			{
				"speaker": "ghost",
				"text": "市場剛更新了我的藏身處。你換來的企業身份還能開門。若要我搭線，把那份通行資格作廢，把註銷回執留下。身份已經外流，這只能少開一扇追我的門。",
				"mood": "hostile",
				"requires_decisions": {
					"ghost_identity_choice": "expose"
				}
			},
			{
				"speaker": "narrator",
				"text": "你選擇如何回應這通電話。",
				"choices": [
					{
						"text": "接受一次接應，保留匿名聯繫。",
						"next": "followup_protect",
						"requires_decisions": {
							"ghost_identity_choice": "protect"
						},
						"set_decision": {
							"ghost_followup_choice": "protected"
						},
						"set_flags": [
							"ghost_followup_resolved",
							"ghost_relay_ready"
						],
						"give_evidence": "ghost_relay_token"
					},
					{
						"text": "註銷企業捷徑，保留交易證據，請求有限接應。",
						"next": "followup_repair",
						"requires_decisions": {
							"ghost_identity_choice": "expose"
						},
						"set_decision": {
							"ghost_followup_choice": "repaired"
						},
						"set_flags": [
							"ghost_followup_resolved",
							"ghost_repaired",
							"ghost_relay_ready"
						],
						"give_evidence": "ghost_relay_token"
					},
					{
						"text": "保留企業捷徑，接受失去他的接應。",
						"next": "followup_refuse",
						"requires_decisions": {
							"ghost_identity_choice": "expose"
						},
						"set_decision": {
							"ghost_followup_choice": "refused"
						},
						"set_flag": "ghost_followup_resolved"
					},
					{
						"text": "還沒決定，先離開。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "ghost",
				"text": "把接應器的脈衝對上維修排程。我會替你開門，也會替被你帶出來的人留一道出口。我的名字不在裡面。",
				"next": "end",
				"mood": "cautious",
				"label": "followup_protect"
			},
			{
				"speaker": "ghost",
				"text": "註銷回執收到了。我只接這一次，不替你作證，也不告訴你新住址。別把這把接應器寫成我原諒了你。",
				"next": "end",
				"mood": "hostile",
				"label": "followup_repair"
			},
			{
				"speaker": "ghost",
				"text": "那就別再敲這條管子。你留下了通行資格，沒有留下等你的人。",
				"next": "end",
				"mood": "hostile",
				"label": "followup_refuse"
			}
		],

		"ch3_hq_entry": [
			{
				"speaker": "narrator",
				"text": "地下第十層，退役資料中心的前室。真正的內門仍然上鎖。你帶來的線索，決定了哪一種敲門方式會得到回應。"
			},
			{
				"speaker": "narrator",
				"text": "選擇進入方式。",
				"choices": [
					{
						"text": "插入幽靈的離線接應器，核對維修暗號。",
						"next": "entry_ghost",
						"requires_flag": "ghost_relay_ready",
						"requires_evidence": "ghost_relay_token"
					},
					{
						"text": "使用身份交易留下的企業通行紀錄。",
						"next": "entry_corporate",
						"requires_flag": "ghost_identity_exposed",
						"requires_missing_flags": [
							"ghost_repaired"
						]
					},
					{
						"text": "自行比對倉庫排程與前室維修表。",
						"next": "entry_independent"
					},
					{
						"text": "先留在前室整理證據。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "ghost",
				"text": "接應器閃兩次短光。排程寫著「三號門，排水停機後開啟」。你要回送哪個訊號？",
				"mood": "cautious",
				"label": "entry_ghost",
				"choices": [
					{
						"text": "三號門，等待排水指示熄滅。",
						"next": "entry_ghost_ok"
					},
					{
						"text": "直接重播上一班貨梯的通行訊號。",
						"next": "entry_ghost_wrong"
					}
				],
				"next": "end"
			},
			{
				"speaker": "ghost",
				"text": "舊訊號會把你送到監控門。我還在這頭，重對一次。",
				"mood": "hostile",
				"label": "entry_ghost_wrong",
				"choices": [
					{
						"text": "核對三號門與排水燈。",
						"next": "entry_ghost_ok"
					},
					{
						"text": "先拔下接應器。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "三號維修門開了。幽靈還能守一次撤離或原件傳輸窗口。進去後可在總部安排；另一件事由你自己核對。這條線不攜帶任何人的證詞。",
				"next": "end",
				"label": "entry_ghost_ok",
				"set_flag": "hq_entry_resolved",
				"set_decision": {
					"hq_entry_route": "ghost"
				}
			},
			{
				"speaker": "narrator",
				"text": "通行紀錄使用的是被轉售的身份。系統會保留本次出勤；你可以進去，但不能再聲稱沒有使用過它。",
				"label": "entry_corporate",
				"choices": [
					{
						"text": "確認留下使用紀錄，開啟企業內門。",
						"next": "entry_corporate_ok"
					},
					{
						"text": "不用這個身份，改查維修表。",
						"next": "entry_independent"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "內門放行，螢幕多出一筆冒用身份的出勤。你保存原始回執，日後公開案件時也必須交代這一筆。",
				"next": "end",
				"label": "entry_corporate_ok",
				"set_flag": "hq_entry_resolved",
				"set_decision": {
					"hq_entry_route": "corporate"
				}
			},
			{
				"speaker": "narrator",
				"text": "倉庫日記記著三號排水泵停機。前室維修表則把同一時段標成無人檢修；一般貨梯仍在上傳乘員資訊。",
				"label": "entry_independent",
				"choices": [
					{
						"text": "比對停機時段，使用三號維修入口。",
						"next": "entry_independent_ok"
					},
					{
						"text": "貨梯能動，直接搭貨梯下去。",
						"next": "entry_independent_wrong"
					},
					{
						"text": "稍後再核對。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "貨梯顯示需要有效企業身份。能運作不代表無人監控。你退回前室，維修表仍在。",
				"label": "entry_independent_wrong",
				"choices": [
					{
						"text": "重新比對排水泵的停機時段。",
						"next": "entry_independent_ok"
					},
					{
						"text": "暫時離開面板。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "你把兩份時刻記在紙上，等到排水燈熄滅才開門。沒有人替你守著回程，你得自己記住出口。",
				"next": "end",
				"label": "entry_independent_ok",
				"set_flag": "hq_entry_resolved",
				"set_decision": {
					"hq_entry_route": "independent"
				}
			}
		],

		"ch3_verify_public_sources": [
			{
				"speaker": "zhao_ming",
				"text": "光靠帳本還不夠。我把另外保管的稽核紀錄調出來了：授權摘要、付款批次，還有設備簽署時間。拿原件一筆一筆對。",
				"mood": "determined"
			},
			{
				"speaker": "narrator",
				"text": "你要用哪種方式確認這三份核心證據？",
				"choices": [
					{
						"text": "用市場帳本的說法，替三份文件背書。",
						"next": "sources_wrong"
					},
					{
						"text": "逐筆核對授權、付款與設備時間，再封存來源。",
						"next": "sources_verified"
					},
					{
						"text": "先回查資料。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "zhao_ming",
				"text": "這樣只是讓同一個來源重複說三次。先拿帳本的批次當索引。再核對獨立保管的授權、付款及設備紀錄。這樣才知道哪裡對不上。",
				"mood": "conflicted",
				"label": "sources_wrong",
				"choices": [
					{
						"text": "改用獨立稽核紀錄逐筆核對。",
						"next": "sources_verified"
					},
					{
						"text": "先離開。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "zhao_ming",
				"text": "三份原件的時間與批次相互對上。你保留核驗方式與原件位置，市場帳本只列作調查起點。幽靈若拒絕作證，這條文件鏈也不需要冒用他的同意。",
				"next": "end",
				"mood": "sincere",
				"label": "sources_verified",
				"set_flag": "public_sources_verified"
			}
		],

		"ch3_review_public_record": [
			{"speaker": "narrator", "text": "目前需要列入的行動紀錄：", "show_public_record": true},
			{
				"speaker": "zhao_ming",
				"text": "送出之前，先把你的行動也放進紀錄。交給蛇女的副本、購買或侵入的資料、身份使用、私人記憶外流，都不能藏在結案報告背後。",
				"mood": "determined"
			},
			{
				"speaker": "zhao_ming",
				"text": "這份紀錄會包含對你不利的部分。補救與後悔不會撤銷原始交易；你仍能揭露企業，但也要接受被追問。",
				"mood": "conflicted",
				"requires_public_liability": true
			},
			{
				"speaker": "zhao_ming",
				"text": "目前沒有需要補列的交易與資料外流。保留來源、署名與交接責任；合作也不是免於追問的保證。",
				"mood": "sincere",
				"requires_public_liability": false
			},
			{
				"speaker": "narrator",
				"text": "確認本次紀錄。若之後又改變迴響或資料的處置，送出前必須回來更新。",
				"choices": [
					{
						"text": "如實列入全部行動，確認最新紀錄。",
						"next": "record_confirm"
					},
					{
						"text": "暫不簽署，先返回調查。",
						"next": "end"
					}
				],
				"next": "end"
			},
			{
				"speaker": "narrator",
				"text": "紀錄保留了這一刻的行動清單。原件核驗與自我交代都完成後，才能在屋頂選擇公開。",
				"next": "end",
				"label": "record_confirm",
				"review_public_record": true
			}
		],

		# --- Endings ---
		"ending_a_justice": [
			{"speaker": "narrator", "text": "市政端的錯誤轉介已暫停，人工受理留下可追查的簽收。案件公開之後，調查人員開始核對其他被退回的撤回申請。", "requires_decisions": {"archive_route": "frozen"}},
			{"speaker": "narrator", "text": "沒有真人資料的測試代碼，將調查帶到實驗室覆核站。市政窗口已改成人工受理；接收站的管理責任成為後續調查的一部分。", "requires_decisions": {"archive_route": "observed"}},
			{"speaker": "narrator", "text": "蕭博士的供述與三段時間紀錄被一併提交。它沒有取代核心原件，也沒有讓其他管理者免於說明。", "requires_decisions": {"xiao_accountability": "admitted"}},
			{"speaker": "narrator", "requires_flag": "ghost_repaired", "text": "幽靈確認維修門已關閉，卻拒絕加入舉報。他提供過有限接應，沒有撤回你出賣身份的紀錄。"},
			{"speaker": "narrator", "text": "你與趙明把封存原件放入離線保管箱，公開副本另行交接。", "show_cg": "cg_public_evidence_handover", "sfx": "res://assets/audio/sfx/handover_confirm.ogg"},
			{"speaker": "narrator", "text": "【正義之光・共同作證】趙明在你旁邊簽名。來源與交接都有各自負責的人；沒有人替另一個人承諾免於追責。", "requires_public_liability": false},
			{"speaker": "narrator", "text": "【正義之光・帶罪揭露】你把自己的交易與資料處置一併交出。調查者收下企業罪證，也約了下一次向你詢問的時間。", "requires_public_liability": true},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "趙明送出署名舉報包。媒體收到遮蔽受害者私密內容的副本，調查者則能核驗封存原件。你們各自的行動紀錄也附在後面。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "授權、付款與技術報告彼此印證。蕭博士被拘捕，正和科技無法再把一切推給地下承包商。回聲網路的核心節點被查封，追查仍在繼續。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flag": "ghost_protected",
				"text": "幽靈的匿名證詞留在紀錄中，身份沒有出現在新聞上。他只傳回一句話：「這次，名字還是我的。」"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flag": "ghost_identity_exposed", "requires_missing_flags": ["ghost_repaired"],
				"text": "幽靈的頻道一直沒有再開。公開真相沒有替你抹去那筆身份交易，也不能保證他已經找到新的藏身處。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left", "requires_flag": "released_echo_ai",
				"text": "舉報副本有了遮蔽，先前被你釋放的原始記憶卻仍在外部流傳。揭發企業，沒有取消受害者向你追問同意的權利。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然回到了美玲身邊。復健的日子還長，她在行事曆上記下了下一次回診的時間。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "雨還在下。但今晚的霓虹燈，看起來比往常明亮了一些。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "[結局A — 正義之光]\n\n回到偵探辦公室，與美玲和浩然見面。"
			}
		],

		"ending_b_grey_deal": [
			{"speaker": "narrator", "text": "回診室裡，浩然把預約單折成四折，壓在水杯下面。美玲問他冷不冷，他搖頭，自己把椅子挪離出風口。", "show_cg": "cg_ending_b_care", "sfx": "res://assets/audio/sfx/handover_confirm.ogg"},
			{"speaker": "hao_ran", "requires_decisions": {"grey_care_terms": "independent"}, "text": "下次能換近一點的地方嗎？我不想每回都讓她請假。"},
			{"speaker": "mei_ling", "requires_decisions": {"grey_care_terms": "independent"}, "text": "能。我明天問那間診所。費用照回執走，你先把水喝了。"},
			{"speaker": "narrator", "requires_decisions": {"grey_care_terms": "corporate"}, "text": "美玲想換一個較近的回診點。櫃檯把預約單推回來，指著指定窗口那一欄。她收起單子，重新翻自己的班表。"},
			{"speaker": "narrator", "text": "浩然等到下一班轉運，帶走一式三份的紙本交接。回診如何付費仍受你談定的交易條款約束，交接方式本身沒有買來自由。", "requires_decisions": {"recovery_channel": "paper"}},
			{"speaker": "narrator", "text": "指定醫師收到浩然逐項同意的接收資料，承包商沒有列在收件者內。這次傳送完成即移除路由，後續照護仍須重新取得同意。", "requires_decisions": {"recovery_channel": "direct"}},
			{"speaker": "narrator", "requires_decisions": {"market_claim_resolution": "pledge", "memory_trade_method": "refuse"}, "text": "市場給的優先預約派上用場，浩然較早排到企業承包的照護。你沒有欠過那筆樣本債，這是拿他人的聯絡路由換來的新交易。"},
			{"speaker": "narrator", "requires_decisions": {"market_claim_resolution": "pledge", "memory_trade_method": "intrude"}, "text": "你用路由換來的優先預約已排入照護。入侵留下的裝置識別仍未消失；一份新合約不能清掉上一條追蹤線。"},
			{"speaker": "narrator", "requires_decisions": {"grey_care_terms": "independent"}, "text": "你把限制追討的回執附進交易。第三方接手照護經費，浩然能在指定企業之外回診。你守住了這個出口，仍付出沉默與核心證據的代價。"},
			{"speaker": "narrator", "requires_decisions": {"grey_care_terms": "corporate"}, "text": "企業指定了浩然的回診窗口。補助已撥下，聯絡限制也一同生效。你換到撤離與照護，卻留下企業能持續施力的入口。"},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "浩然已經離開維持椅。你仍選擇用沉默和核心證據換取後續照護、撤離保障與離開九龍延伸區的錢。救援是真實的，交易也是真實的。"
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
				"text": "[結局B — 灰色交易]\n\n回到偵探辦公室，與美玲和浩然見面。"
			}
		],

		"ending_c_memory_rebirth": [
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你選擇讓迴響恢復舊記憶。被剪開的片段重新連接：你曾調查正和科技，也被列為記憶覆寫技術的早期成功案例。「揭發腐敗後離職」只是留下來的那一層說法。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "你想起自己曾參與維護蕭博士的原型，也曾調查它。測試紀錄把你的角色寫成成功案例，卻剪掉了撤回同意的片段。恢復記憶沒有替參與過的傷害開脫，也沒有讓被覆寫變得合理。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "記憶如潮水般湧回。工程室、調查室、測試椅交疊在一起。成為偵探後的記憶——接下美玲的委託、在雨中奔走、在深淵酒吧的夜晚——卻像沙子一樣從指間滑落。"
			},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"show_cg": "cg_ending_c_awakening",
				"text": "你睜開眼睛，無法再確定那些偵探時期的經歷是否屬於自己。浩然已安全撤離，罪證與你的兩次同意仍留在離線紀錄中。它們不能替醒來的人回答自己是誰。"
			},
			{"speaker": "narrator", "text": "醒來後，你面前多了一份能逐項核對的生活紀錄。美玲圈出自己在場的部分，別人的轉述另列；空白仍是空白。你可以不相信它，再從來源開始問。", "requires_decisions": {"continuity_record": "shared"}},
			{"speaker": "mei_ling", "text": "我不會要求你照著這本子演回原來的樣子。今天你想知道哪一件，我們就從那一件開始。", "requires_decisions": {"continuity_record": "shared"}},
			{"speaker": "narrator", "text": "桌邊留著一封寫給自己的密封信。你認得筆跡，卻不確定認不認得寫信的人；要不要拆開，由現在的你決定。案件原件另存，沒有和私信綁在一起。", "requires_decisions": {"continuity_record": "private"}},
			{
				"speaker": "narrator", "name": "", "portrait_side": "left",
				"text": "美玲把水放在你伸手能碰到的地方，沒有替你拿起來。你問她的名字。她答了，又把椅子拉近一點。"
			},
			{
				"speaker": "narrator",
				"text": "[結局C — 記憶重生]\n\n回到偵探辦公室，與美玲和浩然見面。"
			}
		],
	}
