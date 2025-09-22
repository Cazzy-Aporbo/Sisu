import pandas as pd
import numpy as np
import random
import faker
from datetime import datetime, timedelta

fake = faker.Faker()
num_properties = 200  # Fewer for time-series; multiply rows with dates
num_months = 24       # Simulate 2 years of monthly data

properties = []

# Generate property base info
for i in range(num_properties):
    property_id = f"PROP{random.randint(100000,999999)}"
    prop_type = random.choice(["House", "Apartment", "Condo", "Townhouse"])
    bedrooms = random.randint(1, 6)
    bathrooms = round(random.uniform(1, 4),1)
    area_sqft = round(random.uniform(500, 5000),1)
    year_built = random.randint(1950, 2025)
    address = fake.street_address()
    city = fake.city()
    state = fake.state_abbr()
    zip_code = fake.zipcode()
    latitude = round(random.uniform(-90, 90),6)
    longitude = round(random.uniform(-180, 180),6)
    has_pool = random.choice([True, False])
    has_garage = random.choice([True, False])
    has_garden = random.choice([True, False])
    nearby_schools = random.randint(0,5)
    walk_score = random.randint(0,100)
    
    # Base price and rent
    base_price = round(random.uniform(100000, 2000000),2)
    base_rent = round(random.uniform(500, 8000),2)
    
    # Generate monthly history
    for month in range(num_months):
        date = (datetime.today() - timedelta(days=30*(num_months-month))).date()
        # Simulate price trend with small random fluctuations
        price_trend = base_price * (1 + random.uniform(-0.02,0.02)*month)
        rent_trend = base_rent * (1 + random.uniform(-0.01,0.01)*month)
        property_tax = price_trend * 0.012  # Example: 1.2% property tax
        
        properties.append({
            "property_id": property_id,
            "date": date,
            "property_type": prop_type,
            "bedrooms": bedrooms,
            "bathrooms": bathrooms,
            "area_sqft": area_sqft,
            "year_built": year_built,
            "address": address,
            "city": city,
            "state": state,
            "zip_code": zip_code,
            "latitude": latitude,
            "longitude": longitude,
            "has_pool": has_pool,
            "has_garage": has_garage,
            "has_garden": has_garden,
            "nearby_schools": nearby_schools,
            "walk_score": walk_score,
            "listing_price": round(price_trend,2),
            "rent_price": round(rent_trend,2),
            "property_tax": round(property_tax,2)
        })

# Create DataFrame
df = pd.DataFrame(properties)

# Optional: add 5% missing values randomly
for col in df.columns:
    df.loc[df.sample(frac=0.05).index, col] = np.nan

# Shuffle rows
df = df.sample(frac=1).reset_index(drop=True)

# Save to CSV
df.to_csv("synthetic_realestate_timeseries.csv", index=False)
print("Synthetic real estate time-series dataset generated: synthetic_realestate_timeseries.csv")