/**
 * med-abbr-tooltip.js  —  Auto-wrap medical abbreviations with tooltip support.
 *
 * How it works:
 *  1. On DOMContentLoaded, walks every text node inside <body>.
 *  2. Replaces known abbreviations with <abbr title="..."> elements.
 *  3. A floating tooltip follows the cursor over any <abbr title>.
 *
 * No changes needed to individual note files — all 300+ notes load this script.
 */
(function () {
  'use strict';

  /* ─── 1. ABBREVIATION DICTIONARY ───────────────────────────────────────── */
  var ABBR = {
    // ── General / Vitals ──────────────────────────────────────────────────
    'ABG':   'Arterial Blood Gas',
    'ABGs':  'Arterial Blood Gases',
    'BP':    'Blood Pressure',
    'HR':    'Heart Rate',
    'RR':    'Respiratory Rate',
    'SpO2':  'Peripheral Oxygen Saturation',
    'SaO2':  'Arterial Oxygen Saturation',
    'PaO2':  'Partial Pressure of Arterial Oxygen',
    'PaCO2': 'Partial Pressure of Arterial Carbon Dioxide',
    'pH':    'Potential of Hydrogen (acid-base measure)',
    'HCO3':  'Bicarbonate',
    'MAP':   'Mean Arterial Pressure',
    'CO':    'Cardiac Output',
    'SV':    'Stroke Volume',
    'CVP':   'Central Venous Pressure',
    'ICP':   'Intracranial Pressure',
    'CPP':   'Cerebral Perfusion Pressure',
    'GCS':   'Glasgow Coma Scale',
    'LOC':   'Level of Consciousness',
    'I&O':   'Intake and Output',
    'BMI':   'Body Mass Index',
    'BSA':   'Body Surface Area',
    'Hgb':   'Hemoglobin',
    'Hct':   'Hematocrit',
    'WBC':   'White Blood Cell (count)',
    'RBC':   'Red Blood Cell (count)',
    'PLT':   'Platelet (count)',
    'BUN':   'Blood Urea Nitrogen',
    'Cr':    'Creatinine',
    'eGFR':  'Estimated Glomerular Filtration Rate',
    'GFR':   'Glomerular Filtration Rate',
    'Na':    'Sodium',
    'K':     'Potassium',
    'Ca':    'Calcium',
    'Mg':    'Magnesium',
    'Phos':  'Phosphorus',
    'Cl':    'Chloride',
    'LDL':   'Low-Density Lipoprotein',
    'HDL':   'High-Density Lipoprotein',
    'VLDL':  'Very Low-Density Lipoprotein',
    'TG':    'Triglycerides',
    'INR':   'International Normalized Ratio',
    'PT':    'Prothrombin Time',
    'PTT':   'Partial Thromboplastin Time',
    'aPTT':  'Activated Partial Thromboplastin Time',
    'ESR':   'Erythrocyte Sedimentation Rate',
    'CRP':   'C-Reactive Protein',
    'LFTs':  'Liver Function Tests',
    'LFT':   'Liver Function Test',
    'ALT':   'Alanine Aminotransferase',
    'AST':   'Aspartate Aminotransferase',
    'ALP':   'Alkaline Phosphatase',
    'GGT':   'Gamma-Glutamyl Transferase',
    'TSH':   'Thyroid-Stimulating Hormone',
    'T3':    'Triiodothyronine',
    'T4':    'Thyroxine',
    'HbA1c': 'Glycated Hemoglobin (3-month avg blood sugar)',
    'FBS':   'Fasting Blood Sugar',
    'RBS':   'Random Blood Sugar',
    'BGL':   'Blood Glucose Level',
    'BG':    'Blood Glucose',
    'CBC':   'Complete Blood Count',
    'CMP':   'Comprehensive Metabolic Panel',
    'BMP':   'Basic Metabolic Panel',
    'CXR':   'Chest X-Ray',
    'CT':    'Computed Tomography',
    'MRI':   'Magnetic Resonance Imaging',
    'EKG':   'Electrocardiogram',
    'ECG':   'Electrocardiogram',
    'EEG':   'Electroencephalogram',
    'EMG':   'Electromyography',
    'Echo':  'Echocardiogram',
    'ECHO':  'Echocardiogram',
    'US':    'Ultrasound',
    'IV':    'Intravenous',
    'IM':    'Intramuscular',
    'SQ':    'Subcutaneous',
    'SL':    'Sublingual',
    'PO':    'Per Os (by mouth)',
    'NGT':   'Nasogastric Tube',
    'NG':    'Nasogastric',
    'NJ':    'Nasojejunal',
    'TPN':   'Total Parenteral Nutrition',
    'PPN':   'Peripheral Parenteral Nutrition',
    'NPO':   'Nil Per Os (nothing by mouth)',
    'PRN':   'Pro Re Nata (as needed)',
    'QD':    'Every Day',
    'BID':   'Twice Daily',
    'TID':   'Three Times Daily',
    'QID':   'Four Times Daily',
    'Q4H':   'Every 4 Hours',
    'Q6H':   'Every 6 Hours',
    'Q8H':   'Every 8 Hours',
    'Q12H':  'Every 12 Hours',
    'STAT':  'Immediately',
    'AC':    'Before Meals',
    'PC':    'After Meals',
    'HS':    'Hour of Sleep (at bedtime)',
    'OTC':   'Over the Counter',
    'Rx':    'Prescription',
    'Dx':    'Diagnosis',
    'Hx':    'History',
    'Sx':    'Symptoms',
    'Tx':    'Treatment',
    'Fx':    'Fracture',
    'PMH':   'Past Medical History',
    'FHx':   'Family History',
    'SHx':   'Social History',
    'CC':    'Chief Complaint',
    'HPI':   'History of Present Illness',
    'ROS':   'Review of Systems',
    'VS':    'Vital Signs',
    'SOB':   'Shortness of Breath',
    'DOE':   'Dyspnea on Exertion',
    'CP':    'Chest Pain',
    'HA':    'Headache',
    'HEENT': 'Head, Eyes, Ears, Nose, Throat',
    'WNL':   'Within Normal Limits',
    'A&O':   'Alert and Oriented',
    'PERLA': 'Pupils Equal and Reactive to Light and Accommodation',
    'PERRLA':'Pupils Equal, Round, and Reactive to Light and Accommodation',
    'JVD':   'Jugular Venous Distension',
    'CTA':   'Clear to Auscultation',
    'CTAB':  'Clear to Auscultation Bilaterally',
    'DTR':   'Deep Tendon Reflex',
    'DTRs':  'Deep Tendon Reflexes',
    'PMI':   'Point of Maximal Impulse',
    // ── Cardiovascular ────────────────────────────────────────────────────
    'CAD':   'Coronary Artery Disease',
    'CHD':   'Coronary Heart Disease',
    'CHF':   'Congestive Heart Failure',
    'HF':    'Heart Failure',
    'LVH':   'Left Ventricular Hypertrophy',
    'RVH':   'Right Ventricular Hypertrophy',
    'EF':    'Ejection Fraction',
    'LVEF':  'Left Ventricular Ejection Fraction',
    'MI':    'Myocardial Infarction',
    'AMI':   'Acute Myocardial Infarction',
    'STEMI': 'ST-Elevation Myocardial Infarction',
    'NSTEMI':'Non-ST-Elevation Myocardial Infarction',
    'ACS':   'Acute Coronary Syndrome',
    'PCI':   'Percutaneous Coronary Intervention',
    'PTCA':  'Percutaneous Transluminal Coronary Angioplasty',
    'CABG':  'Coronary Artery Bypass Graft',
    'PAD':   'Peripheral Artery Disease',
    'PVD':   'Peripheral Vascular Disease',
    'DVT':   'Deep Vein Thrombosis',
    'VTE':   'Venous Thromboembolism',
    'HTN':   'Hypertension',
    'AFib':  'Atrial Fibrillation',
    'AF':    'Atrial Fibrillation',
    'SVT':   'Supraventricular Tachycardia',
    'VT':    'Ventricular Tachycardia',
    'VF':    'Ventricular Fibrillation',
    'PVC':   'Premature Ventricular Contraction',
    'PAC':   'Premature Atrial Contraction',
    'AV':    'Atrioventricular',
    'LBBB':  'Left Bundle Branch Block',
    'RBBB':  'Right Bundle Branch Block',
    'ICD':   'Implantable Cardioverter-Defibrillator',
    'PPM':   'Permanent Pacemaker',
    'CRT':   'Cardiac Resynchronization Therapy',
    'BNP':   'B-type Natriuretic Peptide',
    'CK-MB': 'Creatine Kinase-Myocardial Band',
    // ── Respiratory ───────────────────────────────────────────────────────
    'COPD':  'Chronic Obstructive Pulmonary Disease',
    'ARDS':  'Acute Respiratory Distress Syndrome',
    'TB':    'Tuberculosis',
    'URI':   'Upper Respiratory Infection',
    'URTI':  'Upper Respiratory Tract Infection',
    'PNA':   'Pneumonia',
    'CAP':   'Community-Acquired Pneumonia',
    'HAP':   'Hospital-Acquired Pneumonia',
    'VAP':   'Ventilator-Associated Pneumonia',
    'OSA':   'Obstructive Sleep Apnea',
    'FEV1':  'Forced Expiratory Volume in 1 Second',
    'FVC':   'Forced Vital Capacity',
    'PEFR':  'Peak Expiratory Flow Rate',
    'PFTs':  'Pulmonary Function Tests',
    'PFT':   'Pulmonary Function Test',
    'FiO2':  'Fraction of Inspired Oxygen',
    'PEEP':  'Positive End-Expiratory Pressure',
    'CPAP':  'Continuous Positive Airway Pressure',
    'BiPAP': 'Bilevel Positive Airway Pressure',
    'ETT':   'Endotracheal Tube',
    'O2':    'Oxygen',
    'CO2':   'Carbon Dioxide',
    // ── GI / Hepatic ──────────────────────────────────────────────────────
    'GERD':  'Gastroesophageal Reflux Disease',
    'LES':   'Lower Esophageal Sphincter',
    'UES':   'Upper Esophageal Sphincter',
    'PUD':   'Peptic Ulcer Disease',
    'IBD':   'Inflammatory Bowel Disease',
    'IBS':   'Irritable Bowel Syndrome',
    'UC':    'Ulcerative Colitis',
    'GI':    'Gastrointestinal',
    'UGIB':  'Upper GI Bleed',
    'LGIB':  'Lower GI Bleed',
    'HBV':   'Hepatitis B Virus',
    'HCV':   'Hepatitis C Virus',
    'HAV':   'Hepatitis A Virus',
    'NASH':  'Non-Alcoholic Steatohepatitis',
    'NAFLD': 'Non-Alcoholic Fatty Liver Disease',
    'SBO':   'Small Bowel Obstruction',
    'LBO':   'Large Bowel Obstruction',
    'PEG':   'Percutaneous Endoscopic Gastrostomy',
    'EGD':   'Esophagogastroduodenoscopy',
    'ERCP':  'Endoscopic Retrograde Cholangiopancreatography',
    'CDI':   'Clostridioides difficile Infection',
    // ── Renal ─────────────────────────────────────────────────────────────
    'AKI':   'Acute Kidney Injury',
    'CKD':   'Chronic Kidney Disease',
    'ESRD':  'End-Stage Renal Disease',
    'ARF':   'Acute Renal Failure',
    'UTI':   'Urinary Tract Infection',
    'UO':    'Urine Output',
    'HD':    'Hemodialysis',
    'CVVH':  'Continuous Venovenous Hemofiltration',
    'CVVHD': 'Continuous Venovenous Hemodialysis',
    'PKD':   'Polycystic Kidney Disease',
    'HUS':   'Hemolytic Uremic Syndrome',
    // ── Neurology ─────────────────────────────────────────────────────────
    'CVA':   'Cerebrovascular Accident (Stroke)',
    'TIA':   'Transient Ischemic Attack',
    'SAH':   'Subarachnoid Hemorrhage',
    'SDH':   'Subdural Hematoma',
    'EDH':   'Epidural Hematoma',
    'ICH':   'Intracranial Hemorrhage',
    'tPA':   'Tissue Plasminogen Activator',
    'MS':    'Multiple Sclerosis',
    'ALS':   'Amyotrophic Lateral Sclerosis',
    'GBS':   'Guillain-Barré Syndrome',
    'MG':    'Myasthenia Gravis',
    'LP':    'Lumbar Puncture',
    'CSF':   'Cerebrospinal Fluid',
    'CNS':   'Central Nervous System',
    'ANS':   'Autonomic Nervous System',
    'SNS':   'Sympathetic Nervous System',
    'SIADH': 'Syndrome of Inappropriate Antidiuretic Hormone',
    'DI':    'Diabetes Insipidus',
    // ── Endocrine ─────────────────────────────────────────────────────────
    'DM':    'Diabetes Mellitus',
    'T1DM':  'Type 1 Diabetes Mellitus',
    'T2DM':  'Type 2 Diabetes Mellitus',
    'DKA':   'Diabetic Ketoacidosis',
    'HHS':   'Hyperosmolar Hyperglycemic State',
    'HHNS':  'Hyperosmolar Hyperglycemic Nonketotic Syndrome',
    'OGTT':  'Oral Glucose Tolerance Test',
    'ACTH':  'Adrenocorticotropic Hormone',
    'ADH':   'Antidiuretic Hormone',
    'GH':    'Growth Hormone',
    'FSH':   'Follicle-Stimulating Hormone',
    'LH':    'Luteinizing Hormone',
    'PTH':   'Parathyroid Hormone',
    'hCG':   'Human Chorionic Gonadotropin',
    'HRT':   'Hormone Replacement Therapy',
    // ── Musculoskeletal ───────────────────────────────────────────────────
    'RA':    'Rheumatoid Arthritis',
    'OA':    'Osteoarthritis',
    'SLE':   'Systemic Lupus Erythematosus',
    'AS':    'Ankylosing Spondylitis',
    'PMR':   'Polymyalgia Rheumatica',
    'GCA':   'Giant Cell Arteritis',
    'AVN':   'Avascular Necrosis',
    'ACL':   'Anterior Cruciate Ligament',
    'PCL':   'Posterior Cruciate Ligament',
    'MCL':   'Medial Collateral Ligament',
    'LCL':   'Lateral Collateral Ligament',
    'ORIF':  'Open Reduction Internal Fixation',
    'THR':   'Total Hip Replacement',
    'TKR':   'Total Knee Replacement',
    'DEXA':  'Dual-Energy X-Ray Absorptiometry',
    'ROM':   'Range of Motion',
    // ── Mental Health ─────────────────────────────────────────────────────
    'MDD':   'Major Depressive Disorder',
    'GAD':   'Generalized Anxiety Disorder',
    'PTSD':  'Post-Traumatic Stress Disorder',
    'OCD':   'Obsessive-Compulsive Disorder',
    'ADHD':  'Attention Deficit Hyperactivity Disorder',
    'ASD':   'Autism Spectrum Disorder',
    'BPD':   'Borderline Personality Disorder',
    'SSRI':  'Selective Serotonin Reuptake Inhibitor',
    'SNRI':  'Serotonin-Norepinephrine Reuptake Inhibitor',
    'TCA':   'Tricyclic Antidepressant',
    'MAOI':  'Monoamine Oxidase Inhibitor',
    'ECT':   'Electroconvulsive Therapy',
    'CBT':   'Cognitive Behavioral Therapy',
    'DBT':   'Dialectical Behavior Therapy',
    'NMS':   'Neuroleptic Malignant Syndrome',
    'EPS':   'Extrapyramidal Symptoms',
    // ── Reproductive / OB ─────────────────────────────────────────────────
    'OB':    'Obstetrics',
    'GYN':   'Gynecology',
    'LMP':   'Last Menstrual Period',
    'EDD':   'Estimated Due Date',
    'EDC':   'Estimated Date of Confinement (due date)',
    'GA':    'Gestational Age',
    'FHR':   'Fetal Heart Rate',
    'GDM':   'Gestational Diabetes Mellitus',
    'PIH':   'Pregnancy-Induced Hypertension',
    'HELLP': 'Hemolysis, Elevated Liver Enzymes, Low Platelets',
    'VBAC':  'Vaginal Birth After Cesarean',
    'IUGR':  'Intrauterine Growth Restriction',
    'PROM':  'Premature Rupture of Membranes',
    'PPROM': 'Preterm Premature Rupture of Membranes',
    'PPH':   'Postpartum Hemorrhage',
    'PID':   'Pelvic Inflammatory Disease',
    'BV':    'Bacterial Vaginosis',
    'HPV':   'Human Papillomavirus',
    'STI':   'Sexually Transmitted Infection',
    'STD':   'Sexually Transmitted Disease',
    'HIV':   'Human Immunodeficiency Virus',
    'AIDS':  'Acquired Immunodeficiency Syndrome',
    'BPH':   'Benign Prostatic Hyperplasia',
    'PSA':   'Prostate-Specific Antigen',
    // ── Pediatrics ───────────────────────────────────────────────────────
    'NICU':  'Neonatal Intensive Care Unit',
    'PICU':  'Pediatric Intensive Care Unit',
    'SIDS':  'Sudden Infant Death Syndrome',
    'RSV':   'Respiratory Syncytial Virus',
    'KD':    'Kawasaki Disease',
    'CF':    'Cystic Fibrosis',
    'RDS':   'Respiratory Distress Syndrome (newborn)',
    'NEC':   'Necrotizing Enterocolitis',
    'VSD':   'Ventricular Septal Defect',
    'PDA':   'Patent Ductus Arteriosus',
    'TOF':   'Tetralogy of Fallot',
    'TGA':   'Transposition of Great Arteries',
    // ── Oncology ─────────────────────────────────────────────────────────
    'NHL':   'Non-Hodgkin\'s Lymphoma',
    'HL':    'Hodgkin\'s Lymphoma',
    'ALL':   'Acute Lymphoblastic Leukemia',
    'AML':   'Acute Myeloid Leukemia',
    'CLL':   'Chronic Lymphocytic Leukemia',
    'CML':   'Chronic Myeloid Leukemia',
    'MM':    'Multiple Myeloma',
    'XRT':   'Radiation Therapy',
    'BMT':   'Bone Marrow Transplant',
    'HSCT':  'Hematopoietic Stem Cell Transplant',
    // ── Infections ───────────────────────────────────────────────────────
    'MRSA':  'Methicillin-Resistant Staphylococcus aureus',
    'MSSA':  'Methicillin-Sensitive Staphylococcus aureus',
    'VRE':   'Vancomycin-Resistant Enterococcus',
    'ESBL':  'Extended-Spectrum Beta-Lactamase',
    'SIRS':  'Systemic Inflammatory Response Syndrome',
    'DIC':   'Disseminated Intravascular Coagulation',
    'CMV':   'Cytomegalovirus',
    'EBV':   'Epstein-Barr Virus',
    'HSV':   'Herpes Simplex Virus',
    'VZV':   'Varicella-Zoster Virus',
    'PPE':   'Personal Protective Equipment',
    'MDRO':  'Multi-Drug Resistant Organism',
    'HAI':   'Healthcare-Associated Infection',
    'CLABSI':'Central Line-Associated Bloodstream Infection',
    'CAUTI': 'Catheter-Associated Urinary Tract Infection',
    'SSI':   'Surgical Site Infection',
    // ── Medications ───────────────────────────────────────────────────────
    'ACEI':  'ACE Inhibitor',
    'ARB':   'Angiotensin II Receptor Blocker',
    'CCB':   'Calcium Channel Blocker',
    'ASA':   'Aspirin (Acetylsalicylic Acid)',
    'NSAIDs':'Nonsteroidal Anti-Inflammatory Drugs',
    'NSAID': 'Nonsteroidal Anti-Inflammatory Drug',
    'PPI':   'Proton Pump Inhibitor',
    'H2RA':  'H2 Receptor Antagonist',
    'NTG':   'Nitroglycerin',
    'TMP-SMX': 'Trimethoprim-Sulfamethoxazole (Bactrim)',
    'HCTZ':  'Hydrochlorothiazide',
    'KCl':   'Potassium Chloride',
    'NaCl':  'Sodium Chloride (Normal Saline)',
    'D5W':   'Dextrose 5% in Water',
    'LR':    'Lactated Ringer\'s Solution',
    'NS':    'Normal Saline (0.9% NaCl)',
    // ── Nursing / Clinical ────────────────────────────────────────────────
    'ICU':   'Intensive Care Unit',
    'MICU':  'Medical Intensive Care Unit',
    'SICU':  'Surgical Intensive Care Unit',
    'CCU':   'Cardiac Care Unit',
    'OR':    'Operating Room',
    'PACU':  'Post-Anesthesia Care Unit',
    'ER':    'Emergency Room',
    'ED':    'Emergency Department',
    'DNR':   'Do Not Resuscitate',
    'DNI':   'Do Not Intubate',
    'AND':   'Allow Natural Death',
    'CPR':   'Cardiopulmonary Resuscitation',
    'AED':   'Automated External Defibrillator',
    'BLS':   'Basic Life Support',
    'ACLS':  'Advanced Cardiovascular Life Support',
    'PALS':  'Pediatric Advanced Life Support',
    'SBAR':  'Situation, Background, Assessment, Recommendation',
    'HIPAA': 'Health Insurance Portability and Accountability Act',
    'CDC':   'Centers for Disease Control and Prevention',
    'WHO':   'World Health Organization',
    'NCLEX': 'National Council Licensure Examination',
    'RN':    'Registered Nurse',
    'LPN':   'Licensed Practical Nurse',
    'LVN':   'Licensed Vocational Nurse',
    'NP':    'Nurse Practitioner',
    'CRNA':  'Certified Registered Nurse Anesthetist',
    'BSN':   'Bachelor of Science in Nursing',
    'ADN':   'Associate Degree in Nursing',
    'MSN':   'Master of Science in Nursing',
    'CNA':   'Certified Nursing Assistant',
    'MAR':   'Medication Administration Record',
    'EHR':   'Electronic Health Record',
    'EMR':   'Electronic Medical Record',
    'PIV':   'Peripheral IV',
    'CVC':   'Central Venous Catheter',
    'PICC':  'Peripherally Inserted Central Catheter',
    'Foley': 'Foley Catheter (indwelling urinary catheter)',
    'SCD':   'Sequential Compression Device',
    'HOB':   'Head of Bed',
    'OOB':   'Out of Bed',
    'ADLs':  'Activities of Daily Living',
    'ADL':   'Activity of Daily Living',
    'PCA':   'Patient-Controlled Analgesia',
    'NRS':   'Numeric Rating Scale (pain 0–10)',
    // ── Dermatology / Burns ───────────────────────────────────────────────
    'TBSA':  'Total Body Surface Area',
    'SJS':   'Stevens-Johnson Syndrome',
    'TEN':   'Toxic Epidermal Necrolysis',
    // ── Eye / EENT ────────────────────────────────────────────────────────
    'IOP':   'Intraocular Pressure',
    'VA':    'Visual Acuity',
    'AMD':   'Age-Related Macular Degeneration',
    'DR':    'Diabetic Retinopathy',
  };

  /* ─── 2. BUILD REGEX ─────────────────────────────────────────────────────── */
  /* Sort keys longest-first so longer matches take priority.                  */
  var keys = Object.keys(ABBR).sort(function (a, b) { return b.length - a.length; });

  function escRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  /* Build one alternation — longest keys first to prevent partial matches.    */
  var alts = keys.map(escRe).join('|');
  var ABBR_RE = new RegExp('(?:' + alts + ')', 'g');

  /* ─── 3. DOM WALKER ──────────────────────────────────────────────────────── */
  var SKIP_TAGS = {
    SCRIPT:1, STYLE:1, NOSCRIPT:1, TEXTAREA:1,
    CODE:1, PRE:1, ABBR:1, A:1, INPUT:1, BUTTON:1,
    SELECT:1, OPTION:1, HEAD:1, TITLE:1, META:1
  };

  /* Word-boundary check: char before/after the match must not be alphanumeric. */
  function isWordBoundary(text, start, end) {
    var before = start === 0 ? '' : text[start - 1];
    var after  = end >= text.length ? '' : text[end];
    var wordChar = /[A-Za-z0-9_]/;
    if (before && wordChar.test(before)) return false;
    if (after  && wordChar.test(after))  return false;
    return true;
  }

  function wrapTextNode(node) {
    var text = node.nodeValue;
    if (!text) return;

    ABBR_RE.lastIndex = 0;
    var frag = document.createDocumentFragment();
    var last = 0;
    var matched = false;
    var m;

    while ((m = ABBR_RE.exec(text)) !== null) {
      var raw = m[0];
      var def = ABBR[raw];
      if (!def) continue;

      /* Enforce word-boundary manually (handles mixed-case keys like tPA). */
      if (!isWordBoundary(text, m.index, m.index + raw.length)) continue;

      matched = true;
      if (m.index > last) {
        frag.appendChild(document.createTextNode(text.slice(last, m.index)));
      }

      var el = document.createElement('abbr');
      el.title = def;
      el.textContent = raw;
      frag.appendChild(el);

      last = m.index + raw.length;
    }

    if (!matched) return; /* nothing changed */

    if (last < text.length) {
      frag.appendChild(document.createTextNode(text.slice(last)));
    }

    node.parentNode.replaceChild(frag, node);
  }

  function walkNode(node) {
    if (node.nodeType === 3 /* TEXT_NODE */) {
      wrapTextNode(node);
      return;
    }
    if (node.nodeType !== 1 /* ELEMENT_NODE */) return;
    if (SKIP_TAGS[node.tagName]) return;

    /* Snapshot childNodes before mutation */
    var children = Array.prototype.slice.call(node.childNodes);
    for (var i = 0; i < children.length; i++) {
      walkNode(children[i]);
    }
  }

  /* ─── 4. TOOLTIP UI ──────────────────────────────────────────────────────── */
  var tooltip = null;

  function getTooltip() {
    if (!tooltip) {
      tooltip = document.createElement('div');
      tooltip.className = 'abbr-tooltip';
      document.body.appendChild(tooltip);
    }
    return tooltip;
  }

  document.addEventListener('mouseover', function (e) {
    var el = e.target.closest ? e.target.closest('abbr[title]')
           : (e.target.tagName === 'ABBR' && e.target.title ? e.target : null);
    if (!el) return;
    var tip = getTooltip();
    tip.textContent = el.getAttribute('title');
    tip.style.display = 'block';
  });

  document.addEventListener('mousemove', function (e) {
    if (!tooltip || tooltip.style.display === 'none') return;
    var x = e.clientX + window.scrollX + 14;
    var y = e.clientY + window.scrollY + 14;
    /* Keep tooltip inside viewport horizontally */
    var tw = tooltip.offsetWidth || 220;
    if (x + tw > window.scrollX + window.innerWidth - 10) {
      x = e.clientX + window.scrollX - tw - 8;
    }
    tooltip.style.left = x + 'px';
    tooltip.style.top  = y + 'px';
  });

  document.addEventListener('mouseout', function (e) {
    var el = e.target.closest ? e.target.closest('abbr[title]')
           : (e.target.tagName === 'ABBR' && e.target.title ? e.target : null);
    if (!el || !tooltip) return;
    tooltip.style.display = 'none';
  });

  /* ─── 5. RUN ─────────────────────────────────────────────────────────────── */
  function run() {
    ABBR_RE.lastIndex = 0;
    if (document.body) walkNode(document.body);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run);
  } else {
    run();
  }

})();
