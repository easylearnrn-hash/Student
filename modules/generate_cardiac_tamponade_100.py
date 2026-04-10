import json
import random
from pathlib import Path

random.seed(43)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-CARDIAC-TAMPONADE-100.sql')
CATEGORY = 'Cardiac Tamponade - NCLEX'
TOPIC_NAME = 'Cardiac Tamponade'

concepts = [
    {
        'name': 'Definition',
        'fact': 'Cardiac tamponade is fluid accumulation in the pericardial sac that compresses the heart.',
        'priority': 'Treat as an emergency because rapid deterioration and arrest can occur.',
        'true': [
            'Tamponade involves pericardial fluid compressing cardiac chambers.',
            'Cardiac output falls when ventricular filling is impaired.',
            'Untreated tamponade can be rapidly fatal.'
        ],
        'false': [
            'Tamponade improves ventricular filling and raises cardiac output.',
            'Tamponade is a benign condition that can always wait for routine follow-up.'
        ]
    },
    {
        'name': 'Hemodynamic mechanism',
        'fact': 'Increased intrapericardial pressure compresses all four chambers and causes obstructive shock.',
        'priority': 'Recognize obstructive shock pattern when hypotension and poor perfusion progress.',
        'true': [
            'Rising intrapericardial pressure limits chamber filling.',
            'Reduced preload leads to reduced cardiac output.',
            'Tamponade can produce obstructive shock physiology.'
        ],
        'false': [
            'Tamponade is primarily distributive shock from vasodilation in this note.',
            'Tamponade increases preload by compressing the ventricles.'
        ]
    },
    {
        'name': 'Acute volume threshold',
        'fact': 'As little as 150–200 mL acutely accumulated fluid can cause tamponade.',
        'priority': 'Do not underestimate small but rapidly accumulating effusions.',
        'true': [
            'Rapid accumulation allows less compensation time.',
            'A relatively small acute effusion can be dangerous.',
            'Clinical deterioration depends on accumulation speed, not only total volume.'
        ],
        'false': [
            'Only massive chronic effusions can cause tamponade in this note.',
            'Volume rate of accumulation is irrelevant in tamponade risk.'
        ]
    },
    {
        'name': 'Cause profile',
        'fact': 'Pericarditis is the most common cause, with trauma, post-op bleeding, malignancy, and aortic dissection also listed.',
        'priority': 'Screen etiology rapidly while preparing definitive decompression.',
        'true': [
            'Pericarditis is listed as the most common cause.',
            'Penetrating or blunt trauma can precipitate tamponade.',
            'Malignancy and post-cardiac surgery are recognized causes.'
        ],
        'false': [
            'Tamponade is only caused by isolated dehydration in this note.',
            'Aortic dissection is excluded as a tamponade cause in this note.'
        ]
    },
    {
        'name': 'Additional causes',
        'fact': 'Additional causes include MI free-wall rupture, iatrogenic catheterization complications, SLE, uremia, and radiation therapy.',
        'priority': 'Integrate procedural and systemic risk factors into rapid triage.',
        'true': [
            'MI free-wall rupture is listed as a cause.',
            'Iatrogenic catheter-related complications can cause tamponade.',
            'Autoimmune disease and uremia are included causes.'
        ],
        'false': [
            'Radiation therapy cannot contribute to tamponade in this note.',
            'Tamponade causes are limited to congenital defects in this note.'
        ]
    },
    {
        'name': 'Beck triad',
        'fact': 'Beck triad consists of muffled heart sounds, JVD, and hypotension.',
        'priority': 'Escalate immediately when triad features cluster together.',
        'true': [
            'Muffled heart sounds are part of Beck triad.',
            'JVD is part of Beck triad.',
            'Hypotension is part of Beck triad.'
        ],
        'false': [
            'Wheezing replaces JVD in Beck triad in this note.',
            'Hypertension is part of Beck triad in this note.'
        ]
    },
    {
        'name': 'Muffled heart sounds meaning',
        'fact': 'Muffled tones occur because pericardial fluid dampens auscultated sounds.',
        'priority': 'Correlate difficult auscultation with other tamponade signs rather than dismissing technique.',
        'true': [
            'Fluid around the heart can dampen heart sounds.',
            'Muffled tones should be interpreted alongside hypotension and JVD.',
            'Auscultation findings can be subtle but clinically important.'
        ],
        'false': [
            'Muffled sounds indicate hyperdynamic output in this note.',
            'Muffled tones rule out tamponade in this note.'
        ]
    },
    {
        'name': 'JVD mechanism',
        'fact': 'JVD reflects impaired right-heart filling and backed-up venous pressure.',
        'priority': 'Use venous congestion findings to support obstructive physiology.',
        'true': [
            'Impaired right-heart filling contributes to JVD.',
            'Backed-up venous pressure can appear as neck vein distension.',
            'JVD is a high-yield bedside tamponade clue.'
        ],
        'false': [
            'JVD in tamponade represents low venous pressure in this note.',
            'JVD is unrelated to right-heart filling in this note.'
        ]
    },
    {
        'name': 'Hypotension pattern',
        'fact': 'Hypotension occurs from reduced cardiac output and often presents with narrow pulse pressure.',
        'priority': 'Treat narrowing pulse pressure with falling BP as decompensation.',
        'true': [
            'Reduced cardiac output contributes to hypotension.',
            'Narrow pulse pressure can occur in tamponade.',
            'Hypotension should prompt emergency intervention readiness.'
        ],
        'false': [
            'Tamponade typically causes widened pulse pressure in this note.',
            'Hypotension is not expected in tamponade according to this note.'
        ]
    },
    {
        'name': 'Pulsus paradoxus',
        'fact': 'Pulsus paradoxus is a >10 mmHg systolic BP drop during inspiration.',
        'priority': 'Use this measurement to reinforce tamponade suspicion in unstable patients.',
        'true': [
            'A >10 mmHg inspiratory systolic drop indicates pulsus paradoxus.',
            'Pulsus paradoxus supports tamponade assessment.',
            'Inspiratory BP variation is specifically emphasized in this note.'
        ],
        'false': [
            'Pulsus paradoxus is defined as a diastolic rise in this note.',
            'A 2 mmHg inspiratory change defines pulsus paradoxus in this note.'
        ]
    },
    {
        'name': 'Compensatory tachycardia',
        'fact': 'Tachycardia is listed as a compensatory sign in tamponade.',
        'priority': 'Interpret rising heart rate with perfusion decline as compensation failure risk.',
        'true': [
            'Tachycardia can be a compensatory response in tamponade.',
            'Compensation may coexist with hypotension as condition worsens.',
            'Trend vitals rather than evaluating heart rate in isolation.'
        ],
        'false': [
            'Bradycardia is the expected compensatory response in this note.',
            'Heart rate has no monitoring value in tamponade in this note.'
        ]
    },
    {
        'name': 'Perfusion decline',
        'fact': 'Cool clammy skin and decreased urine output are signs of shock/perfusion compromise.',
        'priority': 'Prioritize perfusion rescue and definitive decompression.',
        'true': [
            'Cool clammy skin can indicate shock in tamponade.',
            'Urine output may decrease with low cardiac output.',
            'Perfusion signs should be trended urgently.'
        ],
        'false': [
            'Increased urine output is expected in tamponade shock in this note.',
            'Warm dry skin is listed as hallmark obstructive shock in this note.'
        ]
    },
    {
        'name': 'Respiratory/general signs',
        'fact': 'Dyspnea, orthopnea, anxiety/restlessness, and possible dysphagia are listed additional findings.',
        'priority': 'Interpret escalating respiratory distress and anxiety as potential hemodynamic deterioration.',
        'true': [
            'Dyspnea may occur with tamponade.',
            'Orthopnea can be present in tamponade.',
            'Anxiety and restlessness are compatible with acute instability.'
        ],
        'false': [
            'Tamponade in this note is always asymptomatic until arrest.',
            'Dysphagia cannot occur with larger effusions in this note.'
        ]
    },
    {
        'name': 'Electrical alternans',
        'fact': 'Electrical alternans (alternating QRS amplitude) is pathognomonic and tamponade until proven otherwise.',
        'priority': 'Treat electrical alternans as a red-flag trigger for immediate escalation.',
        'true': [
            'Electrical alternans is beat-to-beat QRS amplitude variation.',
            'Electrical alternans strongly supports tamponade in this note.',
            'Alternans should trigger urgent provider notification and prep for intervention.'
        ],
        'false': [
            'Electrical alternans is a benign normal variant in this note.',
            'Alternans excludes pericardial fluid in this note.'
        ]
    },
    {
        'name': 'Other EKG clues',
        'fact': 'Low-voltage QRS and sinus tachycardia are common; diffuse ST elevation can appear if pericarditis is the cause.',
        'priority': 'Integrate EKG pattern with etiology and bedside instability.',
        'true': [
            'Low-voltage QRS can appear in tamponade.',
            'Sinus tachycardia is a common rhythm finding.',
            'Diffuse ST elevation may occur when pericarditis underlies tamponade.'
        ],
        'false': [
            'High-voltage QRS is the defining tamponade pattern in this note.',
            'Tamponade cannot coexist with pericarditis EKG changes in this note.'
        ]
    },
    {
        'name': 'Echo diagnosis',
        'fact': 'Echocardiogram is the gold standard and shows effusion with chamber compression.',
        'priority': 'Expedite bedside echo in unstable patients with suspected tamponade.',
        'true': [
            'Echocardiography is the gold-standard diagnostic test.',
            'Echo can show pericardial effusion and chamber compression.',
            'Echo findings guide urgent decompression decisions.'
        ],
        'false': [
            'Chest X-ray is the gold standard in this note.',
            'Echo has no role in tamponade diagnosis in this note.'
        ]
    },
    {
        'name': 'Chest X-ray clue',
        'fact': 'Chest X-ray may show an enlarged water-bottle cardiac silhouette.',
        'priority': 'Use X-ray as supportive evidence, not a delay to treatment.',
        'true': [
            'A water-bottle silhouette can support tamponade suspicion.',
            'X-ray is supportive but not the definitive emergent test.',
            'Imaging should be integrated with hemodynamics and bedside findings.'
        ],
        'false': [
            'Normal silhouette excludes tamponade in this note.',
            'Water-bottle silhouette confirms acute coronary occlusion in this note.'
        ]
    },
    {
        'name': 'Pericardiocentesis emergency',
        'fact': 'Immediate pericardiocentesis is the emergency treatment.',
        'priority': 'Prepare urgently and do not delay for nonessential steps.',
        'true': [
            'Pericardiocentesis is the immediate definitive intervention.',
            'Rapid decompression can be lifesaving in tamponade.',
            'Urgent provider notification and procedural preparation are priorities.'
        ],
        'false': [
            'Pericardiocentesis should be deferred until routine clinic follow-up.',
            'Diuretics alone are definitive first-line emergency treatment in this note.'
        ]
    },
    {
        'name': 'Pericardiocentesis technique',
        'fact': 'Patient is semi-recumbent at 45°, needle subxiphoid toward left shoulder.',
        'priority': 'Anticipate setup details to reduce delay during emergency decompression.',
        'true': [
            'Semi-recumbent positioning at about 45° is listed.',
            'Subxiphoid entry directed toward the left shoulder is described.',
            'Procedure setup should be rapid and organized.'
        ],
        'false': [
            'Prone positioning is preferred for tamponade aspiration in this note.',
            'Needle is directed toward the right hip in this note.'
        ]
    },
    {
        'name': 'Small-volume benefit',
        'fact': 'Removing even 20–50 mL can significantly increase cardiac output.',
        'priority': 'Recognize that early partial decompression can rapidly stabilize perfusion.',
        'true': [
            'Small-volume drainage can produce meaningful hemodynamic improvement.',
            'Cardiac output may rise after limited fluid removal.',
            'Clinical response should be reassessed continuously after drainage.'
        ],
        'false': [
            'At least 1 liter must be removed before hemodynamics improve in this note.',
            'Drainage has no immediate effect on output in this note.'
        ]
    },
    {
        'name': 'Fluid analysis',
        'fact': 'Pericardial fluid should be sent for culture, cytology, and chemistry.',
        'priority': 'Pair emergency stabilization with etiology workup.',
        'true': [
            'Culture is part of fluid analysis.',
            'Cytology is part of fluid analysis.',
            'Chemistry testing is part of fluid analysis.'
        ],
        'false': [
            'Pericardial fluid analysis is unnecessary after aspiration in this note.',
            'Only glucose is sent, with no culture/cytology/chemistry in this note.'
        ]
    },
    {
        'name': 'Supportive preload strategy',
        'fact': 'IV fluid bolus is used to maintain preload in tamponade.',
        'priority': 'Maintain filling while arranging definitive decompression.',
        'true': [
            'IV fluids may support preload in tamponade.',
            'Preload support can temporarily improve hemodynamics.',
            'Supportive therapy does not replace urgent pericardiocentesis.'
        ],
        'false': [
            'All preload support is contraindicated in tamponade in this note.',
            'Tamponade management in this note avoids all IV fluid administration.'
        ]
    },
    {
        'name': 'Avoidance list',
        'fact': 'Avoid diuretics and vasodilators; avoid positive pressure ventilation when possible due to reduced venous return.',
        'priority': 'Prevent iatrogenic preload reduction in unstable tamponade.',
        'true': [
            'Diuretics can worsen preload in tamponade.',
            'Vasodilators can worsen hemodynamics by reducing preload.',
            'Positive pressure ventilation may reduce venous return and should be avoided if possible.'
        ],
        'false': [
            'High-dose vasodilators are first-line tamponade stabilizers in this note.',
            'Positive pressure ventilation always improves tamponade preload in this note.'
        ]
    },
    {
        'name': 'Surgical option',
        'fact': 'Pericardial window is considered for recurrent tamponade.',
        'priority': 'Plan recurrence management beyond initial aspiration.',
        'true': [
            'Pericardial window is listed for recurrent tamponade.',
            'Recurrence risk requires ongoing follow-up planning.',
            'Definitive surgical drainage may be needed after repeated episodes.'
        ],
        'false': [
            'Pericardial window is contraindicated in recurrent tamponade in this note.',
            'Recurrence is impossible after one aspiration according to this note.'
        ]
    },
    {
        'name': 'NCLEX first action',
        'fact': 'First action is immediate provider notification and preparation for pericardiocentesis.',
        'priority': 'Do not delay life-saving decompression for low-yield tasks.',
        'true': [
            'Immediate provider notification is prioritized.',
            'Preparation for pericardiocentesis is urgent.',
            'Delay can lead to arrest within minutes.'
        ],
        'false': [
            'Routine discharge teaching is first action in this note.',
            'Observation-only management is adequate in suspected tamponade in this note.'
        ]
    },
    {
        'name': 'Post-procedure monitoring',
        'fact': 'After pericardiocentesis, monitor for re-accumulation because symptoms can return.',
        'priority': 'Sustain surveillance after initial stabilization.',
        'true': [
            'Symptoms can recur due to fluid re-accumulation.',
            'Post-procedure monitoring is essential.',
            'Reassessment should include recurring hypotension/JVD/muffled tones signs.'
        ],
        'false': [
            'No monitoring is needed after successful aspiration in this note.',
            'Recurrence is not possible post-procedure in this note.'
        ]
    },
    {
        'name': 'Differentiation clue',
        'fact': 'The note states tamponade chest pain worsens during expiration and coughing; cough is not typical of MI.',
        'priority': 'Use distinguishing chest pain pattern and associated symptoms for differential prioritization.',
        'true': [
            'Tamponade/pericardial pain may worsen with coughing in this note.',
            'The note contrasts this pattern with typical MI presentation.',
            'Differential reasoning should incorporate associated respiratory features.'
        ],
        'false': [
            'The note says cough is a classic MI hallmark finding.',
            'Tamponade pain is unrelated to breathing/cough in this note.'
        ]
    }
]

