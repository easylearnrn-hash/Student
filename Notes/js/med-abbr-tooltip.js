/**
 * med-abbr-tooltip.js
 * Automatically wraps known medical abbreviations in <abbr title="..."> tags,
 * then shows a floating tooltip on hover.
 *
 * No changes to individual note files are needed — this script runs on every
 * page that includes it and handles everything automatically.
 */
(function () {

  /* ─────────────────────────────────────────────────────────────
   *  MEDICAL ABBREVIATION DICTIONARY
   *  Key   = abbreviation exactly as it appears in text (case-sensitive match)
   *  Value = full expanded term shown in tooltip
   * ───────────────────────────────────────────────────────────── */
  var ABBR = {

    /* ── Routes / Dosing ── */
    'IV':       'Intravenous',
    'IM':       'Intramuscular',
    'SQ':       'Subcutaneous',
    'SC':       'Subcutaneous',
    'PO':       'By Mouth (Per Os)',
    'SL':       'Sublingual',
    'PR':         'Per Rectum / PR Interval (EKG)',
    'TOP':      'Topical',
    'INH':      'Inhaled',
    'IO':       'Intraosseous',
    'IT':       'Intrathecal',
    'NPO':      'Nothing by Mouth (Nil Per Os)',
    'NBO':      'Nothing by Mouth',

    /* ── Dosing Frequency ── */
    'QD':       'Once Daily (Quaque Die)',
    'QID':      'Four Times Daily',
    'TID':      'Three Times Daily',
    'BID':      'Twice Daily',
    'QOD':      'Every Other Day',
    'Q4H':      'Every 4 Hours',
    'Q6H':      'Every 6 Hours',
    'Q8H':      'Every 8 Hours',
    'Q12H':     'Every 12 Hours',
    'Q24H':     'Every 24 Hours',
    'PRN':      'As Needed (Pro Re Nata)',
    'STAT':     'Immediately (Statim)',
    'AC':       'Before Meals (Ante Cibum)',
    'PC':       'After Meals (Post Cibum)',
    'HS':       'At Bedtime (Hora Somni)',
    'SS':       'One Half',
    'Rx':       'Prescription / Treatment',
    'Tx':       'Treatment',
    'Dx':       'Diagnosis',
    'Hx':       'History',
    'Sx':       'Symptoms',
    'Fx':       'Fracture',
    'Px':       'Prognosis / Procedure',

    /* ── Vital Signs / Monitoring ── */
    'BP':       'Blood Pressure',
    'HR':       'Heart Rate',
    'RR':       'Respiratory Rate',
    'Temp':     'Temperature',
    'SpO2':     'Peripheral Oxygen Saturation',
    'SaO2':     'Arterial Oxygen Saturation',
    'SvO2':     'Mixed Venous Oxygen Saturation',
    'O2':       'Oxygen',
    'CO2':      'Carbon Dioxide',
    'MAP':      'Mean Arterial Pressure',
    'CVP':      'Central Venous Pressure',
    'ICP':      'Intracranial Pressure',
    'CPP':      'Cerebral Perfusion Pressure',
    'GCS':      'Glasgow Coma Scale',
    'LOC':        'Level of Consciousness / Loss of Consciousness',
    'AVPU':     'Alert, Voice, Pain, Unresponsive (consciousness scale)',
    'Wt':       'Weight',
    'Ht':       'Height',
    'BMI':      'Body Mass Index',
    'BSA':      'Body Surface Area',
    'I&O':      'Intake and Output',
    'UO':       'Urine Output',
    'VS':       'Vital Signs',
    'TPR':      'Temperature, Pulse, Respirations',

    /* ── Cardiovascular ── */
    'MI':       'Myocardial Infarction (Heart Attack)',
    'AMI':      'Acute Myocardial Infarction',
    'STEMI':    'ST-Elevation Myocardial Infarction',
    'NSTEMI':   'Non-ST-Elevation Myocardial Infarction',
    'ACS':      'Acute Coronary Syndrome',
    'CAD':      'Coronary Artery Disease',
    'CHF':      'Congestive Heart Failure',
    'HF':       'Heart Failure',
    'HFrEF':    'Heart Failure with Reduced Ejection Fraction',
    'HFpEF':    'Heart Failure with Preserved Ejection Fraction',
    'EF':       'Ejection Fraction',
    'EKG':      'Electrocardiogram',
    'ECG':      'Electrocardiogram',
    'PCI':      'Percutaneous Coronary Intervention',
    'CABG':     'Coronary Artery Bypass Graft',
    'DVT':      'Deep Vein Thrombosis',
    'PE':       'Pulmonary Embolism',
    'SVT':      'Supraventricular Tachycardia',
    'VF':       'Ventricular Fibrillation',
    'VT':       'Ventricular Tachycardia',
    'AF':       'Atrial Fibrillation',
    'Afib':     'Atrial Fibrillation',
    'AFL':      'Atrial Flutter',
    'PAC':      'Premature Atrial Contraction',
    'PVC':      'Premature Ventricular Contraction',
    'HTN':      'Hypertension',
    'HBP':      'High Blood Pressure',
    'SBP':        'Systolic Blood Pressure / Spontaneous Bacterial Peritonitis',
    'DBP':      'Diastolic Blood Pressure',
    'HOCM':     'Hypertrophic Obstructive Cardiomyopathy',
    'DCM':      'Dilated Cardiomyopathy',
    'AS':         'Aortic Stenosis / Ankylosing Spondylitis',
    'AR':       'Aortic Regurgitation',
    'MS':         'Mitral Stenosis / Multiple Sclerosis',
    'MR':       'Mitral Regurgitation',
    'MVP':      'Mitral Valve Prolapse',
    'PDA':      'Patent Ductus Arteriosus',
    'ASD':        'Atrial Septal Defect / Autism Spectrum Disorder',
    'VSD':      'Ventricular Septal Defect',
    'TOF':      'Tetralogy of Fallot',
    'CPR':      'Cardiopulmonary Resuscitation',
    'AED':      'Automated External Defibrillator',
    'ACLS':     'Advanced Cardiac Life Support',
    'BLS':      'Basic Life Support',
    'IABP':     'Intra-Aortic Balloon Pump',
    'PAD':      'Peripheral Artery Disease',
    'AAA':      'Abdominal Aortic Aneurysm',

    /* ── Respiratory ── */
    'COPD':     'Chronic Obstructive Pulmonary Disease',
    'ARDS':     'Acute Respiratory Distress Syndrome',
    'ABG':      'Arterial Blood Gas',
    'VBG':      'Venous Blood Gas',
    'FiO2':     'Fraction of Inspired Oxygen',
    'PEEP':     'Positive End-Expiratory Pressure',
    'CPAP':     'Continuous Positive Airway Pressure',
    'BiPAP':    'Bilevel Positive Airway Pressure',
    'ETT':      'Endotracheal Tube',
    'ET':       'Endotracheal',
    'MV':       'Mechanical Ventilation',
    'TV':       'Tidal Volume',
    'FRC':      'Functional Residual Capacity',
    'TLC':      'Total Lung Capacity',
    'PFT':      'Pulmonary Function Test',
    'FEV1':     'Forced Expiratory Volume in 1 Second',
    'FVC':      'Forced Vital Capacity',
    'TB':       'Tuberculosis',
    'CXR':      'Chest X-Ray',
    'SOB':      'Shortness of Breath',
    'DOE':      'Dyspnea on Exertion',
    'OSA':      'Obstructive Sleep Apnea',
    'CF':       'Cystic Fibrosis',
    'PH':       'Pulmonary Hypertension',
    'V/Q':      'Ventilation/Perfusion',
    'NRB':      'Non-Rebreather Mask',
    'NC':       'Nasal Cannula',

    /* ── Gastrointestinal / Hepatic ── */
    'GERD':     'Gastroesophageal Reflux Disease',
    'LES':      'Lower Esophageal Sphincter',
    'UES':      'Upper Esophageal Sphincter',
    'PUD':      'Peptic Ulcer Disease',
    'IBD':      'Inflammatory Bowel Disease',
    'IBS':      'Irritable Bowel Syndrome',
    'UC':       'Ulcerative Colitis',
    'CD':       'Crohn\'s Disease',
    'GI':       'Gastrointestinal',
    'UGI':      'Upper Gastrointestinal',
    'LGI':      'Lower Gastrointestinal',
    'NG':       'Nasogastric',
    'NGT':      'Nasogastric Tube',
    'OGT':      'Orogastric Tube',
    'TPN':      'Total Parenteral Nutrition',
    'PEG':      'Percutaneous Endoscopic Gastrostomy',
    'G-tube':   'Gastrostomy Tube',
    'J-tube':   'Jejunostomy Tube',
    'EGD':      'Esophagogastroduodenoscopy',
    'ERCP':     'Endoscopic Retrograde Cholangiopancreatography',
    'LFT':      'Liver Function Test',
    'AST':      'Aspartate Aminotransferase',
    'ALT':      'Alanine Aminotransferase',
    'ALP':      'Alkaline Phosphatase',
    'GGT':      'Gamma-Glutamyl Transferase',
    'HBV':      'Hepatitis B Virus',
    'HCV':      'Hepatitis C Virus',
    'NAFLD':    'Non-Alcoholic Fatty Liver Disease',
    'NASH':     'Non-Alcoholic Steatohepatitis',
    'SBO':      'Small Bowel Obstruction',
    'LBO':      'Large Bowel Obstruction',
    'BM':       'Bowel Movement',
    'C&S':      'Culture and Sensitivity',
    'H&P':      'History and Physical',
    'H. pylori':'Helicobacter pylori',

    /* ── Renal / Urologic ── */
    'CKD':      'Chronic Kidney Disease',
    'AKI':      'Acute Kidney Injury',
    'ARF':      'Acute Renal Failure',
    'ESRD':     'End-Stage Renal Disease',
    'BUN':      'Blood Urea Nitrogen',
    'Cr':       'Creatinine',
    'SCr':      'Serum Creatinine',
    'GFR':      'Glomerular Filtration Rate',
    'eGFR':     'Estimated Glomerular Filtration Rate',
    'UA':       'Urinalysis',
    'UTI':      'Urinary Tract Infection',
    'CBI':      'Continuous Bladder Irrigation',
    'HD':       'Hemodialysis',
    'PD':         'Peritoneal Dialysis / Pharmacodynamics',
    'CRRT':     'Continuous Renal Replacement Therapy',
    'IVP':      'Intravenous Pyelogram',
    'US':       'Ultrasound',
    'KUB':      'Kidneys, Ureters, Bladder (X-ray)',
    'ATN':      'Acute Tubular Necrosis',
    'PKD':      'Polycystic Kidney Disease',
    'ADPKD':    'Autosomal Dominant Polycystic Kidney Disease',
    'BPH':      'Benign Prostatic Hyperplasia',
    'PSA':      'Prostate-Specific Antigen',

    /* ── Endocrine / Metabolic ── */
    'DM':       'Diabetes Mellitus',
    'T1DM':     'Type 1 Diabetes Mellitus',
    'T2DM':     'Type 2 Diabetes Mellitus',
    'DKA':      'Diabetic Ketoacidosis',
    'HHS':      'Hyperosmolar Hyperglycemic State',
    'HHNS':     'Hyperosmolar Hyperglycemic Nonketotic Syndrome',
    'HbA1c':    'Glycosylated Hemoglobin (3-month avg blood sugar)',
    'A1c':      'Glycosylated Hemoglobin',
    'FBG':      'Fasting Blood Glucose',
    'FSBS':     'Fingerstick Blood Sugar',
    'BG':       'Blood Glucose',
    'BS':       'Blood Sugar',
    'TSH':      'Thyroid-Stimulating Hormone',
    'T3':       'Triiodothyronine',
    'T4':       'Thyroxine',
    'PTH':      'Parathyroid Hormone',
    'ADH':      'Antidiuretic Hormone',
    'SIADH':    'Syndrome of Inappropriate Antidiuretic Hormone',
    'DI':       'Diabetes Insipidus',
    'Cushings': 'Cushing\'s Syndrome (excess cortisol)',
    'Addisons': 'Addison\'s Disease (adrenal insufficiency)',

    /* ── Neurology ── */
    'TIA':      'Transient Ischemic Attack',
    'CVA':      'Cerebrovascular Accident (Stroke)',
    'CNS':        'Central Nervous System / Clinical Nurse Specialist',
    'PNS':      'Peripheral Nervous System',
    'ALS':      'Amyotrophic Lateral Sclerosis',
    'GBS':      'Guillain-Barré Syndrome',
    'PERRL':    'Pupils Equal, Round, Reactive to Light',
    'PERRLA':   'Pupils Equal, Round, Reactive to Light and Accommodation',
    'AMS':      'Altered Mental Status',
    'TBI':      'Traumatic Brain Injury',
    'SAH':      'Subarachnoid Hemorrhage',
    'SDH':      'Subdural Hematoma',
    'EDH':      'Epidural Hematoma',
    'IVH':      'Intraventricular Hemorrhage',
    'LP':       'Lumbar Puncture',
    'CSF':      'Cerebrospinal Fluid',
    'EEG':      'Electroencephalogram',
    'MRI':      'Magnetic Resonance Imaging',
    'CT':       'Computed Tomography',
    'CTA':      'CT Angiography',
    'MRA':      'MR Angiography',
    'PET':      'Positron Emission Tomography',

    /* ── Psychiatric ── */
    'GAD':      'Generalized Anxiety Disorder',
    'PTSD':     'Post-Traumatic Stress Disorder',
    'OCD':      'Obsessive-Compulsive Disorder',
    'MDD':      'Major Depressive Disorder',
    'BD':       'Bipolar Disorder',
    'ADHD':     'Attention-Deficit/Hyperactivity Disorder',
    'EPS':      'Extrapyramidal Symptoms',
    'NMS':      'Neuroleptic Malignant Syndrome',
    'SI':       'Suicidal Ideation',
    'HI':       'Homicidal Ideation',

    /* ── Musculoskeletal ── */
    'ROM':      'Range of Motion',
    'WB':       'Weight Bearing',
    'WBAT':     'Weight Bearing as Tolerated',
    'NWB':      'Non-Weight Bearing',
    'PWB':      'Partial Weight Bearing',
    'OA':       'Osteoarthritis',
    'RA':         'Right Atrium / Rheumatoid Arthritis',
    'SLE':      'Systemic Lupus Erythematosus',
    'CTS':      'Carpal Tunnel Syndrome',
    'ACL':      'Anterior Cruciate Ligament',
    'PCL':      'Posterior Cruciate Ligament',
    'MCL':      'Medial Collateral Ligament',
    'LCL':      'Lateral Collateral Ligament',
    'TKR':      'Total Knee Replacement',
    'THR':      'Total Hip Replacement',
    'ORIF':     'Open Reduction Internal Fixation',
    'DJD':      'Degenerative Joint Disease',
    'CPM':      'Continuous Passive Motion',

    /* ── Obstetrics / Gynecology ── */
    'OB':       'Obstetrics',
    'GYN':      'Gynecology',
    'OB/GYN':   'Obstetrics and Gynecology',
    'PROM':     'Premature Rupture of Membranes',
    'PPROM':    'Preterm Premature Rupture of Membranes',
    'GDM':      'Gestational Diabetes Mellitus',
    'PIH':      'Pregnancy-Induced Hypertension',
    'HELLP':    'Hemolysis, Elevated Liver Enzymes, Low Platelets (syndrome)',
    'C/S':      'Cesarean Section',
    'C-section':'Cesarean Section',
    'VBAC':     'Vaginal Birth After Cesarean',
    'hCG':      'Human Chorionic Gonadotropin',
    'LMP':      'Last Menstrual Period',
    'EDD':      'Estimated Due Date',
    'EDC':      'Estimated Date of Confinement',
    'GA':       'Gestational Age',
    'FHR':      'Fetal Heart Rate',
    'FHT':      'Fetal Heart Tones',
    'FHM':      'Fetal Heart Monitor',
    'NST':      'Non-Stress Test',
    'BPP':      'Biophysical Profile',
    'AFI':      'Amniotic Fluid Index',
    'IUGR':     'Intrauterine Growth Restriction',
    'SGA':      'Small for Gestational Age',
    'LGA':      'Large for Gestational Age',
    'AGA':      'Appropriate for Gestational Age',
    'NSVD':     'Normal Spontaneous Vaginal Delivery',
    'SVD':      'Spontaneous Vaginal Delivery',
    'APGAR':    'Appearance, Pulse, Grimace, Activity, Respiration (newborn score)',
    'LOA':      'Left Occiput Anterior (fetal position)',
    'ROA':      'Right Occiput Anterior (fetal position)',
    'STI':      'Sexually Transmitted Infection',
    'STD':      'Sexually Transmitted Disease',
    'PID':      'Pelvic Inflammatory Disease',
    'PCOS':     'Polycystic Ovary Syndrome',

    /* ── Pediatrics / Neonatal ── */
    'NICU':     'Neonatal Intensive Care Unit',
    'PICU':     'Pediatric Intensive Care Unit',
    'SIDS':     'Sudden Infant Death Syndrome',
    'RSV':      'Respiratory Syncytial Virus',
    'PKU':      'Phenylketonuria',
    'OFC':      'Occipitofrontal Circumference (head circumference)',

    /* ── Hematology / Oncology ── */
    'DIC':      'Disseminated Intravascular Coagulation',
    'ITP':      'Immune Thrombocytopenic Purpura',
    'TTP':      'Thrombotic Thrombocytopenic Purpura',
    'HUS':      'Hemolytic Uremic Syndrome',
    'SCD':      'Sickle Cell Disease',
    'G6PD':     'Glucose-6-Phosphate Dehydrogenase (deficiency)',
    'ALL':      'Acute Lymphoblastic Leukemia',
    'AML':      'Acute Myeloid Leukemia',
    'CLL':      'Chronic Lymphocytic Leukemia',
    'CML':      'Chronic Myeloid Leukemia',
    'NHL':      'Non-Hodgkin Lymphoma',
    'HL':       'Hodgkin Lymphoma',
    'MM':       'Multiple Myeloma',
    'BMT':      'Bone Marrow Transplant',
    'HSCT':     'Hematopoietic Stem Cell Transplant',
    'GvHD':     'Graft-versus-Host Disease',
    'XRT':      'Radiation Therapy',
    'TNM':      'Tumor, Node, Metastasis (staging)',
    'CA':       'Cancer / Carcinoma',

    /* ── Immunology / Infectious Disease ── */
    'HIV':      'Human Immunodeficiency Virus',
    'AIDS':     'Acquired Immunodeficiency Syndrome',
    'CD4':      'CD4 T-Cell (helper T cell)',
    'CMV':      'Cytomegalovirus',
    'EBV':      'Epstein-Barr Virus',
    'HSV':      'Herpes Simplex Virus',
    'VZV':      'Varicella-Zoster Virus',
    'MRSA':     'Methicillin-Resistant Staphylococcus aureus',
    'VRE':      'Vancomycin-Resistant Enterococcus',
    'C. diff':  'Clostridioides difficile (intestinal infection)',
    'SARS':     'Severe Acute Respiratory Syndrome',
    'COVID-19': 'Coronavirus Disease 2019',
    'PPD':      'Purified Protein Derivative (TB test)',
    'IGRA':     'Interferon-Gamma Release Assay (TB test)',

    /* ── Lab Values ── */
    'CBC':      'Complete Blood Count',
    'BMP':      'Basic Metabolic Panel',
    'CMP':      'Comprehensive Metabolic Panel',
    'WBC':      'White Blood Cell Count',
    'RBC':      'Red Blood Cell Count',
    'Hgb':      'Hemoglobin',
    'Hct':      'Hematocrit',
    'PLT':      'Platelet Count',
    'MCV':      'Mean Corpuscular Volume',
    'MCH':      'Mean Corpuscular Hemoglobin',
    'MCHC':     'Mean Corpuscular Hemoglobin Concentration',
    'PT':         'Prothrombin Time / Physical Therapy',
    'PTT':      'Partial Thromboplastin Time',
    'aPTT':     'Activated Partial Thromboplastin Time',
    'INR':      'International Normalized Ratio',
    'BNP':      'B-Type Natriuretic Peptide',
    'proBNP':   'N-terminal Pro-BNP',
    'CRP':      'C-Reactive Protein',
    'ESR':      'Erythrocyte Sedimentation Rate',
    'LDH':      'Lactate Dehydrogenase',
    'CPK':      'Creatine Phosphokinase',
    'CK':       'Creatine Kinase',
    'CK-MB':    'Creatine Kinase-MB (cardiac marker)',
    'Trop':     'Troponin',
    'TropI':    'Troponin I (cardiac marker)',
    'TropT':    'Troponin T (cardiac marker)',
    'LDL':      'Low-Density Lipoprotein (bad cholesterol)',
    'HDL':      'High-Density Lipoprotein (good cholesterol)',
    'VLDL':     'Very Low-Density Lipoprotein',
    'TG':       'Triglycerides',
    'Na':       'Sodium',
    'K':        'Potassium',
    'Cl':       'Chloride',
    'HCO3':     'Bicarbonate',
    'Ca':       'Calcium',
    'Mg':       'Magnesium',
    'Phos':     'Phosphorus',
    'Glu':      'Glucose',
    'Alb':      'Albumin',
    'TP':       'Total Protein',
    'T. bili':  'Total Bilirubin',
    'D. bili':  'Direct Bilirubin',
    'pH':       'Potential of Hydrogen (acid-base measure)',
    'PaO2':     'Partial Pressure of Arterial Oxygen',
    'PaCO2':    'Partial Pressure of Arterial Carbon Dioxide',
    'HbO2':     'Oxyhemoglobin',
    'Lac':      'Lactate',

    /* ── Medications (Classes & Common) ── */
    'NSAIDs':   'Non-Steroidal Anti-Inflammatory Drugs',
    'NSAID':    'Non-Steroidal Anti-Inflammatory Drug',
    'PPI':      'Proton Pump Inhibitor',
    'PPIs':     'Proton Pump Inhibitors',
    'H2RA':     'H2 Receptor Antagonist',
    'ACE':      'Angiotensin-Converting Enzyme (inhibitor)',
    'ACEi':     'ACE Inhibitor',
    'ARB':      'Angiotensin II Receptor Blocker',
    'CCB':      'Calcium Channel Blocker',
    'BB':       'Beta Blocker',
    'OTC':      'Over-the-Counter',
    'MAOIs':    'Monoamine Oxidase Inhibitors',
    'MAOI':     'Monoamine Oxidase Inhibitor',
    'SSRIs':    'Selective Serotonin Reuptake Inhibitors',
    'SSRI':     'Selective Serotonin Reuptake Inhibitor',
    'SNRIs':    'Serotonin-Norepinephrine Reuptake Inhibitors',
    'SNRI':     'Serotonin-Norepinephrine Reuptake Inhibitor',
    'TCAs':     'Tricyclic Antidepressants',
    'TCA':      'Tricyclic Antidepressant',
    'LABA':     'Long-Acting Beta Agonist',
    'SABA':     'Short-Acting Beta Agonist',
    'LAMA':     'Long-Acting Muscarinic Antagonist',
    'ICS':      'Inhaled Corticosteroid',
    'DOAC':     'Direct Oral Anticoagulant',
    'LMWH':     'Low Molecular Weight Heparin',
    'UFH':      'Unfractionated Heparin',
    'tPA':      'Tissue Plasminogen Activator (clot buster)',
    'IVF':      'Intravenous Fluid',
    'LR':       'Lactated Ringer\'s Solution',
    'NS':       'Normal Saline',
    'D5W':      'Dextrose 5% in Water',
    'D5NS':     'Dextrose 5% in Normal Saline',
    'D5LR':     'Dextrose 5% in Lactated Ringer\'s',
    '½NS':      'Half-Normal Saline (0.45% NaCl)',

    /* ── Procedures / Lines / Tubes ── */
    'PICC':     'Peripherally Inserted Central Catheter',
    'CVC':      'Central Venous Catheter',
    'CVL':      'Central Venous Line',
    'A-line':   'Arterial Line',
    'PA':         'Pulmonary Artery / Physician Assistant',
    'Foley':    'Foley Catheter (urinary catheter)',
    'JP':       'Jackson-Pratt Drain',
    'TEE':      'Transesophageal Echocardiogram',
    'TTE':      'Transthoracic Echocardiogram',
    'ECHO':     'Echocardiogram',
    'cath':     'Catheterization',
    'TURP':     'Transurethral Resection of the Prostate',
    'TURBT':    'Transurethral Resection of Bladder Tumor',

    /* ── Clinical Settings ── */
    'ICU':      'Intensive Care Unit',
    'CCU':      'Cardiac Care Unit',
    'MICU':     'Medical Intensive Care Unit',
    'SICU':     'Surgical Intensive Care Unit',
    'TICU':     'Trauma Intensive Care Unit',
    'ER':       'Emergency Room',
    'ED':       'Emergency Department',
    'OR':       'Operating Room',
    'PACU':     'Post-Anesthesia Care Unit',
    'LTAC':     'Long-Term Acute Care',
    'SNF':      'Skilled Nursing Facility',
    'LTC':      'Long-Term Care',
    'DC':       'Discharge',
    'D/C':      'Discharge',
    'AMA':      'Against Medical Advice',
    'DNR':      'Do Not Resuscitate',
    'DNI':      'Do Not Intubate',
    'AND':      'Allow Natural Death',
    'POC':      'Point of Care',
    'POCT':     'Point-of-Care Testing',
    'Tele':     'Telemetry',
    'tele':     'Telemetry',

    /* ── Nursing-Specific ── */
    'ADL':      'Activities of Daily Living',
    'IADL':     'Instrumental Activities of Daily Living',
    'HOB':      'Head of Bed',
    'OOB':      'Out of Bed',
    'A&O':      'Alert and Oriented',
    'A&Ox4':    'Alert and Oriented × 4 (person, place, time, event)',
    'A&Ox3':    'Alert and Oriented × 3 (person, place, time)',
    'RICE':     'Rest, Ice, Compression, Elevation',
    'SBAR':     'Situation, Background, Assessment, Recommendation',
    'SOAP':     'Subjective, Objective, Assessment, Plan (charting format)',
    'MAR':      'Medication Administration Record',
    'eMAR':     'Electronic Medication Administration Record',
    'PIV':      'Peripheral IV',
    'PDN':      'Private Duty Nursing',
    'RN':       'Registered Nurse',
    'LPN':      'Licensed Practical Nurse',
    'LVN':      'Licensed Vocational Nurse',
    'NP':       'Nurse Practitioner',
    'APRN':     'Advanced Practice Registered Nurse',
    'CNA':      'Certified Nursing Assistant',
    'CRNA':     'Certified Registered Nurse Anesthetist',
    'MD':         'Medical Doctor / Maintenance Dose',
    'DO':       'Doctor of Osteopathic Medicine',
    'PCP':      'Primary Care Provider',
    'HCP':      'Healthcare Provider',
    'RT':       'Respiratory Therapist',
    'OT':         'Occupational Therapy / Oxytocin',
    'ST':         'Speech Therapy / ST Segment (EKG)',
    'SW':       'Social Worker',
    'CM':       'Case Manager',

    /* ── Assessment Scales ── */
    'VAS':      'Visual Analog Scale',
    'NRS':      'Numeric Rating Scale',
    'NIHSS':    'National Institutes of Health Stroke Scale',
    'MMSE':     'Mini-Mental State Examination',
    'MoCA':     'Montreal Cognitive Assessment',
    'PHQ-9':    'Patient Health Questionnaire-9 (depression screening)',
    'GAD-7':    'Generalized Anxiety Disorder-7 Scale',
    'AUDIT':    'Alcohol Use Disorders Identification Test',
    'CAGE':     'Cut, Annoyed, Guilty, Eye-opener (alcohol screening)',
    'Braden':   'Braden Scale (pressure injury risk)',
    'Norton':   'Norton Scale (pressure sore risk)',
    'Morse':    'Morse Fall Scale',
    'Apgar':    'Appearance, Pulse, Grimace, Activity, Respiration (newborn)',

    /* ── Fluid / Acid-Base ── */
    'RAAS':     'Renin-Angiotensin-Aldosterone System',
    'ANP':      'Atrial Natriuretic Peptide',
    'ECF':      'Extracellular Fluid',
    'ICF':      'Intracellular Fluid',
    'FVD':      'Fluid Volume Deficit',
    'FVE':      'Fluid Volume Excess',

    /* ── Pharmacology / Drug Actions ── */
    'MOA':      'Mechanism of Action',
    'SE':       'Side Effect',
    'ADR':      'Adverse Drug Reaction',
    'CI':         'Cardiac Index / Contraindication',
    'DDI':      'Drug-Drug Interaction',
    'PK':       'Pharmacokinetics',
    't½':       'Half-life',
    'Vd':       'Volume of Distribution',
    'LD':       'Loading Dose',
    'MEC':      'Minimum Effective Concentration',
    'MTC':      'Minimum Toxic Concentration',

    /* ── Cardiac Rhythms / EKG ── */
    'QRS':      'QRS Complex (ventricular depolarization on ECG)',
    'QT':       'QT Interval (ventricular depolarization + repolarization)',
    'SA':       'Sinoatrial (node)',
    'AV':       'Atrioventricular (node)',
    'NSR':      'Normal Sinus Rhythm',
    'PEA':      'Pulseless Electrical Activity',
    'WPW':      'Wolff-Parkinson-White Syndrome',
    'LBBB':     'Left Bundle Branch Block',
    'RBBB':     'Right Bundle Branch Block',

    /* ── Medications (Specific) ── */
    'NPH':      'Neutral Protamine Hagedorn (intermediate-acting insulin)',
    'PTU':      'Propylthiouracil (antithyroid drug)',
    'MMI':      'Methimazole (antithyroid drug)',
    'EPO':      'Erythropoietin',
    'IVIG':     'Intravenous Immunoglobulin',
    'DMARD':    'Disease-Modifying Antirheumatic Drug',
    'DMARDs':   'Disease-Modifying Antirheumatic Drugs',
    'MTX':      'Methotrexate',
    'AZA':      'Azathioprine',
    'CYC':      'Cyclophosphamide',
    'MMF':      'Mycophenolate Mofetil',
    'CsA':      'Cyclosporine A',
    'FK506':    'Tacrolimus',
    'TNF':      'Tumor Necrosis Factor',
    'IL':       'Interleukin',
    'G-CSF':    'Granulocyte Colony-Stimulating Factor',
    'GM-CSF':   'Granulocyte-Macrophage Colony-Stimulating Factor',
    'ECT':      'Electroconvulsive Therapy',
    'TMS':      'Transcranial Magnetic Stimulation',

    /* ── Vaccines / Immunizations ── */
    'HPV':      'Human Papillomavirus (vaccine)',
    'MMR':      'Measles, Mumps, Rubella (vaccine)',
    'DTaP':     'Diphtheria, Tetanus, acellular Pertussis (vaccine)',
    'Tdap':     'Tetanus, Diphtheria, acellular Pertussis (booster)',
    'IPV':      'Inactivated Polio Vaccine',
    'HiB':      'Haemophilus influenzae type b (vaccine)',
    'PCV':      'Pneumococcal Conjugate Vaccine',
    'PPSV':     'Pneumococcal Polysaccharide Vaccine',
    'HZV':      'Herpes Zoster Vaccine',
    'RV':         'Right Ventricle / Rotavirus',
    'BCG':      'Bacillus Calmette-Guérin (TB vaccine)',

    /* ── Ophthalmology ── */
    'IOP':      'Intraocular Pressure',
    'AMD':      'Age-Related Macular Degeneration',
    'DR':       'Diabetic Retinopathy',
    'ARMD':     'Age-Related Macular Degeneration',
    'VA':       'Visual Acuity',
    'OD':       'Right Eye (Oculus Dexter)',
    'OS':       'Left Eye (Oculus Sinister)',
    'OU':       'Both Eyes (Oculus Uterque)',

    /* ── Infection Control ── */
    'N95':      'N95 Respirator Mask (filters ≥95% airborne particles)',
    'PPE':      'Personal Protective Equipment',
    'AIIR':     'Airborne Infection Isolation Room',
    'CDC':      'Centers for Disease Control and Prevention',
    'HAI':      'Hospital-Acquired Infection',
    'MDRO':     'Multidrug-Resistant Organism',

    /* ── Nursing / Staffing ── */
    'UAP':      'Unlicensed Assistive Personnel',
    'CAM':      'Confusion Assessment Method (delirium tool)',
    'CIWA':     'Clinical Institute Withdrawal Assessment (alcohol)',
    'COWS':     'Clinical Opiate Withdrawal Scale',
    'RASSs':    'Richmond Agitation-Sedation Scale',
    'RASS':     'Richmond Agitation-Sedation Scale',
    'PAAS':     'Pain, Agitation, and Sedation assessment',
    'CPOT':     'Critical-Care Pain Observation Tool',
    'FLACC':    'Face, Legs, Activity, Cry, Consolability (pain scale)',
    'FACES':    'Wong-Baker FACES Pain Scale',

    /* ── Endocrine (extended) ── */
    'LH':       'Luteinizing Hormone',
    'FSH':      'Follicle-Stimulating Hormone',
    'GH':       'Growth Hormone',
    'IGF-1':    'Insulin-Like Growth Factor 1',
    'ACTH':     'Adrenocorticotropic Hormone',
    'CRH':      'Corticotropin-Releasing Hormone',
    'GnRH':     'Gonadotropin-Releasing Hormone',
    'TRH':      'Thyrotropin-Releasing Hormone',
    'PRL':      'Prolactin',
    'MSH':      'Melanocyte-Stimulating Hormone',
    'RAIU':     'Radioactive Iodine Uptake',
    'RAI':      'Radioactive Iodine',

    /* ── Genetics / DNA ── */
    'DNA':      'Deoxyribonucleic Acid',
    'RNA':      'Ribonucleic Acid',
    'mRNA':     'Messenger RNA',
    'tRNA':     'Transfer RNA',
    'PCR':      'Polymerase Chain Reaction',
    'FISH':     'Fluorescence In Situ Hybridization',
    'SNP':      'Single Nucleotide Polymorphism',

    /* ── Cardiology (extended) ── */
    'CO':         'Cardiac Output / Carbon Monoxide',
    'SV':         'Stroke Volume',
    'SVR':      'Systemic Vascular Resistance',
    'PVR':      'Pulmonary Vascular Resistance',
    'PCWP':     'Pulmonary Capillary Wedge Pressure',
    'TPVR':     'Total Peripheral Vascular Resistance',
    'DHP':      'Dihydropyridine (calcium channel blocker class)',
    'CP':       'Chest Pain',
    'PND':      'Paroxysmal Nocturnal Dyspnea',
    'JVD':      'Jugular Venous Distension',
    'JVP':      'Jugular Venous Pressure',
    'S3':       'Third Heart Sound (gallop — ventricular filling)',
    'S4':       'Fourth Heart Sound (atrial gallop)',
    'PMI':      'Point of Maximal Impulse',
    'LVEF':     'Left Ventricular Ejection Fraction',
    'LVHD':     'Left Ventricular Hypertrophy',
    'LVH':      'Left Ventricular Hypertrophy',
    'RVH':      'Right Ventricular Hypertrophy',

    /* ── GI (extended) ── */
    'N/V':      'Nausea and Vomiting',
    'N/V/D':    'Nausea, Vomiting, and Diarrhea',
    'BRAT':     'Bananas, Rice, Applesauce, Toast (diet)',
    'GIB':      'Gastrointestinal Bleed',
    'UGIB':     'Upper Gastrointestinal Bleed',
    'LGIB':     'Lower Gastrointestinal Bleed',
    'HRS':      'Hepatorenal Syndrome',
    'TIPS':     'Transjugular Intrahepatic Portosystemic Shunt',
    'ALF':      'Acute Liver Failure',
    'MELD':     'Model for End-Stage Liver Disease (score)',

    /* ── Vitamin / Nutrition ── */
    'B12':      'Vitamin B12 (Cobalamin)',
    'B6':       'Vitamin B6 (Pyridoxine)',
    'B1':       'Vitamin B1 (Thiamine)',
    'B2':       'Vitamin B2 (Riboflavin)',
    'B3':       'Vitamin B3 (Niacin)',
    'B9':       'Vitamin B9 (Folate / Folic Acid)',
    'VitD':     'Vitamin D',
    'VitC':     'Vitamin C (Ascorbic Acid)',
    'VitK':     'Vitamin K',
    'VitA':     'Vitamin A (Retinol)',
    'VitE':     'Vitamin E (Tocopherol)',
    'Fe':       'Iron',
    'Zn':       'Zinc',

    /* ── COVID / Respiratory Infectious ── */
    'COVID':    'COVID-19 (Coronavirus Disease 2019)',
    'SARS-CoV-2':'Severe Acute Respiratory Syndrome Coronavirus 2',

    /* ── Miscellaneous / General ── */
    'PMH':      'Past Medical History',
    'PSH':      'Past Surgical History',
    'FH':       'Family History',
    'SH':       'Social History',
    'CC':       'Chief Complaint',
    'HPI':      'History of Present Illness',
    'ROS':      'Review of Systems',
    'DDx':      'Differential Diagnosis',
    'WNL':      'Within Normal Limits',
    'NAD':      'No Acute Distress',
    'F/U':      'Follow-Up',
    'f/u':      'Follow-Up',
    'w/u':      'Workup',
    'W/U':      'Workup',
    'Bx':       'Biopsy',
    'Cx':       'Culture',
    's/p':      'Status Post (after a procedure)',
    'S/P':      'Status Post',
    'c/o':      'Complains of',
    'C/O':      'Complains of',
    'r/o':      'Rule Out',
    'R/O':      'Rule Out',
    'n/v':      'Nausea and Vomiting',
    'SOC':      'Standard of Care',
    'EBP':      'Evidence-Based Practice',
    'QI':       'Quality Improvement',
    'TJC':      'The Joint Commission',
    'CMS':      'Centers for Medicare & Medicaid Services',
    'FDA':      'U.S. Food and Drug Administration',
    'HIPAA':    'Health Insurance Portability and Accountability Act',
    'EHR':      'Electronic Health Record',
    'EMR':      'Electronic Medical Record',
    'POA':      'Present on Admission',
    'CAUTI':    'Catheter-Associated Urinary Tract Infection',
    'CLABSI':   'Central Line-Associated Bloodstream Infection',
    'VAP':      'Ventilator-Associated Pneumonia',
    'SSI':      'Surgical Site Infection',
    'SDS':      'Safety Data Sheet',
    'PCA':      'Patient-Controlled Analgesia',
    'PCO2':     'Partial Pressure of Carbon Dioxide',
    'PO2':      'Partial Pressure of Oxygen',
    'O2 sat':   'Oxygen Saturation',
    'O2 Sat':   'Oxygen Saturation',


    /* ── Additional / Corrected ── */
    'LA':         'Left Atrium',
    'LV':         'Left Ventricle',
    'SVC':        'Superior Vena Cava',
    'IVC':        'Inferior Vena Cava'
  };

  /* ─────────────────────────────────────────────────────────────
   *  AUTO-WRAP: walk all text nodes and wrap abbreviations
   * ───────────────────────────────────────────────────────────── */

  // Tags whose children we must NEVER modify
  var SKIP_TAGS = { SCRIPT:1, STYLE:1, ABBR:1, CODE:1, PRE:1,
                    TEXTAREA:1, INPUT:1, SELECT:1, BUTTON:1, A:1 };

  // Build a sorted array of abbreviations, longest first
  // so "NSAIDs" matches before "NSAID", etc.
  var ABBR_KEYS = Object.keys(ABBR).sort(function(a,b){ return b.length - a.length; });

  // Escape special regex characters in a string
  function escapeRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // Build one combined alternation regex for all abbreviations.
  // Each abbreviation is wrapped in \b or lookahead/lookbehind where \b applies.
  // We use a capturing group so we can identify which one matched.
  function buildPattern() {
    var alts = ABBR_KEYS.map(function(k) {
      // For abbreviations containing only word chars, use \b boundaries.
      // For ones with special chars (/, &, ., -), use lookahead/lookbehind.
      if (/^\w+$/.test(k)) {
        return '\\b(' + escapeRe(k) + ')\\b';
      } else {
        return '(?<![\\w])(' + escapeRe(k) + ')(?![\\w])';
      }
    });
    // Combine all into one regex with global flag
    return new RegExp(alts.join('|'), 'g');
  }

  var PATTERN = buildPattern();

  // Build a map from lowercase key → canonical key for fast lookup
  // (We match case-sensitively, so this is just for the replacement lookup)
  var ABBR_LOOKUP = {};
  ABBR_KEYS.forEach(function(k){ ABBR_LOOKUP[k] = k; });

  // Replace text in a single text node with DocumentFragment containing
  // mixed text + <abbr> elements
  function wrapTextNode(node) {
    var text = node.nodeValue;
    // Quick-reject: no uppercase letter at all → skip
    if (!/[A-Z]/.test(text)) return;

    PATTERN.lastIndex = 0;
    var match;
    var lastIndex = 0;
    var frag = document.createDocumentFragment();
    var didMatch = false;

    while ((match = PATTERN.exec(text)) !== null) {
      // Find which capture group matched
      var matched = null;
      for (var i = 1; i < match.length; i++) {
        if (match[i] !== undefined) { matched = match[i]; break; }
      }
      if (!matched) continue;

      var fullTerm = ABBR[matched];
      if (!fullTerm) continue;

      didMatch = true;

      // Text before this match
      if (match.index > lastIndex) {
        frag.appendChild(document.createTextNode(text.slice(lastIndex, match.index)));
      }

      // The <abbr> element
      var abbr = document.createElement('abbr');
      abbr.setAttribute('title', fullTerm);
      abbr.textContent = matched;
      frag.appendChild(abbr);

      lastIndex = match.index + matched.length;
    }

    if (!didMatch) return;

    // Remaining text after last match
    if (lastIndex < text.length) {
      frag.appendChild(document.createTextNode(text.slice(lastIndex)));
    }

    node.parentNode.replaceChild(frag, node);
  }

  // Recursively walk DOM tree, process text nodes
  function walkNode(node) {
    if (node.nodeType === 3) {          // TEXT_NODE
      wrapTextNode(node);
      return;
    }
    if (node.nodeType !== 1) return;    // not an ELEMENT_NODE either → skip
    if (SKIP_TAGS[node.tagName]) return; // skip blacklisted tags

    // Snapshot children because wrapTextNode will mutate the live list
    var children = Array.prototype.slice.call(node.childNodes);
    children.forEach(walkNode);
  }

  function autoWrapAbbreviations() {
    if (!document.body) return;
    walkNode(document.body);
  }

  /* ─────────────────────────────────────────────────────────────
   *  BACK LINK: rewrite "Back to Notes" to "Back to Portal"
   * ───────────────────────────────────────────────────────────── */

  function fixBackToPortalLink() {
    if (!document.body) return;

    // If the premium nav injector is present on this page (acnhs-nav-inject.js),
    // it handles the back link entirely — suppress this fallback button.
    if (document.querySelector('script[src*="acnhs-nav-inject"]') ||
        document.querySelector('.acnhs-site-nav, .acnhs-nav-back')) return;

    // Prefer explicit back buttons by class
    var backLink = document.querySelector('.back-btn, .back-link, .back_btn');
    var created = false;

    // If no class-based match, fall back to link text match
    if (!backLink) {
      var links = document.querySelectorAll('a');
      for (var i = 0; i < links.length; i++) {
        var text = (links[i].textContent || '').trim();
        if (/back to notes/i.test(text)) {
          backLink = links[i];
          break;
        }
      }
    }

    // If nothing exists, create a fixed-position back link so it's always visible
    if (!backLink) {
      backLink = document.createElement('a');
      backLink.className = 'back-btn';
      document.body.insertBefore(backLink, document.body.firstChild);
      created = true;
    }

    // Build the absolute portal URL from the current page's location.
    // Strategy: strip everything after the repo/site root by removing all
    // path segments from "Notes/" onward, then append "student-portal.html".
    // This works for https://, http://, and file:// without cross-origin issues.
    var portalUrl;
    try {
      var href = window.location.href;
      // Find the index of "/Notes/" (case-insensitive) and trim from there
      var notesIdx = href.search(/\/[Nn]otes\//);
      if (notesIdx !== -1) {
        portalUrl = href.slice(0, notesIdx) + '/student-portal.html';
      } else {
        // Fallback: walk up from current path to root
        var origin = window.location.origin; // works for http/https
        if (origin && origin !== 'null') {
          portalUrl = origin + '/student-portal.html';
        } else {
          // file:// — build from pathname
          var parts = window.location.pathname.split('/');
          parts.pop(); // remove filename
          parts.pop(); // remove category folder
          parts.pop(); // remove Notes folder
          portalUrl = 'file://' + parts.join('/') + '/student-portal.html';
        }
      }
    } catch (err) {
      portalUrl = window.location.origin + '/student-portal.html';
    }
    backLink.setAttribute('href', portalUrl);
    backLink.textContent = '← Back to Portal';
    backLink.addEventListener('click', function (e) {
      e.preventDefault();
      window.location.href = portalUrl;
    });

    if (created) {
      backLink.style.position = 'fixed';
      backLink.style.top = '14px';
      backLink.style.left = '14px';
      backLink.style.zIndex = '9999';
      backLink.style.padding = '6px 12px';
      backLink.style.borderRadius = '999px';
      backLink.style.border = '1px solid rgba(45, 212, 191, 0.45)';
      backLink.style.background = 'rgba(7, 18, 40, 0.65)';
      backLink.style.color = '#2dd4bf';
      backLink.style.fontSize = '12px';
      backLink.style.fontWeight = '600';
      backLink.style.letterSpacing = '.02em';
      backLink.style.textDecoration = 'none';
      backLink.style.backdropFilter = 'blur(6px)';
    }
  }

  /* ─────────────────────────────────────────────────────────────
   *  TOOLTIP ENGINE
   * ───────────────────────────────────────────────────────────── */

  var tooltip = null;

  function getOrCreateTooltip() {
    if (!tooltip) {
      tooltip = document.createElement('div');
      tooltip.className = 'abbr-tooltip';
      document.body.appendChild(tooltip);
    }
    return tooltip;
  }

  document.addEventListener('mouseover', function (e) {
    var el = e.target.closest('abbr[title]');
    if (!el) return;
    var tip = getOrCreateTooltip();
    tip.textContent = el.getAttribute('title');
    tip.style.display = 'block';
  });

  document.addEventListener('mousemove', function (e) {
    if (!tooltip || tooltip.style.display === 'none') return;
    // Use clientX/clientY because tooltip is position:fixed
    var x = e.clientX + 14;
    var y = e.clientY + 14;
    // Keep tooltip within viewport
    var tw = tooltip.offsetWidth || 200;
    var th = tooltip.offsetHeight || 30;
    if (x + tw > window.innerWidth  - 8) x = e.clientX - tw - 10;
    if (y + th > window.innerHeight - 8) y = e.clientY - th - 10;
    tooltip.style.left = x + 'px';
    tooltip.style.top  = y + 'px';
  });

  document.addEventListener('mouseout', function (e) {
    var el = e.target.closest('abbr[title]');
    if (!el || !tooltip) return;
    tooltip.style.display = 'none';
  });

  /* ─────────────────────────────────────────────────────────────
   *  INIT: run auto-wrap after DOM is ready
   * ───────────────────────────────────────────────────────────── */

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      autoWrapAbbreviations();
      fixBackToPortalLink();
    });
  } else {
    // DOM is already ready (script loaded with defer or after parse)
    autoWrapAbbreviations();
    fixBackToPortalLink();
  }

})();
