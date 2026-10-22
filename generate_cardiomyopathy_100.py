import json
import re
import statistics
import random
from pathlib import Path

random.seed(48)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-CARDIOMYOPATHY-100.sql')
CATEGORY = 'Cardiomyopathy - NCLEX'
TOPIC = 'Cardiomyopathy'
TOPIC_NAME = 'Cardiomyopathy'

concepts = [
    {
        'name': 'Core definition',
        'fact': 'Cardiomyopathy is heart muscle disease that can make the heart weak, stretched, or stiff and impair pumping.',
        'priority': 'Monitor for progression to heart failure, dysrhythmias, and sudden cardiac death.',
        'true': ['Cardiomyopathy changes muscle structure/function.', 'It impairs pumping effectiveness.', 'Complications include HF and dysrhythmias.'],
        'false': ['Cardiomyopathy only affects coronary arteries.', 'Cardiomyopathy never affects cardiac output.']
    },
    {
        'name': 'Dilated cardiomyopathy pattern',
        'fact': 'Dilated cardiomyopathy has enlarged chambers, especially LV, with thin weak muscle and reduced ejection fraction.',
        'priority': 'Prioritize systolic failure monitoring and congestion assessment.',
        'true': ['Dilated type has enlarged ventricles.', 'Ejection fraction is reduced in dilated type.', 'Systolic failure is the main issue in dilated type.'],
        'false': ['Dilated type has thick septum with normal chamber size.', 'Dilated type usually has increased EF.']
    },
    {
        'name': 'Dilated causes',
        'fact': 'Dilated causes listed include genetics, alcohol/drug use, viral myocarditis, peripartum state, and hypertension.',
        'priority': 'Address reversible contributors while managing HF symptoms.',
        'true': ['Alcohol/drug use is listed cause.', 'Viral myocarditis is listed cause.', 'Peripartum cardiomyopathy is included.'],
        'false': ['Dilated type is only caused by congenital cyanotic defects.', 'Hypertension is excluded.']
    },
    {
        'name': 'Dilated signs',
        'fact': 'Dilated signs include SOB, fatigue, edema, S3 gallop, and displaced PMI.',
        'priority': 'Track fluid status and low-output symptoms to detect decompensation.',
        'true': ['S3 gallop is associated with dilated type.', 'Displaced PMI is listed finding.', 'SOB/fatigue/edema are listed symptoms.'],
        'false': ['S4 gallop is the defining dilated sound.', 'Edema is absent in dilated type.']
    },
    {
        'name': 'HCM structure',
        'fact': 'Hypertrophic cardiomyopathy features thickened myocardium, especially septum, causing outflow obstruction and decreased cardiac output.',
        'priority': 'Avoid interventions that worsen obstruction by reducing preload.',
        'true': ['HCM has septal hypertrophy.', 'Outflow obstruction is central in HCM.', 'Cardiac output can decrease in HCM.'],
        'false': ['HCM is primarily chamber dilation.', 'HCM always improves outflow.']
    },
    {
        'name': 'HCM risk profile',
        'fact': 'HCM is genetic autosomal dominant and is the most common cause of sudden death in young athletes.',
        'priority': 'Enforce activity restrictions and high-risk counseling for athletes.',
        'true': ['HCM is autosomal dominant.', 'Young athletes are high risk for sudden death.', 'Competitive sports restriction is emphasized.'],
        'false': ['HCM is non-genetic.', 'Athletic exertion is encouraged in HCM.']
    },
    {
        'name': 'HCM symptoms',
        'fact': 'HCM signs include exertional SOB, syncope, chest pain, and S4 gallop.',
        'priority': 'Treat exertional syncope/chest pain as red flags for obstructive physiology.',
        'true': ['Syncope is listed HCM symptom.', 'Exertional dyspnea is listed symptom.', 'S4 gallop is associated with HCM.'],
        'false': ['S3 is the hallmark HCM sound.', 'HCM is always asymptomatic.']
    },
    {
        'name': 'HCM exacerbators',
        'fact': 'HCM symptoms worsen with dehydration and Valsalva; nitrates should be avoided.',
        'priority': 'Maintain preload and avoid triggers that intensify obstruction.',
        'true': ['Dehydration worsens HCM.', 'Valsalva worsens HCM.', 'Nitrates are avoided in HCM.'],
        'false': ['Dehydration improves HCM symptoms.', 'Nitrates are first-line for HCM obstruction.']
    },
    {
        'name': 'Restrictive pattern',
        'fact': 'Restrictive cardiomyopathy has stiff myocardium with impaired filling and backup into lungs/body.',
        'priority': 'Recognize diastolic failure signs despite less dramatic chamber enlargement.',
        'true': ['Restrictive type has stiffness and poor filling.', 'Blood can back up into lungs/body in restrictive type.', 'Diastolic failure is the main restrictive issue.'],
        'false': ['Restrictive type is primarily hypercontractile with easy filling.', 'Restrictive type has no congestion risk.']
    },
    {
        'name': 'Restrictive causes',
        'fact': 'Restrictive causes listed are amyloidosis, sarcoidosis, and radiation therapy.',
        'priority': 'Search infiltrative or post-radiation etiologies in stiff-heart presentations.',
        'true': ['Amyloidosis is listed restrictive cause.', 'Sarcoidosis is listed restrictive cause.', 'Radiation therapy is listed restrictive cause.'],
        'false': ['Alcohol alone is the only restrictive cause.', 'Radiation is unrelated to restrictive disease.']
    },
    {
        'name': 'ARVC pathology',
        'fact': 'ARVC replaces right ventricular muscle with fat/scar tissue, creating dangerous arrhythmias and sudden death risk.',
        'priority': 'Prioritize arrhythmia prevention and sudden-death mitigation in ARVC.',
        'true': ['RV fat/scar replacement is core ARVC pathology.', 'ARVC raises V-tach/V-fib risk.', 'ARVC carries sudden cardiac death risk.'],
        'false': ['ARVC primarily causes left ventricular dilation only.', 'ARVC has no arrhythmia risk.']
    },
    {
        'name': 'ARVC epidemiology',
        'fact': 'ARVC is genetic autosomal dominant and often seen in young males and athletes.',
        'priority': 'Screen family/sports history when unexplained syncope or palpitations occur.',
        'true': ['ARVC is autosomal dominant.', 'Young males/athletes are highlighted risk groups.', 'Family-risk context matters in ARVC.'],
        'false': ['ARVC is exclusively acquired after age 80.', 'Athletes are protected from ARVC.']
    },
    {
        'name': 'ARVC diagnosis treatment',
        'fact': 'MRI is gold standard for ARVC; treatment includes ICD, amiodarone, activity restriction, and avoiding competitive sports.',
        'priority': 'Use definitive imaging and aggressive prevention of lethal arrhythmias.',
        'true': ['MRI is gold-standard in ARVC note.', 'ICD is listed ARVC intervention.', 'Competitive sports avoidance is listed ARVC management.'],
        'false': ['Echocardiogram alone is gold standard for ARVC.', 'ARVC treatment encourages strenuous sports.']
    },
    {
        'name': 'Common pathophysiology',
        'fact': 'Across cardiomyopathies, reduced pumping lowers cardiac output and causes fatigue, dyspnea, and fluid buildup.',
        'priority': 'Trend perfusion and volume status regardless of subtype.',
        'true': ['Lower CO is a shared pathway.', 'Fatigue and dyspnea arise from low output/congestion.', 'Fluid buildup can occur across types.'],
        'false': ['All types increase cardiac output.', 'Cardiomyopathy never leads to fluid overload.']
    },
    {
        'name': 'Assessment table: EF',
        'fact': 'EF trends: dilated decreased, hypertrophic normal/increased, restrictive normal or decreased.',
        'priority': 'Interpret EF in subtype context instead of as isolated number.',
        'true': ['Dilated EF is reduced.', 'HCM EF can be normal or increased.', 'Restrictive EF can be normal or reduced.'],
        'false': ['HCM always has reduced EF.', 'Dilated EF is normal.']
    },
    {
        'name': 'Assessment table: heart sounds',
        'fact': 'Heart sounds: dilated S3, hypertrophic S4, restrictive may have S3 or S4.',
        'priority': 'Use auscultation pattern to support subtype differentiation.',
        'true': ['S3 is linked to dilated type.', 'S4 is linked to hypertrophic type.', 'Restrictive may present S3 or S4.'],
        'false': ['S4 is unique to dilated type.', 'No gallop sounds are associated with cardiomyopathy.']
    },
    {
        'name': 'Assessment table: risks',
        'fact': 'Risk patterns: dilated HF/thromboembolism, hypertrophic sudden death, restrictive HF.',
        'priority': 'Tailor surveillance to subtype-specific major complications.',
        'true': ['Dilated type has thromboembolism risk.', 'Hypertrophic type has sudden death risk.', 'Restrictive type is linked with HF risk.'],
        'false': ['Hypertrophic type has no sudden death risk.', 'Restrictive type risk is only stroke.']
    },
    {
        'name': 'Medication strategy',
        'fact': 'Medication classes listed include ACEi/ARB, beta-blockers, diuretics, anticoagulants (especially with A-fib), and antiarrhythmics like amiodarone.',
        'priority': 'Combine workload reduction, decongestion, and rhythm/thromboembolism prevention.',
        'true': ['ACEi/ARB and beta-blockers are listed therapies.', 'Diuretics are listed for fluid overload.', 'Anticoagulants are noted especially with A-fib.'],
        'false': ['All cardiomyopathy medications are contraindicated.', 'Antiarrhythmics are never used.']
    },
    {
        'name': 'Device and advanced therapy',
        'fact': 'Interventions include ICD, CRT, LVAD bridge to transplant, and heart transplant for end-stage dilated cardiomyopathy.',
        'priority': 'Escalate to device/mechanical support when medical therapy is insufficient.',
        'true': ['ICD is listed for life-threatening arrhythmias.', 'LVAD is a bridge strategy in failing LV.', 'Transplant is listed for end-stage dilated disease.'],
        'false': ['LVAD is used only for temporary arrhythmia suppression.', 'ICD has no role in dangerous rhythms.']
    },
    {
        'name': 'Lifestyle counseling',
        'fact': 'Patients are instructed to avoid alcohol, stimulants, and high-sodium diet.',
        'priority': 'Reinforce modifiable behaviors that reduce decompensation risk.',
        'true': ['Alcohol avoidance is recommended.', 'Stimulant avoidance is recommended.', 'High sodium intake should be avoided.'],
        'false': ['High-sodium diet is encouraged.', 'Alcohol is therapeutic in cardiomyopathy.']
    },
    {
        'name': 'Nursing fluid monitoring',
        'fact': 'Nursing priority: daily weights, and weight gain >2 lb/day indicates fluid retention requiring provider notification.',
        'priority': 'Use rapid weight changes as early warning for worsening HF.',
        'true': ['Daily weight is emphasized in nursing care.', '>2 lb/day gain is concerning.', 'Provider should be notified for rapid gain.'],
        'false': ['Daily weights are unnecessary.', 'A 5-lb weekly gain is always normal.']
    },
    {
        'name': 'Nursing respiratory/hemodynamic monitoring',
        'fact': 'Nursing monitoring includes I&O, vital signs, SpO2, and HOB elevation 30–45° for dyspnea relief.',
        'priority': 'Positioning and trend monitoring help detect and reduce decompensation.',
        'true': ['I&O monitoring is listed.', 'HOB 30–45° helps dyspnea.', 'SpO2 and vitals are ongoing priorities.'],
        'false': ['Flat supine positioning is preferred for dyspnea.', 'SpO2 monitoring is not needed.']
    },
    {
        'name': 'HCM nursing teaching',
        'fact': 'For HCM, teach no strenuous activity and avoidance of dehydration, Valsalva, and nitrates.',
        'priority': 'Prevent obstruction-provoked collapse through targeted teaching.',
        'true': ['No strenuous activity is taught for HCM.', 'Avoid dehydration/Valsalva in HCM.', 'Avoid nitrates in HCM.'],
        'false': ['Valsalva is encouraged for HCM symptom control.', 'Nitrates are routine HCM therapy.']
    },
    {
        'name': 'Peripartum alert',
        'fact': 'Peripartum cardiomyopathy can occur in the last month of pregnancy or within 5 months postpartum, presenting with unexplained dyspnea/fatigue.',
        'priority': 'Screen new mothers promptly for cardiomyopathy warning symptoms.',
        'true': ['Peripartum window includes last pregnancy month.', 'Postpartum risk window extends 5 months.', 'Unexplained dyspnea/fatigue in new moms is concerning.'],
        'false': ['Peripartum cardiomyopathy only occurs years after delivery.', 'Postpartum dyspnea is always benign.']
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
        concepts[(i + 5) % len(concepts)]['false'][(i // len(concepts)) % 2],
        'Urgent monitoring is unnecessary because these findings are low-risk.',
        'Volume-depleting strategies are universally beneficial across all subtypes.'
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
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Cardiomyopathy', 'Dilated, hypertrophic, restrictive, ARVC and nursing priorities', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - Cardiomyopathy (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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
