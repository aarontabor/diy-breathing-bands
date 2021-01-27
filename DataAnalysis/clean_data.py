from collections import defaultdict
from csv import DictReader, DictWriter
import numpy as np
import re


PARTICIPANT_ID = 1

BREATHING_PHASES = {
	'natural': (50, 110),
	'deep': (210, 270),
	'medium': (360, 420),
	'shallow': (465, 525),
	'elevated': (630, 770)	
  }


DIY_AGGREGRATE_COLUMNS = 'participant group flex_chest flex_abdomen cord_chest cord_abdomen fabric_chest fabric_abdomen'.split()
BIO_AGGREGRATE_COLUMNS = 'therm'.split()

def main():
	diy_data = aggregrate_diy_data(PARTICIPANT_ID)
	bio_data = aggregrate_bio_data(PARTICIPANT_ID)

	data = combine_data(diy_data, bio_data)

	tag_breathing_phases(data)

	writer = DictWriter(open('p%d/p%d_data.csv' % (PARTICIPANT_ID, PARTICIPANT_ID), 'w+'), fieldnames = ['elapsed_time', 'phase'] + DIY_AGGREGRATE_COLUMNS + BIO_AGGREGRATE_COLUMNS)
	writer.writeheader()
	writer.writerows(data)


def aggregrate_diy_data(participant_id):

	# Step 1. Read Data
	reader = DictReader(open('p%d/p%d_diy.csv' % (participant_id, participant_id)))
	diy_data = [row for row in reader]

	# Step 2: Compute Elapsed Time
	start_time = int(diy_data[0]['tod'])
	for row in diy_data:
		row['elapsed_time'] = int(row['tod']) - start_time

	# Step 3: Remove Noisy Sensor Rows
	diy_data = [r for r in diy_data if not isNoisyDiyReading(r)]

	# Step 4: Aggregrate into 100 ms bins
	binned_data = defaultdict(list)
	for row in diy_data:
		key = row['elapsed_time'] // 100
		binned_data[key] += [row]

	aggregrated_data = []
	for key in sorted(binned_data.keys()):
		aggregrated_row = {'elapsed_time': key*100}
		for column in DIY_AGGREGRATE_COLUMNS:
			aggregrated_row[column] = np.mean([float(row[column]) for row in binned_data[key]])
		aggregrated_data += [aggregrated_row]

	return aggregrated_data

def isNoisyDiyReading(row):
	return int(row['flex_chest']) > 1000 or int(row['flex_abdomen']) > 1000 or int(row['cord_chest']) > 1000 or int(row['cord_abdomen']) > 1000 or int(row['fabric_chest']) > 1000 or int(row['fabric_abdomen']) > 1000

def aggregrate_bio_data(participant_id):

	# Step 1. Read Data
	reader = DictReader(open('p%d/p%d_bio.csv' % (participant_id, participant_id)))
	bio_data = [row for row in reader]

	# Step 2: Parse Elapsed Time
	for row in bio_data:
		time_strings = list(map(int, re.split('[:.]', row['Elapsed Time'])))
		if len(time_strings) == 4:
			time_millis = time_strings[3] + time_strings[2] * 1000 + time_strings[1] * 60000 + time_strings[0] * 3600000
		else:
			time_millis = time_strings[2] * 1000 + time_strings[1] * 60000 + time_strings[0] * 3600000
		row['elapsed_time'] = time_millis
		del(row['Elapsed Time'])

	'''
	# Step 3: Remove Noisy Readings
	clean_data = [bio_data[0]]
	last_good_index = 0
	for i, row in enumerate(bio_data):
		previous_reading = float(bio_data[last_good_index]['therm'])
		current_reading = float(bio_data[i]['therm'])
		if np.abs(current_reading - previous_reading) < 0.00004:
			clean_data += [bio_data[i]]
			last_good_index = i
	bio_data = clean_data
	'''

	# Step 4: Aggregrate into 100 ms bins
	binned_data = defaultdict(list)
	for row in bio_data:
		key = row['elapsed_time'] // 100
		binned_data[key] += [row]

	for key, rows in binned_data.items():
		m = np.mean([float(r['therm']) for r in rows])
		s = np.std([float(r['therm']) for r in rows])
		clean_rows = [r for r in rows if float(r['therm']) > m - 2*s]
		binned_data[key] = clean_rows

	aggregrated_data = []
	for key in sorted(binned_data.keys()):
		aggregrated_row = {'elapsed_time': key*100}
		for column in BIO_AGGREGRATE_COLUMNS:
			aggregrated_row[column] = np.mean([float(row[column]) for row in binned_data[key]])
		aggregrated_data += [aggregrated_row]

	return aggregrated_data

def combine_data(diy_data, bio_data):
	data = []
	diy_index = 0
	bio_index = 0

	while diy_index < len(diy_data) and bio_index < len(bio_data):
		while diy_index < len(diy_data) and diy_data[diy_index]['elapsed_time'] < bio_data[bio_index]['elapsed_time']:
			diy_index += 1
		
		if diy_index >= len(diy_data):
			break

		while bio_index < len(bio_data) and bio_data[bio_index]['elapsed_time'] < diy_data[diy_index]['elapsed_time']:
			bio_index += 1

		if bio_index >= len(bio_data):
			break

		diy_row = diy_data[diy_index]
		bio_row = bio_data[bio_index]
		
		diy_row['therm'] = bio_row['therm']
		data += [diy_row]

		diy_index += 1
		bio_index += 1

	return data

def tag_breathing_phases(data):
	for row in data:
		for phase, time_bound in BREATHING_PHASES.items():
			row['phase'] = 'none'
			if row['elapsed_time'] >= time_bound[0]*1000 and row['elapsed_time'] < time_bound[1]*1000:
				row['phase'] = phase
				break



if __name__ == '__main__':
	main()