import json
import random
from pathlib import Path

random.seed(46)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-IHD-100.sql')
CATEGORY = 'Ischemic Heart Disease - NCLEX'

concepts = [
    {
        'name': 'IHD definition',
        'fact': 'Ischemic heart disease is a group of conditions caused by reduced blood flow to the myocardium.',
        'priority': 'Treat ischemic symptoms as perfusion mismatch until proven otherwise.',
        'true': ['IHD involves reduced myocardial perfusion.', 'IHD is a spectrum rather than one single condition.', 'Myocardial oxygen supply-demand mismatch is central.'],
        'false': ['IHD is primarily pericardial inflammation in this note.', 'IHD always occurs without coronary flow limitation in this note.']
    },
    {
        'name': 'Etiology',
        'fact': 'Major causes listed are atherosclerosis (most common), coronary vasospasm, and thrombosis.',
        'priority': 'Different mechanisms change urgency and treatment strategy.',
        'true': ['Atherosclerosis is the most common cause listed.', 'Coronary vasospasm is listed as a cause.', 'Thrombosis is listed as a cause.'],
        'false': ['Only congenital defects cause IHD in this note.', 'Vasospasm is excluded in this note.']
    },
    {
        'name': 'Clinical spectrum',
        'fact': 'The IHD spectrum is silent ischemia to stable angina, unstable angina, NSTEMI, and STEMI.',
        'priority': 'Progression across spectrum indicates rising acuity and intervention urgency.',
        'true': ['Unstable angina precedes infarction stages in spectrum.', 'NSTEMI and STEMI are part of IHD spectrum.', 'Silent ischemia can occur in this note.'],
        'false': ['STEMI is unrelated to IHD spectrum in this note.', 'Stable angina is the most severe endpoint in this note.']
    },
    {
        'name': 'Risk factors',
        'fact': 'Risk factors include HTN, diabetes, hyperlipidemia, smoking, obesity, family history, and age thresholds male >45/female >55.',
        'priority': 'Risk-factor clustering should increase suspicion even with atypical presentations.',
        'true': ['Hypertension and diabetes are listed risk factors.', 'Smoking and obesity are listed risk factors.', 'Age thresholds are listed for men and women.'],
        'false': ['Family history does not matter in this note.', 'Only age under 30 is listed as risk in this note.']
    },
    {
        'name': 'LAD territory',
        'fact': 'LAD supplies anterior wall and septum; occlusion causes anterior STEMI in V1–V4 and has high LV failure risk.',
        'priority': 'Anterior occlusion patterns require rapid reperfusion planning.',
        'true': ['LAD occlusion maps to V1–V4 anterior STEMI.', 'LAD is called widow maker in this note.', 'Anterior territory loss risks LV failure.'],
        'false': ['LAD mainly supplies inferior wall in this note.', 'LAD infarct primarily appears in II, III, aVF in this note.']
    },
    {
        'name': 'LCX territory',
        'fact': 'LCX supplies lateral wall (and SA node in some); occlusion causes lateral MI in I, aVL, V5–V6.',
        'priority': 'Lead localization should guide likely vessel involvement.',
        'true': ['Lateral MI leads include I, aVL, V5, V6 for LCX.', 'LCX can supply SA node in some patients.', 'LCX is often non-dominant in this note.'],
        'false': ['LCX infarct localizes to V1–V4 in this note.', 'LCX always supplies AV node in this note.']
    },
    {
        'name': 'RCA territory',
        'fact': 'RCA supplies right ventricle, inferior wall, and AV node in about 80%; occlusion causes inferior STEMI in II, III, aVF with AV blocks common.',
        'priority': 'Inferior MI with conduction changes should raise concern for RCA involvement.',
        'true': ['Inferior STEMI leads are II, III, aVF for RCA.', 'AV blocks are common with RCA MI in this note.', 'RCA supplies right ventricle/inferior wall in this note.'],
        'false': ['RCA infarcts primarily produce lateral lead changes in this note.', 'AV block is rare with RCA MI in this note.']
    },
    {
        'name': 'Stable angina pattern',
        'fact': 'Stable angina is predictable with exertion/stress, lasts less than 5 minutes, and resolves with rest.',
        'priority': 'Predictable exertional pain suggests stable ischemia but still requires risk optimization.',
        'true': ['Stable angina is predictable in this note.', 'Duration is usually under 5 minutes.', 'Rest commonly relieves symptoms.'],
        'false': ['Stable angina usually occurs at rest for >20 min in this note.', 'Stable angina does not respond to rest in this note.']
    },
    {
        'name': 'Unstable angina pattern',
        'fact': 'Unstable angina is unpredictable, can occur at rest/minimal activity, often lasts >20 minutes, and does not resolve easily.',
        'priority': 'Treat unstable angina as high-risk ACS needing hospitalization.',
        'true': ['Unstable angina may occur at rest.', 'Duration over 20 minutes is noted.', 'Early PCI strategy is listed for unstable angina.'],
        'false': ['Unstable angina is always exertional and brief in this note.', 'Unstable angina is managed only with home rest in this note.']
    },
    {
        'name': 'Variant angina',
        'fact': 'Prinzmetal angina is due to coronary vasospasm, occurs at rest/night, and shows transient ST elevation.',
        'priority': 'Differentiate vasospastic episodes from fixed plaque obstruction patterns.',
        'true': ['Variant angina occurs at rest/night in this note.', 'Transient ST elevation is described.', 'CCBs and nitrates are listed therapy.'],
        'false': ['Variant angina has permanent ST depression in this note.', 'Beta-blockers are preferred first-line in this note.']
    },
    {
        'name': 'Stable angina treatment',
        'fact': 'Stable angina treatment includes rest, SL nitroglycerin, beta-blockers, and aspirin.',
        'priority': 'Early symptom control and anti-ischemic therapy prevent escalation.',
        'true': ['SL nitroglycerin is listed for stable episodes.', 'Beta-blockers and aspirin are listed in management.', 'Rest is first response in stable episodes.'],
        'false': ['Thrombolytics are routine first-line for stable angina in this note.', 'Stable angina treatment excludes aspirin in this note.']
    },
    {
        'name': 'Unstable angina treatment',
        'fact': 'Unstable angina management includes hospitalization, anticoagulation, dual antiplatelet therapy, and early PCI.',
        'priority': 'Escalate quickly because unstable angina may progress to infarction.',
        'true': ['Hospitalization is indicated in unstable angina.', 'Dual antiplatelet and anticoagulation are listed.', 'Early PCI is part of management.'],
        'false': ['Unstable angina should be managed only with PRN NTG at home in this note.', 'No antithrombotic therapy is used in this note.']
    },
    {
        'name': 'STEMI pathophysiology',
        'fact': 'STEMI is complete coronary occlusion with transmural infarction and ST elevation, with Q waves developing later.',
        'priority': 'Complete occlusion requires immediate reperfusion timeline focus.',
        'true': ['STEMI is complete occlusion in this note.', 'ST elevation is present in STEMI.', 'Q waves may appear later in STEMI.'],
        'false': ['STEMI is partial occlusion without ST changes in this note.', 'STEMI is subendocardial only in this note.']
    },
    {
        'name': 'STEMI reperfusion target',
        'fact': 'Primary PCI should occur within 90 minutes door-to-balloon; if unavailable, thrombolytics within 30 minutes are listed.',
        'priority': 'Time-to-reperfusion drives myocardial salvage and outcomes.',
        'true': ['Door-to-balloon target is 90 minutes in this note.', 'Thrombolytic target is 30 minutes if PCI unavailable.', 'Reperfusion timing is urgent in STEMI.'],
        'false': ['STEMI PCI can wait 24 hours in this note.', 'Thrombolytics are delayed until day 2 in this note.']
    },
    {
        'name': 'NSTEMI profile',
        'fact': 'NSTEMI is partial occlusion or severe vasospasm with subendocardial infarction, ST depression/T inversion, and elevated troponin without ST elevation.',
        'priority': 'No ST elevation does not mean low risk; troponin-positive NSTEMI still needs intervention.',
        'true': ['NSTEMI has no ST elevation in this note.', 'Troponin is elevated in NSTEMI.', 'ST depression/T-wave inversion can occur.'],
        'false': ['NSTEMI requires ST elevation to diagnose in this note.', 'NSTEMI troponin remains normal in this note.']
    },
    {
        'name': 'NSTEMI timing',
        'fact': 'NSTEMI treatment includes anticoagulation + dual antiplatelet and early PCI within 24–72 hours.',
        'priority': 'Schedule timely invasive strategy while stabilizing medically.',
        'true': ['Early PCI window is 24–72 hours in this note.', 'Anticoagulation is listed in NSTEMI care.', 'Dual antiplatelet is listed in NSTEMI care.'],
        'false': ['NSTEMI never receives PCI in this note.', 'NSTEMI is treated with discharge only in this note.']
    },
    {
        'name': 'NTG BP safety',
        'fact': 'Before SL nitroglycerin, check BP and hold if systolic is <90 mmHg; patient should sit down.',
        'priority': 'Prevent NTG-related hypotension and syncope during administration.',
        'true': ['Hold NTG if systolic BP is under 90.', 'Patient should be seated before dosing.', 'BP check is step 1 in protocol.'],
        'false': ['NTG should be given regardless of BP in this note.', 'Standing position is preferred for NTG in this note.']
    },
    {
        'name': 'NTG dosing sequence',
        'fact': 'SL NTG is given every 5 minutes up to 3 doses for persistent angina.',
        'priority': 'Follow timing strictly and escalate if pain persists.',
        'true': ['Dosing interval is 5 minutes in this note.', 'Maximum is 3 doses in protocol.', 'Persistent pain after sequential doses needs escalation.'],
        'false': ['NTG should be repeated every 30 seconds in this note.', 'Unlimited NTG doses are allowed in this note.']
    },
    {
        'name': 'NTG escalation',
        'fact': 'If pain remains after 3 doses, activate emergency response (call 911/STEMI protocol).',
        'priority': 'Unrelieved pain after protocol doses signals possible infarction requiring immediate action.',
        'true': ['Emergency activation follows 3 unrelieved doses.', 'Persistent pain indicates possible acute MI.', 'Escalation should not be delayed.'],
        'false': ['Wait several hours after 3 doses before escalation in this note.', 'Pain persistence after 3 doses is low concern in this note.']
    },
    {
        'name': 'NTG storage',
        'fact': 'NTG should be kept in original dark glass bottle, room temperature, replaced every 6 months or when tongue burning sensation disappears.',
        'priority': 'Proper storage preserves potency for emergency symptom control.',
        'true': ['Dark glass bottle storage is specified.', 'Replace every 6 months is listed.', 'Loss of tongue burning suggests potency loss.'],
        'false': ['NTG should be stored in clear pill organizers in this note.', 'Potency is unaffected by storage in this note.']
    },
    {
        'name': 'MONA oxygen rule',
        'fact': 'Oxygen in MONA is indicated only if SpO2 is below 94% to avoid hyperoxia.',
        'priority': 'Use oxygen selectively rather than automatically in all chest pain cases.',
        'true': ['Oxygen is conditional on SpO2 <94% in this note.', 'Hyperoxia avoidance is emphasized.', 'Oxygen is part of MONA with indication limits.'],
        'false': ['All chest pain patients need routine oxygen regardless of saturation in this note.', 'Oxygen is never used in ACS in this note.']
    },
    {
        'name': 'MONA aspirin detail',
        'fact': 'Aspirin 325 mg is given immediately and chewed.',
        'priority': 'Immediate antiplatelet therapy is a frontline mortality-reduction step.',
        'true': ['Dose listed is 325 mg.', 'Aspirin should be chewed immediately.', 'Aspirin is part of first-line acute MI response.'],
        'false': ['Aspirin should be swallowed whole and delayed in this note.', 'Aspirin is contraindicated in all ACS cases in this note.']
    },
    {
        'name': 'Additional ACS medications',
        'fact': 'Additional therapies listed are DAPT (clopidogrel + aspirin), heparin, beta-blocker, ACE inhibitor, and statin.',
        'priority': 'Combine antithrombotic and cardioprotective therapies to reduce reinfarction and mortality.',
        'true': ['Clopidogrel + aspirin is listed.', 'Heparin is listed for anticoagulation.', 'ACE inhibitor and statin are listed post-MI supports.'],
        'false': ['Heparin is avoided in all ACS in this note.', 'Statins are not part of post-MI care in this note.']
    },
    {
        'name': 'Troponin I kinetics',
        'fact': 'Troponin I normal is <0.04 ng/mL, rises 3–6 hrs, peaks 12–24 hrs, and remains elevated 7–10 days.',
        'priority': 'Use timing to interpret serial markers accurately.',
        'true': ['Troponin I rises at 3–6 hours.', 'Troponin I peaks around 12–24 hours.', 'Troponin I may remain elevated for 7–10 days.'],
        'false': ['Troponin I normal is >5 ng/mL in this note.', 'Troponin I normalizes within 12 hours in this note.']
    },
    {
        'name': 'Troponin T kinetics',
        'fact': 'Troponin T normal is <0.01 ng/mL, rises 3–6 hrs, peaks 12–24 hrs, and can stay elevated 10–14 days.',
        'priority': 'Longer elevation duration affects interpretation in late presenters.',
        'true': ['Troponin T normal threshold is <0.01 ng/mL.', 'Troponin T can stay elevated up to 10–14 days.', 'Rise and peak timing mirror early troponin response windows.'],
        'false': ['Troponin T returns to baseline in 2 hours in this note.', 'Troponin T is not used in MI workup in this note.']
    },
    {
        'name': 'NCLEX first action',
        'fact': 'For chest pain, first action is 12-lead EKG and provider notification; aspirin is immediate and chewed.',
        'priority': 'Immediate rhythm/injury assessment plus antiplatelet action should not be delayed.',
        'true': ['12-lead EKG within 10 minutes is listed.', 'Provider notification is part of first action.', 'Chewed aspirin is immediate in NCLEX tip.'],
        'false': ['Delay EKG until after serial enzymes in this note.', 'NTG potency check precedes all acute actions in this note.']
    }
]

