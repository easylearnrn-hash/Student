import json
import random
from pathlib import Path

random.seed(56)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-SHOCK-MANAGEMENT-100.sql')
CATEGORY = 'Shock Management - NCLEX'
TOPIC_NAME = 'Shock Management'
TEST_NAME = 'Cardiovascular System - Shock Management (Generated)'

concepts = [
    {
        'name': 'Shock definition',
        'fact': 'Shock is inadequate tissue perfusion causing insufficient oxygen delivery and cellular dysfunction.',
        'priority': 'Treat perfusion failure early to prevent irreversible organ injury.',
        'true': ['Shock reflects inadequate tissue perfusion.', 'Cellular oxygen delivery is insufficient in shock.', 'Shock is a physiologic emergency state.'],
        'false': ['Shock is defined as isolated hypertension in this note.', 'Shock has no effect on oxygen delivery in this note.']
    },
    {
        'name': 'Shock metabolic pathway',
        'fact': 'In shock, anaerobic metabolism develops with lactic acidosis and can progress to MODS.',
        'priority': 'Track lactate and organ function to detect decompensation early.',
        'true': ['Anaerobic metabolism occurs in shock.', 'Lactic acidosis is a listed consequence.', 'Progression may lead to MODS.'],
        'false': ['Shock produces alkalosis from hyperperfusion in this note.', 'Shock cannot cause organ dysfunction in this note.']
    },
    {
        'name': 'Hypovolemic profile',
        'fact': 'Hypovolemic shock stems from blood/fluid loss with low CO, high SVR, flat neck veins, pallor, and tachycardia.',
        'priority': 'Rapid volume replacement and bleeding control are primary priorities.',
        'true': ['CO decreases in hypovolemic shock.', 'SVR increases compensatorily in hypovolemic shock.', 'Flat neck veins are listed key sign.'],
        'false': ['Hypovolemic shock has high CO and low SVR in this note.', 'JVD is classic hypovolemic finding in this note.']
    },
    {
        'name': 'Cardiogenic profile',
        'fact': 'Cardiogenic shock is pump failure (e.g., MI/HF/cardiomyopathy) with low CO, high SVR, JVD, crackles, S3, and frothy sputum.',
        'priority': 'Support contractility and address the primary cardiac lesion urgently.',
        'true': ['Pump failure etiology is listed for cardiogenic shock.', 'JVD and crackles are key signs.', 'S3/frothy sputum are associated findings.'],
        'false': ['Cardiogenic shock presents with flat neck veins in this note.', 'Cardiogenic shock has elevated CO in this note.']
    },
    {
        'name': 'Septic profile',
        'fact': 'Septic shock is distributive vasodilation with low SVR and warm flushed skin early; CO may be high early then low late.',
        'priority': 'Initiate sepsis bundle quickly before transition to late hypodynamic phase.',
        'true': ['Septic shock is distributive with vasodilation.', 'SVR is reduced in septic shock.', 'CO may be high early and low late.'],
        'false': ['Septic shock always has high SVR in this note.', 'Skin is cold/clammy from onset in all septic phases in this note.']
    },
    {
        'name': 'Neurogenic profile',
        'fact': 'Neurogenic shock follows spinal injury with loss of sympathetic tone causing low CO, low SVR, bradycardia, hypotension, and warm dry skin below injury.',
        'priority': 'Recognize bradycardia-hypotension pattern as distinguishing feature.',
        'true': ['Neurogenic shock includes bradycardia and hypotension.', 'Loss of sympathetic tone is mechanism.', 'Warm dry skin below injury is listed.'],
        'false': ['Neurogenic shock usually causes tachycardia in this note.', 'Neurogenic shock has high SVR in this note.']
    },
    {
        'name': 'Obstructive profile',
        'fact': 'Obstructive shock is due to physical flow obstruction (tamponade, tension PTX, PE) with low CO and high SVR.',
        'priority': 'Definitive relief of obstruction is mandatory for recovery.',
        'true': ['Tamponade/tension PTX/PE are listed causes.', 'CO is reduced in obstructive shock.', 'SVR is increased in obstructive shock.'],
        'false': ['Obstructive shock is caused by volume loss only in this note.', 'Obstructive shock has high CO in this note.']
    },
    {
        'name': 'Early shock signs',
        'fact': 'Early compensated shock shows tachycardia first, possible normal BP, cool clammy skin, tachypnea, anxiety, and slight urine decrease.',
        'priority': 'Do not be reassured by normal BP when compensatory signs are present.',
        'true': ['Tachycardia is first compensatory sign.', 'BP may still be normal early.', 'Cool clammy skin and tachypnea are early signs.'],
        'false': ['Hypotension is first sign of shock in this note.', 'Normal BP excludes early shock in this note.']
    },
    {
        'name': 'Late shock signs',
        'fact': 'Late decompensated shock includes hypotension, altered LOC, urine output <30 mL/hr, mottled/cyanotic skin, lactic acidosis, and MODS progression.',
        'priority': 'Escalate aggressively at decompensation to prevent arrest.',
        'true': ['Hypotension appears in late shock.', 'Urine output under 30 mL/hr is late sign.', 'Mottling/cyanosis and acidosis indicate decompensation.'],
        'false': ['Late shock has improving urine output in this note.', 'Late shock preserves normal mentation in this note.']
    },
    {
        'name': 'NCLEX early warning',
        'fact': 'NCLEX priority notes that tachycardia is first and BP drops last, so normal BP does not rule out shock.',
        'priority': 'Prioritize trend recognition over single BP value.',
        'true': ['Tachycardia-first principle is emphasized.', 'BP drop is late finding.', 'Normal BP cannot exclude early shock.'],
        'false': ['Normal BP definitively excludes shock in this note.', 'Bradycardia is first universal shock sign in this note.']
    },
    {
        'name': 'General initial treatment',
        'fact': 'General treatment includes oxygenation, large-bore IV access, continuous monitoring, urine output goals, and broad shock labs.',
        'priority': 'Rapid stabilization and monitoring should start before definitive subtype treatment.',
        'true': ['High-flow oxygen is listed in initial management.', 'Two large-bore IVs are recommended.', 'Continuous vitals/SpO2/urine monitoring is required.'],
        'false': ['Monitoring can be delayed until subtype confirmed in this note.', 'Shock treatment begins with oral fluids only in this note.']
    },
    {
        'name': 'Positioning rule',
        'fact': 'Shock positioning is generally supine with legs elevated (Trendelenburg/modified), except cardiogenic shock where HOB is elevated.',
        'priority': 'Choose position by shock type to avoid worsening pulmonary congestion.',
        'true': ['Leg-elevated supine is general shock position.', 'Cardiogenic shock is exception with HOB elevation.', 'Positioning differs by hemodynamic context.'],
        'false': ['All shock types should use strict Trendelenburg in this note.', 'Cardiogenic shock requires leg elevation above heart in this note.']
    },
    {
        'name': 'Urine output target',
        'fact': 'Foley monitoring goal is urine output greater than 0.5 mL/kg/hr.',
        'priority': 'Renal perfusion tracking is critical in shock resuscitation.',
        'true': ['Foley is recommended for hourly urine monitoring.', 'Goal >0.5 mL/kg/hr is listed.', 'Low output suggests perfusion compromise.'],
        'false': ['Urine output monitoring is optional in shock in this note.', 'Goal urine output is 0.05 mL/kg/hr in this note.']
    },
    {
        'name': 'Severe shock invasive monitoring',
        'fact': 'Arterial and central lines are used in severe shock for close hemodynamic management.',
        'priority': 'Use invasive monitoring when rapid titration is needed.',
        'true': ['Arterial line is listed in severe shock.', 'Central line is listed in severe shock.', 'Invasive monitoring supports advanced management.'],
        'false': ['Invasive lines are contraindicated in severe shock in this note.', 'Only pulse oximetry is needed in severe shock in this note.']
    },
    {
        'name': 'Shock lab panel',
        'fact': 'Recommended labs include ABG, lactate, CBC, BMP, coagulation tests, and blood cultures in sepsis.',
        'priority': 'Combine perfusion, metabolic, and infectious data quickly.',
        'true': ['ABG and lactate are listed labs.', 'CBC/BMP/coags are listed labs.', 'Blood cultures are included for sepsis context.'],
        'false': ['No labs are needed during shock in this note.', 'Only lipid panel is urgent in this note.']
    },
    {
        'name': 'Hypovolemic treatment specifics',
        'fact': 'Hypovolemic treatment is IV crystalloids (NS/LR), blood products if hemorrhagic, bleeding control, and delaying vasopressors until volume replacement.',
        'priority': 'Restore intravascular volume before vasoconstriction strategies.',
        'true': ['NS/LR fluid resuscitation is listed.', 'PRBC/FFP used in hemorrhagic shock.', 'No vasopressors before adequate volume is key point.'],
        'false': ['Vasopressors are first-line before fluids in hypovolemia in this note.', 'Bleeding source control is unnecessary in this note.']
    },
    {
        'name': 'Cardiogenic treatment specifics',
        'fact': 'Cardiogenic management includes treating cause (e.g., PCI for MI), inotropes (dobutamine/milrinone), norepinephrine if persistent hypotension, diuretics if overloaded, and possible IABP/LVAD.',
        'priority': 'Support pump function while correcting primary cardiac pathology.',
        'true': ['Dobutamine/milrinone are listed inotropes.', 'Norepinephrine may be added if hypotension persists.', 'IABP/LVAD are listed for refractory cases.'],
        'false': ['Cardiogenic shock is treated with volume loading only in this note.', 'Inotropes are contraindicated in cardiogenic shock in this note.']
    },
    {
        'name': 'Septic bundle timing',
        'fact': 'Septic shock care includes blood cultures before antibiotics, broad-spectrum antibiotics within 1 hour, and 30 mL/kg fluid bolus within 3 hours.',
        'priority': 'Time-sensitive sepsis actions strongly influence outcomes.',
        'true': ['Cultures are obtained before antibiotics.', 'Antibiotics are given within one hour.', '30 mL/kg bolus within 3 hours is listed.'],
        'false': ['Antibiotics are delayed until cultures finalize in this note.', 'Fluid bolus is contraindicated in septic shock in this note.']
    },
    {
        'name': 'Septic vasopressors/steroids',
        'fact': 'Norepinephrine is first-line vasopressor in septic shock, with corticosteroids considered if refractory.',
        'priority': 'Escalate pressor support and adjuncts when fluid response is inadequate.',
        'true': ['Norepinephrine first-line is explicitly listed.', 'Steroids are considered in refractory septic shock.', 'Septic vasodilatory physiology supports pressor use.'],
        'false': ['Dobutamine alone is first-line septic pressor in this note.', 'Steroids are always first treatment before fluids in this note.']
    },
    {
        'name': 'Neurogenic treatment specifics',
        'fact': 'Neurogenic shock treatment includes cautious fluids, norepinephrine/phenylephrine, atropine for bradycardia, and spinal immobilization.',
        'priority': 'Address vasodilation and bradycardia while protecting spinal injury.',
        'true': ['Atropine for bradycardia is listed.', 'Norepinephrine/phenylephrine are listed pressors.', 'Spinal immobilization is listed intervention.'],
        'false': ['Neurogenic shock requires no vasopressors in this note.', 'Tachycardia treatment is atropine goal in this note.']
    },
    {
        'name': 'Obstructive definitive care',
        'fact': 'Obstructive shock requires removing obstruction: pericardiocentesis for tamponade, needle decompression for tension PTX, and thrombolysis/embolectomy for PE.',
        'priority': 'Definitive mechanical relief is essential; supportive measures alone are insufficient.',
        'true': ['Tamponade requires pericardiocentesis.', 'Tension PTX needs needle decompression at 2nd ICS MCL.', 'PE may need thrombolytics or embolectomy.'],
        'false': ['Obstructive shock is corrected by fluids alone in this note.', 'Pericardiocentesis is contraindicated in tamponade in this note.']
    },
    {
        'name': 'Norepinephrine profile',
        'fact': 'Norepinephrine acts via α1 + β1 to increase SVR with mild CO effect and is first-line for septic shock; also used in neurogenic shock.',
        'priority': 'Monitor peripheral perfusion while titrating SVR support.',
        'true': ['α1 + β1 mechanism is listed.', 'First-line in septic shock is listed.', 'Neurogenic use is listed.'],
        'false': ['Norepinephrine is pure β2 bronchodilator in this note.', 'Norepinephrine lowers SVR in this note.']
    },
    {
        'name': 'Dobutamine profile',
        'fact': 'Dobutamine is a β1 inotrope increasing contractility and is used in cardiogenic shock with reduced EF.',
        'priority': 'Use inotropy to augment forward flow in pump failure.',
        'true': ['Dobutamine is β1 inotrope in note.', 'It increases contractility.', 'Used for cardiogenic shock with low EF.'],
        'false': ['Dobutamine is first-line for anaphylaxis in this note.', 'Dobutamine primarily decreases contractility in this note.']
    },
    {
        'name': 'Epinephrine and vasopressin profiles',
        'fact': 'Epinephrine is α1/β1/β2 and used in anaphylaxis/cardiac arrest, while vasopressin (V1) is septic add-on vasoconstrictor.',
        'priority': 'Match pressor receptor profile to clinical indication.',
        'true': ['Epinephrine has alpha/beta effects in note.', 'Epinephrine indications include anaphylaxis/cardiac arrest.', 'Vasopressin is septic add-on via V1 vasoconstriction.'],
        'false': ['Vasopressin is first-line bronchodilator in this note.', 'Epinephrine has no cardiovascular receptor effects in this note.']
    },
    {
        'name': 'Shock-type mnemonic',
        'fact': 'Mnemonic in note: H hypovolemic (empty tank), C cardiogenic (broken pump), D distributive (leaky pipes), O obstructive (blocked exit).',
        'priority': 'Use simple mechanistic labels to speed differentiation and treatment selection.',
        'true': ['Hypovolemic is described as empty tank.', 'Cardiogenic is broken pump.', 'Obstructive is blocked exit.'],
        'false': ['Distributive is blocked exit in this note.', 'Cardiogenic is leaky pipes in this note.']
    },
    {
        'name': 'Integrated NCLEX triage',
        'fact': 'Early shock recognition hinges on tachycardia/tachypnea/anxiety before hypotension, with subtype-targeted definitive management thereafter.',
        'priority': 'Identify compensated shock early and tailor treatment by mechanism.',
        'true': ['Compensated shock can present before BP drop.', 'Subtype-specific therapy is required after initial stabilization.', 'Delayed recognition increases MODS risk.'],
        'false': ['All shock is treated identically long-term in this note.', 'Hypotension must appear before any intervention in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this shock scenario?',
    'The nurse reviews hemodynamic data. Which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent triage, which conclusion aligns with {name}?',
    'Which statement most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For management involving {name}, which statements are correct? (Select all that apply)',
    'The nurse plans interventions around {name}. Which items belong in the plan? (Select all that apply)',
    'During reassessment, which observations support {name}? (Select all that apply)',
    'Which cues are consistent with {name} in this note? (Select all that apply)'
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
    stem = mcq_templates[i % len(mcq_templates)].format(name=c['name'])
    correct = c['fact'] if i % 2 == 0 else c['priority']

    distractors = c['false'] + [
        f'This pattern is more consistent with {concepts[(i + 4) % len(concepts)]["name"]}.',
        'Shock subtype is irrelevant once oxygen is started.',
        'Blood pressure normalization alone confirms full recovery.'
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
