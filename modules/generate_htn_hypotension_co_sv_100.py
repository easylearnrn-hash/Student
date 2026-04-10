import json
import random
from pathlib import Path

random.seed(49)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-HTN-HYPOTENSION-CO-SV-100.sql')
CATEGORY = 'Hypertension Hypotension CO SV - NCLEX'
TOPIC_NAME = 'Hypertension, Hypotension, CO & SV'

concepts = [
    {
        'name': 'BP formula',
        'fact': 'Blood pressure is determined by cardiac output multiplied by systemic vascular resistance (BP = CO × SVR).',
        'priority': 'Interpret BP changes by evaluating both pump flow and vascular tone.',
        'true': ['BP depends on both CO and SVR.', 'Rising SVR can increase BP when CO constant.', 'Falling CO can lower BP if SVR unchanged.'],
        'false': ['BP equals HR minus SV in this note.', 'SVR has no influence on BP in this note.']
    },
    {
        'name': 'CO formula',
        'fact': 'Cardiac output equals stroke volume times heart rate (CO = SV × HR).',
        'priority': 'Assess tachy/bradycardia and stroke volume drivers when perfusion worsens.',
        'true': ['CO combines HR and SV.', 'Changes in either HR or SV change CO.', 'Formula is explicitly provided in note.'],
        'false': ['CO equals MAP divided by pulse pressure in this note.', 'Heart rate does not affect CO in this note.']
    },
    {
        'name': 'MAP formula and normal',
        'fact': 'MAP is calculated as (2×DBP + SBP) ÷ 3 and normal range listed is 70–100 mmHg.',
        'priority': 'Use MAP for organ perfusion triage, not SBP alone.',
        'true': ['MAP formula weights diastolic pressure twice.', 'Normal MAP range listed is 70–100.', 'MAP interpretation is key for perfusion.'],
        'false': ['MAP is calculated as SBP + DBP divided by 2 in this note.', 'Normal MAP is listed as 30–50 in this note.']
    },
    {
        'name': 'Core definitions',
        'fact': 'BP is force against artery walls, CO is blood pumped per minute by LV, SV is blood per beat, SVR is resistance to LV ejection, preload is venous return stretch, afterload is resistance to ejection.',
        'priority': 'Distinguish preload/afterload effects when choosing interventions.',
        'true': ['Preload is venous return/stretch in this note.', 'Afterload is resistance to ejection in this note.', 'SV is blood volume pumped per beat in this note.'],
        'false': ['Afterload means venous return volume in this note.', 'SVR is defined as oxygen saturation in this note.']
    },
    {
        'name': 'HTN staging normal/elevated',
        'fact': 'Normal BP is <120/<80 and elevated is 120–129 systolic with diastolic <80.',
        'priority': 'Catch early elevation stage to prevent progression.',
        'true': ['Normal is below 120/80 in this note.', 'Elevated has SBP 120–129 with DBP <80.', 'Elevated is not yet stage 1 in this note.'],
        'false': ['Elevated BP requires DBP over 90 in this note.', 'Normal BP is listed as under 140/90 in this note.']
    },
    {
        'name': 'HTN stages 1 and 2',
        'fact': 'Stage 1 HTN is 130–139 or 80–89; stage 2 is ≥140 or ≥90.',
        'priority': 'Stage classification guides urgency and treatment intensity.',
        'true': ['Stage 1 includes 130–139 systolic.', 'Stage 2 begins at 140 systolic.', 'Diastolic thresholds are 80–89 for stage 1 and ≥90 for stage 2.'],
        'false': ['Stage 1 starts at SBP 150 in this note.', 'Stage 2 requires SBP >200 in this note.']
    },
    {
        'name': 'Hypertensive crisis threshold',
        'fact': 'Hypertensive crisis is listed as BP >180/>120.',
        'priority': 'Escalate rapidly and assess for acute organ damage.',
        'true': ['Crisis threshold includes systolic above 180.', 'Crisis threshold includes diastolic above 120.', 'Crisis is higher risk than stage 2 in this note.'],
        'false': ['Crisis starts at 150/90 in this note.', 'Crisis requires low BP in this note.']
    },
    {
        'name': 'HTN risk factors',
        'fact': 'Non-modifiable risks include age, family history, and race; modifiable include obesity, smoking, high sodium diet, sedentary lifestyle, alcohol, and stress.',
        'priority': 'Target modifiable risks aggressively for BP control.',
        'true': ['Family history is listed non-modifiable risk.', 'High sodium intake is listed modifiable risk.', 'Smoking and obesity are modifiable risks.'],
        'false': ['Age is modifiable in this note.', 'Stress has no relation to HTN in this note.']
    },
    {
        'name': 'HTN complications',
        'fact': 'Complications listed are stroke, MI, heart failure, CKD, and retinal damage.',
        'priority': 'Uncontrolled BP requires organ-protection strategy and close follow-up.',
        'true': ['Stroke and MI are listed complications.', 'CKD is listed complication.', 'Retinal damage is listed complication.'],
        'false': ['HTN has no end-organ complications in this note.', 'Only skin complications are listed in this note.']
    },
    {
        'name': 'Lifestyle HTN management',
        'fact': 'Lifestyle management includes DASH (lower sodium/higher potassium), exercise, weight loss, and smoking cessation.',
        'priority': 'Pair medication with sustained lifestyle adherence for long-term control.',
        'true': ['DASH diet is recommended.', 'Exercise and weight loss are recommended.', 'Smoking cessation is part of plan.'],
        'false': ['High-salt diet is recommended for HTN in this note.', 'Sedentary rest is first-line lifestyle in this note.']
    },
    {
        'name': 'ACE inhibitor specifics',
        'fact': 'ACE inhibitors (e.g., lisinopril) can cause dry cough and are contraindicated in pregnancy.',
        'priority': 'Screen for pregnancy status and cough intolerance.',
        'true': ['Dry cough is a listed ACE inhibitor side effect.', 'ACE inhibitors are contraindicated in pregnancy.', 'Lisinopril is listed ACE example.'],
        'false': ['ACE inhibitors are preferred during pregnancy in this note.', 'ACE inhibitors have no cough risk in this note.']
    },
    {
        'name': 'ARB specifics',
        'fact': 'ARBs (e.g., losartan) are used if ACE inhibitors are not tolerated and do not cause cough per note.',
        'priority': 'Use ARB substitution when ACE cough limits adherence.',
        'true': ['Losartan is listed ARB example.', 'ARBs are used when ACE not tolerated.', 'No-cough advantage is highlighted.'],
        'false': ['ARBs are only emergency IV drugs in this note.', 'ARBs worsen ACE cough in this note.']
    },
    {
        'name': 'Thiazide/CCB/beta-blocker roles',
        'fact': 'Thiazides are first-line for most patients, CCBs cause vasodilation, and beta-blockers reduce HR/contractility.',
        'priority': 'Match medication mechanism to hemodynamic target.',
        'true': ['HCTZ is listed first-line for many patients.', 'Amlodipine is listed for vasodilation.', 'Metoprolol lowers HR and contractility.'],
        'false': ['Beta-blockers increase contractility in this note.', 'CCBs are listed as preload boosters in this note.']
    },
    {
        'name': 'Hypertensive emergency treatment',
        'fact': 'Hypertensive emergency with organ damage requires IV antihypertensives such as nicardipine, labetalol, or nitroprusside.',
        'priority': 'Treat with controlled IV reduction while monitoring perfusion.',
        'true': ['IV nicardipine/labetalol/nitroprusside are listed.', 'Organ damage presence defines emergency context.', 'Emergency is distinct from asymptomatic severe HTN.'],
        'false': ['Oral-only delayed treatment is recommended in this note.', 'No organ damage assessment is needed in this note.']
    },
    {
        'name': 'MAP reduction limit',
        'fact': 'In hypertensive emergency, MAP should not be reduced by more than 25% in the first hour.',
        'priority': 'Avoid overcorrection that can cause organ hypoperfusion.',
        'true': ['First-hour MAP reduction cap is 25%.', 'Rapid excessive reduction is unsafe.', 'MAP-guided titration is emphasized.'],
        'false': ['Reduce MAP by 60% in first hour in this note.', 'MAP has no role in emergency treatment in this note.']
    },
    {
        'name': 'Hypotension definition',
        'fact': 'Hypotension is systolic <90 or diastolic <60 and is significant when symptoms or hypoperfusion are present.',
        'priority': 'Treat symptomatic low BP rapidly to protect organ perfusion.',
        'true': ['SBP under 90 is hypotension in this note.', 'DBP under 60 is hypotension in this note.', 'Clinical significance depends on perfusion impact.'],
        'false': ['Hypotension is defined as SBP under 130 in this note.', 'Any low BP without symptoms is always shock in this note.']
    },
    {
        'name': 'Hypotension types and causes',
        'fact': 'Types listed are orthostatic, hypovolemic, neurogenic, and cardiogenic; causes include bleeding/dehydration, HF, sepsis, medications, and Addison disease.',
        'priority': 'Identify subtype/cause to guide targeted therapy.',
        'true': ['Orthostatic and hypovolemic are listed types.', 'Sepsis and HF are listed causes.', 'Meds and Addison disease are listed causes.'],
        'false': ['Only neurogenic hypotension exists in this note.', 'Sepsis cannot cause hypotension in this note.']
    },
    {
        'name': 'Orthostatic criteria',
        'fact': 'Orthostatic hypotension is drop ≥20 systolic or ≥10 diastolic within 3 minutes of standing.',
        'priority': 'Measure postural vitals correctly before labeling orthostasis.',
        'true': ['Systolic drop threshold is 20 mmHg.', 'Diastolic drop threshold is 10 mmHg.', 'Timing window is within 3 minutes of standing.'],
        'false': ['Orthostatic criteria require HR rise only in this note.', 'Drop must occur after 30 minutes in this note.']
    },
    {
        'name': 'Orthostatic management',
        'fact': 'Nursing actions include dangling legs before standing, slow position changes, and adequate hydration.',
        'priority': 'Prevent falls and syncope with positional safety teaching.',
        'true': ['Dangle legs before standing is listed.', 'Slow position changes are recommended.', 'Hydration support is recommended.'],
        'false': ['Rapid standing is preferred in this note.', 'Hydration should be restricted in orthostasis in this note.']
    },
    {
        'name': 'Hypotension symptoms',
        'fact': 'Symptoms include dizziness, syncope, blurred vision, confusion, compensatory tachycardia, cool pale skin, and low urine output.',
        'priority': 'Trend neuro, skin, pulse, and urine output for perfusion decline.',
        'true': ['Syncope/dizziness are listed symptoms.', 'Low urine output is listed symptom.', 'Cool pale skin and tachycardia are listed.'],
        'false': ['Warm flushed skin with high urine output is hallmark in this note.', 'Bradycardia is always present in this note.']
    },
    {
        'name': 'Hypotension treatment',
        'fact': 'Management includes treating cause, IV fluids or blood products for hypovolemia, vasopressors for severe cases, supine position with legs elevated, and slow postural changes.',
        'priority': 'Restore circulating volume and perfusion while preventing recurrent drops.',
        'true': ['IV fluids/blood products used if hypovolemic.', 'Norepinephrine/dopamine listed for severe hypotension.', 'Supine with legs elevated is listed positioning.'],
        'false': ['Diuresis is first-line for hypovolemic hypotension in this note.', 'Standing position is preferred in severe hypotension in this note.']
    },
    {
        'name': 'CO factors: heart rate',
        'fact': 'CO can increase with tachycardia/epinephrine and decrease with bradycardia/beta-blockers per table.',
        'priority': 'Evaluate whether HR changes are compensatory or harmful to perfusion.',
        'true': ['Tachycardia and epinephrine can raise CO in table.', 'Bradycardia can lower CO in table.', 'Beta-blockers can lower CO via HR effects in table.'],
        'false': ['HR has no relation to CO in this table.', 'Bradycardia always raises CO in this note.']
    },
    {
        'name': 'CO factors: preload',
        'fact': 'Preload increase with fluid volume can raise CO; dehydration/hemorrhage lower preload and CO.',
        'priority': 'Volume assessment is central in hypotension and shock states.',
        'true': ['Higher fluid volume can increase preload/CO.', 'Dehydration lowers preload in table.', 'Hemorrhage lowers preload in table.'],
        'false': ['Hemorrhage raises preload in this note.', 'Preload is unaffected by fluid status in this note.']
    },
    {
        'name': 'CO factors: afterload/contractility',
        'fact': 'Vasodilation (lower SVR) can improve CO while vasoconstriction (higher SVR) can reduce CO; contractility rises with digoxin/epinephrine and falls with HF/MI.',
        'priority': 'Balance vascular tone and contractility when optimizing output.',
        'true': ['Higher SVR can reduce CO in the table context.', 'Digoxin/epinephrine increase contractility in table.', 'HF/MI decrease contractility in table.'],
        'false': ['Vasoconstriction always increases CO in this note.', 'HF improves contractility in this note.']
    },
    {
        'name': 'NCLEX MAP warning',
        'fact': 'MAP below 60 mmHg means organs are at risk of ischemia and immediate BP/oxygenation support is priority.',
        'priority': 'Treat MAP <60 as urgent perfusion threat.',
        'true': ['MAP <60 is ischemia risk in note tip.', 'Immediate BP support is prioritized.', 'Oxygenation support is also prioritized.'],
        'false': ['MAP 55 is acceptable organ perfusion in this note.', 'No action needed unless MAP <20 in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this hemodynamic scenario?',
    'The nurse interprets cardiovascular data. Which statement best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent prioritization, which conclusion aligns with {name}?',
    'Which option most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is assessed for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For blood pressure management and {name}, which statements are correct? (Select all that apply)',
    'The nurse plans care around {name}. Which interventions belong in the plan? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which clues are consistent with {name} from this note? (Select all that apply)'
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
        'Because perfusion appears stable, immediate reassessment is unnecessary.',
        'Aggressive BP shifts are always preferred regardless of organ perfusion.'
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
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Hypertension, Hypotension, CO & SV', 'Blood pressure physiology and management', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - HTN/Hypotension/CO/SV (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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
