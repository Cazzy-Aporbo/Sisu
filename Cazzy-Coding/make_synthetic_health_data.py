import pandas as pd
import numpy as np
import random
import faker
from datetime import timedelta

fake = faker.Faker()
num_patients = 500  # Can increase as needed

# 1. Patient Demographics
demographics = {
    "patient_id": [f"MRN{random.randint(100000,999999)}" for _ in range(num_patients)],
    "first_name": [fake.first_name() for _ in range(num_patients)],
    "last_name": [fake.last_name() for _ in range(num_patients)],
    "dob": [fake.date_of_birth(minimum_age=0, maximum_age=100) for _ in range(num_patients)],
    "gender": [random.choice(["Male", "Female", "Other"]) for _ in range(num_patients)],
    "address": [fake.address().replace("\n", ", ") for _ in range(num_patients)],
    "phone": [fake.phone_number() for _ in range(num_patients)],
    "email": [fake.email() for _ in range(num_patients)]
}

# 2. Vital Signs
vitals = {
    "height_cm": [round(random.uniform(140, 200), 1) for _ in range(num_patients)],
    "weight_kg": [round(random.uniform(40, 150), 1) for _ in range(num_patients)],
    "systolic_bp": [random.randint(90, 160) for _ in range(num_patients)],
    "diastolic_bp": [random.randint(60, 100) for _ in range(num_patients)],
    "heart_rate": [random.randint(50, 120) for _ in range(num_patients)],
    "temperature_c": [round(random.uniform(36.0, 39.0),1) for _ in range(num_patients)]
}

# 3. Lab Results
labs = {
    "hemoglobin": [round(random.uniform(10.0, 17.0),1) for _ in range(num_patients)],
    "white_blood_cell_count": [round(random.uniform(3.0, 11.0),1) for _ in range(num_patients)],
    "platelets": [random.randint(150, 450) for _ in range(num_patients)],
    "glucose_mg_dl": [round(random.uniform(70, 180),1) for _ in range(num_patients)]
}

# 4. Diagnoses, Procedures, Medications
diagnoses_list = ["Hypertension", "Diabetes", "Asthma", "COVID-19", "COPD", "Obesity", "Depression"]
procedures_list = ["X-Ray", "MRI", "CT Scan", "Blood Test", "Vaccination", "Ultrasound"]
medications_list = ["Metformin", "Lisinopril", "Albuterol", "Atorvastatin", "Omeprazole", "Sertraline"]

medical = {
    "diagnosis": [random.choice(diagnoses_list) for _ in range(num_patients)],
    "procedure": [random.choice(procedures_list) for _ in range(num_patients)],
    "medication": [random.choice(medications_list) for _ in range(num_patients)],
    "admission_date": [fake.date_between(start_date='-2y', end_date='today') for _ in range(num_patients)],
}

# 5. Combine All
data = {**demographics, **vitals, **labs, **medical}
df = pd.DataFrame(data)

# 6. Optional: Add Noise / Missing Values
for col in df.columns:
    df.loc[df.sample(frac=0.05).index, col] = np.nan  # 5% missing values

# Shuffle rows to remove patterns
df = df.sample(frac=1).reset_index(drop=True)

# 7. Save Dataset
df.to_csv("synthetic_healthcare_data.csv", index=False)
print("Synthetic healthcare dataset generated: synthetic_healthcare_data.csv")