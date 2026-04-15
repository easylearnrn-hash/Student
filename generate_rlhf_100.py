import json
import random
from pathlib import Path

random.seed(42)

OUT_PATH = Path("/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/COMPLETE NEW /modules/Test/INSERT-RLHF-100.sql")
CATEGORY = "Right-Left Heart Failure - NCLEX"
TOPIC_NAME = "Right & Left Heart Failure"

# Source-constrained facts from Notes/Cardiovascular System/Right-Left-Heart-Failure.html
concepts = [
    {
        "name": "HF Definition",
        "fact": "Heart failure is the inability of the heart to pump sufficient blood to meet metabolic needs.",
        "priority": "Recognize that congestion and low forward output can coexist.",
        "true": [
            "Heart failure means the heart cannot pump enough blood to meet metabolic demand.",
            "Heart failure can cause backward fluid congestion.",
            "Heart failure can reduce forward perfusion."
        ],
        "false": [
            "Heart failure requires an ejection fraction below 20% in all patients.",
            "Heart failure always presents without fluid overload."
        ]
    },
    {
        "name": "HFrEF",
        "fact": "HFrEF has EF <40% with a dilated, weak heart.",
        "priority": "Link reduced EF with weakened pump function.",
        "true": [
            "HFrEF is associated with EF below 40%.",
            "HFrEF is commonly described as a dilated, weak heart.",
            "Reduced contractility contributes to poor forward output in HFrEF."
        ],
        "false": [
            "HFrEF is defined by EF above 50%.",
            "HFrEF is primarily a stiff non-compliant ventricle with preserved EF."
        ]
    },
    {
        "name": "HFpEF",
        "fact": "HFpEF has EF >50% with a stiff, non-compliant heart.",
        "priority": "Avoid ruling out HF just because EF is preserved.",
        "true": [
            "HFpEF is associated with EF above 50%.",
            "HFpEF is described as a stiff, non-compliant ventricle.",
            "Symptoms may still indicate heart failure even with preserved EF."
        ],
        "false": [
            "HFpEF is a dilated weak ventricle by definition.",
            "HFpEF excludes all congestion symptoms."
        ]
    },
    {
        "name": "EF Range",
        "fact": "Normal EF is 55-70%; HF diagnosis can still be made if symptoms are present regardless of EF.",
        "priority": "Prioritize clinical symptoms over EF alone.",
        "true": [
            "Normal EF is approximately 55-70%.",
            "Symptoms remain central to HF diagnosis.",
            "A patient can have HF symptoms even when EF is preserved."
        ],
        "false": [
            "Any EF above 50% rules out heart failure.",
            "EF alone is always enough to diagnose or exclude HF."
        ]
    },
    {
        "name": "Left HF Core",
        "fact": "Left-sided HF primarily causes pulmonary congestion.",
        "priority": "Map left side findings to lung congestion.",
        "true": [
            "Left-sided HF causes pulmonary congestion.",
            "Dyspnea and crackles are hallmark left-sided findings.",
            "Orthopnea strongly supports left-sided congestion."
        ],
        "false": [
            "Left-sided HF primarily causes isolated ankle edema without lung findings.",
            "Left-sided HF typically has no respiratory symptoms."
        ]
    },
    {
        "name": "Left HF Causes",
        "fact": "Left HF causes include mitral/aortic valve disease, MI, chronic hypertension, cardiomyopathy.",
        "priority": "Connect structural and ischemic causes to LV failure.",
        "true": [
            "Mitral valve disease can cause left-sided HF.",
            "Aortic valve disease can precipitate left-sided HF.",
            "Anterior MI and chronic hypertension are common contributors."
        ],
        "false": [
            "Tricuspid disease is listed as the most common isolated cause of left HF in this note.",
            "Left HF is unrelated to cardiomyopathy."
        ]
    },
    {
        "name": "Left HF Path",
        "fact": "LV failure backs blood into pulmonary veins; pressure rises and fluid leaks into alveoli causing pulmonary edema.",
        "priority": "Identify sequence leading to respiratory compromise.",
        "true": [
            "LV failure causes pulmonary venous backup.",
            "Increased pulmonary venous pressure can push fluid into alveoli.",
            "Pulmonary edema can result from this process."
        ],
        "false": [
            "LV failure first causes isolated portal venous congestion in the note.",
            "Left HF pathophysiology in the note excludes alveolar fluid leakage."
        ]
    },
    {
        "name": "DOE",
        "fact": "Dyspnea on exertion is the first symptom listed for left HF.",
        "priority": "Escalate evaluation when exertional dyspnea appears in risk patients.",
        "true": [
            "Dyspnea on exertion is an early left HF symptom.",
            "Progressive exertional intolerance supports worsening congestion.",
            "DOE should prompt reassessment of fluid status and respiratory findings."
        ],
        "false": [
            "DOE is unrelated to left HF in this note.",
            "DOE appears only in right-sided HF section in this note."
        ]
    },
    {
        "name": "Orthopnea and PND",
        "fact": "Orthopnea and PND are classic left-sided HF symptoms.",
        "priority": "Use nocturnal and positional dyspnea to triage severity.",
        "true": [
            "Orthopnea means inability to lie flat without dyspnea.",
            "PND involves waking at night gasping for air.",
            "Both findings support pulmonary congestion from left HF."
        ],
        "false": [
            "Orthopnea is identified as a right-sided-only symptom in this note.",
            "PND indicates isolated GI congestion in this note."
        ]
    },
    {
        "name": "Pulmonary edema",
        "fact": "Pink frothy sputum is a severe pulmonary edema sign in left HF.",
        "priority": "Treat as high-acuity respiratory compromise.",
        "true": [
            "Pink frothy sputum indicates severe pulmonary edema.",
            "Pulmonary edema is strongly linked to left-sided failure in the note.",
            "Respiratory compromise may escalate rapidly when this appears."
        ],
        "false": [
            "Pink frothy sputum is listed as a benign right-sided finding.",
            "Pulmonary edema is excluded from left HF in this note."
        ]
    },
    {
        "name": "S3",
        "fact": "S3 gallop is described as a hallmark of heart failure (especially in left HF section).",
        "priority": "Interpret S3 with full volume-overload context.",
        "true": [
            "S3 gallop is a hallmark heart failure clue in this note.",
            "S3 may be present with left-sided congestion.",
            "S3 should be integrated with dyspnea, crackles, and edema findings."
        ],
        "false": [
            "S3 excludes heart failure in this note.",
            "S3 is only a normal physiologic finding in this note."
        ]
    },
    {
        "name": "Right HF Core",
        "fact": "Right-sided HF primarily causes systemic (peripheral) congestion.",
        "priority": "Distinguish body-fluid retention pattern from pulmonary pattern.",
        "true": [
            "Right-sided HF causes systemic venous congestion.",
            "Peripheral edema and JVD are key right-sided clues.",
            "Weight gain from fluid retention supports right-sided congestion."
        ],
        "false": [
            "Right-sided HF is described as isolated alveolar edema only.",
            "Right-sided HF has no venous pressure effects in this note."
        ]
    },
    {
        "name": "Right HF Causes",
        "fact": "Most common right HF cause is left-sided HF; others include tricuspid disease, pulmonary HTN, RV MI, chronic lung disease.",
        "priority": "Search upstream causes when right-sided findings appear.",
        "true": [
            "Left-sided HF is the most common cause of right-sided HF in this note.",
            "Pulmonary hypertension can drive right-sided failure.",
            "RV MI and tricuspid disease are listed right-sided causes."
        ],
        "false": [
            "Aortic stenosis is listed as the dominant right-sided cause in this note.",
            "Right-sided HF in this note is unrelated to chronic lung disease."
        ]
    },
    {
        "name": "Right HF Path",
        "fact": "RV failure causes venous backup and systemic fluid accumulation.",
        "priority": "Connect venous pressure rise to peripheral signs.",
        "true": [
            "RV failure causes blood to back up in venous circulation.",
            "Systemic venous pressure rise promotes body fluid accumulation.",
            "Peripheral congestion results from this mechanism."
        ],
        "false": [
            "RV failure in this note lowers venous pressure and prevents edema.",
            "RV failure in this note directly causes only alveolar edema."
        ]
    },
    {
        "name": "JVD",
        "fact": "JVD reflects elevated venous pressure and is a major right HF sign.",
        "priority": "Use JVD as high-yield bedside congestion marker.",
        "true": [
            "JVD suggests elevated systemic venous pressure.",
            "JVD is emphasized in right-sided HF symptom profile.",
            "JVD with edema supports peripheral congestion."
        ],
        "false": [
            "JVD is listed as a hallmark of isolated left alveolar pathology in this note.",
            "JVD indicates low venous pressure in this note."
        ]
    },
    {
        "name": "Peripheral edema",
        "fact": "Right HF commonly causes bilateral peripheral pitting edema.",
        "priority": "Trend bilateral edema and rapid fluid changes.",
        "true": [
            "Bilateral pitting edema supports right-sided congestion.",
            "Dependent leg/ankle swelling is expected in systemic fluid overload.",
            "Peripheral edema should be interpreted with weight trends and JVD."
        ],
        "false": [
            "Peripheral edema is absent in right HF according to this note.",
            "Unilateral trauma edema is listed as classic HF edema in this note."
        ]
    },
    {
        "name": "Weight rule physiology",
        "fact": "Rapid gain indicates fluid retention; 1 kg equals about 1 liter.",
        "priority": "Use objective weight data for early decompensation detection.",
        "true": [
            "Rapid weight gain indicates fluid retention.",
            "The note equates 1 kg to roughly 1 liter of retained fluid.",
            "Daily weights are a core monitoring strategy."
        ],
        "false": [
            "Weight changes are considered unreliable and not used in HF monitoring in this note.",
            "The note states 1 kg equals 100 mL of fluid."
        ]
    },
    {
        "name": "Ascites/hepatomegaly",
        "fact": "Severe right HF can cause ascites and hepatomegaly with RUQ discomfort; GI congestion can cause nausea/anorexia.",
        "priority": "Recognize abdominal signs as venous-congestion progression.",
        "true": [
            "Ascites can occur in severe right-sided HF.",
            "Hepatomegaly with RUQ discomfort is linked to hepatic congestion.",
            "GI congestion may cause nausea and anorexia."
        ],
        "false": [
            "Ascites is listed as a defining left-sided pulmonary finding.",
            "Hepatomegaly in this note is unrelated to venous congestion."
        ]
    },
    {
        "name": "Cor pulmonale",
        "fact": "Chronic lung disease raises pulmonary vascular resistance and can lead to RV failure/right HF.",
        "priority": "Identify cardiopulmonary linkage in chronic lung patients.",
        "true": [
            "Cor pulmonale links chronic lung disease to right-sided HF.",
            "Increased pulmonary vascular resistance increases RV workload.",
            "JVD and peripheral edema can appear in COPD-related right HF."
        ],
        "false": [
            "Cor pulmonale in this note is a left-ventricular primary valvular disorder.",
            "Chronic lung disease reduces RV workload in this note."
        ]
    },
    {
        "name": "Comparison matrix",
        "fact": "Left HF = lungs; right HF = body; BNP can be elevated in both; valve associations differ.",
        "priority": "Use pattern recognition for side differentiation.",
        "true": [
            "Left HF primarily accumulates fluid in lungs.",
            "Right HF primarily accumulates fluid in systemic tissues.",
            "BNP can be elevated in both left and right HF."
        ],
        "false": [
            "BNP elevation is impossible in right HF according to this note.",
            "Both sides are associated with the same valve pattern in this note."
        ]
    },
    {
        "name": "General therapy",
        "fact": "General treatment includes diuretics, ACEI/ARB, beta-blockers, sodium restriction, daily weight monitoring, and fluid restriction in severe HF.",
        "priority": "Prioritize evidence-aligned daily management bundle.",
        "true": [
            "Diuretics are used to reduce fluid overload.",
            "ACE inhibitors or ARBs help reduce afterload and improve survival.",
            "Beta-blockers reduce workload in chronic HF care."
        ],
        "false": [
            "Sodium loading is recommended in this note.",
            "Daily weights are discouraged in this note."
        ]
    },
    {
        "name": "Weight reporting thresholds",
        "fact": "Report >2 lb in 24 h or >5 lb in a week.",
        "priority": "Escalate early before severe decompensation.",
        "true": [
            "Patients should report weight gain over 2 lb in 24 hours.",
            "Patients should report weight gain over 5 lb in one week.",
            "Using same time and same scale is emphasized."
        ],
        "false": [
            "Any weight change under 10 lb/day is ignored in this note.",
            "Daily weighing time variability is preferred in this note."
        ]
    },
    {
        "name": "Left-specific therapy",
        "fact": "Left HF specifics include high Fowler positioning, O2/BiPAP for refractory pulmonary edema, digoxin for AF+HF rate control, spironolactone, LVAD/transplant for refractory HFrEF.",
        "priority": "Match intervention to pulmonary decompensation severity.",
        "true": [
            "High Fowler positioning helps reduce preload in left HF.",
            "BiPAP is used for refractory pulmonary edema.",
            "LVAD or transplant is considered in refractory HFrEF."
        ],
        "false": [
            "Immediate fluid bolus is first-line for pulmonary edema in this note.",
            "BiPAP is contraindicated in refractory pulmonary edema per this note."
        ]
    },
    {
        "name": "Digoxin-furosemide risk",
        "fact": "Furosemide can lower potassium, increasing digoxin toxicity risk.",
        "priority": "Prevent medication-related deterioration.",
        "true": [
            "Loop diuretic-related hypokalemia increases digoxin toxicity risk.",
            "Potassium monitoring is important when furosemide and digoxin are combined.",
            "Medication safety requires rhythm and symptom surveillance."
        ],
        "false": [
            "Furosemide reliably raises potassium and protects from digoxin toxicity.",
            "No electrolyte monitoring is needed when combining these drugs per this note."
        ]
    },
    {
        "name": "Digoxin toxicity signs",
        "fact": "Early digoxin toxicity signs listed are nausea/vomiting and visual disturbances (halos).",
        "priority": "Hold and escalate promptly when early toxicity appears.",
        "true": [
            "Nausea and vomiting are early digoxin toxicity signs in this note.",
            "Visual halos are a toxicity warning sign in this note.",
            "These findings warrant prompt medication review and provider notification."
        ],
        "false": [
            "Visual halos are listed as benign and expected in this note.",
            "Digoxin toxicity is described as asymptomatic in this note."
        ]
    },
    {
        "name": "Digoxin hold thresholds",
        "fact": "Hold digoxin for HR <60 adult, <70 child, <90 infant.",
        "priority": "Apply age-specific hold parameters accurately.",
        "true": [
            "Hold digoxin when adult HR is below 60.",
            "Hold digoxin when child HR is below 70.",
            "Hold digoxin when infant HR is below 90."
        ],
        "false": [
            "The same 60 bpm threshold applies to all ages in this note.",
            "Digoxin is never held for bradycardia in this note."
        ]
    }
]


