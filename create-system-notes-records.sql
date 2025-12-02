-- ============================================================
-- SQL to Create Student Notes Records for All NCLEX Systems
-- ============================================================
-- INSTRUCTIONS:
-- 1. First, manually upload PDFs to Supabase Storage under student-notes bucket
--    in folders named exactly as the system names below
-- 2. Update the pdf_url, file_name, and file_size for each record
-- 3. Run this SQL in Supabase SQL Editor
-- ============================================================

-- Replace 'your-email@example.com' with your actual email
-- Replace file paths, names, and sizes with your actual file details

INSERT INTO student_notes (
  title,
  description,
  group_name,
  class_date,
  pdf_url,
  file_name,
  file_size,
  uploaded_by,
  requires_payment,
  deleted
) VALUES

-- 1. Medical Terminology
(
  'Medical Terminology - Complete Notes',
  'Comprehensive notes covering medical terminology',
  'Medical Terminology',
  CURRENT_DATE,
  'Medical Terminology/medical_terminology_notes.pdf',
  'medical_terminology_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 2. Human Anatomy
(
  'Human Anatomy - Complete Notes',
  'Comprehensive notes covering human anatomy',
  'Human Anatomy',
  CURRENT_DATE,
  'Human Anatomy/human_anatomy_notes.pdf',
  'human_anatomy_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 3. Medication Suffixes and Drug Classes
(
  'Medication Suffixes and Drug Classes - Complete Notes',
  'Comprehensive notes covering medication suffixes and drug classes',
  'Medication Suffixes and Drug Classes',
  CURRENT_DATE,
  'Medication Suffixes and Drug Classes/medication_suffixes_notes.pdf',
  'medication_suffixes_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 4. Cardiovascular System
(
  'Cardiovascular System - Complete Notes',
  'Comprehensive notes covering the cardiovascular system',
  'Cardiovascular System',
  CURRENT_DATE,
  'Cardiovascular System/cardiovascular_notes.pdf',
  'cardiovascular_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 5. Endocrine System
(
  'Endocrine System - Complete Notes',
  'Comprehensive notes covering the endocrine system',
  'Endocrine System',
  CURRENT_DATE,
  'Endocrine System/endocrine_notes.pdf',
  'endocrine_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 6. Gastrointestinal & Hepatic System
(
  'Gastrointestinal & Hepatic System - Complete Notes',
  'Comprehensive notes covering the gastrointestinal and hepatic system',
  'Gastrointestinal & Hepatic System',
  CURRENT_DATE,
  'Gastrointestinal & Hepatic System/gastrointestinal_notes.pdf',
  'gastrointestinal_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 7. Respiratory System
(
  'Respiratory System - Complete Notes',
  'Comprehensive notes covering the respiratory system',
  'Respiratory System',
  CURRENT_DATE,
  'Respiratory System/respiratory_notes.pdf',
  'respiratory_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 8. Renal
(
  'Renal - Complete Notes',
  'Comprehensive notes covering the renal system',
  'Renal',
  CURRENT_DATE,
  'Renal/renal_notes.pdf',
  'renal_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 9. Fluids, Electrolytes & Nutrition
(
  'Fluids, Electrolytes & Nutrition - Complete Notes',
  'Comprehensive notes covering fluids, electrolytes and nutrition',
  'Fluids, Electrolytes & Nutrition',
  CURRENT_DATE,
  'Fluids, Electrolytes & Nutrition/fluids_electrolytes_notes.pdf',
  'fluids_electrolytes_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 10. Eye Disorders
(
  'Eye Disorders - Complete Notes',
  'Comprehensive notes covering eye disorders',
  'Eye Disorders',
  CURRENT_DATE,
  'Eye Disorders/eye_disorders_notes.pdf',
  'eye_disorders_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 11. EENT
(
  'EENT - Complete Notes',
  'Comprehensive notes covering ear, eye, nose, and throat',
  'EENT',
  CURRENT_DATE,
  'EENT/eent_notes.pdf',
  'eent_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 12. Burns and Skin
(
  'Burns and Skin - Complete Notes',
  'Comprehensive notes covering burns and skin disorders',
  'Burns and Skin',
  CURRENT_DATE,
  'Burns and Skin/burns_skin_notes.pdf',
  'burns_skin_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 13. Reproductive and Sexual Health System
(
  'Reproductive and Sexual Health System - Complete Notes',
  'Comprehensive notes covering reproductive and sexual health',
  'Reproductive and Sexual Health System',
  CURRENT_DATE,
  'Reproductive and Sexual Health System/reproductive_health_notes.pdf',
  'reproductive_health_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 14. Maternal Health
(
  'Maternal Health - Complete Notes',
  'Comprehensive notes covering maternal health',
  'Maternal Health',
  CURRENT_DATE,
  'Maternal Health/maternal_health_notes.pdf',
  'maternal_health_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 15. Pediatrics
(
  'Pediatrics - Complete Notes',
  'Comprehensive notes covering pediatrics',
  'Pediatrics',
  CURRENT_DATE,
  'Pediatrics/pediatrics_notes.pdf',
  'pediatrics_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 16. Medical-Surgical Care
(
  'Medical-Surgical Care - Complete Notes',
  'Comprehensive notes covering medical-surgical care',
  'Medical-Surgical Care',
  CURRENT_DATE,
  'Medical-Surgical Care/medical_surgical_notes.pdf',
  'medical_surgical_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 17. Mental Health
(
  'Mental Health - Complete Notes',
  'Comprehensive notes covering mental health',
  'Mental Health',
  CURRENT_DATE,
  'Mental Health/mental_health_notes.pdf',
  'mental_health_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 18. Autoimmune & Infectious Disorders
(
  'Autoimmune & Infectious Disorders - Complete Notes',
  'Comprehensive notes covering autoimmune and infectious disorders',
  'Autoimmune & Infectious Disorders',
  CURRENT_DATE,
  'Autoimmune & Infectious Disorders/autoimmune_infectious_notes.pdf',
  'autoimmune_infectious_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 19. Neurology
(
  'Neurology - Complete Notes',
  'Comprehensive notes covering neurology',
  'Neurology',
  CURRENT_DATE,
  'Neurology/neurology_notes.pdf',
  'neurology_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 20. Cancer
(
  'Cancer - Complete Notes',
  'Comprehensive notes covering cancer and oncology',
  'Cancer',
  CURRENT_DATE,
  'Cancer/cancer_notes.pdf',
  'cancer_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 21. Musculoskeletal Disorders
(
  'Musculoskeletal Disorders - Complete Notes',
  'Comprehensive notes covering musculoskeletal disorders',
  'Musculoskeletal Disorders',
  CURRENT_DATE,
  'Musculoskeletal Disorders/musculoskeletal_notes.pdf',
  'musculoskeletal_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 22. Psycho-Social Aspects
(
  'Psycho-Social Aspects - Complete Notes',
  'Comprehensive notes covering psycho-social aspects',
  'Psycho-Social Aspects',
  CURRENT_DATE,
  'Psycho-Social Aspects/psycho_social_notes.pdf',
  'psycho_social_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 23. Nursing Skills and Fundamentals
(
  'Nursing Skills and Fundamentals - Complete Notes',
  'Comprehensive notes covering nursing skills and fundamentals',
  'Nursing Skills and Fundamentals',
  CURRENT_DATE,
  'Nursing Skills and Fundamentals/nursing_skills_notes.pdf',
  'nursing_skills_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
),

-- 24. Pharmacology
(
  'Pharmacology - Complete Notes',
  'Comprehensive notes covering pharmacology',
  'Pharmacology',
  CURRENT_DATE,
  'Pharmacology/pharmacology_notes.pdf',
  'pharmacology_notes.pdf',
  1024000,
  'your-email@example.com',
  true,
  false
);

-- ============================================================
-- After running this SQL:
-- 1. Go to Supabase Storage → student-notes bucket
-- 2. Upload your PDFs to folders matching the system names above
-- 3. The folders will auto-create when you upload
-- 4. Update this SQL with actual file names/sizes if different
-- ============================================================

-- All 24 NCLEX Systems:
-- 1. Medical Terminology
-- 2. Human Anatomy
-- 3. Medication Suffixes and Drug Classes
-- 4. Cardiovascular System
-- 5. Endocrine System
-- 6. Gastrointestinal & Hepatic System
-- 7. Respiratory System
-- 8. Renal
-- 9. Fluids, Electrolytes & Nutrition
-- 10. Eye Disorders
-- 11. EENT
-- 12. Burns and Skin
-- 13. Reproductive and Sexual Health System
-- 14. Maternal Health
-- 15. Pediatrics
-- 16. Medical-Surgical Care
-- 17. Mental Health
-- 18. Autoimmune & Infectious Disorders
-- 19. Neurology
-- 20. Cancer
-- 21. Musculoskeletal Disorders
-- 22. Psycho-Social Aspects
-- 23. Nursing Skills and Fundamentals
-- 24. Pharmacology

