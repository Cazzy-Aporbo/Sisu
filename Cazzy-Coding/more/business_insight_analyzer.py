"""
Business Insight Analyzer
Author: Cazzy
Purpose: Analyze structured business data to generate actionable insights, detect anomalies, and visualize trends.
This program is designed to showcase mastery of software engineering, data analysis, and reporting.
"""

# Standard libraries for data handling
import csv
import json
import math
from datetime import datetime
from collections import defaultdict

# Optional visualization
try:
    import matplotlib.pyplot as plotter
except ImportError:
    plotter = None

# =========================
# Section 1: Input Processing
# =========================

def load_csv_data(file_path):
    """
    Load CSV data into a list of dictionaries.
    
    Arguments:
    file_path : str : path to CSV file
    
    Returns:
    data_records : list[dict] : list of rows as dictionaries
    """
    data_records = []
    with open(file_path, mode='r', encoding='utf-8') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            data_records.append(row)
    return data_records

def load_json_data(file_path):
    """
    Load JSON data into a Python dictionary.
    
    Arguments:
    file_path : str : path to JSON file
    
    Returns:
    data : dict or list : JSON content
    """
    with open(file_path, mode='r', encoding='utf-8') as json_file:
        data = json.load(json_file)
    return data

# =========================
# Section 2: Metrics Calculation
# =========================

def calculate_average(values):
    """
    Compute the arithmetic mean of a list of numerical values.
    
    Arguments:
    values : list[float] : numeric values
    
    Returns:
    mean_value : float
    """
    if not values:
        return 0.0
    total_sum = sum(values)
    count = len(values)
    mean_value = total_sum / count
    return mean_value

def detect_anomalies(values, sensitivity_factor=2.0):
    """
    Detect anomalies in a dataset using standard deviation thresholding.
    
    Arguments:
    values : list[float] : numeric values
    sensitivity_factor : float : how many standard deviations from mean to flag
    
    Returns:
    anomalies : list[tuple(index, value)] : flagged outliers
    """
    if not values:
        return []
    mean_value = calculate_average(values)
    variance_sum = sum((value - mean_value) ** 2 for value in values)
    standard_deviation = math.sqrt(variance_sum / len(values))
    threshold_upper = mean_value + sensitivity_factor * standard_deviation
    threshold_lower = mean_value - sensitivity_factor * standard_deviation
    anomalies = [(index, value) for index, value in enumerate(values) if value > threshold_upper or value < threshold_lower]
    return anomalies

# =========================
# Section 3: Business Insights Generator
# =========================

def generate_summary_report(metric_name, values):
    """
    Produce a textual summary for a metric including average, extremes, and anomalies.
    
    Arguments:
    metric_name : str : descriptive name of metric
    values : list[float] : data values
    
    Returns:
    report_text : str : human-readable summary
    """
    if not values:
        return f"No data available for metric '{metric_name}'."
    average_value = calculate_average(values)
    minimum_value = min(values)
    maximum_value = max(values)
    anomalies = detect_anomalies(values)
    report_text = f"Metric '{metric_name}' Analysis:\n"
    report_text += f"  Average Value : {average_value:.2f}\n"
    report_text += f"  Minimum Value : {minimum_value:.2f}\n"
    report_text += f"  Maximum Value : {maximum_value:.2f}\n"
    if anomalies:
        report_text += f"  Detected Anomalies at indices: {', '.join(str(idx) for idx, _ in anomalies)}\n"
    else:
        report_text += "  No significant anomalies detected.\n"
    return report_text

# =========================
# Section 4: Visualization (Optional)
# =========================

def plot_metric(values, metric_name):
    """
    Visualize a metric with a line plot. Requires matplotlib.
    
    Arguments:
    values : list[float] : numeric values
    metric_name : str : descriptive name
    """
    if not plotter:
        print("Plotting skipped. Matplotlib not installed.")
        return
    plotter.figure(figsize=(10, 4))
    plotter.plot(values, marker='o', linestyle='-', color='blue')
    plotter.title(f"{metric_name} Trend Over Time")
    plotter.xlabel("Record Index")
    plotter.ylabel(metric_name)
    plotter.grid(True)
    plotter.show()

# =========================
# Section 5: Main Execution
# =========================

def main():
    """
    Main execution sequence: loads data, computes insights, prints summary, optionally plots.
    """
    # Example: using a CSV with numeric column 'Revenue'
    try:
        business_data = load_csv_data("business_metrics.csv")
        revenue_values = [float(record["Revenue"]) for record in business_data if "Revenue" in record]
        summary_text = generate_summary_report("Revenue", revenue_values)
        print(summary_text)
        plot_metric(revenue_values, "Revenue")
    except FileNotFoundError:
        print("business_metrics.csv not found. Replace with your data file.")
    except Exception as error:
        print(f"Unexpected error occurred: {error}")

# Run the program
if __name__ == "__main__":
    main()