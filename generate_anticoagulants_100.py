import json
import random
from pathlib import Path

random.seed(57)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-ANTICOAGULANTS-100.sql')
CATEGORY = 'Anticoagulants - NCLEX'
TOPIC_NAME = 'Anticoagulants'
TEST_NAME = 'Cardiovascular System - Anticoagulants (Generated)'

concepts = [
    {
        'name': 'aPTT role',
        'fact': 'aPTT monitors heparin therapy; normal is about 30–40 sec and therapeutic heparin range is 45–80 sec.',
        'priority': 'Trend aPTT during heparin titration to avoid under- or over-anticoagulation.',
        'true': ['aPTT is used to monitor heparin.', 'Therapeutic heparin aPTT is 45–80 sec.', 'Normal aPTT is around 30–40 sec.'],
        'false': ['aPTT is the primary warfarin monitoring test in this note.', 'Therapeutic heparin aPTT is below 20 sec in this note.']
    },
    {
        'name': 'PT/INR role',
        'fact': 'PT/INR monitor warfarin; INR therapeutic range is 2–3 for most indications.',
        'priority': 'Use INR trends to guide safe warfarin dosing.',
        'true': ['INR is used for warfarin monitoring.', 'Typical therapeutic INR is 2–3.', 'PT is associated with warfarin monitoring in this note.'],
        'false': ['Warfarin is monitored by aPTT only in this note.', 'INR goal for most patients is below 1 in this note.']
    },
    {
        'name': 'heparin basics',
        'fact': 'Heparin is given IV or SubQ, has immediate IV onset, and is used for DVT, PE, ACS, dialysis, and perioperative prevention.',
        'priority': 'Heparin is chosen when rapid anticoagulation is needed.',
        'true': ['Heparin can be IV or SubQ.', 'IV heparin onset is immediate.', 'DVT/PE/ACS are listed uses.'],
        'false': ['Heparin is oral only in this note.', 'Heparin requires 2–5 days to start working in this note.']
    },
    {
        'name': 'heparin antidote',
        'fact': 'Protamine sulfate is the antidote for heparin.',
        'priority': 'Prepare protamine quickly when significant heparin-associated bleeding risk is present.',
        'true': ['Protamine sulfate reverses heparin.', 'Protamine is linked with heparin overdose management.', 'Heparin has a named antidote in this note.'],
        'false': ['Vitamin K is the heparin antidote in this note.', 'Idarucizumab reverses heparin in this note.']
    },
    {
        'name': 'aPTT above 80',
        'fact': 'If aPTT exceeds 80 sec: stop infusion, assess vitals for bleeding, prepare protamine, then notify provider before giving antidote.',
        'priority': 'Follow sequence: stop, assess, prepare, call.',
        'true': ['Stop heparin infusion if aPTT is >80 sec.', 'Assess for bleeding signs like low BP and high HR.', 'Notify provider before antidote administration.'],
        'false': ['Continue infusion and recheck next shift in this note.', 'Give antidote before any assessment in this note.']
    },
    {
        'name': 'HIT recognition',
        'fact': 'HIT is suspected when platelets drop more than 50% on heparin; stop heparin and switch to argatroban.',
        'priority': 'HIT increases clotting risk paradoxically despite thrombocytopenia.',
        'true': ['Platelet drop >50% suggests HIT.', 'Heparin should be stopped in suspected HIT.', 'Argatroban is listed as alternative.'],
        'false': ['HIT primarily lowers clot risk in this note.', 'Continue heparin despite HIT signs in this note.']
    },
    {
        'name': 'warfarin basics',
        'fact': 'Warfarin is oral and has delayed onset of 2–5 days, so it is used for long-term anticoagulation.',
        'priority': 'Delayed onset drives need for bridging in acute clot treatment.',
        'true': ['Warfarin is oral.', 'Warfarin onset is delayed 2–5 days.', 'Warfarin is used for long-term anticoagulation.'],
        'false': ['Warfarin has immediate IV onset in this note.', 'Warfarin is only used during surgery in this note.']
    },
    {
        'name': 'warfarin therapeutic range',
        'fact': 'Therapeutic INR is usually 2–3, but mechanical heart valves often target 2.5–3.5.',
        'priority': 'Valve patients often require higher anticoagulation intensity.',
        'true': ['Usual INR target is 2–3.', 'Mechanical valves may require INR 2.5–3.5.', 'INR goal differs by indication.'],
        'false': ['Mechanical valve INR target is below 2 in this note.', 'Warfarin has one fixed INR for all patients in this note.']
    },
    {
        'name': 'warfarin antidote',
        'fact': 'Vitamin K (phytonadione) is the reversal agent for warfarin.',
        'priority': 'Know warfarin-vitamin K pair for rapid NCLEX decisions.',
        'true': ['Vitamin K reverses warfarin.', 'Phytonadione is vitamin K name in note.', 'Warfarin has specific antidote listed.'],
        'false': ['Protamine reverses warfarin in this note.', 'Andexanet alfa reverses warfarin in this note.']
    },
    {
        'name': 'warfarin teaching vitamin K',
        'fact': 'Patients should keep vitamin K intake consistent rather than eliminating leafy greens entirely.',
        'priority': 'Diet consistency prevents INR instability.',
        'true': ['Vitamin K intake should be consistent.', 'Patients should not completely avoid leafy greens.', 'Diet changes can alter warfarin effect.'],
        'false': ['Leafy greens must be eliminated forever in this note.', 'Vitamin K intake has no effect on warfarin in this note.']
    },
    {
        'name': 'warfarin teaching interactions',
        'fact': 'Avoid NSAIDs and grapefruit while on warfarin due to increased bleeding risk or level changes.',
        'priority': 'Medication/food interaction review is a safety essential.',
        'true': ['NSAIDs should be avoided with warfarin.', 'Grapefruit is listed to avoid.', 'Interaction teaching reduces bleeding risk.'],
        'false': ['Warfarin patients should take NSAIDs for routine pain in this note.', 'Grapefruit lowers warfarin effect safely in this note.']
    },
    {
        'name': 'warfarin bleeding teaching',
        'fact': 'Teach patients to report unusual bleeding, hematuria, or blood in stool and wear a medical alert bracelet.',
        'priority': 'Early bleeding recognition prevents severe complications.',
        'true': ['Report unusual bleeding immediately.', 'Blood in urine/stool is concerning.', 'Medical alert bracelet is recommended.'],
        'false': ['Bleeding signs can be ignored if INR is therapeutic in this note.', 'Medical alert ID is unnecessary in this note.']
    },
    {
        'name': 'bridge overlap duration',
        'fact': 'When transitioning heparin to warfarin, overlap both drugs for at least 5–7 days.',
        'priority': 'Bridge prevents gaps in anticoagulation while warfarin effect develops.',
        'true': ['Heparin-warfarin overlap should be 5–7 days minimum.', 'Heparin provides immediate effect during bridge.', 'Warfarin delay necessitates overlap.'],
        'false': ['Stop heparin the same day warfarin starts in this note.', 'Overlap is unnecessary if INR is pending in this note.']
    },
    {
        'name': 'bridge discontinuation rule',
        'fact': 'Do not stop heparin until INR is therapeutic 2–3 for two consecutive days.',
        'priority': 'Require stable therapeutic INR before removing rapid-acting anticoagulant.',
        'true': ['Heparin continues until INR is therapeutic.', 'Therapeutic INR must persist two consecutive days.', 'Target INR for this bridge is 2–3.'],
        'false': ['Heparin stops after one therapeutic INR in this note.', 'Heparin stops before INR reaches goal in this note.']
    },
    {
        'name': 'stable INR follow-up',
        'fact': 'Once INR is stable, warfarin monitoring can be every 3 weeks per note.',
        'priority': 'Stable outpatient monitoring still requires routine checks.',
        'true': ['Stable warfarin INR checks can be every 3 weeks.', 'INR monitoring continues long-term.', 'Monitoring frequency depends on stability.'],
        'false': ['Warfarin monitoring is discontinued once stable in this note.', 'INR should be checked yearly only in this note.']
    },
    {
        'name': 'critical high-risk thresholds',
        'fact': 'INR greater than 4 or aPTT greater than 80 sec indicates high hemorrhage risk and immediate intervention.',
        'priority': 'Recognize threshold triggers for urgent safety response.',
        'true': ['INR >4 is high hemorrhage risk in note.', 'aPTT >80 sec is high hemorrhage risk in note.', 'Both trigger urgent intervention sequence.'],
        'false': ['INR 4.5 is reassuring in this note.', 'aPTT >80 sec suggests under-anticoagulation in this note.']
    },
    {
        'name': 'STOP ASSESS PREPARE CALL',
        'fact': 'NCLEX priority order for suspected internal bleeding is STOP anticoagulant, ASSESS vitals/bleeding, PREPARE antidote, then CALL provider.',
        'priority': 'Sequence discipline improves emergency anticoagulant safety.',
        'true': ['Stop anticoagulant first.', 'Assess for low BP/high HR/pallor/bleeding.', 'Prepare antidote then call provider.'],
        'false': ['Call provider before stopping active infusion in this note.', 'Give antidote before assessment in this note.']
    },
    {
        'name': 'internal bleeding signs',
        'fact': 'Signs of internal bleeding include low BP, high HR, melena, hematuria, and severe headache suggesting intracranial bleed.',
        'priority': 'Combine hemodynamic and symptom clues for early detection.',
        'true': ['Low BP plus high HR can indicate internal bleeding.', 'Melena and hematuria are warning signs.', 'Severe headache may indicate intracranial bleed.'],
        'false': ['Bradycardia with hypertension is classic anticoagulant bleed in this note.', 'Hematuria is expected and not concerning in this note.']
    },
    {
        'name': 'dabigatran profile',
        'fact': 'Dabigatran is a direct thrombin inhibitor; monitor renal function and reverse with idarucizumab.',
        'priority': 'Match class and antidote accurately in urgent reversal decisions.',
        'true': ['Dabigatran is direct thrombin inhibitor.', 'Renal function monitoring is listed.', 'Idarucizumab is antidote.'],
        'false': ['Dabigatran is factor Xa inhibitor in this note.', 'Protamine is dabigatran antidote in this note.']
    },
    {
        'name': 'factor Xa inhibitors profile',
        'fact': 'Rivaroxaban and apixaban are factor Xa inhibitors; monitor renal function/CBC and reverse with andexanet alfa.',
        'priority': 'Differentiate Xa inhibitor reversal from other anticoagulants.',
        'true': ['Rivaroxaban/apixaban are factor Xa inhibitors.', 'Andexanet alfa is their listed antidote.', 'Renal function and CBC monitoring are listed.'],
        'false': ['Idarucizumab reverses apixaban in this note.', 'Xa inhibitors are monitored by daily INR in this note.']
    },
    {
        'name': 'enoxaparin profile',
        'fact': 'Enoxaparin is LMWH with anti-Xa monitoring if needed; protamine provides partial reversal.',
        'priority': 'Understand that reversal is partial, not complete.',
        'true': ['Enoxaparin is LMWH.', 'Anti-Xa may be checked when needed.', 'Protamine gives partial reversal.'],
        'false': ['Enoxaparin is fully reversed by vitamin K in this note.', 'Enoxaparin is monitored by INR only in this note.']
    },
    {
        'name': 'lab-memory rule',
        'fact': 'Memory cue: H for Heparin equals aPTT; W for Warfarin equals INR.',
        'priority': 'Use mnemonic for rapid exam-time lab matching.',
        'true': ['Heparin pairs with aPTT.', 'Warfarin pairs with INR.', 'Mnemonic supports quick recall.'],
        'false': ['Heparin pairs with INR in this note.', 'Warfarin pairs only with anti-Xa in this note.']
    },
    {
        'name': 'monitoring distinction',
        'fact': 'Warfarin monitoring is INR/PT only, while heparin titration requires frequent aPTT checks every 6 hours.',
        'priority': 'Do not interchange heparin and warfarin monitoring labs.',
        'true': ['Heparin titration uses q6h aPTT checks.', 'Warfarin is monitored with INR/PT.', 'Monitoring strategy differs by drug.'],
        'false': ['Both drugs are monitored with same lab in this note.', 'Warfarin titration uses q6h aPTT in this note.']
    },
    {
        'name': 'integrated anticoagulant safety',
        'fact': 'Safe anticoagulant care requires correct lab-drug pairing, bleeding surveillance, antidote readiness, and structured escalation.',
        'priority': 'Most preventable harm comes from delayed recognition and delayed response.',
        'true': ['Correct lab-drug matching is central to safety.', 'Bleeding signs require immediate action.', 'Antidote readiness is emphasized in NCLEX priorities.'],
        'false': ['Anticoagulants do not require routine monitoring in this note.', 'Escalation sequence is optional in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this anticoagulation scenario?',
    'The nurse reviews current data. Which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent triage, which conclusion aligns with {name}?',
    'Which statement most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For management involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans interventions around {name}. Which items belong in the plan? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which cues are consistent with {name} in this note? (Select all that apply)'
]


def option_objects(texts):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(texts)]


def esc(s: str) -> str:
    return s.replace("'", "''")


TOPIC_NAME_SQL = esc(TOPIC_NAME)
CATEGORY_SQL = esc(CATEGORY)
TEST_NAME_SQL = esc(TEST_NAME)

questions = []

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'])
    correct = c['fact'] if i % 2 == 0 else c['priority']

    distractors = c['false'] + [
        f'This pattern is more consistent with {concepts[(i + 4) % len(concepts)]["name"]}.',
        'Blood pressure alone is enough for all anticoagulant safety decisions.',
        'Antidote planning is unnecessary when labs are elevated.'
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
    f"    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, '{TOPIC_NAME_SQL}', 'Anticoagulant pharmacology, monitoring, antidotes, and bridge safety', 'published') RETURNING id INTO v_topic_id;",
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
