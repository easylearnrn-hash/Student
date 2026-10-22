import json
import re
import statistics
import random
from pathlib import Path

random.seed(44)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-PERICARDITIS-100.sql')
CATEGORY = 'Pericarditis - NCLEX'
TOPIC = 'Pericarditis'

concepts = [
    {
        'name': 'Definition',
        'fact': 'Pericarditis is inflammation of the pericardium, the fibrous sac surrounding the heart.',
        'priority': 'Identify inflammatory pericardial pain patterns early to prevent complications.',
        'true': [
            'Pericarditis involves inflammation of pericardial layers.',
            'The pericardium is the sac around the heart.',
            'Inflammation can progress to pericardial effusion.'
        ],
        'false': [
            'Pericarditis is inflammation of heart valves.',
            'Pericarditis is confined to coronary arteries.'
        ]
    },
    {
        'name': 'Disease course',
        'fact': 'Pericarditis can be acute, recurrent, or chronic constrictive.',
        'priority': 'Recurrent patterns require recurrence-prevention therapy and follow-up.',
        'true': [
            'Acute forms are described.',
            'Recurrent forms are described.',
            'Chronic constrictive forms are also listed.'
        ],
        'false': [
            'Pericarditis is always single-episode and never recurrent.',
            'Constrictive disease is unrelated to pericarditis.'
        ]
    },
    {
        'name': 'Effusion complication',
        'fact': 'Fluid accumulation can cause pericardial effusion, and large effusions can lead to cardiac tamponade.',
        'priority': 'Escalate promptly when effusion signs appear because tamponade is life-threatening.',
        'true': [
            'Pericardial inflammation can produce effusion.',
            'Large effusions can compress the heart.',
            'Tamponade is a life-threatening pericarditis complication.'
        ],
        'false': [
            'Effusion improves cardiac filling.',
            'Tamponade is a harmless expected phase.'
        ]
    },
    {
        'name': 'Common causes',
        'fact': 'Viral causes are most common, and many cases are idiopathic.',
        'priority': 'Prioritize broad etiologic review while managing inflammation and pain.',
        'true': [
            'Viral etiologies are highlighted as most common.',
            'Idiopathic cases are frequent.',
            'Coxsackievirus/Echovirus/Influenza are listed viral examples.'
        ],
        'false': [
            'Pericarditis is almost never viral.',
            'Idiopathic causes are excluded.'
        ]
    },
    {
        'name': 'Systemic/infectious causes',
        'fact': 'Bacterial TB/S. aureus, autoimmune disease, uremia, malignancy, radiation, trauma, surgery, and medications are listed causes.',
        'priority': 'Tailor treatment to the underlying cause while controlling inflammation.',
        'true': [
            'TB and S. aureus are listed infectious causes.',
            'SLE/RA/scleroderma are autoimmune causes.',
            'Hydralazine and Procainamide are listed medication causes.'
        ],
        'false': [
            'Pericarditis is unrelated to renal failure.',
            'Radiation cannot cause pericarditis.'
        ]
    },
    {
        'name': 'Dressler syndrome timing',
        'fact': 'Dressler syndrome is autoimmune pericarditis occurring 1–6 weeks after MI or cardiac surgery.',
        'priority': 'Recognize delayed post-MI/surgical chest pain as possible Dressler syndrome.',
        'true': [
            'Dressler syndrome can occur after MI.',
            'Timing is listed as 1–6 weeks post-event.',
            'Cardiac surgery is another trigger.'
        ],
        'false': [
            'Dressler syndrome occurs immediately during MI.',
            'Dressler syndrome is bacterial endocarditis.'
        ]
    },
    {
        'name': 'Classic pain profile',
        'fact': 'Pericarditis pain is sharp/pleuritic, worse with inspiration and lying flat, and relieved by sitting up/leaning forward.',
        'priority': 'Use positional and pleuritic features to distinguish from ischemic chest pain patterns.',
        'true': [
            'Pain worsens when lying flat.',
            'Pain worsens with inspiration.',
            'Leaning forward provides relief.'
        ],
        'false': [
            'Pain is position-independent pressure pain.',
            'Leaning forward worsens pain.'
        ]
    },
    {
        'name': 'Radiation and associated symptoms',
        'fact': 'Pain can radiate to left shoulder/trapezius; fever, malaise, myalgia, and dyspnea can occur.',
        'priority': 'Link systemic symptoms with inflammatory etiology during triage.',
        'true': [
            'Left shoulder/trapezius radiation is described.',
            'Dyspnea can accompany pericarditis.',
            'Viral-associated constitutional symptoms may occur.'
        ],
        'false': [
            'Trapezius radiation excludes pericarditis.',
            'Dyspnea never occurs in pericarditis.'
        ]
    },
    {
        'name': 'Friction rub hallmark',
        'fact': 'Pericardial friction rub is pathognomonic: high-pitched scratchy/grating, best heard at left sternal border with patient leaning forward.',
        'priority': 'Prioritize focused auscultation technique to capture fleeting rub findings.',
        'true': [
            'Friction rub is pathognomonic.',
            'The rub is described as high-pitched scratchy/grating.',
            'Best heard at left sternal border while leaning forward.'
        ],
        'false': [
            'Friction rub is a definitive MI finding.',
            'Rub is best heard at the carotids.'
        ]
    },
    {
        'name': 'Rub nuances',
        'fact': 'The rub may be triphasic and can disappear if effusion develops as fluid separates pericardial layers.',
        'priority': 'Do not rule out pericarditis solely because rub is absent later in disease.',
        'true': [
            'Triphasic friction rub may be present.',
            'Rub can disappear when effusion increases.',
            'Loss of rub does not exclude worsening complications.'
        ],
        'false': [
            'Persistent rub is required throughout all stages.',
            'Effusion makes rub louder by increasing friction.'
        ]
    },
    {
        'name': 'Diffuse ST elevation',
        'fact': 'Pericarditis classically shows diffuse (all-lead) saddle-shaped ST elevation.',
        'priority': 'Differentiate diffuse inflammatory ST elevation from territorial ischemic patterns.',
        'true': [
            'Diffuse ST elevation is emphasized.',
            'Saddle-shaped morphology is associated with pericarditis.',
            'This pattern differs from localized MI territories.'
        ],
        'false': [
            'Pericarditis causes only contiguous territorial ST elevation.',
            'ST elevation is absent in pericarditis.'
        ]
    },
    {
        'name': 'PR depression',
        'fact': 'PR depression is a classic early pericarditis finding and opposite ST direction.',
        'priority': 'Use PR deviation as a high-yield discriminator in early interpretation.',
        'true': [
            'PR depression is a classic finding.',
            'It appears early in the disease course.',
            'PR direction contrasts with ST elevation.'
        ],
        'false': [
            'PR elevation is the classic early finding.',
            'PR changes are irrelevant in pericarditis.'
        ]
    },
    {
        'name': 'No reciprocal changes',
        'fact': 'Pericarditis has no reciprocal ST depression, unlike MI.',
        'priority': 'Avoid mislabeling diffuse pericarditis as STEMI when reciprocal changes are absent.',
        'true': [
            'Reciprocal ST depression is absent in pericarditis.',
            'Reciprocal changes support MI rather than pericarditis.',
            'This distinction is used in pericarditis vs MI comparison.'
        ],
        'false': [
            'Pericarditis requires reciprocal ST depression.',
            'Reciprocal changes have no differential value.'
        ]
    },
    {
        'name': 'Later EKG evolution',
        'fact': 'T-wave inversion may appear in later stages; electrical alternans can appear with large effusion.',
        'priority': 'Interpret EKG changes in temporal context and effusion severity.',
        'true': [
            'T-wave inversion can occur later.',
            'Electrical alternans can accompany large effusion.',
            'EKG pattern evolves over time in pericarditis.'
        ],
        'false': [
            'EKG pattern is fixed and never evolves.',
            'Electrical alternans excludes effusion.'
        ]
    },
    {
        'name': 'Pericarditis vs MI pain differences',
        'fact': 'Pericarditis pain is gradual, sharp, pleuritic, and positional; MI pain is sudden, crushing, pressure-like, and non-positional.',
        'priority': 'Use symptom quality and positional response to sharpen early triage decisions.',
        'true': [
            'Pericarditis pain is often pleuritic and positional.',
            'MI pain is described as pressure-like/crushing.',
            'MI pain is generally not position-dependent.'
        ],
        'false': [
            'Pericarditis pain is classically crushing pressure.',
            'MI pain improves when leaning forward.'
        ]
    },
    {
        'name': 'Pericarditis vs MI EKG/lab clues',
        'fact': 'Pericarditis: diffuse ST elevation + PR depression + absent Q waves; MI: localized ST elevation, reciprocal changes, Q waves in STEMI, higher troponin rise.',
        'priority': 'Integrate EKG with biomarker pattern to avoid anchoring errors.',
        'true': [
            'Diffuse ST elevation with PR depression supports pericarditis.',
            'Localized ST elevation with reciprocal changes supports MI.',
            'Troponin may be mildly elevated in myopericarditis but higher in MI.'
        ],
        'false': [
            'Q waves are a pericarditis hallmark.',
            'Troponin is never elevated in any pericarditis scenario.'
        ]
    },
    {
        'name': 'First-line therapy',
        'fact': 'First-line treatment is NSAIDs (ibuprofen/aspirin) plus colchicine to reduce recurrence risk.',
        'priority': 'Start anti-inflammatory therapy early and include recurrence prevention.',
        'true': [
            'NSAIDs are first-line.',
            'Colchicine is added to reduce recurrence risk.',
            'Combination therapy is emphasized for acute management.'
        ],
        'false': [
            'Colchicine is contraindicated in all pericarditis.',
            'Opioids are listed as definitive first-line therapy.'
        ]
    },
    {
        'name': 'Activity guidance',
        'fact': 'Rest and activity restriction are recommended during the acute phase; avoid strenuous exercise until symptom-free.',
        'priority': 'Prevent recurrence/worsening by enforcing temporary exertion limits.',
        'true': [
            'Rest is recommended in acute pericarditis.',
            'Strenuous exercise should be avoided until symptom-free.',
            'Activity guidance is part of initial management.'
        ],
        'false': [
            'High-intensity exercise accelerates recovery.',
            'No activity limits are needed during acute phase.'
        ]
    },
    {
        'name': 'Second-line steroids',
        'fact': 'Corticosteroids are reserved when NSAID/colchicine fails or for specific causes like SLE.',
        'priority': 'Use steroids selectively to avoid unnecessary exposure and recurrence risk concerns.',
        'true': [
            'Prednisone is not first-line in routine cases.',
            'Steroids are considered when first-line therapy fails.',
            'Specific etiologies (e.g., SLE) can justify steroid use.'
        ],
        'false': [
            'Steroids are mandatory first-line for all cases.',
            'SLE-related pericarditis should avoid steroids.'
        ]
    },
    {
        'name': 'Cause-specific caveats',
        'fact': 'Avoid NSAIDs in uremic pericarditis; use IV antibiotics for bacterial causes and anti-TB therapy for TB.',
        'priority': 'Adapt treatment to etiology instead of one-size-fits-all prescribing.',
        'true': [
            'Uremic pericarditis is a context to avoid NSAIDs.',
            'Bacterial pericarditis requires IV antibiotics.',
            'TB pericarditis requires anti-TB therapy.'
        ],
        'false': [
            'All causes are treated identically with NSAID monotherapy.',
            'TB management is excluded from pericarditis care.'
        ]
    },
    {
        'name': 'Tamponade emergency bridge',
        'fact': 'Tamponade complication is identified by Beck triad and treated with emergency pericardiocentesis.',
        'priority': 'Escalate immediately when hypotension + JVD + muffled tones develop.',
        'true': [
            'Beck triad is listed with tamponade complication.',
            'Emergency pericardiocentesis is required for tamponade.',
            'Tamponade is life-threatening.'
        ],
        'false': [
            'Tamponade in pericarditis is managed with observation only.',
            'Beck triad excludes tamponade.'
        ]
    },
    {
        'name': 'Dressler management caveat',
        'fact': 'Dressler syndrome is treated with NSAIDs + colchicine and anticoagulants are avoided due to bleeding risk into pericardium.',
        'priority': 'Prevent iatrogenic hemopericardium by avoiding anticoagulants in this context.',
        'true': [
            'NSAID plus colchicine is recommended for Dressler syndrome.',
            'Anticoagulants are avoided because of pericardial bleeding risk.',
            'Dressler is autoimmune and post-MI/surgery.'
        ],
        'false': [
            'Routine anticoagulation is first-line Dressler treatment.',
            'Dressler treatment excludes NSAIDs.'
        ]
    },
    {
        'name': 'NCLEX triage anchor',
        'fact': 'In suspected pericarditis, prioritize pain pattern recognition, friction rub assessment, EKG interpretation, and tamponade surveillance.',
        'priority': 'Rapid differentiation from MI and early complication detection guide safe outcomes.',
        'true': [
            'Pain pattern and position response are triage anchors.',
            'Friction rub and EKG clues are high-yield assessments.',
            'Monitor for progression to effusion/tamponade.'
        ],
        'false': [
            'Triage can ignore EKG in chest pain with suspected pericarditis.',
            'Tamponade surveillance is unnecessary in pericarditis.'
        ]
    },
    {
        'name': 'Hallmark synthesis',
        'fact': 'Core hallmarks are pleuritic positional chest pain, friction rub, diffuse ST elevation, PR depression, and absent reciprocal ST changes.',
        'priority': 'Synthesize multi-domain clues rather than relying on one isolated finding.',
        'true': [
            'Pleuritic positional pain is a hallmark.',
            'Friction rub is a hallmark.',
            'Diffuse ST elevation with PR depression supports diagnosis.'
        ],
        'false': [
            'Reciprocal ST depression is a hallmark of pericarditis.',
            'Localized-only ST elevation is required for diagnosis.'
        ]
    }
]

