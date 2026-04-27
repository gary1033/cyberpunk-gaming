#!/usr/bin/env python3
"""
NEON MEMORIES - Story Progression Score

Scores how much of the written Chapter 1/2/3 story content is mechanically
reachable from CaseData. The score is the autoresearch metric: higher is better.
Structural errors still fail the command; missing reachability lowers the score.
"""

import argparse
import os
import re
import sys


PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EXPECTED_LOCATION_DIALOGUES = {
    "detective_office": ["ch1_mei_ling_intro"],
    "mei_ling_apartment": ["ch1_kai_eye_glitch_scan"],
    "hao_ran_workshop": ["ch1_workshop_enter", "ch1_eye_signature_decode", "ch1_dr_chen_eye_warning"],
    "bitstorm_cafe": ["ch2_opening", "ch2_kid_encounter"],
    "memory_black_market": ["ch2_memory_market_enter", "ch2_ghost_encounter"],
    "abandoned_warehouse": ["ch2_warehouse_explore"],
    "zhengtek_exterior": ["ch2_zhao_ming_meeting"],
    "echo_network_hq": ["ch3_opening"],
    "secret_lab": ["ch3_dr_xiao_confrontation", "ch3_hao_ran_found", "ch3_echo_ai"],
    "memory_space": ["ch3_echo_ai"],
    "rooftop": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"],
    "office_epilogue": ["ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"],
}

CHAPTER_STARTS = {
    1: "detective_office",
    2: "bitstorm_cafe",
    3: "echo_network_hq",
}

CHAPTER_DIALOGUE_PREFIXES = ("ch1_", "ch2_", "ch3_", "ending_")


def read_file(rel_path):
    with open(os.path.join(PROJECT_ROOT, rel_path), "r", encoding="utf-8") as f:
        return f.read()


def find_matching(text, start, opener, closer):
    depth = 0
    in_string = False
    escaped = False
    for index in range(start, len(text)):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char == opener:
            depth += 1
        elif char == closer:
            depth -= 1
            if depth == 0:
                return index
    return -1


