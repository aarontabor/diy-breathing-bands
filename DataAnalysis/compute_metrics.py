from collections import defaultdict
from csv import DictReader, DictWriter

import numpy as np
import pandas as pd
import re

participant_id = 1

sensor_names = ['flex', 'cord', 'fabric']

def main():
	filename = 'p%d/p%d_data.csv' % (participant_id, participant_id)
	remove_none_phases(filename)
	normalize_readings(filename)
	aggregrate_chest_and_abdomen_readings(filename)
	compute_r_squared_error(filename)
	# compute_sliding_window_cpm(filename)

def remove_none_phases(filename):
	df = pd.read_csv(filename)
	df = df.loc[df['phase'] != 'none']
	df.to_csv(filename, index=False)

def normalize_readings(filename):
	df = pd.read_csv(filename)
	for name in sensor_names:
		for site in ['chest', 'abdomen']:
			min_val = min(df[name + '_' + site])
			max_val = max(df[name + '_' + site])
			df[name + '_' + site + '_norm'] = (df[name + '_' + site] - min_val) / (max_val - min_val)
	min_therm = min(df['therm'])
	max_therm = max(df['therm'])
	df['therm_norm'] = (df['therm'] - min_therm) / (max_therm - min_therm)
	df.to_csv(filename, index=False)

def aggregrate_chest_and_abdomen_readings(filename):
	df = pd.read_csv(filename)
	for name in sensor_names:
		df[name + '_norm'] = (df['%s_chest_norm' % name] + df['%s_abdomen_norm' % name]) / 2
	df.to_csv(filename, index=False)

def compute_r_squared_error(filename):
	df = pd.read_csv(filename)
	for name in sensor_names:
		df['%s_R' % name] = abs(df[name + '_norm'] - df['therm_norm'])
	df.to_csv(filename, index=False)

'''
def compute_sliding_window_cpm(filename):
	# Step 1: Open data file
	# Step 2: Read data into list
	# Step 3: Compute CPM at different time slices using SciPy find_peaks()
	# Step 4: Write back to a new file
'''


if __name__ == '__main__':
	main()