mcq_templates = [
    'In this high-acuity chest pain scenario, which finding best supports {name}?',
    'Which interpretation most accurately reflects {name}?',
    'The nurse prioritizes interventions; which statement aligns with {name}?',
    'Which conclusion is most consistent with {name} in this patient?',
    'Which clinical judgment best matches {name}?'
]

sata_templates = [
    'A patient is being assessed for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For suspected ACS and {name}, which statements are correct? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'The nurse plans care around {name}. Which items belong in the plan? (Select all that apply)',
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
        f'This presentation is more consistent with {concepts[(i + 4) % len(concepts)]["name"]}.',
        'Emergency escalation is unnecessary because these findings are low risk.',
        'Serial evaluation can be deferred to outpatient follow-up.'
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

    questions.append({
        'stem': stem,
        'options': option_objects(all_opts),
        'correct': correct_ids,
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
    "  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'Ischemic Heart Disease' LIMIT 1;",
    '  IF v_topic_id IS NULL THEN',
    "    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Ischemic Heart Disease', 'IHD spectrum, ACS patterns, NTG, reperfusion', 'published') RETURNING id INTO v_topic_id;",
    END_IF_SQL,
    '  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;',
    '  IF v_test_id IS NULL THEN',
    "    INSERT INTO tests (test_name, system_category, description, is_active)",
    "    VALUES ('Cardiovascular System - Ischemic Heart Disease (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)",
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
    lines.append(
        f"  VALUES (v_test_id, v_topic_id, '{stem}', '{stem}', '{options}'::jsonb, '{correct}'::jsonb, '{rationale}', '{CATEGORY}', {is_multi}, {i}, 1, true);"
    )

lines.extend(['END $$;', 'COMMIT;'])
OUT_PATH.write_text('\n'.join(lines), encoding='utf-8')
print(f'Wrote {OUT_PATH} with {len(questions)} questions')
