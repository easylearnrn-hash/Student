# 📝 How to Add Tests by Category

## Quick Start

1. **Run the SQL Migration**
   - Go to your Supabase SQL Editor
   - Run `add-category-to-test-questions.sql`
   - This adds `category` and `difficulty` fields

2. **Access Test Manager**
   - Login as admin
   - Go to Student Portal Admin
   - Click "📝 Test Manager" button

3. **Add Questions**

---

## Adding Questions by Category

### Method 1: Single Question Entry

1. Click **"➕ Add Single Question"** tab
2. Select **Category** from dropdown:
   - Cardiovascular Medications
   - Respiratory Medications  
   - Renal Medications
   - Neurological Medications
   - Endocrine Medications
   - Gastrointestinal Medications
   - Antimicrobial Medications
   - Oncology Medications
   - Pediatric Medications
   - Obstetric Medications
   - Medical-Surgical
   - Critical Care
   - Emergency Nursing
   - General

3. Select **Difficulty**: Easy, Medium, or Hard
4. Enter question and options
5. Click "➕ Add Question"

✅ **Tip**: Category and difficulty stay selected, so you can quickly add multiple questions to the same category!

---

### Method 2: Bulk Import (Same Category)

1. Click **"📋 Bulk Import"** tab
2. Paste questions (one per line)
3. Currently adds to "General" category
4. Perfect for quick imports

**Format:**
```
What is the action of Lisinopril? | ACE inhibitor | Beta blocker | Calcium channel blocker | Diuretic | A
What is the action of Metoprolol? | ACE inhibitor | Beta blocker | Calcium channel blocker | Diuretic | B
```

---

### Method 3: JSON Import with Categories

1. Click **"📄 JSON Upload"** tab
2. Paste JSON text OR upload .json file

**Example JSON with Categories:**
```json
[
  {
    "question": "What is the primary action of Lisinopril?",
    "options": ["ACE inhibitor", "Beta blocker", "Calcium blocker", "Diuretic"],
    "correct_answer": "A",
    "category": "Cardiovascular Medications",
    "difficulty": "Medium"
  },
  {
    "question": "What is the primary action of Albuterol?",
    "options": ["Bronchodilator", "Steroid", "Antihistamine", "Decongestant"],
    "correct_answer": "A",
    "category": "Respiratory Medications",
    "difficulty": "Easy"
  },
  {
    "question": "What is the primary action of Furosemide?",
    "options": ["ACE inhibitor", "Beta blocker", "Calcium blocker", "Loop diuretic"],
    "correct_answer": "D",
    "category": "Renal Medications",
    "difficulty": "Medium"
  }
]
```

✅ **Note**: If you omit `category` or `difficulty`, they default to "General" and "Medium"

---

## Organizing Tests by Topic

### Example: Cardiovascular Medications Test

**Questions you might add:**
1. Lisinopril (ACE inhibitor) - Easy
2. Metoprolol (Beta blocker) - Easy
3. Amlodipine (Calcium channel blocker) - Medium
4. Furosemide (Loop diuretic) - Medium
5. Warfarin (Anticoagulant) - Hard
6. Amiodarone (Antiarrhythmic) - Hard
7. Nitroglycerin (Vasodilator) - Medium
8. Digoxin (Cardiac glycoside) - Hard

### Example: Respiratory Medications Test

**Questions you might add:**
1. Albuterol (Short-acting bronchodilator) - Easy
2. Ipratropium (Anticholinergic) - Medium
3. Fluticasone (Inhaled corticosteroid) - Medium
4. Montelukast (Leukotriene inhibitor) - Hard
5. Theophylline (Methylxanthine) - Hard

---

## Viewing Your Questions

In the **"📚 Manage Questions"** tab, you'll see:
- 🏷️ **Category badge** (blue)
- 🎯 **Difficulty badge** (green = Easy, yellow = Medium, red = Hard)
- Question text
- All options with correct answer marked

---

## Student Experience

When students take the test:
- They see ALL questions from ALL categories mixed together
- Can use **🔀 Mix** button to shuffle question order
- Questions are randomized for better learning

---

## Tips for Organizing

### By Medication Class
- Create one category per medication system
- Use difficulty levels for nursing student years:
  - **Easy** = 1st year
  - **Medium** = 2nd year  
  - **Hard** = 3rd/4th year or NCLEX prep

### By Nursing Topic
- Medical-Surgical → General procedures
- Critical Care → ICU/advanced care
- Emergency → ER/trauma
- Pediatric → Children-specific
- Obstetric → Pregnancy/birth

### By Exam Prep
- Create difficulty progression
- Easy → build confidence
- Medium → standard practice
- Hard → NCLEX-level challenge

---

## Quick Workflow

**Adding 20 Cardiovascular Questions:**

1. Select "Cardiovascular Medications" from dropdown
2. Select "Medium" difficulty
3. Add question #1 → Click "Add Question"
4. Category & difficulty stay selected!
5. Add question #2 → Click "Add Question"
6. Continue until done
7. Change difficulty to "Hard" for advanced questions
8. Keep adding!

**Result:** All questions tagged with category + difficulty for easy tracking!
