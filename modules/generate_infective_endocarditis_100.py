import json
import random
from pathlib import Path

random.seed(45)

OUT_PATH = Path('/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-INFECTIVE-ENDOCARDITIS-100.sql')
CATEGORY = 'Infective Endocarditis - NCLEX'

concepts = [
    {
        'name': 'Definition',
        'fact': 'Infective endocarditis is infection of the endocardium, especially heart valves, with vegetations made of fibrin, platelets, and organisms.',
        'priority': 'Treat suspected valve infection urgently to limit embolic and valvular destruction.',
        'true': [
            'Endocarditis affects the inner lining and valves.',
            'Vegetations include fibrin, platelets, and microorganisms.',
            'Valve involvement is a central feature.'
        ],
        'false': [
            'Endocarditis is infection of the pericardium in this note.',
            'Vegetations in this note are sterile in infective cases.'
        ]
    },
    {
        'name': 'Valve distribution',
        'fact': 'Mitral valve is commonly affected on the left side, and tricuspid involvement is common in IV drug use (right-sided).',
        'priority': 'Use risk profile to anticipate likely side/valve complications.',
        'true': [
            'Mitral valve involvement is common in this note.',
            'IV drug use is linked to right-sided (tricuspid) disease.',
            'Valve pattern can reflect exposure risks.'
        ],
        'false': [
            'IV drug use is primarily linked to left-sided mitral lesions in this note.',
            'Valve choice is random and unrelated to risk factors in this note.'
        ]
    },
    {
        'name': 'Organisms overview',
        'fact': 'Common organisms include Streptococcus viridans, Staphylococcus aureus, Enterococcus, S. epidermidis on prosthetic valves, and HACEK organisms.',
        'priority': 'Start broad directed therapy and narrow with culture data.',
        'true': [
            'S. viridans and S. aureus are major pathogens listed.',
            'Enterococcus is associated with GI/GU sources.',
            'Prosthetic valves are linked with S. epidermidis in this note.'
        ],
        'false': [
            'HACEK organisms are excluded in this note.',
            'Only viral organisms cause infective endocarditis in this note.'
        ]
    },
    {
        'name': 'Non-infective forms',
        'fact': 'Non-infective endocarditis includes marantic (cancer/wasting) and Libman-Sacks (SLE), where vegetations have no organisms.',
        'priority': 'Differentiate sterile vegetations from true infection before prolonged antimicrobials.',
        'true': [
            'Marantic endocarditis is a sterile form in this note.',
            'Libman-Sacks is associated with SLE.',
            'Non-infective vegetations lack organisms.'
        ],
        'false': [
            'Libman-Sacks is caused by S. aureus in this note.',
            'All endocarditis forms in this note are infectious.'
        ]
    },
    {
        'name': 'AIE profile',
        'fact': 'Acute infective endocarditis is commonly due to S. aureus, has sudden severe onset, often attacks healthy valves, and is rapidly destructive.',
        'priority': 'Escalate quickly in high-fever septic presentations with new murmur.',
        'true': [
            'AIE onset is sudden and severe in this note.',
            'S. aureus is the common acute organism listed.',
            'AIE can involve previously healthy valves.'
        ],
        'false': [
            'AIE is insidious over months in this note.',
            'AIE is less destructive than subacute disease in this note.'
        ]
    },
    {
        'name': 'SIE profile',
        'fact': 'Subacute infective endocarditis is commonly due to S. viridans, progresses gradually over weeks to months, and usually occurs on pre-existing valve disease.',
        'priority': 'Investigate prolonged low-grade constitutional symptoms in at-risk valve patients.',
        'true': [
            'SIE course is gradual in this note.',
            'S. viridans is the common subacute organism listed.',
            'Pre-existing valve disease is commonly present in SIE.'
        ],
        'false': [
            'SIE typically presents as sudden sepsis in this note.',
            'SIE usually occurs on completely normal valves in this note.'
        ]
    },
    {
        'name': 'PATHOGENS mnemonic',
        'fact': 'Risk factors are summarized by PATHOGENS: prosthetic valve, acquired valvular disease, trauma/invasive procedures, hypertrophic cardiomyopathy, other structural defects, gram-positive risk, elderly, needles, and sepsis/bacteremia.',
        'priority': 'Use mnemonic risk screening to trigger earlier blood culture and echo workup.',
        'true': [
            'Prosthetic valves are included in PATHOGENS.',
            'Needles/IV drug use is included in PATHOGENS.',
            'Sepsis/bacteremia source is included in PATHOGENS.'
        ],
        'false': [
            'PATHOGENS excludes invasive procedures in this note.',
            'Age has no impact on risk in this note.'
        ]
    },
    {
        'name': 'Classic findings',
        'fact': 'Fever is the most common sign, with new regurgitant murmur, chills, malaise, night sweats, splenomegaly, and positive blood cultures.',
        'priority': 'Treat new murmur plus fever as high-risk until proven otherwise.',
        'true': [
            'Fever is emphasized as the most common sign.',
            'New regurgitant murmur is a major clue.',
            'Positive blood cultures support diagnosis.'
        ],
        'false': [
            'Fever is uncommon in endocarditis in this note.',
            'A new murmur argues against endocarditis in this note.'
        ]
    },
    {
        'name': 'Janeway lesions',
        'fact': 'Janeway lesions are painless flat red spots on palms and soles from embolic phenomena.',
        'priority': 'Differentiate painless Janeway lesions from painful Osler nodes at bedside.',
        'true': [
            'Janeway lesions are painless in this note.',
            'They are found on palms/soles.',
            'They reflect embolic phenomena.'
        ],
        'false': [
            'Janeway lesions are painful fingertip nodules in this note.',
            'Janeway lesions are retinal findings in this note.'
        ]
    },
    {
        'name': 'Osler nodes',
        'fact': 'Osler nodes are painful nodules on fingertips/toes and represent immunologic phenomena.',
        'priority': 'Use painful digital lesions to strengthen diagnostic probability with other criteria.',
        'true': [
            'Osler nodes are painful in this note.',
            'They occur on fingers or toes.',
            'They are categorized as immunologic phenomena in criteria.'
        ],
        'false': [
            'Osler nodes are painless palm lesions in this note.',
            'Osler nodes are a vascular catheter complication in this note.'
        ]
    },
    {
        'name': 'Roth and splinter findings',
        'fact': 'Roth spots are retinal hemorrhages with pale center, and splinter hemorrhages are linear nail-bed hemorrhages.',
        'priority': 'Perform focused eye and nail assessment when embolic signs are suspected.',
        'true': [
            'Roth spots are retinal hemorrhages with pale centers.',
            'Splinter hemorrhages appear in nail beds.',
            'Both support systemic endocarditis manifestations.'
        ],
        'false': [
            'Roth spots are painful toe nodules in this note.',
            'Splinter hemorrhages are diffuse trunk petechiae in this note.'
        ]
    },
    {
        'name': 'Embolic complications',
        'fact': 'Vegetation embolization can cause stroke, renal infarct, and pulmonary emboli in right-sided disease.',
        'priority': 'Monitor neurologic, renal, and respiratory status for embolic deterioration.',
        'true': [
            'Stroke is an embolic complication listed.',
            'Renal infarct is listed as an embolic complication.',
            'Right-sided disease can embolize to lungs (PE).'
        ],
        'false': [
            'Endocarditis emboli only affect skin in this note.',
            'Right-sided emboli primarily cause cerebral emboli in this note.'
        ]
    },
    {
        'name': 'Duke major criteria',
        'fact': 'Major criteria include two positive blood cultures from separate sites and evidence of endocardial involvement (echo/new regurgitation).',
        'priority': 'Anchor diagnosis on objective microbiology plus valve involvement evidence.',
        'true': [
            'Two separate positive blood cultures are a major criterion.',
            'Echo evidence of endocardial involvement is major.',
            'New valve regurgitation supports major criteria.'
        ],
        'false': [
            'A single nonspecific fever is a major criterion in this note.',
            'Negative blood cultures satisfy major criteria in this note.'
        ]
    },
    {
        'name': 'Duke minor criteria',
        'fact': 'Minor criteria include predisposition, fever >38°C, vascular phenomena, immunologic phenomena, and microbiologic evidence not meeting major.',
        'priority': 'Count minor criteria carefully when major evidence is incomplete.',
        'true': [
            'Fever above 38°C is a minor criterion.',
            'Vascular phenomena count as minor criteria.',
            'Immunologic findings like Osler/Roth count as minor.'
        ],
        'false': [
            'Any two minor criteria are definite diagnosis in this note.',
            'Predisposing condition is excluded from minor criteria in this note.'
        ]
    },
    {
        'name': 'Definite diagnosis combinations',
        'fact': 'Definite diagnosis is 2 major OR 1 major + 3 minor OR 5 minor criteria.',
        'priority': 'Apply combination thresholds precisely to avoid under/over diagnosis.',
        'true': [
            'Two major criteria can establish definite diagnosis.',
            'One major plus three minor can establish diagnosis.',
            'Five minor criteria can establish diagnosis.'
        ],
        'false': [
            'One major alone is always definitive in this note.',
            'Three minor criteria alone are definitive in this note.'
        ]
    },
    {
        'name': 'Blood culture protocol',
        'fact': 'Obtain blood cultures ×3 from different sites before starting antibiotics.',
        'priority': 'Preserve microbiologic yield by drawing cultures prior to first dose.',
        'true': [
            'Three culture sets are recommended in this note.',
            'Different collection sites are required.',
            'Cultures should be drawn before antibiotics.'
        ],
        'false': [
            'Antibiotics should start before any cultures in this note.',
            'Only one blood culture is needed in this note.'
        ]
    },
    {
        'name': 'Echo sensitivity',
        'fact': 'TEE is more sensitive than TTE for detecting vegetations.',
        'priority': 'Escalate to TEE when suspicion remains high despite less-sensitive imaging.',
        'true': [
            'TEE is more sensitive than TTE in this note.',
            'Echo evaluates endocardial involvement.',
            'Vegetation detection is central to diagnosis.'
        ],
        'false': [
            'TTE is always more sensitive than TEE in this note.',
            'Echo has no role in diagnosis in this note.'
        ]
    },
    {
        'name': 'Lab trends',
        'fact': 'CBC can show leukocytosis, ESR/CRP can be elevated, and urinalysis can show hematuria from renal emboli.',
        'priority': 'Use labs as supportive evidence while pursuing definitive criteria.',
        'true': [
            'Leukocytosis is listed in workup.',
            'ESR/CRP elevation is listed in workup.',
            'Hematuria may suggest renal embolic involvement.'
        ],
        'false': [
            'Inflammatory markers are always normal in this note.',
            'Hematuria excludes endocarditis in this note.'
        ]
    },
    {
        'name': 'Antibiotic duration',
        'fact': 'Treatment requires IV antibiotics for 4–6 weeks with organism-specific regimens and culture-confirmed clearance.',
        'priority': 'Ensure prolonged IV adherence and follow-up culture monitoring.',
        'true': [
            'IV treatment is typically 4–6 weeks.',
            'Regimen depends on organism type.',
            'Culture clearance monitoring is required.'
        ],
        'false': [
            'A 3-day oral course is adequate in this note.',
            'No culture follow-up is needed after therapy starts in this note.'
        ]
    },
    {
        'name': 'Organism-specific regimens',
        'fact': 'Examples listed: strep with penicillin/ampicillin, staph with nafcillin or vancomycin for MRSA, enterococcus with ampicillin plus gentamicin.',
        'priority': 'Match regimen to probable/confirmed organism and resistance pattern.',
        'true': [
            'Strep regimens include penicillin or ampicillin.',
            'MRSA coverage can require vancomycin.',
            'Enterococcus regimen includes ampicillin + gentamicin.'
        ],
        'false': [
            'MRSA is first-line treated with amoxicillin alone in this note.',
            'Enterococcus is treated with no antibiotics in this note.'
        ]
    },
    {
        'name': 'Surgical indications',
        'fact': 'Surgery is indicated for severe regurgitation from valve destruction, uncontrolled infection, vegetation >10 mm with embolic risk, prosthetic valve infection, or fungal endocarditis.',
        'priority': 'Escalate to surgical consultation when medical therapy is insufficient or embolic risk is high.',
        'true': [
            'Severe regurgitation from valve destruction is an indication.',
            'Uncontrolled infection despite antibiotics is an indication.',
            'Vegetation >10 mm with embolic risk is an indication.'
        ],
        'false': [
            'All cases should avoid surgery regardless of deterioration in this note.',
            'Fungal endocarditis is never surgical in this note.'
        ]
    },
    {
        'name': 'Nursing priorities',
        'fact': 'Nursing priorities include cultures before antibiotics, fever monitoring, new murmur assessment, embolic surveillance, and long-term IV access care.',
        'priority': 'Prioritize early detection of progression while maintaining reliable IV therapy.',
        'true': [
            'Fever monitoring is emphasized.',
            'New murmur assessment is emphasized.',
            'Long-term IV access maintenance is emphasized.'
        ],
        'false': [
            'Murmur reassessment is unnecessary in this note.',
            'Short peripheral IV rotation is preferred over stable long-term access in this note.'
        ]
    },
    {
        'name': 'Prophylaxis',
        'fact': 'High-risk patients should receive amoxicillin prophylaxis before dental procedures.',
        'priority': 'Prevent procedure-related bacteremia in vulnerable cardiac patients.',
        'true': [
            'Dental prophylaxis is listed for high-risk groups.',
            'Amoxicillin is the prophylactic example provided.',
            'Prevention targets bacteremia-triggered endocarditis.'
        ],
        'false': [
            'Dental prophylaxis is unnecessary in high-risk patients in this note.',
            'Prophylaxis is only after procedures in this note.'
        ]
    },
    {
        'name': 'NCLEX synthesis',
        'fact': 'High-yield pattern: fever + new regurgitant murmur + positive cultures + embolic signs should trigger urgent IE workup and treatment.',
        'priority': 'Treat clustered red flags as a high-acuity syndrome requiring rapid action.',
        'true': [
            'Fever plus new murmur is a key cluster.',
            'Positive cultures strengthen urgency.',
            'Embolic signs increase concern for active IE.'
        ],
        'false': [
            'Embolic signs lower IE suspicion in this note.',
            'Culture positivity should delay treatment in this note.'
        ]
    }
]