mcq_templates = [
    "A patient with cardiovascular decompensation is being reassessed. Which finding most strongly supports {name}?",
    "During clinical handoff, which interpretation is most accurate for {name}?",
    "The nurse is prioritizing care. Which statement best reflects {name}?",
    "A complex symptom cluster is reviewed. Which conclusion best matches {name}?",
    "Which clinical judgment is most consistent with {name}?"
]

sata_templates = [
    "A nurse is evaluating a patient for {name}. Which findings or actions are appropriate? (Select all that apply)",
    "For a patient with suspected {name}, which statements are correct? (Select all that apply)",
    "The charge nurse audits care planning for {name}. Which items should be included? (Select all that apply)",
    "During patient teaching about {name}, which points are accurate? (Select all that apply)",
    "Which assessment findings support {name}? (Select all that apply)"
]


def option_objects(labels):
    return [{"id": chr(97 + i), "text": t} for i, t in enumerate(labels)]


def esc(s: str) -> str:
    return s.replace("'", "''")


questions = []

# 50 very hard MCQ
for i in range(50):
    c = concepts[i % len(concepts)]
    stem = mcq_templates[i % len(mcq_templates)].format(name=c["name"])
    correct = c["fact"] if i % 2 == 0 else c["priority"]

    distractor_pool = c["false"] + [
        f"This finding is more consistent with {concepts[(i+3) % len(concepts)]['name']}.",
        f"This finding excludes heart failure when EF is preserved.",
        "No further assessment is needed when symptoms fluctuate.",
        "Fluid trends are not useful for cardiovascular reassessment."
    ]
    random.shuffle(distractor_pool)
    distractors = distractor_pool[:3]

    choices = [correct] + distractors
    random.shuffle(choices)
    ans_idx = choices.index(correct)

    rationale = f"Correct because {c['fact']} {c['priority']}"

    questions.append({
        "stem": stem,
        "options": option_objects(choices),
        "correct": [chr(97 + ans_idx)],
        "rationale": rationale,
        "is_multi": False
    })

