import json
import random
from pathlib import Path

random.seed(51)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-PVD-PAD-DVT-100.sql')
CATEGORY = 'PVD PAD DVT - NCLEX'
TOPIC_NAME = 'PVD / PAD / DVT'

concepts = [
    {
        'name': 'PVD umbrella concept',
        'fact': 'Peripheral vascular disease is an umbrella term that includes arterial and/or venous disorders.',
        'priority': 'Differentiate arterial from venous findings before intervention.',
        'true': ['PVD can involve arteries and veins.', 'PAD is within broader PVD category.', 'Venous disease can also fall under PVD.'],
        'false': ['PVD includes only pulmonary vessels in this note.', 'PVD excludes venous disease in this note.']
    },
    {
        'name': 'PAD definition',
        'fact': 'Peripheral arterial disease is arterial narrowing from atherosclerosis causing reduced blood flow.',
        'priority': 'Recognize ischemic limb signs and perfusion threats early.',
        'true': ['PAD is arterial only in this note.', 'Atherosclerosis is core mechanism in PAD.', 'Reduced distal flow causes ischemic symptoms.'],
        'false': ['PAD is venous valve failure in this note.', 'PAD is caused by pulmonary emboli in this note.']
    },
    {
        'name': 'DVT definition',
        'fact': 'Deep vein thrombosis is thrombus formation in deep veins, usually leg, with pulmonary embolism risk.',
        'priority': 'Prevent embolization and monitor for PE deterioration.',
        'true': ['DVT usually occurs in deep leg veins.', 'Thrombus embolization can cause PE.', 'DVT is venous clot disease.'],
        'false': ['DVT is primarily arterial plaque rupture in this note.', 'DVT has no embolic risk in this note.']
    },
    {
        'name': 'Venous insufficiency signs',
        'fact': 'Venous insufficiency signs include varicosities, edema, brown hemosiderin skin changes, warm moist skin, and pulses present.',
        'priority': 'Use skin temperature/pulse pattern to separate venous from arterial disease.',
        'true': ['Brown pigmentation is venous finding.', 'Pulses are generally present in venous insufficiency.', 'Warm moist skin suggests venous disease.'],
        'false': ['Absent pulses are hallmark venous insufficiency sign in this note.', 'Cool hairless skin is classic venous profile in this note.']
    },
    {
        'name': 'Venous stasis ulcer profile',
        'fact': 'Venous ulcers are usually at medial malleolus, irregular edges, and often painless.',
        'priority': 'Correct ulcer classification guides positioning and wound strategy.',
        'true': ['Medial malleolus location suggests venous ulcer.', 'Venous ulcer edges are irregular/ragged.', 'Venous ulcer pain is often mild or absent.'],
        'false': ['Venous ulcers are punched-out lateral toe lesions in this note.', 'Venous ulcers are always severe pain in this note.']
    },
    {
        'name': 'PAD symptom hallmark',
        'fact': 'Intermittent claudication is leg pain with walking relieved by rest; advanced disease may cause rest pain.',
        'priority': 'Progression from exertional pain to rest pain signals worsening ischemia.',
        'true': ['Claudication appears with activity in PAD.', 'Rest relieves claudication in earlier PAD.', 'Rest pain indicates advanced disease in note.'],
        'false': ['PAD pain improves with walking in this note.', 'PAD never causes rest pain in this note.']
    },
    {
        'name': 'ABI threshold',
        'fact': 'Ankle-brachial index below 0.9 supports PAD diagnosis.',
        'priority': 'Use ABI to quantify arterial perfusion deficit objectively.',
        'true': ['ABI <0.9 is abnormal for PAD in note.', 'ABI compares ankle and brachial pressures.', 'ABI is listed PAD assessment tool.'],
        'false': ['ABI >1.5 confirms PAD in this note.', 'ABI is not used for PAD in this note.']
    },
    {
        'name': '6 Ps arterial emergency',
        'fact': 'Acute arterial occlusion signs are pain, pallor, pulselessness, paresthesia, poikilothermia, and paralysis.',
        'priority': 'Treat 6 Ps as limb-threatening emergency requiring immediate escalation.',
        'true': ['Pain and pallor are in 6 Ps.', 'Pulselessness and paresthesia are in 6 Ps.', 'Poikilothermia and paralysis are in 6 Ps.'],
        'false': ['Pitting edema replaces pulselessness in 6 Ps in this note.', '6 Ps indicate stable chronic venous disease in this note.']
    },
    {
        'name': 'Buerger-Allen test',
        'fact': 'In Buerger-Allen test, leg elevation causing pallor then dependent rubor supports PAD.',
        'priority': 'Interpret positional color changes as arterial insufficiency evidence.',
        'true': ['Elevation pallor is PAD clue in this test.', 'Dependent rubor supports PAD in this test.', 'Test is listed under PAD assessment.'],
        'false': ['Buerger test confirms DVT in this note.', 'No color change is required for positive test in this note.']
    },
    {
        'name': 'PAD management essentials',
        'fact': 'PAD management includes smoking cessation priority, antiplatelets, supervised walking, revascularization, and dependent leg positioning.',
        'priority': 'Combine risk modification and perfusion restoration interventions.',
        'true': ['Smoking cessation is absolute priority in PAD note.', 'Aspirin/clopidogrel are listed PAD meds.', 'Legs dependent can improve arterial flow.'],
        'false': ['PAD legs should always be elevated high in this note.', 'Smoking has no effect on PAD outcomes in this note.']
    },
    {
        'name': 'Virchow triad overview',
        'fact': 'DVT causes follow Virchow triad: stasis, hypercoagulability, and endothelial injury.',
        'priority': 'Identify which triad component is present to target prevention.',
        'true': ['Stasis is a Virchow component.', 'Hypercoagulability is a Virchow component.', 'Endothelial damage is a Virchow component.'],
        'false': ['Hypothermia is a Virchow component in this note.', 'Virchow triad applies only to arterial disease in this note.']
    },
    {
        'name': 'Stasis examples',
        'fact': 'Stasis examples listed include immobility, long flights, and post-op state.',
        'priority': 'Early mobilization plans reduce stasis-driven thrombosis risk.',
        'true': ['Immobility is stasis risk in note.', 'Long flights are stasis risk in note.', 'Post-op state can contribute to stasis.'],
        'false': ['Frequent ambulation is stasis cause in this note.', 'Stasis is unrelated to DVT in this note.']
    },
    {
        'name': 'Hypercoagulability examples',
        'fact': 'Hypercoagulability risks listed include oral contraceptives, cancer, and clotting disorders.',
        'priority': 'Screen thrombosis history and prothrombotic exposures carefully.',
        'true': ['Oral contraceptives are listed hypercoagulability risk.', 'Cancer is listed hypercoagulability risk.', 'Inherited/acquired clotting disorders are listed.'],
        'false': ['Cancer lowers DVT risk in this note.', 'Hypercoagulability excludes medication effects in this note.']
    },
    {
        'name': 'Endothelial injury examples',
        'fact': 'Endothelial injury examples include trauma, surgery, and catheters.',
        'priority': 'Protect vessel integrity and monitor post-procedural patients.',
        'true': ['Trauma is endothelial injury risk.', 'Surgery is endothelial injury risk.', 'Catheter-related injury is listed risk.'],
        'false': ['Intact endothelium is risk factor in this note.', 'Only diet causes endothelial injury in this note.']
    },
    {
        'name': 'DVT signs',
        'fact': 'DVT signs include unilateral calf pain/tenderness, unilateral edema, warmth, redness, and possible low-grade fever.',
        'priority': 'Unilateral inflammatory limb signs should trigger urgent DVT evaluation.',
        'true': ['Unilateral swelling is classic DVT clue.', 'Warmth/redness can occur in DVT.', 'Low-grade fever may be present.'],
        'false': ['Bilateral cool pale legs are hallmark DVT sign in this note.', 'DVT typically causes absent pulses as first sign in this note.']
    },
    {
        'name': 'Homans sign caution',
        'fact': 'Homans sign is noted as unreliable and rarely tested now.',
        'priority': 'Rely on modern diagnostics rather than outdated bedside signs.',
        'true': ['Homans sign reliability is poor per note.', 'Homans is rarely tested now per note.', 'Do not overvalue Homans in diagnosis.'],
        'false': ['Homans sign is gold-standard DVT diagnosis in this note.', 'Homans is mandatory for all exams in this note.']
    },
    {
        'name': 'PE deterioration clue',
        'fact': 'DVT can embolize causing PE with sudden dyspnea, chest pain, hypoxia, and tachycardia.',
        'priority': 'Sudden respiratory decline in DVT patient is emergency PE suspicion.',
        'true': ['Sudden dyspnea can indicate PE in DVT patient.', 'Chest pain/hypoxia/tachycardia are PE clues.', 'Embolization risk is central DVT danger.'],
        'false': ['PE presents only with slow asymptomatic edema in this note.', 'PE risk is absent after DVT diagnosis in this note.']
    },
    {
        'name': 'DVT anticoagulation',
        'fact': 'DVT treatment starts with heparin acutely then warfarin or NOAC for 3–6 months.',
        'priority': 'Ensure transition from acute to maintenance anticoagulation safely.',
        'true': ['Heparin is acute DVT treatment in note.', 'Warfarin/NOAC are long-term options.', 'Duration listed is about 3–6 months.'],
        'false': ['DVT is treated with antiplatelet only in this note.', 'Anticoagulation is limited to one day in this note.']
    },
    {
        'name': 'DVT supportive care',
        'fact': 'Supportive care includes leg elevation above heart, compression stockings, and early ambulation once anticoagulated.',
        'priority': 'Balance clot stabilization with circulation/mobility support.',
        'true': ['Leg elevation above heart is listed.', 'Compression stockings are listed.', 'Early ambulation is advised after anticoagulation.'],
        'false': ['Strict indefinite bed rest is required in this note.', 'Leg dependency is preferred for DVT edema in this note.']
    },
    {
        'name': 'IVC filter indication',
        'fact': 'IVC filter is considered if anticoagulation is contraindicated.',
        'priority': 'Use mechanical embolic protection when anticoagulation cannot be used.',
        'true': ['IVC filter is alternative when anticoagulation contraindicated.', 'Indication is inability to anticoagulate safely.', 'Filter use is not first-line for all DVT patients.'],
        'false': ['IVC filter replaces anticoagulation in every case in this note.', 'IVC filters are only for arterial occlusion in this note.']
    },
    {
        'name': 'Arterial ulcer profile',
        'fact': 'Arterial ulcers are on toes/lateral malleolus/foot, very painful, punched-out, pale/necrotic, with diminished/absent pulses and cool hairless skin.',
        'priority': 'Identify ischemic ulcer features to prevent limb loss.',
        'true': ['Arterial ulcers are very painful.', 'Arterial ulcer edges are punched-out/well-defined.', 'Arterial pulses are diminished/absent in note.'],
        'false': ['Arterial ulcers are warm moist and painless in this note.', 'Arterial ulcers usually occur medial malleolus with pulses present in this note.']
    },
    {
        'name': 'Venous ulcer profile',
        'fact': 'Venous ulcers are medial malleolus, irregular/ragged, granulating/ruddy, warm edematous skin with pulses present.',
        'priority': 'Use venous profile to prioritize elevation and compression strategies.',
        'true': ['Medial malleolus location suggests venous ulcer.', 'Venous skin is warm and edematous.', 'Pulses are present in venous ulcer profile.'],
        'false': ['Venous ulcers have absent pulses and pale necrotic bed in this note.', 'Venous ulcers are lateral toe punched-out lesions in this note.']
    },
    {
        'name': 'Positioning contrast',
        'fact': 'Arterial disease benefits from dependent legs, while venous disease benefits from elevation to reduce pooling.',
        'priority': 'Correct positioning is immediate, high-yield bedside intervention.',
        'true': ['PAD legs dependent improves arterial flow in note.', 'Venous insufficiency legs elevated helps pooling.', 'Positioning differs by arterial vs venous pathology.'],
        'false': ['Both arterial and venous disease require identical positioning in this note.', 'PAD requires leg elevation above heart in this note.']
    },
    {
        'name': 'Key nursing NCLEX points',
        'fact': 'Do not massage suspected DVT leg, assess pulses pre/post interventions, prevent DVT with ambulation/compression/anticoagulation post-op, and treat 6 Ps as arterial emergency.',
        'priority': 'Avoid embolization and identify limb-threatening ischemia rapidly.',
        'true': ['Never massage suspected DVT limb.', 'Pulse assessment before/after intervention is emphasized.', '6 Ps require immediate provider notification.'],
        'false': ['Massaging DVT leg is recommended to improve flow in this note.', '6 Ps can be observed without escalation in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this vascular scenario?',
    'The nurse analyzes assessment data. Which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent triage, which conclusion aligns with {name}?',
    'Which statement most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For care involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans interventions for {name}. Which items belong in the plan? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which clues are consistent with {name} in this note? (Select all that apply)'
]


def option_objects(texts):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(texts)]


def esc(s: str) -> str:
    return s.replace("'", "''")


questions = []

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'])
    correct = c['fact'] if i % 2 == 0 else c['priority']

    distractors = c['false'] + [
        f'This pattern is more consistent with {concepts[(i + 6) % len(concepts)]["name"]}.',
        'Immediate escalation is unnecessary unless bilateral symptoms are present.',
        'Pulses do not need reassessment after vascular interventions.'
    ]
    random.shuffle(distractors)
    options = [correct] + distractors[:3]
    random.shuffle(options)

    questions.append({
        'stem': stem,
        'options': option_objects(options),
        'correct': [chr(97 + options.index(correct))],
        'rationale': f"Correct because {c['fact']} {c['priority']}",
        'is_multi': False
    })

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = sata_templates[i % len(sata_templates)].format(name=c['name'])

    t = c['true'][:]
    f = c['false'][:]
    random.shuffle(t)
    random.shuffle(f)
    opts = t[:3] + f[:2]
    random.shuffle(opts)

    questions.append({
        'stem': stem,
        'options': option_objects(opts),
        'correct': [chr(97 + idx) for idx, txt in enumerate(opts) if txt in t[:3]],
        'rationale': f"Correct selections align with note-based facts: {c['fact']}",
        'is_multi': True
    })

assert len(questions) == 100

END_IF_SQL = '  END IF;'
lines = [
    'BEGIN;',
    'DO $$',
    'DECLARE',
    '  v_subject_id UUID;',
    '  v_topic_id UUID;',
    '  v_test_id BIGINT;',
    'BEGIN',
    "  SELECT id INTO v_subject_id FROM test_subjects WHERE name ILIKE '%cardio%' ORDER BY id LIMIT 1;",
    '  IF v_subject_id IS NULL THEN',
    "    INSERT INTO test_subjects (name, description) VALUES ('Cardiovascular System', 'Cardiovascular notes') RETURNING id INTO v_subject_id;",
    END_IF_SQL,
    f"  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = '{TOPIC_NAME}' LIMIT 1;",
    '  IF v_topic_id IS NULL THEN',
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'PVD / PAD / DVT', 'Peripheral vascular disorders comparison and management', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - PVD/PAD/DVT (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
    '    RETURNING id INTO v_test_id;',
    END_IF_SQL,
    f"  DELETE FROM test_questions WHERE topic_id = v_topic_id AND category = '{CATEGORY}';"
]

for i, q in enumerate(questions, start=1):
    stem = esc(q['stem'])
    options = esc(json.dumps(q['options'], ensure_ascii=False))
    correct = esc(json.dumps(q['correct'], ensure_ascii=False))
    rationale = esc(q['rationale'])
    is_multi = 'true' if q['is_multi'] else 'false'

    lines.append('  INSERT INTO test_questions (test_id, topic_id, question, question_stem, options, correct_answer, rationale, category, is_multiple_choice, display_order, points, is_active)')
    lines.append(f"  VALUES (v_test_id, v_topic_id, '{stem}', '{stem}', '{options}'::jsonb, '{correct}'::jsonb, '{rationale}', '{CATEGORY}', {is_multi}, {i}, 1, true);")

lines.extend(['END $$;', 'COMMIT;'])
OUT_PATH.write_text('\n'.join(lines), encoding='utf-8')
print(f'Wrote {OUT_PATH} with {len(questions)} questions')
