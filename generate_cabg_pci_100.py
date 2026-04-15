import json
import random
from pathlib import Path

random.seed(53)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-CABG-PCI-100.sql')
CATEGORY = 'CABG and PCI - NCLEX'
TOPIC_NAME = 'CABG & PCI'

concepts = [
    {
        'name': 'CAD progression',
        'fact': 'CAD progression listed is stable angina to unstable angina to NSTEMI to STEMI.',
        'priority': 'Escalating symptoms should trigger faster revascularization decisions.',
        'true': ['Stable angina appears before unstable in progression.', 'NSTEMI and STEMI are later stages.', 'Progression reflects worsening myocardial perfusion.'],
        'false': ['STEMI is earliest stage in this note.', 'CAD progression ends at stable angina in this note.']
    },
    {
        'name': 'Revascularization options',
        'fact': 'Two options are PCI (less invasive) and CABG (surgery), selected by vessel count, anatomy, EF, and comorbidities.',
        'priority': 'Procedure choice must match anatomy and risk profile, not convenience.',
        'true': ['PCI is less invasive option.', 'CABG is surgical option.', 'Selection factors include vessels/anatomy/EF/comorbidities.'],
        'false': ['PCI and CABG are interchangeable regardless anatomy in this note.', 'EF is irrelevant to decision in this note.']
    },
    {
        'name': 'PCI basics',
        'fact': 'PCI is catheter-based via radial or femoral access, using balloon angioplasty and often stent placement.',
        'priority': 'Monitor access-site and reperfusion outcomes immediately post-procedure.',
        'true': ['Radial and femoral access are listed.', 'Balloon compresses plaque.', 'Stent scaffold may be left in artery.'],
        'false': ['PCI is open-heart surgery in this note.', 'PCI never uses stents in this note.']
    },
    {
        'name': 'Drug-eluting stent role',
        'fact': 'Drug-eluting stents contain antiproliferative medication to reduce restenosis.',
        'priority': 'Maintain antiplatelet adherence to prevent stent thrombosis/restenosis.',
        'true': ['DES has antiproliferative coating.', 'DES aims to lower restenosis risk.', 'Stent choice affects post-procedure management.'],
        'false': ['DES increases restenosis intentionally in this note.', 'DES removes need for any antiplatelet therapy in this note.']
    },
    {
        'name': 'Primary PCI timing',
        'fact': 'Primary PCI is treatment of choice for STEMI with door-to-balloon goal within 90 minutes.',
        'priority': 'Time-to-balloon directly impacts myocardial salvage.',
        'true': ['STEMI door-to-balloon target is 90 min.', 'Primary PCI is preferred STEMI reperfusion strategy.', 'Rapid activation is essential.'],
        'false': ['Primary PCI target is 24 hours in this note.', 'Primary PCI is not used for STEMI in this note.']
    },
    {
        'name': 'PCI indications',
        'fact': 'PCI indications include STEMI/NSTEMI, refractory unstable angina, suitable 1–2 vessel disease, or high CABG surgical risk.',
        'priority': 'Use PCI when anatomy and risk profile make catheter strategy appropriate.',
        'true': ['STEMI and NSTEMI are listed indications.', 'Refractory unstable angina is listed indication.', '1–2 vessel suitable anatomy is listed indication.'],
        'false': ['Left main multivessel disease is always first-choice PCI in this note.', 'PCI is contraindicated in all acute MI in this note.']
    },
    {
        'name': 'Pre-PCI preparation',
        'fact': 'Pre-PCI care includes NPO 4–6 hours, IV access, type and screen, DAPT initiation, anticoagulation, creatinine check, and pulse marking.',
        'priority': 'Optimize safety by preparing bleeding, renal, and access monitoring plans.',
        'true': ['NPO 4–6 hours is listed.', 'Creatinine check is listed for contrast risk.', 'Pedal pulses are assessed/marked pre-procedure.'],
        'false': ['Renal function check is unnecessary pre-PCI in this note.', 'Pulse baseline is not needed in this note.']
    },
    {
        'name': 'Post-PCI vitals and site care',
        'fact': 'Post-PCI protocol includes frequent vitals and puncture site checks for bleeding/hematoma.',
        'priority': 'Early detection of access complications prevents deterioration.',
        'true': ['Frequent scheduled vitals are listed.', 'Bleeding/hematoma monitoring is required.', 'Access-site surveillance is key post-PCI.'],
        'false': ['Vitals can be deferred for several hours in this note.', 'Site checks are unnecessary after sheath removal in this note.']
    },
    {
        'name': 'Post-PCI limb and hydration',
        'fact': 'Femoral approach requires limb straight with bedrest 4–6 hours; fluids are encouraged to clear contrast.',
        'priority': 'Protect access integrity while lowering nephropathy risk.',
        'true': ['Affected femoral limb kept straight post-procedure.', 'Bedrest 4–6 hours listed for femoral access.', 'Hydration is encouraged to flush contrast.'],
        'false': ['Immediate vigorous leg flexion is recommended in this note.', 'Fluid restriction is mandatory after contrast in this note.']
    },
    {
        'name': 'Post-PCI medication adherence',
        'fact': 'Dual antiplatelet therapy is required for at least 1 year after stent placement.',
        'priority': 'Nonadherence significantly raises stent thrombosis risk.',
        'true': ['DAPT minimum one year is listed.', 'Aspirin + P2Y12 strategy is emphasized.', 'Medication adherence is critical after stent.'],
        'false': ['DAPT stops after 48 hours in this note.', 'Aspirin alone is immediate replacement for all stent patients in this note.']
    },
    {
        'name': 'PCI complications',
        'fact': 'Listed PCI complications include access-site bleeding (most common), contrast nephropathy, arterial dissection, restenosis/re-occlusion, and stent thrombosis.',
        'priority': 'Monitor for ischemic recurrence and bleeding/renal complications continuously.',
        'true': ['Bleeding at access site is most common complication listed.', 'Contrast nephropathy is listed.', 'Stent thrombosis is emergency complication.'],
        'false': ['PCI has no renal complications in this note.', 'Restenosis is impossible with stents in this note.']
    },
    {
        'name': 'CABG definition',
        'fact': 'CABG is open-heart bypass surgery using grafts to route blood around blocked coronaries.',
        'priority': 'Post-op priorities focus on airway, hemodynamics, and graft-related complications.',
        'true': ['CABG is open-heart surgery in note.', 'Bypass grafts reroute flow around blockage.', 'CABG is revascularization option for complex CAD.'],
        'false': ['CABG is a bedside catheter procedure in this note.', 'CABG avoids any graft vessel use in this note.']
    },
    {
        'name': 'CABG graft options',
        'fact': 'Graft choices include reversed saphenous vein, internal mammary artery (most durable to LAD), and radial artery.',
        'priority': 'Understand graft source/patency differences for long-term follow-up education.',
        'true': ['Saphenous vein graft is listed.', 'LIMA-to-LAD is highlighted as durable.', 'Radial artery can be used.'],
        'false': ['Only synthetic grafts are used in this note.', 'Internal mammary graft is never connected to LAD in this note.']
    },
    {
        'name': 'CABG indications high risk anatomy',
        'fact': 'CABG indications include left main disease >50%, 3-vessel CAD especially with reduced EF, and proximal LAD involvement.',
        'priority': 'Escalate to surgical strategy for high-risk multivessel anatomy.',
        'true': ['Left main >50% is listed indication.', '3-vessel with low EF favors CABG.', 'Proximal LAD involvement in 2-vessel disease listed indication.'],
        'false': ['Single-vessel mild disease always requires CABG in this note.', 'Left main stenosis is managed only with lifestyle in this note.']
    },
    {
        'name': 'Other CABG indications',
        'fact': 'CABG is indicated for failed PCI and in diabetic patients with multivessel CAD.',
        'priority': 'Recognize scenarios where surgery outperforms repeat catheter interventions.',
        'true': ['Failed PCI is listed CABG indication.', 'Diabetes with multivessel CAD is listed indication.', 'CABG can be chosen when PCI strategy insufficient.'],
        'false': ['CABG is contraindicated after failed PCI in this note.', 'Diabetic multivessel CAD always avoids surgery in this note.']
    },
    {
        'name': 'Post-CABG airway care',
        'fact': 'Post-op patient is initially intubated, extubated when stable; monitor ABGs and use incentive spirometry/deep breathing to prevent atelectasis.',
        'priority': 'Respiratory optimization reduces post-op pulmonary complications.',
        'true': ['Initial intubation then extubation when ready is listed.', 'ABG monitoring is listed.', 'Incentive spirometry/deep breathing are listed.'],
        'false': ['Pulmonary exercises are avoided after CABG in this note.', 'ABGs are irrelevant post-CABG in this note.']
    },
    {
        'name': 'Chest tube threshold',
        'fact': 'Chest tube output greater than 100 mL/hr for 2+ hours suggests hemorrhage and requires provider notification.',
        'priority': 'Treat persistent high drainage as possible active bleeding emergency.',
        'true': ['>100 mL/hr for 2+ hr threshold is listed.', 'High output indicates possible hemorrhage.', 'Escalation/notification is required.'],
        'false': ['500 mL/hr output is expected and ignored in this note.', 'Chest tube output trends are unimportant in this note.']
    },
    {
        'name': 'Chest tube handling',
        'fact': 'Chest tubes should remain dependent without kinks and may be removed when output drops below 25–50 mL per shift.',
        'priority': 'Maintain drainage patency and monitor for removal readiness safely.',
        'true': ['Dependent tubing is emphasized.', 'Avoid kinks in tubing is listed.', 'Removal threshold <25–50 mL/shift is listed.'],
        'false': ['Clamp chest tubes routinely to test patency in this note.', 'Tube removal is based only on patient request in this note.']
    },
    {
        'name': 'Post-CABG arrhythmia',
        'fact': 'Atrial fibrillation is the most common arrhythmia after CABG, typically on post-op days 2–4.',
        'priority': 'Heighten rhythm surveillance during peak AF window.',
        'true': ['AF is most common post-CABG arrhythmia.', 'Peak timing days 2–4 is listed.', 'Continuous monitoring is needed.'],
        'false': ['V-fib is listed most common post-CABG rhythm in this note.', 'Arrhythmias occur only immediately in OR in this note.']
    },
    {
        'name': 'Tamponade vigilance',
        'fact': "Post-CABG priorities include monitoring for tamponade using Beck's triad and maintaining MAP at least 65.",
        'priority': 'Low-pressure triad signs require immediate escalation after cardiac surgery.',
        'true': ["Beck's triad monitoring is listed post-CABG.", 'MAP ≥65 target is listed.', 'Hemodynamic deterioration can indicate tamponade.'],
        'false': ['Tamponade risk is absent after CABG in this note.', 'MAP target under 40 is acceptable in this note.']
    },
    {
        'name': 'Sternal precautions lifting',
        'fact': 'Sternal precautions include no lifting over 5–10 pounds for 6–8 weeks.',
        'priority': 'Protect sternal healing and prevent dehiscence.',
        'true': ['Lifting limit 5–10 lb is listed.', 'Restriction duration 6–8 weeks is listed.', 'Precaution supports sternal healing.'],
        'false': ['Heavy lifting accelerates healing in this note.', 'No lifting restrictions exist post-CABG in this note.']
    },
    {
        'name': 'Other sternal precautions',
        'fact': 'No heavy pushing/pulling, no driving 4–6 weeks, and splint sternum with pillow when coughing/sneezing.',
        'priority': 'Teach movement restrictions clearly before discharge.',
        'true': ['No driving 4–6 weeks is listed.', 'Pillow splinting when coughing is listed.', 'Heavy push/pull restriction is listed.'],
        'false': ['Unrestricted driving starts day after surgery in this note.', 'Coughing should avoid splint support in this note.']
    },
    {
        'name': 'Sternal wound red flags',
        'fact': 'Patients should report sternal clicking, drainage, fever, or increasing redness.',
        'priority': 'Early infection/dehiscence signs require prompt evaluation.',
        'true': ['Sternal clicking is warning sign.', 'Drainage/fever/redness are warning signs.', 'Prompt reporting is part of discharge teaching.'],
        'false': ['Redness and fever are expected, no report needed in this note.', 'Sternal clicking indicates normal healing in this note.']
    },
    {
        'name': 'PCI vs CABG outcomes summary',
        'fact': 'PCI has shorter recovery and suits selected 1–2 vessel/STEMI/high-surgical-risk cases; CABG has longer recovery and suits left main/multivessel/DM/low EF.',
        'priority': 'Balance invasiveness and durability against anatomy and comorbidity burden.',
        'true': ['PCI recovery is faster in comparison table.', 'CABG preferred for left main/3-vessel/DM/low EF patterns.', 'Procedure selection differs by disease complexity.'],
        'false': ['CABG is first choice for all simple 1-vessel lesions in this note.', 'PCI recovery is listed longer than CABG in this note.']
    },
    {
        'name': 'NCLEX priority synthesis',
        'fact': 'NCLEX priorities emphasize post-CABG tamponade assessment, strict sternal precautions, and post-PCI DAPT compliance.',
        'priority': 'Focus teaching and monitoring on highest-risk preventable complications.',
        'true': ['Tamponade assessment is highlighted NCLEX priority.', 'Sternal precautions are highlighted NCLEX priority.', 'DAPT adherence post-PCI is highlighted NCLEX priority.'],
        'false': ['Medication adherence is optional after stent in this note.', 'Tamponade surveillance is not needed after CABG in this note.']
    }
]

mcq_templates = [
    'Which finding most strongly supports {name} in this revascularization scenario?',
    'The nurse reviews post-procedure data; which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent triage, which conclusion aligns with {name}?',
    'Which statement best reflects {name} from this note?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For care involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans interventions around {name}. Which items belong in the plan? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which cues are consistent with {name} in this note? (Select all that apply)'
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
        f'This pattern is more consistent with {concepts[(i + 4) % len(concepts)]["name"]}.',
        'Frequent reassessment can be delayed when initial vitals are stable.',
        'Post-procedure education has minimal impact on outcomes.'
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
    "  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'CABG & PCI' LIMIT 1;",
    '  IF v_topic_id IS NULL THEN',
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'CABG & PCI', 'Revascularization indications and post-op priorities', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - CABG and PCI (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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
