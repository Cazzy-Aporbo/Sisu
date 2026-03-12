import pandas as pd
import numpy as np
import random
import faker

fake = faker.Faker()
num_properties = 500  # Adjust as needed

# 1. Property Details
property_data = {
    "property_id": [f"PROP{random.randint(100000,999999)}" for _ in range(num_properties)],
    "property_type": [random.choice(["House", "Apartment", "Condo", "Townhouse"]) for _ in range(num_properties)],
    "bedrooms": [random.randint(1, 6) for _ in range(num_properties)],
    "bathrooms": [round(random.uniform(1, 4),1) for _ in range(num_properties)],
    "area_sqft": [round(random.uniform(500, 5000),1) for _ in range(num_properties)],
    "year_built": [random.randint(1950, 2025) for _ in range(num_properties)]
}

# 2. Pricing Info
pricing_data = {
    "listing_price": [round(random.uniform(50000, 2000000),2) for _ in range(num_properties)],
    "rent_price": [round(random.uniform(500, 8000),2) for _ in range(num_properties)],
    "property_tax": [round(random.uniform(500, 20000),2) for _ in range(num_properties)]
}

# 3. Location Info
location_data = {
    "address": [fake.street_address() for _ in range(num_properties)],
    "city": [fake.city() for _ in range(num_properties)],
    "state": [fake.state_abbr() for _ in range(num_properties)],
    "zip_code": [fake.zipcode() for _ in range(num_properties)],
    "latitude": [round(random.uniform(-90, 90),6) for _ in range(num_properties)],
    "longitude": [round(random.uniform(-180, 180),6) for _ in range(num_properties)]
}

# 4. Optional Features
features_data = {
    "has_pool": [random.choice([True, False]) for _ in range(num_properties)],
    "has_garage": [random.choice([True, False]) for _ in range(num_properties)],
    "has_garden": [random.choice([True, False]) for _ in range(num_properties)],
    "nearby_schools": [random.randint(0, 5) for _ in range(num_properties)],
    "walk_score": [random.randint(0, 100) for _ in range(num_properties)]
}

# 5. Combine All
data = {**property_data, **pricing_data, **location_data, **features_data}
df = pd.DataFrame(data)

# 6. Add Noise / Missing Values
for col in df.columns:
    df.loc[df.sample(frac=0.05).index, col] = np.nan  # 5% missing

# Shuffle rows
df = df.sample(frac=1).reset_index(drop=True)

# 7. Save Dataset
df.to_csv("synthetic_realestate_data.csv", index=False)
print("Synthetic real estate dataset generated: synthetic_realestate_data.csv")