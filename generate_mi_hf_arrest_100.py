import json
import re
import statistics
import random
from pathlib import Path

random.seed(47)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-MI-HF-ARREST-100.sql')
CATEGORY = 'MI vs HF vs Cardiac Arrest - NCLEX'
TOPIC = 'Heart Attack vs Heart Failure vs Cardiac Arrest'
TOPIC_NAME = 'Heart Attack vs Heart Failure vs Cardiac Arrest'

concepts = [
    {
        'name': 'MI definition',
        'fact': 'Heart attack (MI) is blocked coronary blood flow causing heart muscle death.',
        'priority': 'Treat suspected MI as time-sensitive myocardial injury requiring rapid reperfusion strategy.',
        'true': ['MI involves coronary blood-flow blockage.', 'Myocardial tissue death occurs with sustained ischemia.', 'MI is an acute emergency condition.'],
        'false': ['MI is primarily chronic fluid overload.', 'MI occurs with absent pulse by definition.']
    },
    {
        'name': 'HF definition',
        'fact': 'Heart failure is a condition where the heart is too weak or stiff to pump effectively.',
        'priority': 'Differentiate pump failure from acute coronary occlusion and arrest during triage.',
        'true': ['HF is impaired pumping/filling efficiency.', 'HF often develops more gradually than MI.', 'HF patients may still have a pulse and consciousness.'],
        'false': ['HF means sudden cessation of all heart activity.', 'HF always presents with no pulse.']
    },
    {
        'name': 'Cardiac arrest definition',
        'fact': 'Cardiac arrest is sudden stop of all effective heart activity, causing no pulse and unresponsiveness.',
        'priority': 'Start CPR immediately when pulse is absent and patient is unresponsive.',
        'true': ['Cardiac arrest has absent pulse.', 'Cardiac arrest patients are unconscious.', 'Immediate resuscitation is required in arrest.'],
        'false': ['Cardiac arrest patients are usually awake and conversational.', 'Cardiac arrest is gradual over months.']
    },
    {
        'name': 'Onset differences',
        'fact': 'MI onset is sudden in minutes, heart failure is gradual over weeks-months, and cardiac arrest is immediate in seconds.',
        'priority': 'Use onset timeline to prioritize differential and response speed.',
        'true': ['MI is sudden.', 'HF is typically gradual.', 'Cardiac arrest occurs in seconds.'],
        'false': ['HF generally begins in seconds.', 'Cardiac arrest develops gradually over weeks.']
    },
    {
        'name': 'Pulse consciousness pattern',
        'fact': 'MI and HF generally have a pulse; cardiac arrest has no pulse and unconsciousness.',
        'priority': 'Pulse check rapidly separates arrest from non-arrest chest pain syndromes.',
        'true': ['Cardiac arrest has no pulse.', 'MI often presents while conscious.', 'HF patients may have weak but present pulse.'],
        'false': ['Pulse is absent in uncomplicated HF.', 'MI always has no pulse at presentation.']
    },
    {
        'name': 'MI causes',
        'fact': 'MI causes listed include atherosclerotic plaque and clot blocking coronary artery; risk factors include HTN, smoking, cholesterol, diabetes, sedentary lifestyle.',
        'priority': 'Risk-profile plus symptoms should prompt urgent MI protocol activation.',
        'true': ['Atherosclerosis and thrombosis are listed MI causes.', 'HTN/smoking/cholesterol/diabetes are listed risks.', 'Sedentary lifestyle is listed as risk.'],
        'false': ['MI is caused only by chronic valve calcification.', 'Smoking lowers MI risk.']
    },
    {
        'name': 'MI symptoms classic',
        'fact': 'Classic MI symptoms include crushing chest pain, radiation to left arm/jaw/neck/back, diaphoresis, nausea, SOB, and anxiety.',
        'priority': 'Clustered ischemic symptoms require immediate ACS workflow.',
        'true': ['Crushing chest pain is described in MI.', 'Radiation to arm/jaw/neck/back is listed.', 'Diaphoresis and nausea are listed features.'],
        'false': ['MI pain is always painless.', 'Radiation is absent in MI.']
    },
    {
        'name': 'MI atypical in women',
        'fact': 'Women may present atypically with fatigue and epigastric pain.',
        'priority': 'Avoid missed MI by recognizing atypical presentations.',
        'true': ['Fatigue can be atypical MI symptom in women.', 'Epigastric pain may be atypical MI symptom in women.', 'Atypical symptoms still warrant urgent evaluation.'],
        'false': ['Women always present with classic elephant-on-chest pain.', 'Atypical symptoms rule out MI.']
    },
    {
        'name': 'STEMI vs NSTEMI',
        'fact': 'STEMI has ST elevation with complete occlusion; NSTEMI has ST depression with partial occlusion; both have elevated troponin.',
        'priority': 'ECG pattern plus troponin should direct urgency and intervention pathway.',
        'true': ['STEMI is complete occlusion.', 'NSTEMI is partial occlusion.', 'Troponin elevates in both STEMI and NSTEMI.'],
        'false': ['NSTEMI requires ST elevation.', 'STEMI and NSTEMI both have normal troponin.']
    },
    {
        'name': 'MI treatment timing',
        'fact': 'STEMI requires PCI within 90 minutes; if PCI unavailable, thrombolytics are considered within 30 minutes.',
        'priority': 'Time-to-reperfusion is critical for myocardial salvage.',
        'true': ['Door-to-balloon target is 90 minutes for STEMI.', 'Thrombolytics are considered if PCI unavailable within 30 minutes.', 'NSTEMI uses anticoagulants and cardiac cath strategy.'],
        'false': ['STEMI reperfusion can wait 24 hours.', 'Thrombolytics are never used when PCI unavailable.']
    },
    {
        'name': 'MONA in MI',
        'fact': 'MONA includes Morphine, Oxygen, Nitrates, and Aspirin in acute MI management from this note.',
        'priority': 'Initiate first-line MI measures while preparing definitive reperfusion.',
        'true': ['Morphine is in MONA.', 'Nitrates are in MONA.', 'Aspirin is in MONA.'],
        'false': ['MONA excludes aspirin.', 'MONA is a heart-failure-only acronym.']
    },
    {
        'name': 'HF causes',
        'fact': 'Heart failure causes listed include post-MI scar, long-term hypertension, valve disease, cardiomyopathy, and COPD causing right-sided failure.',
        'priority': 'Address underlying cause while treating congestion and low output.',
        'true': ['Post-MI scar tissue can cause HF.', 'Long-term HTN is listed HF cause.', 'COPD is linked to right-sided HF.'],
        'false': ['HF is caused only by acute anaphylaxis.', 'Valve disease is unrelated to HF.']
    },
    {
        'name': 'Left-sided HF signs',
        'fact': 'Left HF signs include pulmonary edema, crackles, dyspnea, orthopnea, and PND.',
        'priority': 'Recognize pulmonary congestion and position patient to improve breathing.',
        'true': ['Crackles are left HF sign.', 'Orthopnea/PND are left HF signs.', 'Pulmonary edema is linked to left HF.'],
        'false': ['Ascites is primary left HF sign.', 'Left HF has no respiratory symptoms.']
    },
    {
        'name': 'Right-sided HF signs',
        'fact': 'Right HF signs include JVD, peripheral edema, ascites, and weight gain.',
        'priority': 'Track systemic venous congestion and fluid accumulation closely.',
        'true': ['JVD is a right HF sign.', 'Ascites is listed in right HF.', 'Peripheral edema and weight gain are right HF signs.'],
        'false': ['Pulmonary crackles are the defining right HF sign.', 'Right HF has no edema.']
    },
    {
        'name': 'HF treatment core',
        'fact': 'HF treatment listed includes diuretics, ACE inhibitors/ARBs, beta-blockers, digoxin, low sodium diet, and fluid restriction.',
        'priority': 'Combine pharmacologic and fluid/sodium strategies for decongestion and workload reduction.',
        'true': ['Furosemide is listed to remove fluid.', 'ACEi/ARB and beta-blockers are listed.', 'Low-sodium diet and fluid restriction are listed.'],
        'false': ['HF treatment excludes all diuretics.', 'Unlimited sodium intake is recommended.']
    },
    {
        'name': 'Cardiac arrest rhythms',
        'fact': 'Shockable arrest rhythms are ventricular fibrillation and pulseless ventricular tachycardia; non-shockable are asystole and PEA.',
        'priority': 'Rhythm classification determines defibrillation decisions during ACLS.',
        'true': ['V-fib and pulseless V-tach are shockable.', 'Asystole and PEA are non-shockable.', 'Rhythm identification guides intervention.'],
        'false': ['Asystole is shockable.', 'PEA should be defibrillated first.']
    },
    {
        'name': 'Cardiac arrest triggers',
        'fact': 'Cardiac arrest can be triggered by MI, electrolyte imbalance, drowning, and drug overdose.',
        'priority': 'Search reversible triggers while running high-quality resuscitation.',
        'true': ['MI is a listed trigger for arrest.', 'Electrolyte imbalance is listed trigger.', 'Drowning and drug overdose are listed triggers.'],
        'false': ['Only chronic obesity triggers arrest.', 'Drug overdose cannot cause arrest.']
    },
    {
        'name': 'Cardiac arrest signs',
        'fact': 'Key signs are sudden unresponsiveness, no pulse, no breathing, and cyanosis.',
        'priority': 'Immediate recognition should trigger CPR without delay.',
        'true': ['No pulse and no breathing are key signs.', 'Sudden unconsciousness is expected.', 'Cyanosis can be seen in arrest.'],
        'false': ['Strong peripheral pulse is typical of arrest.', 'Cardiac arrest patients remain fully alert.']
    },
    {
        'name': 'CAB order',
        'fact': 'Resuscitation sequence emphasizes CAB: Compressions first, then Airway, then Breathing.',
        'priority': 'Prioritize circulation immediately to preserve perfusion.',
        'true': ['Compressions come first in CAB.', 'Airway follows compressions in sequence.', 'Breathing follows airway in sequence.'],
        'false': ['Breathing should always start before compressions.', 'CAB means check rhythm before compressions.']
    },
    {
        'name': 'Compression quality',
        'fact': 'Compressions should be hard and fast, depth about 2 inches, at 100–120 per minute.',
        'priority': 'High-quality compressions are central to survival in arrest.',
        'true': ['Target rate is 100–120/min.', 'Depth target is around 2 inches.', 'Hard, fast compressions are emphasized.'],
        'false': ['Compression rate should be 40/min.', 'Shallow compressions are preferred.']
    },
    {
        'name': 'Defibrillation use',
        'fact': 'AED/defibrillation is indicated for V-fib or V-tach rhythms.',
        'priority': 'Deliver shock promptly for shockable rhythms while minimizing pauses.',
        'true': ['AED is used for V-fib.', 'AED is used for V-tach.', 'Defibrillation depends on rhythm type.'],
        'false': ['AED is first-line for asystole.', 'All rhythms are treated identically with no shocks.']
    },
    {
        'name': 'Epinephrine timing',
        'fact': 'Epinephrine is given every 3–5 minutes during cardiac arrest management.',
        'priority': 'Follow medication interval while maintaining uninterrupted CPR cycles.',
        'true': ['Epinephrine interval is every 3–5 minutes.', 'Epinephrine is part of arrest protocol.', 'Drug timing complements CPR, not replaces it.'],
        'false': ['Epinephrine is given once only then stopped.', 'Epinephrine is contraindicated in all arrest cases.']
    },
    {
        'name': 'No pulse NCLEX rule',
        'fact': 'NCLEX rule in note: if no pulse, start CPR first and do not delay compressions to check rhythm.',
        'priority': 'Immediate compressions outrank delayed diagnostic steps in pulseless patients.',
        'true': ['No pulse triggers CPR immediately.', 'Rhythm check should not delay first compressions.', 'This is highlighted as a key NCLEX rule.'],
        'false': ['Always check rhythm for several minutes before compressions.', 'No pulse should be observed without intervention.']
    },
    {
        'name': 'MI vs arrest distinction',
        'fact': 'MI patient is usually awake and in pain, while cardiac arrest patient is unresponsive and pulseless.',
        'priority': 'Distinguish syndrome quickly to choose PCI pathway vs resuscitation pathway.',
        'true': ['MI can present with chest pain in conscious patient.', 'Arrest presents with unresponsiveness and absent pulse.', 'Both are emergencies but require different immediate responses.'],
        'false': ['MI and arrest share identical first actions.', 'Arrest patients are typically ambulatory.']
    },
    {
        'name': 'Key tests by syndrome',
        'fact': 'Key tests listed: MI uses 12-lead ECG and troponin; HF uses BNP/echo/chest X-ray; arrest uses rhythm analysis for shockability.',
        'priority': 'Select diagnostics that match syndrome and urgency.',
        'true': ['Troponin and ECG are key for MI.', 'BNP/echo/chest X-ray are listed for HF.', 'Rhythm analysis identifies shockable arrest rhythms.'],
        'false': ['HF diagnosis relies only on troponin.', 'Arrest diagnosis depends on BNP trend first.']
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

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'], topic=TOPIC)
    distractors = c['false'] + [
        # a false statement from another section, never a section heading
        concepts[(i + 6) % len(concepts)]['false'][(i // len(concepts)) % 2],
        'Because symptoms are mild, urgent action can be deferred safely.',
        'Rhythm assessment should always precede compressions in pulseless states.'
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

    questions.append({
        'stem': stem,
        'options': option_objects(options),
        'correct': [chr(97 + options.index(correct))],
        'rationale': f"Correct because {c['fact']} {c['priority']}",
        'is_multi': False
    })

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = sata_templates[i % len(sata_templates)].format(name=c['name'], topic=TOPIC)
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
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Heart Attack vs Heart Failure vs Cardiac Arrest', 'Comparison of MI, HF, and arrest with priorities', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - MI/HF/Arrest (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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

lines += ['END $$;', 'COMMIT;']
OUT_PATH.write_text('\n'.join(lines), encoding='utf-8')
print(f'Wrote {OUT_PATH} with {len(questions)} questions')
