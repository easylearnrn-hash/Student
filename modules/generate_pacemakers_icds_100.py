import json
import random
from pathlib import Path

random.seed(50)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-PACEMAKERS-ICDS-100.sql')
CATEGORY = 'Pacemakers and ICDs - NCLEX'
TOPIC_NAME = 'Pacemakers & ICDs'

concepts = [
    {
        'name': 'Pacemaker definition',
        'fact': 'A pacemaker is an implanted device that delivers electrical impulses to maintain adequate heart rate and contraction.',
        'priority': 'Assess rhythm response and perfusion after pacing initiation.',
        'true': ['Pacemakers deliver electrical impulses.', 'Goal is adequate heart rate/perfusion.', 'Device supports contraction when intrinsic rate is insufficient.'],
        'false': ['Pacemakers only deliver defibrillation shocks in this note.', 'Pacemakers are used to raise blood volume directly in this note.']
    },
    {
        'name': 'Temporary vs permanent pacing',
        'fact': 'Temporary pacing uses external wires (e.g., acute bradycardia/post-MI), while permanent pacing is surgically implanted under skin.',
        'priority': 'Match pacing type to acute versus chronic rhythm support needs.',
        'true': ['Temporary pacing can be used post-MI in this note.', 'Permanent systems are implanted under skin.', 'Temporary and permanent pacing have different use contexts.'],
        'false': ['Permanent pacemakers are external bedside-only in this note.', 'Temporary pacing is lifelong default therapy in this note.']
    },
    {
        'name': 'Bradycardia indication',
        'fact': 'Pacemaker indication includes symptomatic bradycardia with heart rate below 60 bpm.',
        'priority': 'Treat symptomatic low-rate states to prevent syncope and hypoperfusion.',
        'true': ['Symptomatic bradycardia is listed indication.', '<60 bpm threshold appears in note context.', 'Symptoms drive urgency for intervention.'],
        'false': ['Asymptomatic tachycardia is primary pacing indication in this note.', 'Bradycardia is never paced in this note.']
    },
    {
        'name': 'Heart block indication',
        'fact': 'Pacemaker indications include second-degree type II and third-degree AV block.',
        'priority': 'High-grade AV block should trigger prompt pacing preparedness.',
        'true': ['Second-degree type II block is listed indication.', 'Third-degree block is listed indication.', 'Electrical signal interruption between atria and ventricles is emphasized.'],
        'false': ['First-degree block is the only mandatory pacing indication in this note.', 'AV block is contraindication to pacing in this note.']
    },
    {
        'name': 'Other pacing indications',
        'fact': 'Other listed pacing indications include asystole with reversible cause, sick sinus syndrome, and post-cardiac surgery prophylaxis.',
        'priority': 'Recognize broader pacing use beyond simple bradycardia.',
        'true': ['Sick sinus syndrome is listed indication.', 'Asystole with reversible cause is listed indication.', 'Post-cardiac surgery prophylaxis is listed use.'],
        'false': ['Only ventricular tachycardia is paced in this note.', 'Pacemaker use is excluded after cardiac surgery in this note.']
    },
    {
        'name': 'ECG post-implant monitoring',
        'fact': 'Nursing care includes ECG monitoring to verify pacing spikes and appropriate response.',
        'priority': 'Correlate spikes with electrical/mechanical outcomes continuously.',
        'true': ['ECG monitoring is immediate post-implant priority.', 'Pacing spikes should be visible/appropriate.', 'Rhythm verification is central to pacemaker safety.'],
        'false': ['ECG is unnecessary after implant in this note.', 'Spikes indicate malfunction by default in this note.']
    },
    {
        'name': 'Pacing threshold',
        'fact': 'Pacing threshold is the lowest current needed to pace the heart.',
        'priority': 'Optimize threshold to ensure reliable capture with minimal energy.',
        'true': ['Threshold refers to minimum effective current.', 'Threshold assessment is listed nursing priority.', 'Capture reliability depends on adequate output above threshold.'],
        'false': ['Threshold is the maximum tolerated blood pressure in this note.', 'Threshold has no relation to pacing effectiveness in this note.']
    },
    {
        'name': 'Failure to pace',
        'fact': 'Failure to pace is identified by absence of pacing spike when one is expected.',
        'priority': 'Recognize no-spike failure quickly to prevent brady-asystolic events.',
        'true': ['No pacing spike can indicate failure to pace.', 'Expected pacing without spike is abnormal.', 'Immediate troubleshooting is required when no spike appears.'],
        'false': ['Failure to pace shows spike with no QRS in this note.', 'Failure to pace is normal after implantation in this note.']
    },
    {
        'name': 'Failure to capture',
        'fact': 'Failure to capture is pacing spike without resulting QRS complex.',
        'priority': 'Spike-no-QRS pattern requires urgent evaluation of lead/output issues.',
        'true': ['Spike without QRS defines failure to capture.', 'Electrical output without depolarization is abnormal.', 'Capture failure threatens perfusion.'],
        'false': ['Failure to capture means no spike present in this note.', 'Spike followed by QRS always indicates failure in this note.']
    },
    {
        'name': 'Arm movement restriction',
        'fact': 'After implant, restrict affected arm movement for 24–48 hours to prevent lead displacement.',
        'priority': 'Protect lead position in early post-op period.',
        'true': ['Arm restriction duration is 24–48 hours.', 'Reason is prevention of lead displacement.', 'Post-op mobility guidance is part of nursing care.'],
        'false': ['Aggressive overhead arm exercise is encouraged immediately in this note.', 'Arm restriction is unnecessary after implant in this note.']
    },
    {
        'name': 'Electromagnetic precautions',
        'fact': 'Patients should avoid strong electromagnetic fields (e.g., MRI, arc welding, certain equipment).',
        'priority': 'Prevent device interference through exposure counseling.',
        'true': ['Strong electromagnetic fields should be avoided.', 'MRI is listed as concern in note context.', 'Device safety teaching includes environmental risks.'],
        'false': ['All magnetic exposures are harmless in this note.', 'Arc welding is recommended with pacemakers in this note.']
    },
    {
        'name': 'Patient ID and symptom reporting',
        'fact': 'Patients should carry pacemaker ID card and report hiccups, dizziness, or syncope.',
        'priority': 'Early symptom reporting can identify displacement or pacing failure.',
        'true': ['Pacemaker ID card is recommended.', 'Hiccups can signal diaphragm stimulation/lead displacement.', 'Dizziness/syncope should be reported.'],
        'false': ['Device identification is unnecessary in emergencies in this note.', 'Hiccups are always benign in this context in this note.']
    },
    {
        'name': 'ICD function',
        'fact': 'ICD continuously monitors rhythm and delivers shock for ventricular fibrillation or ventricular tachycardia.',
        'priority': 'Use ICD in patients at risk for sudden cardiac death from lethal ventricular rhythms.',
        'true': ['ICD monitors rhythm continuously.', 'ICD shocks V-fib/V-tach per note.', 'ICD is indicated for sudden death risk patients.'],
        'false': ['ICD is for sinus bradycardia only in this note.', 'ICD does not treat ventricular arrhythmias in this note.']
    },
    {
        'name': 'If ICD fires',
        'fact': 'If ICD fires, patient should lie down, note time, and notify provider if symptoms continue.',
        'priority': 'Post-shock self-management reduces injury and ensures urgent follow-up.',
        'true': ['Lie down after ICD discharge is recommended.', 'Documenting shock time is recommended.', 'Persistent symptoms require provider notification.'],
        'false': ['Exercise immediately after shock is advised in this note.', 'ICD firing never requires follow-up in this note.']
    },
    {
        'name': 'Bystander sensation with ICD',
        'fact': 'People touching the patient during ICD discharge may feel mild shock that is not dangerous.',
        'priority': 'Provide reassurance to family and staff to reduce panic during discharge events.',
        'true': ['Bystanders may feel mild shock.', 'Mild shock to bystander is noted as not dangerous.', 'Education reduces fear around ICD events.'],
        'false': ['ICD discharge is fatal to bystanders in this note.', 'No one near patient feels anything in this note.']
    },
    {
        'name': 'ICD storm emergency',
        'fact': 'Repeated ICD firing should be reported immediately as an emergency (ICD storm).',
        'priority': 'Escalate recurrent shocks urgently for rhythm stabilization.',
        'true': ['Repeated firing is emergency in this note.', 'Immediate reporting is required.', 'Storm implies unstable arrhythmia burden.'],
        'false': ['Repeated shocks can be ignored if conscious in this note.', 'ICD storm is routine expected function in this note.']
    },
    {
        'name': 'Chest pain initial priorities',
        'fact': 'Chest pain protocol starts with ABC assessment, oxygen if saturation <90%, vitals, and 12-lead ECG within 10 minutes.',
        'priority': 'Rapid physiologic stabilization and STEMI detection are first-line priorities.',
        'true': ['ABCs come first in chest pain approach.', 'Oxygen threshold is O2 sat <90% in note.', 'ECG target is within 10 minutes.'],
        'false': ['Medications are given before ABC assessment in this note.', '12-lead ECG can be delayed several hours in this note.']
    },
    {
        'name': 'Chest pain workflow continuation',
        'fact': 'Protocol includes large-bore IV access, labs (troponin, CK-MB, BMP), and meds sequence: aspirin, nitroglycerin, morphine if needed, then heparin.',
        'priority': 'Establish access and objective diagnostics while initiating evidence-based medication sequence.',
        'true': ['Large-bore IV is listed.', 'Troponin/CK-MB/BMP are listed labs.', 'Aspirin then nitroglycerin then morphine/heparin sequence is listed.'],
        'false': ['No labs are needed for chest pain in this note.', 'Heparin is given before aspirin in this note.']
    },
    {
        'name': 'Nitroglycerin safety',
        'fact': 'Check blood pressure before nitroglycerin; avoid nitroglycerin if systolic BP <90 or recent sildenafil use within 24–48 hours.',
        'priority': 'Prevent severe hypotension from contraindicated nitrate administration.',
        'true': ['SBP <90 is NTG hold criterion.', 'Recent sildenafil is contraindication in this note.', 'BP check before NTG is emphasized.'],
        'false': ['NTG is safe regardless of BP in this note.', 'Sildenafil timing has no relevance in this note.']
    },
    {
        'name': 'Positioning HF/SOB',
        'fact': 'For heart failure/SOB, best position is HOB elevated 30–45° (Fowler) to reduce preload and ease breathing.',
        'priority': 'Use positioning to improve oxygenation while other therapies are prepared.',
        'true': ['Fowler position 30–45° is listed for HF/SOB.', 'Positioning reduces preload in this note.', 'Breathing relief is rationale for elevated HOB.'],
        'false': ['Flat Trendelenburg is best for HF/SOB in this note.', 'Position has no respiratory impact in this note.']
    },
    {
        'name': 'Positioning hypotension/shock',
        'fact': 'For hypotension/shock, position supine with legs elevated 15–30° to increase venous return.',
        'priority': 'Use immediate non-pharmacologic perfusion support while treating cause.',
        'true': ['Supine with legs elevated is listed for hypotension/shock.', 'Rationale is increased venous return.', 'Positioning is an early supportive intervention.'],
        'false': ['Sit upright is best for hypotensive shock in this note.', 'Leg lowering improves hypotension in this note.']
    },
    {
        'name': 'Cardiogenic shock position caution',
        'fact': 'For cardiogenic shock, note recommends supine with caution and to avoid Trendelenburg.',
        'priority': 'Balance BP support with cardiopulmonary tolerance in cardiogenic states.',
        'true': ['Trendelenburg is avoided in cardiogenic shock.', 'Supine positioning is listed with caution.', 'Positioning differs from routine assumptions.'],
        'false': ['Trendelenburg is first-line for cardiogenic shock in this note.', 'Cardiogenic shock requires sitting upright always in this note.']
    },
    {
        'name': 'Pericarditis and post-op positioning',
        'fact': 'Pericarditis position is sit up/lean forward; post-cardiac surgery preferred is semi-Fowler for comfort and lung expansion.',
        'priority': 'Condition-specific positioning can reduce pain and improve ventilation.',
        'true': ['Pericarditis relieved by sit up and leaning forward.', 'Post-cardiac surgery semi-Fowler is listed.', 'Lung expansion is rationale for semi-Fowler post-op.'],
        'false': ['Pericarditis is best managed flat supine in this note.', 'Post-op position should always be Trendelenburg in this note.']
    },
    {
        'name': 'Lifestyle diet teaching',
        'fact': 'Diet teaching includes sodium restriction <2 g/day, low saturated fat/cholesterol, high fiber/fruits/vegetables, and avoiding processed high-salt foods.',
        'priority': 'Long-term dietary adherence reduces cardiovascular decompensation risk.',
        'true': ['Sodium target <2 g/day is listed.', 'High-fiber fruits/vegetables are recommended.', 'Processed foods/deli meats/canned soups are discouraged.'],
        'false': ['High-sodium canned foods are recommended in this note.', 'Fiber should be minimized in this note.']
    },
    {
        'name': 'Lifestyle fluid/weight teaching',
        'fact': 'Lifestyle instructions include no smoking, weight loss if BMI >25, fluid restriction 1.5–2 L/day in HF, and daily weight reporting if gain >2 lb.',
        'priority': 'Self-monitoring and fluid control detect and prevent worsening heart failure.',
        'true': ['Fluid restriction 1.5–2 L/day is listed for HF.', 'Daily weight gain >2 lb should be reported.', 'Smoking cessation and weight-loss goals are included.'],
        'false': ['Unlimited fluids are advised for HF in this note.', 'Daily weight changes are irrelevant in this note.']
    },
    {
        'name': 'NCLEX perfusion tip',
        'fact': 'NCLEX tip emphasizes avoiding Trendelenburg for hypotension and prioritizing oxygenation/circulation first.',
        'priority': 'Stabilize airway-breathing-circulation before noncritical steps.',
        'true': ['Avoid Trendelenburg in hypotension is explicit tip.', 'Oxygenation is prioritized first.', 'Circulation support is prioritized first.'],
        'false': ['Trendelenburg is preferred for all hypotension in this note.', 'Documentation precedes circulation in this note.']
    }
]

mcq_templates = [
    'Which finding most strongly supports {name} in this cardiovascular device scenario?',
    'The nurse analyzes data; which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent prioritization, which conclusion aligns with {name}?',
    'Which statement best reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For management involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans care around {name}. Which items belong in the plan? (Select all that apply)',
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
        f'This presentation is more consistent with {concepts[(i + 5) % len(concepts)]["name"]}.',
        'Immediate reassessment is unnecessary when symptoms fluctuate briefly.',
        'Magnetic field precautions are optional and have no device implications.'
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
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Pacemakers & ICDs', 'Device indications, troubleshooting, and chest pain priorities', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - Pacemakers and ICDs (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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