mcq_templates = [
    'Which finding most strongly supports {name} in this patient with suspected valve infection?',
    'The nurse reviews chart data; which interpretation best matches {name}?',
    'Which clinical judgment is most accurate regarding {name}?',
    'In rapid prioritization, which conclusion aligns best with {name}?',
    'Which statement best reflects {name} in high-acuity endocarditis care?'
]

sata_templates = [
    'A patient is being evaluated for {name}. Which findings/actions are appropriate? (Select all that apply)',
    'For suspected infective endocarditis and {name}, which statements are correct? (Select all that apply)',
    'The nurse plans care around {name}. Which items should be included? (Select all that apply)',
    'Which findings support {name} rather than an alternative diagnosis? (Select all that apply)',
    'During reassessment, which observations align with {name}? (Select all that apply)'
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
        f'This pattern is more consistent with {concepts[(i + 5) % len(concepts)]["name"]}.',
        'Because embolic risk is minimal, urgent workup is unnecessary.',
        'Cultures should be deferred until after several antibiotic doses.'
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
lines.append("  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'Infective Endocarditis' LIMIT 1;")
lines.append('  IF v_topic_id IS NULL THEN')
lines.append("    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Infective Endocarditis', 'Valve infection, Duke criteria, embolic signs, treatment', 'published') RETURNING id INTO v_topic_id;")
lines.append(END_IF_SQL)
lines.append('  SELECT id INTO v_test_id FROM tests WHERE is_active = true ORDER BY id LIMIT 1;')
lines.append('  IF v_test_id IS NULL THEN')
lines.append("    INSERT INTO tests (test_name, system_category, description, is_active)")
lines.append("    VALUES ('Cardiovascular System - Infective Endocarditis (Generated)', 'Cardiovascular System', 'Auto-generated NCLEX question set', true)")
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