mcq_templates = [
    'According to the {topic} note, which statement about "{name}" is most accurate?',
    'The nurse is reviewing "{name}" in {topic}. Which statement is correct?',
    'Which clinical judgment is most accurate regarding "{name}" in {topic}?',
    'In rapid prioritization, which statement is most consistent with "{name}" in {topic}?',
    'Which conclusion about "{name}" in {topic} would the nurse recognize as correct?'
]

sata_templates = [
    'Which statements about "{name}" in {topic} are correct? (Select all that apply)',
    'For {topic}, which findings or actions relate to "{name}"? (Select all that apply)',
    'The nurse is planning care. Which items apply to "{name}" in {topic}? (Select all that apply)',
    'Which of the following are consistent with "{name}" in {topic}? (Select all that apply)',
    'During reassessment, which observations align with "{name}" in {topic}? (Select all that apply)'
]


def option_objects(texts):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(texts)]


def esc(s: str) -> str:
    return s.replace("'", "''")


questions = []

# 50 Very Hard MCQ
for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'], topic=TOPIC)
    distractors = c['false'] + [
        # a false statement from another section, never a section heading
        concepts[(i + 3) % len(concepts)]['false'][(i // len(concepts)) % 2],
        'Immediate escalation is unnecessary because complication risk is negligible.',
        'The best approach is to defer EKG differentiation until outpatient review.'
    ]
    # pick the correct statement whose length is closest to the wrong ones so length does not give it away
    meta = re.compile(r'listed|described|highlighted|emphasized|mentioned|noted')
    cands = [t for t in [c['fact'], c['priority']] + c['true'] if len(t) >= 35 and not meta.search(t)] or [c['fact'], c['priority']]
    mid = statistics.median(len(d) for d in distractors)
    cands.sort(key=lambda t: abs(len(t) - mid))
    correct = cands[(i // len(concepts)) % min(2, len(cands))]
    own = min(c['false'], key=lambda d: abs(len(d) - len(correct)))
    extra = [f for k in (3, 8) for f in concepts[(i + k) % len(concepts)]['false']]
    rest = [d for d in dict.fromkeys(distractors + extra) if d not in (own, correct)]
    random.shuffle(rest)
    rest.sort(key=lambda d: abs(len(d) - len(correct)))  # similar lengths so the answer is not the longest option
    options = [correct, own] + rest[:2]
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
    stem = sata_templates[i % len(sata_templates)].format(name=c['name'], topic=TOPIC)

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
lines.append("  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'Pericarditis' LIMIT 1;")
lines.append('  IF v_topic_id IS NULL THEN')
lines.append("    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Pericarditis', 'Inflammation, EKG changes, MI differential, treatment', 'published') RETURNING id INTO v_topic_id;")
lines.append(END_IF_SQL)
lines.append('  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;')
lines.append('  IF v_test_id IS NULL THEN')
lines.append("    INSERT INTO tests (test_name, system_category, description, is_active)")
lines.append("    VALUES ('Cardiovascular System - Pericarditis (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)")
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
