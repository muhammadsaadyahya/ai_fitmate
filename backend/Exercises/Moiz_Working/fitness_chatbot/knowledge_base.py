"""
Fitness knowledge base — exercises, nutrition, and workout FAQs.
Each document has an id, text (for embedding), and metadata for filtering.
"""

DOCUMENTS = [
    # ── EXERCISES ─────────────────────────────────────────────────────────────
    {
        "id": "ex_001",
        "text": "Question: How do I do a proper push-up?\nAnswer: Start in a high plank with hands shoulder-width apart. Lower your chest to the floor keeping elbows at 45°, then push back up. Keep your core tight and body in a straight line throughout.",
        "category": "exercise", "topic": "upper_body",
    },
    {
        "id": "ex_002",
        "text": "Question: What muscles do squats work?\nAnswer: Squats primarily target the quadriceps, hamstrings, and glutes. They also engage the core, calves, and lower back as stabilizers. They are one of the best compound lower-body exercises.",
        "category": "exercise", "topic": "lower_body",
    },
    {
        "id": "ex_003",
        "text": "Question: How do I perform a deadlift correctly?\nAnswer: Stand with feet hip-width apart, bar over mid-foot. Hinge at hips, grip the bar just outside your legs, keep your back flat and chest up. Drive through your heels and stand tall. Lower with control.",
        "category": "exercise", "topic": "compound",
    },
    {
        "id": "ex_004",
        "text": "Question: What is the best exercise for building a stronger core?\nAnswer: The plank is highly effective — hold a straight body position on forearms and toes for 30–60 seconds. Other great core exercises include dead bugs, hollow holds, and ab wheel rollouts.",
        "category": "exercise", "topic": "core",
    },
    {
        "id": "ex_005",
        "text": "Question: How do I do a proper pull-up?\nAnswer: Hang from a bar with palms facing away, hands shoulder-width apart. Pull your chest toward the bar by driving your elbows down, then lower with control. Avoid swinging or kipping for strength development.",
        "category": "exercise", "topic": "upper_body",
    },
    {
        "id": "ex_006",
        "text": "Question: What are the best exercises for building shoulder muscle?\nAnswer: Overhead press, lateral raises, front raises, and face pulls are excellent for shoulder development. Aim for 3–4 sets of 10–15 reps each. Train all three heads: front, lateral, and rear deltoid.",
        "category": "exercise", "topic": "upper_body",
    },
    {
        "id": "ex_007",
        "text": "Question: How do I build bigger biceps?\nAnswer: Barbell curls, dumbbell curls, hammer curls, and concentration curls are the best bicep builders. Focus on full range of motion, slow eccentric, and progressive overload with 3–4 sets of 8–12 reps.",
        "category": "exercise", "topic": "upper_body",
    },
    {
        "id": "ex_008",
        "text": "Question: What is progressive overload?\nAnswer: Progressive overload means gradually increasing the stress placed on your body during training — by adding weight, reps, sets, or reducing rest time. It is the single most important principle for building muscle and strength.",
        "category": "exercise", "topic": "principles",
    },
    {
        "id": "ex_009",
        "text": "Question: How many sets and reps should I do to build muscle?\nAnswer: For hypertrophy (muscle growth), aim for 3–5 sets of 8–12 reps per exercise with 60–90 seconds rest. Train each muscle group 2× per week. Focus on progressive overload over time.",
        "category": "exercise", "topic": "programming",
    },
    {
        "id": "ex_010",
        "text": "Question: What are the best exercises for burning calories?\nAnswer: High-intensity exercises like burpees, jump rope, rowing, cycling, and running burn the most calories. HIIT (High Intensity Interval Training) is especially effective — alternating max effort with short rest periods.",
        "category": "exercise", "topic": "cardio",
    },
    {
        "id": "ex_011",
        "text": "Question: How do I do a proper lunge?\nAnswer: Step forward with one foot, lowering your back knee toward the floor until both knees are at 90°. Keep your front knee over your ankle. Push through the front heel to return. Alternate legs for 10–12 reps each.",
        "category": "exercise", "topic": "lower_body",
    },
    {
        "id": "ex_012",
        "text": "Question: What is a good beginner workout routine?\nAnswer: Start with 3 days per week full-body training: squats, push-ups, rows, lunges, and planks. Do 3 sets of 10 reps each. Focus on form before adding weight. Rest at least one day between sessions.",
        "category": "exercise", "topic": "programming",
    },
    {
        "id": "ex_013",
        "text": "Question: How do I improve my running endurance?\nAnswer: Follow the 10% rule — increase weekly mileage by no more than 10% per week. Include easy runs (conversational pace), interval training, and one long run weekly. Rest and consistency are key.",
        "category": "exercise", "topic": "cardio",
    },
    {
        "id": "ex_014",
        "text": "Question: What is HIIT and how do it?\nAnswer: HIIT is High Intensity Interval Training. Alternate 20–40 seconds of maximum effort (sprints, burpees, jump squats) with 10–20 seconds of rest. Repeat for 15–30 minutes. It burns more calories than steady cardio in less time.",
        "category": "exercise", "topic": "cardio",
    },
    {
        "id": "ex_015",
        "text": "Question: How often should I work out?\nAnswer: Beginners should train 3 days per week. Intermediate lifters can train 4–5 days. Advanced athletes may train 5–6 days. Always include at least 1–2 rest days per week for recovery and muscle growth.",
        "category": "exercise", "topic": "programming",
    },

    # ── NUTRITION ─────────────────────────────────────────────────────────────
    {
        "id": "nu_001",
        "text": "Question: How much protein should I eat to build muscle?\nAnswer: Aim for 1.6–2.2g of protein per kg of bodyweight per day. For an 80kg person that is 128–176g of protein daily. Spread intake across 4–5 meals. Good sources: chicken, eggs, fish, Greek yogurt, and legumes.",
        "category": "nutrition", "topic": "protein",
    },
    {
        "id": "nu_002",
        "text": "Question: What should I eat before a workout?\nAnswer: Eat a balanced meal 2–3 hours before training: carbs for energy (oats, rice, banana) and protein for muscle support (chicken, eggs). For a quick pre-workout snack 30–60 min before, try a banana with peanut butter.",
        "category": "nutrition", "topic": "meal_timing",
    },
    {
        "id": "nu_003",
        "text": "Question: What should I eat after a workout?\nAnswer: Eat within 30–60 minutes post-workout. Combine protein (30–40g) to repair muscle with fast carbs to replenish glycogen. Examples: chicken with rice, protein shake with banana, Greek yogurt with fruit.",
        "category": "nutrition", "topic": "meal_timing",
    },
    {
        "id": "nu_004",
        "text": "Question: How do I calculate my daily calorie needs?\nAnswer: Use the Mifflin-St Jeor equation for BMR, then multiply by your activity factor (sedentary ×1.2, moderately active ×1.55, very active ×1.725). To lose weight subtract 500 kcal; to gain muscle add 300 kcal.",
        "category": "nutrition", "topic": "calories",
    },
    {
        "id": "nu_005",
        "text": "Question: Are carbohydrates bad for weight loss?\nAnswer: No. Carbohydrates are your body's primary energy source. Focus on quality carbs like oats, sweet potato, brown rice, and fruits. Avoid refined sugars and ultra-processed foods. Total calorie balance matters most for weight loss.",
        "category": "nutrition", "topic": "macros",
    },
    {
        "id": "nu_006",
        "text": "Question: How much water should I drink daily?\nAnswer: Aim for 35–40ml per kg of bodyweight per day. For an 80kg person that is about 2.8–3.2 litres. Drink more during exercise — add 500ml per hour of intense training. Pale yellow urine is a sign of good hydration.",
        "category": "nutrition", "topic": "hydration",
    },
    {
        "id": "nu_007",
        "text": "Question: What are the best foods for weight loss?\nAnswer: Prioritise high-volume, low-calorie foods: vegetables, fruits, lean proteins (chicken, fish, tofu), and legumes. These keep you full longer. Avoid liquid calories, ultra-processed snacks, and high-fat fast food.",
        "category": "nutrition", "topic": "weight_loss",
    },
    {
        "id": "nu_008",
        "text": "Question: Do I need protein supplements to build muscle?\nAnswer: No — you can meet your protein needs through whole foods. Supplements like whey protein are convenient but not required. If you struggle to hit 1.6–2.2g/kg through food, a shake can help fill the gap.",
        "category": "nutrition", "topic": "supplements",
    },
    {
        "id": "nu_009",
        "text": "Question: What is the role of fats in the diet?\nAnswer: Dietary fat is essential for hormone production, brain function, and absorbing fat-soluble vitamins (A, D, E, K). Prioritise unsaturated fats: avocado, olive oil, nuts, and fatty fish. Limit saturated and avoid trans fats.",
        "category": "nutrition", "topic": "macros",
    },
    {
        "id": "nu_010",
        "text": "Question: How many meals should I eat per day?\nAnswer: Meal frequency matters less than total daily intake. 3–5 meals work for most people. Spreading protein across 4+ meals may slightly improve muscle protein synthesis. Eat in a pattern that fits your schedule and keeps you consistent.",
        "category": "nutrition", "topic": "meal_timing",
    },
    {
        "id": "nu_011",
        "text": "Question: What is a caloric deficit and how much should mine be?\nAnswer: A caloric deficit means consuming fewer calories than you burn. A deficit of 300–500 kcal/day leads to 0.3–0.5 kg fat loss per week — sustainable and muscle-preserving. Larger deficits risk muscle loss and fatigue.",
        "category": "nutrition", "topic": "weight_loss",
    },
    {
        "id": "nu_012",
        "text": "Question: What foods are high in protein?\nAnswer: Top protein sources: chicken breast (31g/100g), canned tuna (30g/100g), eggs (13g/100g), Greek yogurt (10g/100g), lentils (9g/100g), tofu (8g/100g), and whey protein powder (25g/scoop).",
        "category": "nutrition", "topic": "protein",
    },

    # ── WORKOUT FAQs ──────────────────────────────────────────────────────────
    {
        "id": "faq_001",
        "text": "Question: How long does it take to see results from working out?\nAnswer: Strength improvements start in 2–4 weeks as the nervous system adapts. Visible muscle changes typically appear in 8–12 weeks with consistent training and proper nutrition. Fat loss is visible in 4–8 weeks at a 500 kcal deficit.",
        "category": "faq", "topic": "expectations",
    },
    {
        "id": "faq_002",
        "text": "Question: Is it okay to work out every day?\nAnswer: Training daily is possible but requires smart programming. Alternate muscle groups and include active recovery days (light walking, yoga, stretching). Beginners need more recovery time — 3–4 days per week is optimal.",
        "category": "faq", "topic": "recovery",
    },
    {
        "id": "faq_003",
        "text": "Question: What is muscle soreness and how do I recover faster?\nAnswer: Delayed Onset Muscle Soreness (DOMS) peaks 24–72 hours after training. Speed recovery with: adequate sleep (7–9 hours), protein intake, light movement, foam rolling, and staying hydrated.",
        "category": "faq", "topic": "recovery",
    },
    {
        "id": "faq_004",
        "text": "Question: Should I do cardio or weights first?\nAnswer: It depends on your goal. For fat loss or general fitness, either order works. For strength or muscle gain, do weights first — cardio fatigues muscles and reduces lifting performance. For endurance events, cardio first is preferred.",
        "category": "faq", "topic": "programming",
    },
    {
        "id": "faq_005",
        "text": "Question: How do I lose belly fat?\nAnswer: Spot reduction is a myth — you cannot target fat loss in one area. Reduce overall body fat through a caloric deficit, high-protein diet, and consistent exercise. Compound lifts and HIIT are most effective for fat loss.",
        "category": "faq", "topic": "fat_loss",
    },
    {
        "id": "faq_006",
        "text": "Question: How important is sleep for fitness progress?\nAnswer: Sleep is when muscle repair and growth hormone release peak. Aim for 7–9 hours per night. Poor sleep increases cortisol, reduces recovery, impairs performance, and raises hunger hormones — making fat loss harder.",
        "category": "faq", "topic": "recovery",
    },
    {
        "id": "faq_007",
        "text": "Question: What is the difference between fat loss and weight loss?\nAnswer: Weight loss includes muscle, water, and fat. Fat loss specifically targets adipose tissue while preserving muscle. To maximise fat loss: high protein intake, strength training, moderate cardio, and a controlled caloric deficit.",
        "category": "faq", "topic": "fat_loss",
    },
    {
        "id": "faq_008",
        "text": "Question: How do I stay motivated to work out?\nAnswer: Set specific goals, track progress, find a workout you enjoy, train with a partner, and celebrate small wins. Consistency beats motivation — build a routine so exercise becomes a habit, not a choice.",
        "category": "faq", "topic": "mindset",
    },
    {
        "id": "faq_009",
        "text": "Question: Can I build muscle and lose fat at the same time?\nAnswer: Yes — body recomposition is possible, especially for beginners or those returning after a break. Eat at maintenance or slight deficit, train with progressive overload, and consume high protein (2g/kg). Progress is slower than doing one goal at a time.",
        "category": "faq", "topic": "recomposition",
    },
    {
        "id": "faq_010",
        "text": "Question: How do I avoid injury during exercise?\nAnswer: Warm up for 5–10 minutes before training. Use proper form over heavy weight. Progress gradually (10% rule). Listen to your body — pain means stop. Cool down and stretch after sessions. Stay hydrated and get enough sleep.",
        "category": "faq", "topic": "safety",
    },
    {
        "id": "faq_011",
        "text": "Question: What is the best time of day to work out?\nAnswer: The best time is whenever you can be consistent. Morning workouts improve adherence for many people. Afternoon/evening workouts typically have peak strength and performance. Choose a time you can stick to long-term.",
        "category": "faq", "topic": "programming",
    },
    {
        "id": "faq_012",
        "text": "Question: How do I warm up properly before lifting?\nAnswer: Start with 5 minutes light cardio (brisk walk or jump rope). Then do dynamic stretches: leg swings, arm circles, hip circles. Finish with 1–2 warm-up sets of your first exercise at 50–60% of your working weight.",
        "category": "faq", "topic": "safety",
    },
]
