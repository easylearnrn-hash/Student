import json
import random
from pathlib import Path

random.seed(52)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-BUERGERS-100.sql')
CATEGORY = "Buerger's Disease - NCLEX"
TOPIC_NAME = "Buerger's Disease"

concepts = [
    {
        'name': 'Core definition',
        'fact': "Buerger's disease (thromboangiitis obliterans) is an inflammatory occlusive disease of small and medium arteries and veins.",
        'priority': 'Differentiate inflammatory tobacco-related occlusion from atherosclerotic PAD early.',
        'true': ['TAO is inflammatory and occlusive.', 'Small/medium vessels are involved.', 'Both arteries and veins can be affected.'],
        'false': ['Buerger disease is primary large-vessel atherosclerosis in this note.', 'Only coronary vessels are affected in this note.']
    },
    {
        'name': 'Pathologic process',
        'fact': 'Disease causes segmental thrombosis and fibrosis in extremity vessels.',
        'priority': 'Monitor for progressive ischemia as occlusion advances segmentally.',
        'true': ['Segmental thrombosis is described.', 'Fibrosis of vessels is described.', 'Extremity vessel involvement is emphasized.'],
        'false': ['Diffuse valve incompetence is primary lesion in this note.', 'No thrombosis occurs in this disease in this note.']
    },
    {
        'name': 'Tobacco exclusivity',
        'fact': 'Buerger disease is almost exclusively caused by tobacco exposure, including cigarettes and smokeless products.',
        'priority': 'Absolute cessation of all tobacco/nicotine exposure is mandatory.',
        'true': ['Tobacco is the near-exclusive trigger.', 'Smokeless tobacco is included risk in note.', 'Continuing tobacco sustains disease activity.'],
        'false': ['Disease is unrelated to tobacco in this note.', 'Only alcohol causes this disease in this note.']
    },
    {
        'name': 'Not atherosclerosis',
        'fact': "Buerger's is not atherosclerosis; it is an inflammatory immune-mediated process.",
        'priority': 'Avoid conflating TAO with classic PAD risk modeling.',
        'true': ['TAO is non-atherosclerotic in this note.', 'Inflammatory/immune mechanisms are emphasized.', 'Pathogenesis differs from PAD plaque disease.'],
        'false': ['TAO is identical to PAD plaque disease in this note.', 'Immune inflammation is excluded in this note.']
    },
    {
        'name': 'Typical patient profile',
        'fact': 'Typical profile is heavy tobacco user, often young male under 45; women less common but rising with tobacco use.',
        'priority': 'Suspect TAO in young smokers with bilateral ischemic extremity signs.',
        'true': ['Young male under 45 is typical profile.', 'Heavy tobacco use is central risk.', 'Female incidence rises with tobacco use.'],
        'false': ['TAO is primarily disease of nonsmoking elderly in this note.', 'Gender/age profile is irrelevant in this note.']
    },
    {
        'name': 'Distribution pattern',
        'fact': 'Buerger disease may involve both upper and lower extremities, unlike PAD that mainly affects lower limbs.',
        'priority': 'Upper-limb ischemia in smoker should raise TAO suspicion.',
        'true': ['Upper and lower extremities can be affected.', 'PAD is usually lower-extremity predominant in comparison table.', 'Distribution helps differential diagnosis.'],
        'false': ['TAO affects only lower limbs in this note.', 'PAD primarily affects upper limbs in this note.']
    },
    {
        'name': 'BURGER mnemonic - burning pain',
        'fact': 'Burning ischemic pain at rest in fingers/toes/feet is a key symptom.',
        'priority': 'Rest pain indicates significant ischemia requiring urgent management.',
        'true': ['Burning pain is in mnemonic.', 'Pain may occur at rest.', 'Distal digits/feet are common sites.'],
        'false': ['Pain appears only with exertion and never at rest in this note.', 'Pain is absent in TAO in this note.']
    },
    {
        'name': 'BURGER mnemonic - ulcers',
        'fact': 'Painful ulceration of fingertips/toes is listed in BURGER mnemonic.',
        'priority': 'Protect ulcerated ischemic tissue and prevent infection progression.',
        'true': ['Digit ulcers are highlighted.', 'Ulcers are painful in TAO profile.', 'Distal ulceration suggests severe ischemia.'],
        'false': ['TAO ulcers are painless venous stasis ulcers in this note.', 'Ulceration never occurs in TAO in this note.']
    },
    {
        'name': 'BURGER mnemonic - rubor',
        'fact': "Dependent rubor/redness and Raynaud-like color changes are characteristic findings.",
        'priority': 'Interpret positional color shifts as ischemic vascular dysfunction.',
        'true': ['Dependent rubor is listed.', 'Raynaud-like color changes are listed.', 'Color changes are part of BURGER mnemonic.'],
        'false': ['Color is unaffected by position in this note.', 'Only fixed cyanosis with no variation occurs in this note.']
    },
    {
        'name': 'BURGER mnemonic - gangrene',
        'fact': 'Dry gangrene of digits may occur in advanced disease.',
        'priority': 'Escalate when tissue viability declines toward amputation risk.',
        'true': ['Dry gangrene is advanced feature.', 'Digits are common gangrene location.', 'Gangrene indicates severe progression.'],
        'false': ['Gangrene is never seen in TAO in this note.', 'Only wet gangrene is described in this note.']
    },
    {
        'name': 'BURGER mnemonic - extremity coolness',
        'fact': 'Extremities are often cool to touch, especially hands and feet.',
        'priority': 'Frequent perfusion checks are needed in cool ischemic limbs.',
        'true': ['Cool hands/feet are listed finding.', 'Temperature change reflects poor perfusion.', 'Distal extremities are emphasized.'],
        'false': ['Extremities are warm and flushed in TAO in this note.', 'Temperature is unrelated to TAO in this note.']
    },
    {
        'name': 'BURGER mnemonic - reduced pulses',
        'fact': 'Distal pulses (pedal/radial) are reduced or absent.',
        'priority': 'Track pulse changes serially to detect worsening ischemia.',
        'true': ['Reduced or absent pulses are listed.', 'Pedal/radial pulses specifically mentioned.', 'Pulse loss indicates arterial compromise.'],
        'false': ['Pulses remain strong in severe TAO in this note.', 'Pulse checks are unnecessary in TAO in this note.']
    },
    {
        'name': 'Additional signs',
        'fact': 'Additional signs include migratory superficial thrombophlebitis, intermittent claudication, nail changes, and ischemic neuropathy.',
        'priority': 'Recognize multisystem limb signs beyond pain alone.',
        'true': ['Migratory superficial thrombophlebitis is listed.', 'Intermittent claudication is listed.', 'Nail/neuropathy changes are listed.'],
        'false': ['Only cardiac murmurs diagnose TAO in this note.', 'Neurologic changes are excluded in this note.']
    },
    {
        'name': 'Allen test purpose',
        'fact': 'Allen test assesses radial/ulnar patency and upper-extremity circulation.',
        'priority': 'Use Allen test correctly before arterial procedures and in TAO evaluation.',
        'true': ['Allen test evaluates hand arterial flow.', 'Both radial and ulnar arteries are assessed.', 'Used for upper-extremity circulation evaluation.'],
        'false': ['Allen test diagnoses DVT in this note.', 'Allen test is unrelated to arterial patency in this note.']
    },
    {
        'name': 'Allen test steps',
        'fact': 'Steps include fist clench, compress both radial/ulnar arteries, open blanched hand, release one artery, and observe reperfusion.',
        'priority': 'Sequence accuracy is crucial for valid test interpretation.',
        'true': ['Both arteries are compressed initially.', 'Hand should appear pale before release.', 'Release one artery while keeping the other compressed.'],
        'false': ['Release both arteries simultaneously is required in this note.', 'Test begins with leg elevation in this note.']
    },
    {
        'name': 'Allen test interpretation',
        'fact': 'Normal test is flush within 5–7 seconds after release; persistent pallor suggests occlusion.',
        'priority': 'Delayed reperfusion indicates compromised arterial patency.',
        'true': ['Flush in 5–7 seconds is normal.', 'Persistent pallor indicates occlusion.', 'Timing criterion is explicitly provided.'],
        'false': ['Persistent pallor confirms normal flow in this note.', 'Any refill after 30 seconds is still normal in this note.']
    },
    {
        'name': 'Angiography hallmark',
        'fact': 'Angiography finding of corkscrew collaterals is pathognomonic for Buerger disease.',
        'priority': 'Use angiographic pattern to strengthen diagnosis when clinical picture fits.',
        'true': ['Corkscrew collaterals are pathognomonic in note.', 'Angiography is key diagnostic study.', 'Pattern supports TAO diagnosis.'],
        'false': ['Corkscrew pattern indicates PAD only in this note.', 'Angiography is never used in TAO in this note.']
    },
    {
        'name': 'Other diagnostics',
        'fact': 'Doppler and ABI may be used; blood tests are used to rule out autoimmune/hypercoagulable causes, with no reliable biomarker.',
        'priority': 'Diagnosis is clinical plus imaging after excluding mimics.',
        'true': ['No reliable standalone biomarker is listed.', 'Blood tests help rule out other causes.', 'Doppler/ABI are listed supportive studies.'],
        'false': ['Single specific blood biomarker confirms TAO in this note.', 'No imaging is required for diagnosis in this note.']
    },
    {
        'name': 'Primary treatment',
        'fact': 'Absolute cessation of all smoking/tobacco is the only intervention that halts progression.',
        'priority': 'Prioritize cessation counseling as non-negotiable first intervention.',
        'true': ['Smoking cessation is mandatory and first priority.', 'Progression continues with ongoing tobacco use.', 'Even low-level smoking can sustain disease activity.'],
        'false': ['Revascularization alone halts TAO despite smoking in this note.', 'Smoking reduction without cessation is sufficient in this note.']
    },
    {
        'name': 'Nicotine product caution',
        'fact': 'Nicotine patches/gums may worsen disease because nicotine exposure can maintain activity.',
        'priority': 'Teach that nicotine itself may perpetuate TAO process.',
        'true': ['Nicotine replacement products may worsen TAO per note.', 'Any nicotine exposure is concerning in TAO.', 'Counseling should include smokeless/nicotine products.'],
        'false': ['Nicotine patches are guaranteed curative in TAO in this note.', 'Only cigarette smoke, not nicotine, matters in this note.']
    },
    {
        'name': 'Supportive therapy',
        'fact': 'Supportive management includes wound care, CCB for vasospasm, iloprost for severe ischemia, pain control, and avoiding cold.',
        'priority': 'Adjunctive care supports tissue survival but does not replace cessation.',
        'true': ['Wound care is listed supportive management.', 'Nifedipine for vasospasm is listed.', 'Avoiding cold triggers is listed advice.'],
        'false': ['Cold exposure is recommended in this note.', 'Supportive care is unnecessary if ulcers present in this note.']
    },
    {
        'name': 'Amputation context',
        'fact': 'Amputation may be required when gangrene is non-viable.',
        'priority': 'Monitor tissue viability closely to time surgical escalation appropriately.',
        'true': ['Non-viable gangrene can require amputation.', 'Advanced ischemia may progress despite support.', 'Gangrene surveillance is key nursing focus.'],
        'false': ['Gangrene always reverses without intervention in this note.', 'Amputation is contraindicated in all cases in this note.']
    },
    {
        'name': 'Buerger vs PAD cause/age',
        'fact': 'Buerger is tobacco-induced in younger patients (<45), while PAD is atherosclerotic and generally older (>50).',
        'priority': 'Age-plus-risk profile helps rapid differential diagnosis.',
        'true': ['Buerger age profile is younger than PAD in table.', 'PAD cause is atherosclerosis in table.', 'Buerger cause is tobacco inflammation in table.'],
        'false': ['Buerger and PAD share identical etiology in this note.', 'Buerger is primarily elderly disease in this note.']
    },
    {
        'name': 'Buerger vs PAD vessel/risk patterns',
        'fact': 'Buerger affects small/medium vessels in upper and lower limbs with tobacco-only risk; PAD affects large/medium mostly lower limbs with multiple metabolic risks.',
        'priority': 'Distribution and risk-factor pattern guide triage and counseling focus.',
        'true': ['Buerger can affect upper and lower extremities.', 'PAD mostly affects lower extremities.', 'PAD risk list includes HTN/DM/lipids/smoking in table.'],
        'false': ['PAD risk factor is tobacco only in this note.', 'Buerger affects only large proximal vessels in this note.']
    },
    {
        'name': 'NCLEX priority synthesis',
        'fact': "NCLEX priority: young male smoker with bilateral ischemia suggests Buerger; immediate STOP ALL TOBACCO and monitor gangrene progression.",
        'priority': 'Frame all teaching around mandatory cessation and limb preservation.',
        'true': ['Young smoker + bilateral ischemia is key TAO clue.', 'Stop all tobacco is first intervention.', 'Gangrene progression monitoring is emphasized.'],
        'false': ['Smoking cessation is optional in TAO in this note.', 'Gangrene monitoring is low priority in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this vascular case?',
    'The nurse reviews assessment data. Which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent prioritization, which conclusion aligns with {name}?',
    'Which statement most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For management involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans care around {name}. Which items should be included? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which clues are consistent with {name} in this note? (Select all that apply)'
]


def option_objects(texts):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(texts)]


def esc(s: str) -> str:
    return s.replace("'", "''")


TOPIC_NAME_SQL = esc(TOPIC_NAME)
CATEGORY_SQL = esc(CATEGORY)
TEST_NAME_SQL = esc("Cardiovascular System - Buerger's Disease (Generated)")


questions = []

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'])
    correct = c['fact'] if i % 2 == 0 else c['priority']

    distractors = c['false'] + [
        f'This profile is more consistent with {concepts[(i + 3) % len(concepts)]["name"]}.',
        'Cessation counseling can be deferred until after tissue loss occurs.',
        'Pulse and color trends are not relevant to TAO progression.'
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
    f"  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = '{TOPIC_NAME_SQL}' LIMIT 1;",
    '  IF v_topic_id IS NULL THEN',
    f"    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, '{TOPIC_NAME_SQL}', 'TAO diagnosis, tobacco cessation, and management', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    f"    VALUES ('{TEST_NAME_SQL}', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
    '    RETURNING id INTO v_test_id;',
    END_IF_SQL,
    f"  DELETE FROM test_questions WHERE topic_id = v_topic_id AND category = '{CATEGORY_SQL}';"
]

for i, q in enumerate(questions, start=1):
    stem = esc(q['stem'])
    options = esc(json.dumps(q['options'], ensure_ascii=False))
    correct = esc(json.dumps(q['correct'], ensure_ascii=False))
    rationale = esc(q['rationale'])
    is_multi = 'true' if q['is_multi'] else 'false'

    lines.append('  INSERT INTO test_questions (test_id, topic_id, question, question_stem, options, correct_answer, rationale, category, is_multiple_choice, display_order, points, is_active)')
    lines.append(f"  VALUES (v_test_id, v_topic_id, '{stem}', '{stem}', '{options}'::jsonb, '{correct}'::jsonb, '{rationale}', '{CATEGORY_SQL}', {is_multi}, {i}, 1, true);")

lines.extend(['END $$;', 'COMMIT;'])
OUT_PATH.write_text('\n'.join(lines), encoding='utf-8')
print(f'Wrote {OUT_PATH} with {len(questions)} questions')
