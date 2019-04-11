

import csv
import os
import rasterio
import pandas as pd
import time
os.chdir("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/ndvi")
raster_dir = os.listdir("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/ndvi/3km_ndvi")
raster_dir = raster_dir[1:]
my_rasters = {}
for i in list(range(0, 20)):
	my_path = str("3km_ndvi/" + raster_dir[i])
	my_rasters[i] = rasterio.open(my_path)

extract_dataset = open("/Users/christianbaehr/Desktop/full_grid.csv", "w")
extract_csvwriter = csv.DictWriter(extract_dataset, delimiter=str(","), fieldnames=list(range(0, 22)))
extract_csvwriter.writeheader()
ndvi = pd.read_csv("/users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/ndvi/empty_grid.csv", nrows=1000)
count1 = 0

for i in list(range(0, 88148314)):
	if (i % 1000 == 0 and i!=0):
		extract_dataset.close()
		extract_dataset = open("/Users/christianbaehr/Desktop/full_grid.csv", "a")
		extract_csvwriter = csv.DictWriter(extract_dataset, delimiter=str(","), fieldnames=list(range(0, 22)))
		ndvi = pd.read_csv("/users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/ndvi/empty_grid.csv", skiprows=i, nrows=1000)
		count1 = 0
		print(i)
	if (i == 88148314 - (88148314%1000)):
		extract_dataset.close()
		extract_dataset = open("/Users/christianbaehr/Desktop/full_grid.csv", "a")
		ndvi = pd.read_csv("/users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/ndvi/empty_grid.csv", skiprows=i, nrows=(88148314%1000))
		count1 = 0
	x = ndvi.iloc[count1, 0]
	y = ndvi.iloc[count1, 1]
	out_vec = {}
	out_vec[0] = x
	out_vec[1] = y
	for j in list(range(0, 20)):
		my_path = my_rasters[j]
		out_vec[j+2] = float(list(my_path.sample( [ (x, y) ] ))[0])
	extract_csvwriter.writerow(out_vec)
	count1 = count1+1

