mcq_templates = [
    'A patient in acute cardiovascular decline is reassessed. Which finding best supports {name}?',
    'During rapid handoff, which interpretation is most accurate for {name}?',
    'The nurse must prioritize interventions. Which statement best reflects {name}?',
    'A high-acuity symptom cluster is reviewed. Which conclusion best matches {name}?',
    'Which clinical judgment is most consistent with {name}?'
]

sata_templates = [
    'A nurse is evaluating a patient for {name}. Which findings or actions are appropriate? (Select all that apply)',
    'For a patient with suspected {name}, which statements are correct? (Select all that apply)',
    'The charge nurse audits care planning for {name}. Which items should be included? (Select all that apply)',
    'During patient teaching about {name}, which points are accurate? (Select all that apply)',
    'Which assessment findings support {name}? (Select all that apply)'
]


def option_objects(texts):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(texts)]


def esc(s: str) -> str:
    return s.replace("'", "''")


questions = []

# 50 Very Hard MCQ
for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'])
    correct = c['fact'] if i % 2 == 0 else c['priority']

    distractors = c['false'] + [
        f'This finding is more consistent with {concepts[(i+4) % len(concepts)]["name"]}.',
        'Immediate deterioration risk is low, so urgent escalation is unnecessary.',
        'Preload reduction is preferred before confirming diagnosis in unstable cases.'
    ]
    random.shuffle(distractors)
    options = [correct] + distractors[:3]
    random.shuffle(options)

    ans_id = chr(97 + options.index(correct))
    rationale = f"Correct because {c['fact']} {c['priority']}"

    questions.append({
        'stem': stem,
        'options': option_objects(options),
        'correct': [ans_id],
        'rationale': rationale,
        'is_multi': False
    })

