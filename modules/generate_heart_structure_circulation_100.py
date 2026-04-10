import json
import random
from pathlib import Path

random.seed(55)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-HEART-STRUCTURE-CIRCULATION-100.sql')
CATEGORY = 'Heart Structure and Circulation - NCLEX'
TOPIC_NAME = 'Heart Structure & Circulation'
TEST_NAME = 'Cardiovascular System - Heart Structure & Circulation (Generated)'

concepts = [
    {
        'name': 'Right heart role',
        'fact': 'Right heart receives deoxygenated venous blood and pumps it to lungs via pulmonary circulation.',
        'priority': 'Differentiate right-sided flow purpose when interpreting oxygenation pathways.',
        'true': ['RA receives deoxygenated blood from SVC/IVC.', 'RV pumps to lungs.', 'Pulmonary circuit begins from right ventricle.'],
        'false': ['Right heart pumps oxygenated blood to aorta in this note.', 'Right atrium receives blood from pulmonary veins in this note.']
    },
    {
        'name': 'Left heart role',
        'fact': 'Left heart receives oxygenated blood from pulmonary veins and pumps it systemically via aorta.',
        'priority': 'Use left-sided failure signs to infer systemic output compromise.',
        'true': ['LA receives oxygenated blood from lungs.', 'LV pumps blood to body via aorta.', 'Systemic circulation is driven by left ventricle.'],
        'false': ['Left atrium receives blood from SVC in this note.', 'Left ventricle empties into pulmonary artery in this note.']
    },
    {
        'name': 'Tricuspid valve location',
        'fact': 'Tricuspid valve lies between RA and RV and prevents backflow from RV to RA.',
        'priority': 'Valve-location clarity supports murmur and regurgitation interpretation.',
        'true': ['Tricuspid separates right atrium and ventricle.', 'It prevents RV-to-RA backflow.', 'It has three leaflets in this note.'],
        'false': ['Tricuspid sits between LA and LV in this note.', 'Tricuspid opens into aorta in this note.']
    },
    {
        'name': 'Pulmonic valve function',
        'fact': 'Pulmonic valve opens from RV into pulmonary artery during RV contraction.',
        'priority': 'Link right ventricular systole to pulmonary artery outflow events.',
        'true': ['Pulmonic valve is between RV and pulmonary artery.', 'It opens with RV contraction.', 'It directs blood toward lungs.'],
        'false': ['Pulmonic valve controls flow from LV to aorta in this note.', 'Pulmonic valve routes blood to SVC in this note.']
    },
    {
        'name': 'Mitral valve location',
        'fact': 'Mitral (bicuspid) valve is between LA and LV and prevents LV-to-LA backflow.',
        'priority': 'Recognize mitral pathology impact on pulmonary venous pressures.',
        'true': ['Mitral separates LA and LV.', 'Mitral is bicuspid (2 leaflets).', 'Mitral limits LV-to-LA regurgitation.'],
        'false': ['Mitral is right-sided semilunar valve in this note.', 'Mitral has three leaflets in this note.']
    },
    {
        'name': 'Aortic valve function',
        'fact': 'Aortic valve opens from LV into aorta during LV contraction to supply systemic circulation.',
        'priority': 'Aortic outflow understanding is key to systemic perfusion interpretation.',
        'true': ['Aortic valve lies between LV and aorta.', 'It opens during LV systole.', 'It delivers oxygenated blood to body.'],
        'false': ['Aortic valve opens into pulmonary artery in this note.', 'Aortic valve functions during atrial filling in this note.']
    },
    {
        'name': 'Valve mnemonic',
        'fact': 'Valve order mnemonic is Try Pulling My Aorta: Tricuspid, Pulmonic, Mitral, Aortic.',
        'priority': 'Use mnemonic to avoid right-left sequence errors under exam pressure.',
        'true': ['Tricuspid is first in mnemonic.', 'Pulmonic follows tricuspid.', 'Mitral then aortic complete sequence.'],
        'false': ['Mnemonic order starts with aortic in this note.', 'Pulmonic is last in sequence in this note.']
    },
    {
        'name': 'Pulmonary circuit',
        'fact': 'Pulmonary circulation route is RV to pulmonary artery to lungs to pulmonary veins to LA.',
        'priority': 'Confirm oxygenation transition occurs in lungs before LA return.',
        'true': ['RV ejects deoxygenated blood to pulmonary artery.', 'Gas exchange occurs in lungs.', 'Pulmonary veins return oxygenated blood to LA.'],
        'false': ['Pulmonary veins carry deoxygenated blood to RA in this note.', 'Pulmonary artery carries oxygenated blood to body in this note.']
    },
    {
        'name': 'Systemic circuit',
        'fact': 'Systemic circulation route is LV to aorta to body tissues then venous return via SVC/IVC to RA.',
        'priority': 'Trace systemic return correctly to localize circulation problems.',
        'true': ['LV drives systemic outflow through aorta.', 'Tissues extract oxygen peripherally.', 'SVC/IVC return deoxygenated blood to RA.'],
        'false': ['Systemic return enters LA directly in this note.', 'RV pumps systemic circulation in this note.']
    },
    {
        'name': 'Full blood flow sequence',
        'fact': 'Complete sequence is SVC/IVC→RA→Tricuspid→RV→Pulmonic→Pulmonary artery→Lungs→Pulmonary veins→LA→Mitral→LV→Aortic→Aorta→Body.',
        'priority': 'Sequential mastery supports congenital/valvular defect reasoning.',
        'true': ['Sequence starts with venous return to RA.', 'Pulmonary veins precede LA in sequence.', 'Aortic valve precedes aorta/body in sequence.'],
        'false': ['Sequence bypasses right ventricle in this note.', 'Mitral valve comes before pulmonary veins in this note.']
    },
    {
        'name': 'Artery vs vein rule',
        'fact': 'Arteries carry blood away from heart and veins carry blood toward heart, with pulmonary vessels as oxygenation exceptions.',
        'priority': 'Separate directionality from oxygen-content assumptions.',
        'true': ['Arteries move blood away from heart.', 'Veins return blood to heart.', 'Pulmonary artery/vein are oxygenation exceptions.'],
        'false': ['Veins always carry deoxygenated blood with no exceptions in this note.', 'Arteries always carry oxygenated blood with no exceptions in this note.']
    },
    {
        'name': 'Pulmonary artery exception',
        'fact': 'Pulmonary artery is an artery carrying deoxygenated blood from RV to lungs.',
        'priority': 'Do not equate artery classification with oxygen content.',
        'true': ['Pulmonary artery is deoxygenated in this note.', 'It travels away from heart so remains an artery.', 'Origin is right ventricle.'],
        'false': ['Pulmonary artery carries oxygenated blood from lungs in this note.', 'Pulmonary artery is classified as a vein in this note.']
    },
    {
        'name': 'Pulmonary vein exception',
        'fact': 'Pulmonary veins are veins carrying oxygenated blood from lungs to LA.',
        'priority': 'Use direction-based vessel naming during differential questions.',
        'true': ['Pulmonary veins carry oxygenated blood.', 'They return blood toward heart.', 'They empty into left atrium.'],
        'false': ['Pulmonary veins carry deoxygenated blood to RV in this note.', 'Pulmonary veins empty into right atrium in this note.']
    },
    {
        'name': 'Heart wall layers',
        'fact': 'Heart wall layers are epicardium outer, myocardium muscular middle, and endocardium inner chamber/valve lining.',
        'priority': 'Layer differentiation helps map pathology (myocarditis, endocarditis, etc.).',
        'true': ['Epicardium is outer layer.', 'Myocardium is pumping muscle.', 'Endocardium lines chambers/valves.'],
        'false': ['Endocardium is outer pericardial layer in this note.', 'Myocardium is non-muscular lining in this note.']
    },
    {
        'name': 'Pericardium facts',
        'fact': 'Pericardium is a double-layer sac with lubricating fluid; excess fluid may cause cardiac tamponade.',
        'priority': 'Monitor effusion progression because tamponade is hemodynamically dangerous.',
        'true': ['Pericardium has two layers in note.', 'Lubricating fluid reduces friction.', 'Excess fluid can lead to tamponade.'],
        'false': ['Pericardium has no fluid in normal state in this note.', 'Excess pericardial fluid improves output in this note.']
    },
    {
        'name': 'LCA branches',
        'fact': 'Left coronary artery branches into LAD and LCX; LAD supplies anterior LV and 2/3 septum, LCX supplies lateral LV wall.',
        'priority': 'Lead-territory ischemia mapping depends on branch supply knowledge.',
        'true': ['LAD and LCX branch from LCA.', 'LAD supplies anterior wall and most septum.', 'LCX supplies lateral LV wall.'],
        'false': ['LCA branches directly into PDA only in this note.', 'LCX supplies right ventricle primarily in this note.']
    },
    {
        'name': 'RCA territory',
        'fact': 'RCA supplies right ventricle and posterior wall and branches into PDA in this note.',
        'priority': 'Inferior/posterior ischemia questions require RCA territory recall.',
        'true': ['RCA supplies right ventricle.', 'Posterior wall supply is associated with RCA here.', 'PDA branch from RCA is listed.'],
        'false': ['RCA supplies only left atrium in this note.', 'RCA has no major branches in this note.']
    },
    {
        'name': 'S1 sound',
        'fact': 'S1 (lub) is closure of mitral and tricuspid valves at start of systole.',
        'priority': 'Correctly time heart sounds with valve events and cardiac cycle.',
        'true': ['S1 corresponds to AV valve closure.', 'S1 marks beginning of systole.', 'S1 is a normal sound in this context.'],
        'false': ['S1 is semilunar valve closure in this note.', 'S1 marks end of systole in this note.']
    },
    {
        'name': 'S2 sound',
        'fact': 'S2 (dub) is closure of aortic and pulmonic valves, marking end of systole.',
        'priority': 'Pair semilunar closure timing with pressure-cycle interpretation.',
        'true': ['S2 is semilunar valve closure.', 'S2 marks end of systole.', 'Aortic and pulmonic closure create S2.'],
        'false': ['S2 is AV valve closure in this note.', 'S2 indicates ventricular filling start only in this note.']
    },
    {
        'name': 'S3 significance',
        'fact': 'S3 is linked to rapid ventricular filling and is abnormal in adults, associated with heart failure.',
        'priority': 'New S3 in adults should prompt volume overload/heart-failure evaluation.',
        'true': ['S3 is tied to rapid ventricular filling.', 'S3 in adults is abnormal in this note.', 'S3 associates with heart failure.'],
        'false': ['S3 is normal adult athletic finding in this note.', 'S3 indicates valvular stenosis only in this note.']
    },
    {
        'name': 'S4 significance',
        'fact': 'S4 reflects atrial kick against a stiff ventricle and is associated with hypertension and hypertrophic cardiomyopathy.',
        'priority': 'S4 suggests reduced ventricular compliance.',
        'true': ['S4 comes from atrial kick into stiff ventricle.', 'Hypertension is linked with S4 in note.', 'HCM is linked with S4 in note.'],
        'false': ['S4 indicates acute pulmonary embolism in this note.', 'S4 is caused by AV valve closure in this note.']
    },
    {
        'name': 'Murmur meaning',
        'fact': 'Murmurs represent turbulent blood flow and may indicate valve stenosis or regurgitation.',
        'priority': 'Characterize murmurs to evaluate structural valve disease risk.',
        'true': ['Murmur means turbulent flow.', 'Stenosis can cause murmur.', 'Regurgitation can cause murmur.'],
        'false': ['Murmurs are always benign in this note.', 'Murmurs indicate normal laminar flow in this note.']
    },
    {
        'name': 'NCLEX sound mnemonics',
        'fact': 'NCLEX note links S3 to “Ken-tuc-ky” and heart failure, and S4 to “Ten-nes-see” and stiff ventricles/HTN.',
        'priority': 'Memory mnemonics can speed sound interpretation under exam pressure.',
        'true': ['S3 mnemonic is Kentucky in note.', 'S4 mnemonic is Tennessee in note.', 'Mnemonic pairing reflects HF vs stiff ventricle context.'],
        'false': ['S3 mnemonic is Tennessee in this note.', 'S4 is linked to normal youthful physiology in this note.']
    },
    {
        'name': 'Integrated circulation reasoning',
        'fact': 'Gas exchange occurs in lungs between pulmonary artery output and pulmonary vein return, enabling oxygenated LA inflow before systemic ejection.',
        'priority': 'Use exchange location to resolve oxygenation pathway questions accurately.',
        'true': ['Lungs are gas-exchange site in sequence.', 'Pulmonary venous return is oxygenated.', 'LA receives oxygenated blood before LV systemic ejection.'],
        'false': ['Gas exchange occurs in left ventricle in this note.', 'Aorta returns deoxygenated blood to RA in this note.']
    }
]

mcq_templates = [
    'Which finding best supports {name} in this cardiac anatomy scenario?',
    'The nurse reviews cardiovascular physiology data. Which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In urgent triage, which conclusion aligns with {name}?',
    'Which statement most appropriately reflects {name}?'
]

sata_templates = [
    'A patient is evaluated for concepts related to {name}. Which findings/statements are correct? (Select all that apply)',
    'For assessment involving {name}, which options are appropriate? (Select all that apply)',
    'The nurse teaches cardiac flow and {name}. Which points should be included? (Select all that apply)',
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
        f'This pattern is more consistent with {concepts[(i + 5) % len(concepts)]["name"]}.',
        'Direction of blood flow is optional when identifying vessel type.',
        'Valve-sequence recall has no impact on hemodynamic interpretation.'
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
    f"    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, '{TOPIC_NAME_SQL}', 'Chambers valves circulation pathways and heart sounds', 'published') RETURNING id INTO v_topic_id;",
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
