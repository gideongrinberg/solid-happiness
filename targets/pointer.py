import sys
import pandas as pd
from astropy.coordinates import SkyCoord
from tesswcs.locate import get_pixel_locations

df = pd.read_csv(sys.argv[1], names=["ID", "ra", "dec"])

stars_df = df[["ID", "ra", "dec"]]
stars_df["sky_coord"] = SkyCoord(
    ra=stars_df["ra"], dec=stars_df["dec"], frame="icrs", unit="deg"
)

obs_df = get_pixel_locations(list(stars_df["sky_coord"])).to_pandas()

results_df = pd.merge(stars_df, obs_df, left_index=True, right_on='Target Index')
results_df = results_df.drop(columns=["Target Index", "sky_coord"])
results_df.to_csv(sys.argv[2], header=False, index=False)