def extract_braced_block(text, key):
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\{{', text)
    if not match:
        return ""
    start = text.find("{", match.start())
    end = find_matching(text, start, "{", "}")
    if end == -1:
        return ""
    return text[start : end + 1]


def extract_array_block(text, key):
    match = re.search(rf'"{re.escape(key)}"\s*:\s*\[', text)
    if not match:
        return ""
    start = text.find("[", match.start())
    end = find_matching(text, start, "[", "]")
    if end == -1:
        return ""
    return text[start : end + 1]


def extract_location_block(case_content, location_id):
    return extract_braced_block(case_content, location_id)


def extract_chapter_block(case_content, chapter):
    # Bug regression: CaseData uses numeric chapter keys (2: {...}), not
    # quoted dictionary keys, so chapter scoring must parse that shape too.
    match = re.search(rf'^\s*{chapter}\s*:\s*\{{', case_content, re.MULTILINE)
    if not match:
        return ""
    start = case_content.find("{", match.start())
    end = find_matching(case_content, start, "{", "}")
    if end == -1:
        return ""
    return case_content[start : end + 1]


def extract_top_level_ids(content, prefix_pattern):
    return set(re.findall(rf'^\s*"({prefix_pattern}[^"]+)"\s*:\s*\[', content, re.MULTILINE))


def extract_evidence_ids(evidence_content):
    return set(re.findall(r'^\s*"(\w+)"\s*:\s*\{', evidence_content, re.MULTILINE))


def extract_story_actions(location_block):
    actions_block = extract_array_block(location_block, "story_actions")
    if not actions_block:
        return []
    actions = []
    index = 0
    while index < len(actions_block):
        start = actions_block.find("{", index)
        if start == -1:
            break
        end = find_matching(actions_block, start, "{", "}")
        if end == -1:
            break
        actions.append(actions_block[start : end + 1])
        index = end + 1
    return actions


def collect_dialogue_effects(dialogue_content):
    flags = set(re.findall(r'"set_flag"\s*:\s*"(\w+)"', dialogue_content))
    evidence = set(re.findall(r'"give_evidence"\s*:\s*"(\w+)"', dialogue_content))
    return flags, evidence


def collect_board_effects(board_content):
    flags = set()
    section = re.search(r'valid_connection_flags\s*:\s*Dictionary\s*=\s*\{(.*?)\}', board_content, re.DOTALL)
    if section:
        flags.update(re.findall(r'"\w+:\w+"\s*:\s*"(\w+)"', section.group(1)))
    return flags


def strip_story_actions(location_block):
    actions_block = extract_array_block(location_block, "story_actions")
    if not actions_block:
        return location_block
    return location_block.replace(actions_block, "")


def score_progression(case_content, dialogue_content, evidence_content, board_content):
    dialogue_ids = extract_top_level_ids(dialogue_content, r"(?:ch\d+|ending)_")
    evidence_ids = extract_evidence_ids(evidence_content)
    produced_flags, produced_evidence = collect_dialogue_effects(dialogue_content)
    produced_flags.update(collect_board_effects(board_content))
    reachable_dialogues = set()
    failures = []
    details = []
    score = 0

    for chapter, start_location in CHAPTER_STARTS.items():
        chapter_block = extract_chapter_block(case_content, chapter)
        if f'"starting_location": "{start_location}"' in chapter_block:
            score += 10
            details.append(f"chapter {chapter} starts at {start_location}: +10")
        else:
            details.append(f"chapter {chapter} start location not wired: +0")

    for location_id, expected_dialogues in EXPECTED_LOCATION_DIALOGUES.items():
        location_block = extract_location_block(case_content, location_id)
        if not location_block:
            details.append(f"{location_id} missing from CaseData: +0")
            continue

        initial_match = re.search(r'"initial_dialogue"\s*:\s*"(\w+)"', location_block)
        if initial_match:
            initial_dialogue = initial_match.group(1)
            reachable_dialogues.add(initial_dialogue)
            if initial_dialogue in dialogue_ids:
                score += 6
                details.append(f"{location_id} has initial_dialogue {initial_dialogue}: +6")
            else:
                failures.append(f"{location_id} initial_dialogue missing in DialogueData: {initial_dialogue}")
        else:
            details.append(f"{location_id} has no initial_dialogue: +0")

        actions = extract_story_actions(location_block)
        seen_action_ids = set()
        if actions:
            score += min(len(actions), 4) * 4
            details.append(f"{location_id} has {len(actions)} story action(s): +{min(len(actions), 4) * 4}")
        for action in actions:
            action_id = re.search(r'"id"\s*:\s*"(\w+)"', action)
            if action_id:
                if action_id.group(1) in seen_action_ids:
                    failures.append(f"{location_id} duplicate story action id: {action_id.group(1)}")
                seen_action_ids.add(action_id.group(1))

            dialogue_match = re.search(r'"dialogue"\s*:\s*"(\w+)"', action)
            if dialogue_match:
                dialogue_id = dialogue_match.group(1)
                reachable_dialogues.add(dialogue_id)
                if dialogue_id not in dialogue_ids:
                    failures.append(f"{location_id} story action references missing dialogue: {dialogue_id}")

            ending_dialogues = re.findall(r'"(ending_\w+)"', extract_array_block(action, "ending_dialogues"))
            if '"use_calculated_ending": true' in action and not ending_dialogues:
                failures.append(f"{location_id} calculated ending action must list ending_dialogues")
            for dialogue_id in ending_dialogues:
                reachable_dialogues.add(dialogue_id)
                if dialogue_id not in dialogue_ids:
                    failures.append(f"{location_id} ending action references missing dialogue: {dialogue_id}")

            for evidence_id in re.findall(r'"requires_evidence"\s*:\s*"(\w+)"', action):
                if evidence_id not in evidence_ids:
                    failures.append(f"{location_id} story action requires missing evidence: {evidence_id}")

            for flag in re.findall(r'"requires_flag"\s*:\s*"(\w+)"', action):
                if flag not in produced_flags:
                    failures.append(f"{location_id} story action requires missing flag producer: {flag}")

            for evidence_id in re.findall(r'"give_evidence"\s*:\s*"(\w+)"', action):
                if evidence_id not in evidence_ids:
                    failures.append(f"{location_id} story action gives missing evidence: {evidence_id}")
                produced_evidence.add(evidence_id)

            for flag in re.findall(r'"set_flag"\s*:\s*"(\w+)"', action):
                produced_flags.add(flag)

        for dialogue_id in expected_dialogues:
            if dialogue_id in reachable_dialogues:
                score += 8
                details.append(f"{dialogue_id} reachable from {location_id}: +8")
            else:
                details.append(f"{dialogue_id} not reachable from {location_id}: +0")

        location_shell = strip_story_actions(location_block)
        requires_flag = re.search(r'"requires_flag"\s*:\s*"(\w+)"', location_shell)
        if requires_flag:
            flag = requires_flag.group(1)
            if flag in produced_flags:
                score += 6
                details.append(f"{location_id} gate flag {flag} is produced: +6")
            else:
                details.append(f"{location_id} gate flag {flag} has no producer: +0")
        else:
            score += 3
            details.append(f"{location_id} has no flag gate: +3")

    all_story_dialogues = {
        dialogue_id
        for dialogue_id in dialogue_ids
        if dialogue_id.startswith(CHAPTER_DIALOGUE_PREFIXES)
    }
    for dialogue_id in sorted(all_story_dialogues):
        if dialogue_id in reachable_dialogues:
            score += 3
        else:
            details.append(f"unreachable written dialogue: {dialogue_id}: +0")

    if "has_fake_id" in produced_flags and "fake_id_chip" in produced_evidence:
        score += 8
        details.append("fake ID evidence also unlocks market flag: +8")
    else:
        details.append("fake ID evidence does not yet unlock market flag: +0")

    if {"ending_a_justice", "ending_b_grey_deal", "ending_c_memory_rebirth"}.issubset(reachable_dialogues):
        score += 12
        details.append("all endings have a reachable location hook: +12")
    else:
        details.append("not all endings have reachable location hooks: +0")

    return score, failures, details


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--score", action="store_true", help="print parseable score line")
    parser.add_argument("--details", action="store_true", help="print scoring detail")
    args = parser.parse_args()

    case_content = read_file("scripts/data/case_data.gd")
    dialogue_content = read_file("scripts/data/dialogue_data.gd")
    evidence_content = read_file("scripts/data/evidence_data.gd")
    board_content = read_file("scripts/gameplay/evidence_board.gd")

    score, failures, details = score_progression(case_content, dialogue_content, evidence_content, board_content)

    print("NEON MEMORIES Story Progression")
    print(f"PROGRESS_SCORE={score}")

    if args.details:
        for detail in details:
            print(f"  - {detail}")

    if failures:
        for failure in failures:
            print(f"[FAIL] {failure}")
        return 1

    if not args.score and not args.details:
        print("Use --details to inspect missing progression coverage.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
