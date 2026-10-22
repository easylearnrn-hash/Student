import json
import re
import statistics
import random
from pathlib import Path

random.seed(54)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-CARDIAC-BIOMARKERS-100.sql')
CATEGORY = 'Cardiac Biomarkers - NCLEX'
TOPIC = 'Cardiac Biomarkers'
TOPIC_NAME = 'Cardiac Biomarkers'
TEST_NAME = 'Cardiovascular System - Cardiac Biomarkers (Generated)'

concepts = [
    {
        'name': 'Biomarker purpose',
        'fact': 'Cardiac biomarkers are blood proteins released after cardiac cell injury and are used for MI/HF diagnosis and stress assessment.',
        'priority': 'Use biomarkers with clinical context to confirm or exclude acute cardiac injury.',
        'true': ['Biomarkers rise when cardiac cells are damaged.', 'They assist MI and HF evaluation.', 'They assess cardiac stress patterns.'],
        'false': ['Biomarkers only diagnose pulmonary embolism.', 'Cardiac injury does not alter biomarker levels.']
    },
    {
        'name': 'Serial testing principle',
        'fact': 'Serial values every 3–6 hours are needed, and a rise-and-fall pattern supports MI rather than one isolated elevation.',
        'priority': 'Trend interpretation is safer than single-point interpretation.',
        'true': ['Serial q3–6h testing is listed.', 'Rise-and-fall pattern supports MI.', 'Single value alone is insufficient for MI confirmation.'],
        'false': ['One elevated value always confirms MI.', 'Serial testing is unnecessary in acute chest pain.']
    },
    {
        'name': 'Troponin priority',
        'fact': 'Troponin is the most specific and sensitive biomarker for MI and is the gold standard.',
        'priority': 'Prioritize troponin trend review in suspected ACS workflows.',
        'true': ['Troponin is gold standard for MI.', 'Troponin is both highly sensitive and specific in note.', 'Troponin has highest NCLEX priority in this section.'],
        'false': ['BNP is the gold standard for MI.', 'Myoglobin is more specific than troponin.']
    },
    {
        'name': 'Troponin I kinetics',
        'fact': 'Troponin I normal is <0.04 ng/mL, rises 3–6h, peaks 12–24h, normalizes in 7–10 days.',
        'priority': 'Use timing to detect delayed presentations and avoid false reassurance early.',
        'true': ['Troponin I rises at 3–6 hours.', 'Peak is 12–24 hours.', 'Troponin I can stay elevated for 7–10 days.'],
        'false': ['Troponin I normalizes within 12 hours.', 'Troponin I peak occurs at 2 hours.']
    },
    {
        'name': 'Troponin T kinetics',
        'fact': 'Troponin T normal is <0.01 ng/mL, rises 3–6h, peaks 12–24h, and normalizes over 10–14 days.',
        'priority': 'Recognize prolonged elevation window for recent MI detection.',
        'true': ['Troponin T normal is <0.01 ng/mL.', 'Rise/peak times mirror early troponin kinetics.', 'Duration extends up to 10–14 days.'],
        'false': ['Troponin T is gone by 24 hours.', 'Troponin T has no normal reference.']
    },
    {
        'name': 'hsTnT utility',
        'fact': 'High-sensitivity Troponin T can detect smaller myocardial infarctions.',
        'priority': 'Interpret small dynamic changes carefully in early injury.',
        'true': ['hsTnT detects smaller infarcts.', 'Sensitivity is higher than conventional threshold-only approach.', 'Useful in early subtle MI detection.'],
        'false': ['hsTnT is less sensitive than CK-MB.', 'hsTnT is used only for heart failure.']
    },
    {
        'name': 'CK isoform composition',
        'fact': 'CK-MM is 96–100%, CK-MB is 0–5%, and CK-BB is about 0% in normal distribution listed.',
        'priority': 'Know isoform proportions to avoid misattributing skeletal injury as MI.',
        'true': ['CK-MM is dominant fraction.', 'CK-MB normal proportion is small.', 'CK-BB is minimal in routine blood profile here.'],
        'false': ['CK-BB is dominant in healthy blood.', 'CK-MB comprises most CK.']
    },
    {
        'name': 'CK-MB timeline/use',
        'fact': 'CK-MB rises 4–6h, peaks 18–24h, normalizes 48–72h, and is useful for MI and re-infarction detection.',
        'priority': 'Use CK-MB especially when looking for reinfarction after initial event.',
        'true': ['CK-MB normalizes faster than troponin.', 'CK-MB is useful for reinfarction detection.', 'Rise/peak/normalization windows are listed.'],
        'false': ['CK-MB remains elevated for 14 days.', 'CK-MB has no role in reinfarction.']
    },
    {
        'name': 'CK-MM limitation',
        'fact': 'CK-MM reflects skeletal muscle injury such as rhabdomyolysis and is not cardiac-specific.',
        'priority': 'Avoid diagnosing MI from CK-MM elevation alone.',
        'true': ['CK-MM source is skeletal muscle.', 'CK-MM can rise in rhabdomyolysis.', 'CK-MM is not cardiac-specific.'],
        'false': ['CK-MM is most cardiac-specific marker.', 'CK-MM excludes muscle injury.']
    },
    {
        'name': 'CK-BB limitation',
        'fact': 'CK-BB is associated with brain/smooth muscle injury and is not used for cardiac monitoring.',
        'priority': 'Keep CK-BB out of MI-focused biomarker decisions.',
        'true': ['CK-BB is linked to brain/smooth muscle.', 'CK-BB can relate to bowel infarction in note.', 'CK-BB is not cardiac marker of choice.'],
        'false': ['CK-BB is preferred biomarker for MI.', 'CK-BB comes from ventricular myocardium.']
    },
    {
        'name': 'BNP physiology',
        'fact': 'BNP is released from ventricular myocytes when stretched by volume overload.',
        'priority': 'Interpret BNP as volume-stress signal rather than infarction specificity.',
        'true': ['Ventricular stretch triggers BNP release.', 'Volume overload increases BNP.', 'BNP reflects wall stress.'],
        'false': ['BNP rises only from skeletal injury.', 'BNP is unrelated to ventricular stretch.']
    },
    {
        'name': 'BNP ranges',
        'fact': 'BNP normal is <100 pg/mL; 100–400 possible HF; >400 likely HF exacerbation.',
        'priority': 'Use BNP strata to grade heart-failure likelihood and urgency.',
        'true': ['BNP <100 is normal.', '100–400 suggests possible HF.', '>400 suggests likely HF exacerbation.'],
        'false': ['BNP <20 defines severe HF.', 'BNP >400 excludes HF.']
    },
    {
        'name': 'BNP clinical use',
        'fact': 'BNP helps differentiate cardiac from pulmonary dyspnea, guides diuresis/discharge, and higher BNP suggests worse prognosis.',
        'priority': 'Apply BNP trends to dyspnea triage and HF trajectory planning.',
        'true': ['BNP can separate cardiac vs pulmonary dyspnea causes.', 'BNP helps guide diuretic and discharge decisions.', 'Higher BNP correlates with worse prognosis.'],
        'false': ['BNP confirms MI infarct size directly.', 'BNP has no prognostic value.']
    },
    {
        'name': 'BNP not MI marker',
        'fact': 'The note explicitly states BNP does not indicate MI; it indicates fluid overload/heart failure context.',
        'priority': 'Do not substitute BNP for troponin in ACS diagnosis.',
        'true': ['BNP indicates volume overload, not infarction specificity.', 'Troponin remains MI marker priority.', 'BNP is HF-oriented biomarker in note.'],
        'false': ['BNP is the most specific MI marker.', 'BNP rise alone proves STEMI.']
    },
    {
        'name': 'NT-proBNP reference',
        'fact': 'NT-proBNP normal is listed as <300 pg/mL and has longer half-life.',
        'priority': 'Account for assay type when interpreting natriuretic peptide results.',
        'true': ['NT-proBNP reference <300 is listed.', 'Longer half-life is noted.', 'NT-proBNP interpretation differs from BNP thresholds.'],
        'false': ['NT-proBNP normal is <30.', 'NT-proBNP has shorter half-life than BNP.']
    },
    {
        'name': 'Myoglobin kinetics',
        'fact': 'Myoglobin rises first at 1–3h after MI but normalizes quickly within 24h.',
        'priority': 'Use for very early phase support, then rely on specific markers.',
        'true': ['Myoglobin is earliest riser in note.', 'Rise occurs 1–3 hours.', 'Normalization occurs by about 24 hours.'],
        'false': ['Myoglobin rises after troponin peak.', 'Myoglobin stays elevated 10 days.']
    },
    {
        'name': 'Myoglobin limitation/use',
        'fact': 'Myoglobin is not cardiac-specific and is used mainly for early rule-out when normal at around 3h.',
        'priority': 'Avoid overcalling MI from isolated myoglobin elevation.',
        'true': ['Myoglobin comes from skeletal and cardiac muscle.', 'Normal early myoglobin lowers immediate MI likelihood.', 'Specificity is limited.'],
        'false': ['Myoglobin is highly cardiac-specific.', 'Myoglobin alone confirms MI.']
    },
    {
        'name': 'Timeline comparison',
        'fact': 'Timeline summary: myoglobin earliest/shortest, CK-MB intermediate, troponin longest duration.',
        'priority': 'Choose marker by time-from-onset and diagnostic objective.',
        'true': ['Myoglobin rises earliest.', 'CK-MB clears before troponin.', 'Troponin persists the longest.'],
        'false': ['Troponin clears before CK-MB.', 'Myoglobin persists longest.']
    },
    {
        'name': 'BUN/creatinine interpretation',
        'fact': 'BUN 7–20 and creatinine 0.6–1.2 are listed normal; high BUN with normal creatinine suggests dehydration, while both high suggest renal impairment.',
        'priority': 'Use renal trends to separate prerenal dehydration from intrinsic decline.',
        'true': ['BUN normal range 7–20 is listed.', 'Creatinine normal 0.6–1.2 is listed.', 'High BUN + high creatinine suggests renal impairment.'],
        'false': ['High BUN with normal creatinine proves MI.', 'Normal creatinine excludes dehydration.']
    },
    {
        'name': 'Low-output renal effect',
        'fact': 'Reduced cardiac output can increase BUN/creatinine due to renal hypoperfusion.',
        'priority': 'Treat perfusion deficits to protect kidney function.',
        'true': ['Low cardiac output can impair renal perfusion.', 'Renal markers may rise in low-output states.', 'Cardiorenal relationship is explicitly noted.'],
        'false': ['Renal perfusion is unaffected by cardiac output.', 'BUN/Cr are unrelated to hemodynamics.']
    },
    {
        'name': 'Lactate and ABG significance',
        'fact': 'Shock/MI may show metabolic acidosis; lactate >2 mmol/L indicates tissue hypoperfusion and helps gauge shock severity.',
        'priority': 'Escalate perfusion support when lactate and acidosis worsen.',
        'true': ['Lactate >2 indicates hypoperfusion in note.', 'Metabolic acidosis can occur in shock/MI.', 'ABG/lactate assist shock severity assessment.'],
        'false': ['Lactate <0.2 is the shock threshold.', 'ABG is irrelevant in shock.']
    },
    {
        'name': 'Lipid panel targets',
        'fact': 'Desired lipids listed are total cholesterol <200, LDL <70 in high-risk patients, and HDL >60 as protective.',
        'priority': 'Incorporate lipid targets into long-term post-ACS risk reduction.',
        'true': ['Total cholesterol target <200 is listed.', 'LDL <70 is listed for high-risk.', 'HDL >60 is protective per note.'],
        'false': ['LDL >160 is optimal in high-risk.', 'HDL under 20 is protective.']
    },
    {
        'name': 'NCLEX synthesis',
        'fact': 'NCLEX summary: Troponin is gold standard and longest-lasting, CK-MB best for reinfarction, BNP for HF dyspnea differentiation, myoglobin earliest but nonspecific.',
        'priority': 'Match biomarker selection to the clinical question (diagnosis timing vs HF vs reinfarction).',
        'true': ['Troponin is top MI marker in NCLEX summary.', 'CK-MB favored for reinfarction detection.', 'BNP and myoglobin have distinct non-overlapping roles.'],
        'false': ['Myoglobin is best reinfarction marker.', 'BNP replaces troponin for MI confirmation.']
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


TOPIC_NAME_SQL = esc(TOPIC_NAME)
CATEGORY_SQL = esc(CATEGORY)
TEST_NAME_SQL = esc(TEST_NAME)

questions = []

for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'], topic=TOPIC)
    distractors = c['false'] + [
        # a false statement from another section, never a section heading
        concepts[(i + 4) % len(concepts)]['false'][(i // len(concepts)) % 2],
        'Single-point interpretation is always definitive regardless trend direction.',
        'Serial rechecks are unnecessary when first value is borderline.'
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
    f"  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = '{TOPIC_NAME_SQL}' LIMIT 1;",
    '  IF v_topic_id IS NULL THEN',
    f"    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, '{TOPIC_NAME_SQL}', 'Troponin CK-MB BNP and myoglobin interpretation', 'published') RETURNING id INTO v_topic_id;",
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