# 50 SATA
for i in range(50):
    c = concepts[i % len(concepts)]
    stem = sata_templates[i % len(sata_templates)].format(name=c["name"])

    true_pool = c["true"][:]
    false_pool = c["false"][:]

    # 3 correct + 2 incorrect options
    random.shuffle(true_pool)
    random.shuffle(false_pool)
    selected_true = true_pool[:3]
    selected_false = false_pool[:2]

    all_opts = selected_true + selected_false
    random.shuffle(all_opts)

    correct_ids = [chr(97 + idx) for idx, txt in enumerate(all_opts) if txt in selected_true]

    rationale = f"Correct selections align with note-based facts: {c['fact']}"

    questions.append({
        "stem": stem,
        "options": option_objects(all_opts),
        "correct": correct_ids,
        "rationale": rationale,
        "is_multi": True
    })

assert len(questions) == 100

sql_lines = []
sql_lines.append("BEGIN;")
sql_lines.append("DO $$")
sql_lines.append("DECLARE")
sql_lines.append("  v_subject_id UUID;")
sql_lines.append("  v_topic_id UUID;")
sql_lines.append("  v_test_id BIGINT;")
sql_lines.append("BEGIN")
sql_lines.append("  SELECT id INTO v_subject_id FROM test_subjects WHERE name ILIKE '%cardio%' ORDER BY id LIMIT 1;")
sql_lines.append("  IF v_subject_id IS NULL THEN")
sql_lines.append("    INSERT INTO test_subjects (name, description) VALUES ('Cardiovascular System', 'Cardiovascular notes') RETURNING id INTO v_subject_id;")
sql_lines.append("  END IF;")
sql_lines.append("  SELECT id INTO v_topic_id FROM test_topics WHERE subject_id = v_subject_id AND name = 'Right & Left Heart Failure' LIMIT 1;")
sql_lines.append("  IF v_topic_id IS NULL THEN")
sql_lines.append("    INSERT INTO test_topics (subject_id, name, description, status) VALUES (v_subject_id, 'Right & Left Heart Failure', 'Right-sided and left-sided heart failure', 'published') RETURNING id INTO v_topic_id;")
sql_lines.append("  END IF;")
sql_lines.append("  SELECT test_id INTO v_test_id FROM test_configs WHERE subject_id = v_subject_id ORDER BY test_id LIMIT 1;")
sql_lines.append("  IF v_test_id IS NULL THEN")
sql_lines.append("    v_test_id := 1;")
sql_lines.append("  END IF;")
sql_lines.append(f"  DELETE FROM test_questions WHERE topic_id = v_topic_id AND category = '{CATEGORY}';")

for i, q in enumerate(questions, start=1):
    stem = esc(q["stem"])
    options = esc(json.dumps(q["options"], ensure_ascii=False))
    correct = esc(json.dumps(q["correct"], ensure_ascii=False))
    rationale = esc(q["rationale"])
    is_multi = 'true' if q["is_multi"] else 'false'

    sql_lines.append("  INSERT INTO test_questions (test_id, topic_id, question, question_stem, options, correct_answer, rationale, category, is_multiple_choice, display_order, points, is_active)")
    sql_lines.append(
        f"  VALUES (v_test_id, v_topic_id, '{stem}', '{stem}', '{options}'::jsonb, '{correct}'::jsonb, '{rationale}', '{CATEGORY}', {is_multi}, {i}, 1, true);"
    )

sql_lines.append("END $$;")
sql_lines.append("COMMIT;")

OUT_PATH.write_text("\n".join(sql_lines), encoding="utf-8")
print(f"Wrote {OUT_PATH} with {len(questions)} questions")
