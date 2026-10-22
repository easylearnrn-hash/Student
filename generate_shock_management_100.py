import json
import re
import statistics
import random
from pathlib import Path

random.seed(56)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-SHOCK-MANAGEMENT-100.sql')
CATEGORY = 'Shock Management - NCLEX'
TOPIC = 'Shock Management'
TOPIC_NAME = 'Shock Management'
TEST_NAME = 'Cardiovascular System - Shock Management (Generated)'

concepts = [
    {
        'name': 'Shock definition',
        'fact': 'Shock is inadequate tissue perfusion causing insufficient oxygen delivery and cellular dysfunction.',
        'priority': 'Treat perfusion failure early to prevent irreversible organ injury.',
        'true': ['Shock reflects inadequate tissue perfusion.', 'Cellular oxygen delivery is insufficient in shock.', 'Shock is a physiologic emergency state.'],
        'false': ['Shock is defined as isolated hypertension.', 'Shock has no effect on oxygen delivery.']
    },
    {
        'name': 'Shock metabolic pathway',
        'fact': 'In shock, anaerobic metabolism develops with lactic acidosis and can progress to MODS.',
        'priority': 'Track lactate and organ function to detect decompensation early.',
        'true': ['Anaerobic metabolism occurs in shock.', 'Lactic acidosis is a listed consequence.', 'Progression may lead to MODS.'],
        'false': ['Shock produces alkalosis from hyperperfusion.', 'Shock cannot cause organ dysfunction.']
    },
    {
        'name': 'Hypovolemic profile',
        'fact': 'Hypovolemic shock stems from blood/fluid loss with low CO, high SVR, flat neck veins, pallor, and tachycardia.',
        'priority': 'Rapid volume replacement and bleeding control are primary priorities.',
        'true': ['CO decreases in hypovolemic shock.', 'SVR increases compensatorily in hypovolemic shock.', 'Flat neck veins are listed key sign.'],
        'false': ['Hypovolemic shock has high CO and low SVR.', 'JVD is classic hypovolemic finding.']
    },
    {
        'name': 'Cardiogenic profile',
        'fact': 'Cardiogenic shock is pump failure (e.g., MI/HF/cardiomyopathy) with low CO, high SVR, JVD, crackles, S3, and frothy sputum.',
        'priority': 'Support contractility and address the primary cardiac lesion urgently.',
        'true': ['Pump failure etiology is listed for cardiogenic shock.', 'JVD and crackles are key signs.', 'S3/frothy sputum are associated findings.'],
        'false': ['Cardiogenic shock presents with flat neck veins.', 'Cardiogenic shock has elevated CO.']
    },
    {
        'name': 'Septic profile',
        'fact': 'Septic shock is distributive vasodilation with low SVR and warm flushed skin early; CO may be high early then low late.',
        'priority': 'Initiate sepsis bundle quickly before transition to late hypodynamic phase.',
        'true': ['Septic shock is distributive with vasodilation.', 'SVR is reduced in septic shock.', 'CO may be high early and low late.'],
        'false': ['Septic shock always has high SVR.', 'Skin is cold/clammy from onset in all septic phases.']
    },
    {
        'name': 'Neurogenic profile',
        'fact': 'Neurogenic shock follows spinal injury with loss of sympathetic tone causing low CO, low SVR, bradycardia, hypotension, and warm dry skin below injury.',
        'priority': 'Recognize bradycardia-hypotension pattern as distinguishing feature.',
        'true': ['Neurogenic shock includes bradycardia and hypotension.', 'Loss of sympathetic tone is mechanism.', 'Warm dry skin below injury is listed.'],
        'false': ['Neurogenic shock usually causes tachycardia.', 'Neurogenic shock has high SVR.']
    },
    {
        'name': 'Obstructive profile',
        'fact': 'Obstructive shock is due to physical flow obstruction (tamponade, tension PTX, PE) with low CO and high SVR.',
        'priority': 'Definitive relief of obstruction is mandatory for recovery.',
        'true': ['Tamponade/tension PTX/PE are listed causes.', 'CO is reduced in obstructive shock.', 'SVR is increased in obstructive shock.'],
        'false': ['Obstructive shock is caused by volume loss only.', 'Obstructive shock has high CO.']
    },
    {
        'name': 'Early shock signs',
        'fact': 'Early compensated shock shows tachycardia first, possible normal BP, cool clammy skin, tachypnea, anxiety, and slight urine decrease.',
        'priority': 'Do not be reassured by normal BP when compensatory signs are present.',
        'true': ['Tachycardia is first compensatory sign.', 'BP may still be normal early.', 'Cool clammy skin and tachypnea are early signs.'],
        'false': ['Hypotension is first sign of shock.', 'Normal BP excludes early shock.']
    },
    {
        'name': 'Late shock signs',
        'fact': 'Late decompensated shock includes hypotension, altered LOC, urine output <30 mL/hr, mottled/cyanotic skin, lactic acidosis, and MODS progression.',
        'priority': 'Escalate aggressively at decompensation to prevent arrest.',
        'true': ['Hypotension appears in late shock.', 'Urine output under 30 mL/hr is late sign.', 'Mottling/cyanosis and acidosis indicate decompensation.'],
        'false': ['Late shock has improving urine output.', 'Late shock preserves normal mentation.']
    },
    {
        'name': 'NCLEX early warning',
        'fact': 'NCLEX priority notes that tachycardia is first and BP drops last, so normal BP does not rule out shock.',
        'priority': 'Prioritize trend recognition over single BP value.',
        'true': ['Tachycardia-first principle is emphasized.', 'BP drop is late finding.', 'Normal BP cannot exclude early shock.'],
        'false': ['Normal BP definitively excludes shock.', 'Bradycardia is first universal shock sign.']
    },
    {
        'name': 'General initial treatment',
        'fact': 'General treatment includes oxygenation, large-bore IV access, continuous monitoring, urine output goals, and broad shock labs.',
        'priority': 'Rapid stabilization and monitoring should start before definitive subtype treatment.',
        'true': ['High-flow oxygen is listed in initial management.', 'Two large-bore IVs are recommended.', 'Continuous vitals/SpO2/urine monitoring is required.'],
        'false': ['Monitoring can be delayed until subtype confirmed.', 'Shock treatment begins with oral fluids only.']
    },
    {
        'name': 'Positioning rule',
        'fact': 'Shock positioning is generally supine with legs elevated (Trendelenburg/modified), except cardiogenic shock where HOB is elevated.',
        'priority': 'Choose position by shock type to avoid worsening pulmonary congestion.',
        'true': ['Leg-elevated supine is general shock position.', 'Cardiogenic shock is exception with HOB elevation.', 'Positioning differs by hemodynamic context.'],
        'false': ['All shock types should use strict Trendelenburg.', 'Cardiogenic shock requires leg elevation above heart.']
    },
    {
        'name': 'Urine output target',
        'fact': 'Foley monitoring goal is urine output greater than 0.5 mL/kg/hr.',
        'priority': 'Renal perfusion tracking is critical in shock resuscitation.',
        'true': ['Foley is recommended for hourly urine monitoring.', 'Goal >0.5 mL/kg/hr is listed.', 'Low output suggests perfusion compromise.'],
        'false': ['Urine output monitoring is optional in shock.', 'Goal urine output is 0.05 mL/kg/hr.']
    },
    {
        'name': 'Severe shock invasive monitoring',
        'fact': 'Arterial and central lines are used in severe shock for close hemodynamic management.',
        'priority': 'Use invasive monitoring when rapid titration is needed.',
        'true': ['Arterial line is listed in severe shock.', 'Central line is listed in severe shock.', 'Invasive monitoring supports advanced management.'],
        'false': ['Invasive lines are contraindicated in severe shock.', 'Only pulse oximetry is needed in severe shock.']
    },
    {
        'name': 'Shock lab panel',
        'fact': 'Recommended labs include ABG, lactate, CBC, BMP, coagulation tests, and blood cultures in sepsis.',
        'priority': 'Combine perfusion, metabolic, and infectious data quickly.',
        'true': ['ABG and lactate are listed labs.', 'CBC/BMP/coags are listed labs.', 'Blood cultures are included for sepsis context.'],
        'false': ['No labs are needed during shock.', 'Only lipid panel is urgent.']
    },
    {
        'name': 'Hypovolemic treatment specifics',
        'fact': 'Hypovolemic treatment is IV crystalloids (NS/LR), blood products if hemorrhagic, bleeding control, and delaying vasopressors until volume replacement.',
        'priority': 'Restore intravascular volume before vasoconstriction strategies.',
        'true': ['NS/LR fluid resuscitation is listed.', 'PRBC/FFP used in hemorrhagic shock.', 'No vasopressors before adequate volume is key point.'],
        'false': ['Vasopressors are first-line before fluids in hypovolemia.', 'Bleeding source control is unnecessary.']
    },
    {
        'name': 'Cardiogenic treatment specifics',
        'fact': 'Cardiogenic management includes treating cause (e.g., PCI for MI), inotropes (dobutamine/milrinone), norepinephrine if persistent hypotension, diuretics if overloaded, and possible IABP/LVAD.',
        'priority': 'Support pump function while correcting primary cardiac pathology.',
        'true': ['Dobutamine/milrinone are listed inotropes.', 'Norepinephrine may be added if hypotension persists.', 'IABP/LVAD are listed for refractory cases.'],
        'false': ['Cardiogenic shock is treated with volume loading only.', 'Inotropes are contraindicated in cardiogenic shock.']
    },
    {
        'name': 'Septic bundle timing',
        'fact': 'Septic shock care includes blood cultures before antibiotics, broad-spectrum antibiotics within 1 hour, and 30 mL/kg fluid bolus within 3 hours.',
        'priority': 'Time-sensitive sepsis actions strongly influence outcomes.',
        'true': ['Cultures are obtained before antibiotics.', 'Antibiotics are given within one hour.', '30 mL/kg bolus within 3 hours is listed.'],
        'false': ['Antibiotics are delayed until cultures finalize.', 'Fluid bolus is contraindicated in septic shock.']
    },
    {
        'name': 'Septic vasopressors/steroids',
        'fact': 'Norepinephrine is first-line vasopressor in septic shock, with corticosteroids considered if refractory.',
        'priority': 'Escalate pressor support and adjuncts when fluid response is inadequate.',
        'true': ['Norepinephrine first-line is explicitly listed.', 'Steroids are considered in refractory septic shock.', 'Septic vasodilatory physiology supports pressor use.'],
        'false': ['Dobutamine alone is first-line septic pressor.', 'Steroids are always first treatment before fluids.']
    },
    {
        'name': 'Neurogenic treatment specifics',
        'fact': 'Neurogenic shock treatment includes cautious fluids, norepinephrine/phenylephrine, atropine for bradycardia, and spinal immobilization.',
        'priority': 'Address vasodilation and bradycardia while protecting spinal injury.',
        'true': ['Atropine for bradycardia is listed.', 'Norepinephrine/phenylephrine are listed pressors.', 'Spinal immobilization is listed intervention.'],
        'false': ['Neurogenic shock requires no vasopressors.', 'Tachycardia treatment is atropine goal.']
    },
    {
        'name': 'Obstructive definitive care',
        'fact': 'Obstructive shock requires removing obstruction: pericardiocentesis for tamponade, needle decompression for tension PTX, and thrombolysis/embolectomy for PE.',
        'priority': 'Definitive mechanical relief is essential; supportive measures alone are insufficient.',
        'true': ['Tamponade requires pericardiocentesis.', 'Tension PTX needs needle decompression at 2nd ICS MCL.', 'PE may need thrombolytics or embolectomy.'],
        'false': ['Obstructive shock is corrected by fluids alone.', 'Pericardiocentesis is contraindicated in tamponade.']
    },
    {
        'name': 'Norepinephrine profile',
        'fact': 'Norepinephrine acts via α1 + β1 to increase SVR with mild CO effect and is first-line for septic shock; also used in neurogenic shock.',
        'priority': 'Monitor peripheral perfusion while titrating SVR support.',
        'true': ['α1 + β1 mechanism is listed.', 'First-line in septic shock is listed.', 'Neurogenic use is listed.'],
        'false': ['Norepinephrine is pure β2 bronchodilator.', 'Norepinephrine lowers SVR.']
    },
    {
        'name': 'Dobutamine profile',
        'fact': 'Dobutamine is a β1 inotrope increasing contractility and is used in cardiogenic shock with reduced EF.',
        'priority': 'Use inotropy to augment forward flow in pump failure.',
        'true': ['Dobutamine is β1 inotrope in note.', 'It increases contractility.', 'Used for cardiogenic shock with low EF.'],
        'false': ['Dobutamine is first-line for anaphylaxis.', 'Dobutamine primarily decreases contractility.']
    },
    {
        'name': 'Epinephrine and vasopressin profiles',
        'fact': 'Epinephrine is α1/β1/β2 and used in anaphylaxis/cardiac arrest, while vasopressin (V1) is septic add-on vasoconstrictor.',
        'priority': 'Match pressor receptor profile to clinical indication.',
        'true': ['Epinephrine has alpha/beta effects in note.', 'Epinephrine indications include anaphylaxis/cardiac arrest.', 'Vasopressin is septic add-on via V1 vasoconstriction.'],
        'false': ['Vasopressin is first-line bronchodilator.', 'Epinephrine has no cardiovascular receptor effects.']
    },
    {
        'name': 'Shock-type mnemonic',
        'fact': 'Mnemonic in note: H hypovolemic (empty tank), C cardiogenic (broken pump), D distributive (leaky pipes), O obstructive (blocked exit).',
        'priority': 'Use simple mechanistic labels to speed differentiation and treatment selection.',
        'true': ['Hypovolemic is described as empty tank.', 'Cardiogenic is broken pump.', 'Obstructive is blocked exit.'],
        'false': ['Distributive is blocked exit.', 'Cardiogenic is leaky pipes.']
    },
    {
        'name': 'Integrated NCLEX triage',
        'fact': 'Early shock recognition hinges on tachycardia/tachypnea/anxiety before hypotension, with subtype-targeted definitive management thereafter.',
        'priority': 'Identify compensated shock early and tailor treatment by mechanism.',
        'true': ['Compensated shock can present before BP drop.', 'Subtype-specific therapy is required after initial stabilization.', 'Delayed recognition increases MODS risk.'],
        'false': ['All shock is treated identically long-term.', 'Hypotension must appear before any intervention.']
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
        'Shock subtype is irrelevant once oxygen is started.',
        'Blood pressure normalization alone confirms full recovery.'
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
    f"    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, '{TOPIC_NAME_SQL}', 'Shock types, recognition, and targeted treatment', 'published') RETURNING id INTO v_topic_id;",
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