# 50 SATA
for i in range(50):
    c = concepts[i % len(concepts)]
    stem = sata_templates[i % len(sata_templates)].format(name=c['name'])

    true_opts = c['true'][:]
    false_opts = c['false'][:]
    random.shuffle(true_opts)
    random.shuffle(false_opts)

    selected_true = true_opts[:3]
    selected_false = false_opts[:2]
    all_opts = selected_true + selected_false
    random.shuffle(all_opts)

    correct_ids = [chr(97 + idx) for idx, txt in enumerate(all_opts) if txt in selected_true]

    rationale = f"Correct selections align with note-based facts: {c['fact']}"

    questions.append({
        'stem': stem,
        'options': option_objects(all_opts),
        'correct': correct_ids,
        'rationale': rationale,
        'is_multi': True
    })

assert len(questions) == 100

END_IF_SQL = '  END IF;'

lines = []
lines.append('BEGIN;')
lines.append('DO $$')
lines.append('DECLARE')
lines.append('  v_subject_id UUID;')
lines.append('  v_topic_id UUID;')
lines.append('  v_test_id BIGINT;')
lines.append('BEGIN')
lines.append("  SELECT id INTO v_subject_id FROM test_subjects WHERE name ILIKE '%cardio%' ORDER BY id LIMIT 1;")
lines.append('  IF v_subject_id IS NULL THEN')
lines.append("    INSERT INTO test_subjects (name, description) VALUES ('Cardiovascular System', 'Cardiovascular notes') RETURNING id INTO v_subject_id;")
lines.append(END_IF_SQL)
lines.append("  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'Cardiac Tamponade' LIMIT 1;")
lines.append('  IF v_topic_id IS NULL THEN')
lines.append("    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Cardiac Tamponade', 'Beck''s triad, diagnosis, and emergency management', 'published') RETURNING id INTO v_topic_id;")
lines.append(END_IF_SQL)
lines.append('  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;')
lines.append('  IF v_test_id IS NULL THEN')
lines.append("    INSERT INTO tests (test_name, system_category, description, is_active)")
lines.append("    VALUES ('Cardiovascular System - Cardiac Tamponade (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)")
lines.append('    RETURNING id INTO v_test_id;')
lines.append(END_IF_SQL)
lines.append(f"  DELETE FROM test_questions WHERE topic_id = v_topic_id AND category = '{CATEGORY}';")

for i, q in enumerate(questions, start=1):
    stem = esc(q['stem'])
    options = esc(json.dumps(q['options'], ensure_ascii=False))
    correct = esc(json.dumps(q['correct'], ensure_ascii=False))
    rationale = esc(q['rationale'])
    is_multi = 'true' if q['is_multi'] else 'false'

    lines.append('  INSERT INTO test_questions (test_id, topic_id, question, question_stem, options, correct_answer, rationale, category, is_multiple_choice, display_order, points, is_active)')
    lines.append(
        f"  VALUES (v_test_id, v_topic_id, '{stem}', '{stem}', '{options}'::jsonb, '{correct}'::jsonb, '{rationale}', '{CATEGORY}', {is_multi}, {i}, 1, true);"
    )

lines.append('END $$;')
lines.append('COMMIT;')

OUT_PATH.write_text('\n'.join(lines), encoding='utf-8')
print(f'Wrote {OUT_PATH} with {len(questions)} questions')
