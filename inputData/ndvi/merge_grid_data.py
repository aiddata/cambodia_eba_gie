
## set this to the directory you have the grid files stored in. These files aren't stored in Box because they are too large
my_dir = "/Users/christianbaehr/Downloads"

import pandas as pd

ndvi = pd.read_csv(my_dir + "/ndvi_grid_cambodia.csv")

covars = pd.read_csv(my_dir + "/plantation-concession_cambodia.csv")
covars = covars.drop(columns=["latitude", "longitude", "wdpa_pre2001_sea.na.count", "concessions_subset.na.count", "concessions_subset.na.count", "NAME_0"])

treatment = pd.read_csv(my_dir + "/cambodia_treatment.csv")
treatment = treatment.drop(columns=["latitude", "longitude"])
treatment.columns = "trt" + treatment.columns

adm = pd.read_csv(my_dir + "/full_adm_data.csv")
adm = adm.drop(columns=["lat", "lon"])

pre_panel = pd.concat(objs = [adm, ndvi, treatment, covars], axis = 1)

del adm
del ndvi
del covars
del treatment

pre_panel = pre_panel.assign(cell_id = list(range(1, 88148314)))

grid_cell_coords = pre_panel[['cell_id', 'latitude', 'longitude']]
grid_cell_coords.to_csv(my_dir + "/grid_cell_coords.csv", index=False)

del grid_cell_coords

pre_panel = pre_panel.drop(['latitude', 'longitude'], axis=1)
pre_panel.to_csv(my_dir + "/pre_panel.csv", index=False)

# test_panel = pre_panel.sample(n=100)
# test_panel.to_csv(path_or_buf = my_dir + "/test_panel.csv", index=False)

