

import os
import json
import math
import itertools
import fiona
import numpy as np
from shapely.geometry import shape, Point
from shapely.prepared import prep

import pandas as pd

from datetime import datetime



# -----------------------------------------------------------------------------


polygon_path = os.path.expanduser(
    "~/Documents/cambodia_grid/3km_buffer.geojson")

output_path = os.path.expanduser(
        "~/Documents/cambodia_grid/output.csv")

pixel_size = 0.0002695

polygon_data = fiona.open(polygon_path, 'r')


# -----------------------------------------------------------------------------


feature_list = []

canal_feature = polygon_data[0]

canal_id = canal_feature['properties']['VILL_CODE']
canal_shape = shape(canal_feature['geometry'])
prep_feat = prep(canal_shape)

# print "Running {0}".format(canal_id)
bounds = canal_shape.bounds
xmin, ymin, xmax, ymax = bounds
adj_xmin = math.floor((xmin - -180) / pixel_size) * pixel_size + -180
adj_ymin = math.floor((ymin - -90) / pixel_size) * pixel_size + -90
adj_xmax = math.ceil((xmax - -180) / pixel_size) * pixel_size + -180
adj_ymax = math.ceil((ymax - -90) / pixel_size) * pixel_size + -90
adj_bounds = (adj_xmin, adj_ymin, adj_xmax, adj_ymax)
x_count = (adj_xmax-adj_xmin)/pixel_size
if x_count < round(x_count):
    adj_xmax += pixel_size
y_count = (adj_ymax-adj_ymin)/pixel_size
if y_count < round(y_count):
    adj_ymax += pixel_size
coords = itertools.product(
    np.arange(adj_xmin, adj_xmax, pixel_size),
    np.arange(adj_ymin, adj_ymax, pixel_size))

# coords = list(coords)[:20]


point_list = map(Point, coords)

# [
#     {
#         "longitude": c[0],
#         "latitude": c[1],
#         "unique": "{0}_{1}".format(round(c[0], 9), round(c[1], 9))
#     }
#     for c in coords
# ]

point_list_country = filter(prep_feat.contains, point_list)

df_list = [{"longitude": i.x, "latitude": i.y} for i in point_list_country]
df = pd.Dataframe(df_list)


df.to_csv(output_path, index=False, encoding='utf-8')
