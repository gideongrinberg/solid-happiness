import os
import pandas as pd

LIST_PATH = "./output/lists"

def mkdir(dir):
    try:
        os.mkdir(dir)
    except:
        pass

mkdir("./output")
mkdir(LIST_PATH)
for p in ["qlp", "tglc", "spoc_2m", "spoc_20s"]:
    mkdir(LIST_PATH + "/" + p)

def _make_download_cmd(product, sector):
    return f"aria2c -d ./lightcurves/{product}/s{str(sector).zfill(4)} -i ./lists/{product}/{str(sector).zfill(4)}.txt -j 20 --max-connection-per-server=1"

def make_qlp_script(data, sector):
    data = data[(data["product"] == "QLP") & (data["sector"] == sector)]
    data["ID_str"] = data["ID"].astype(str).str.zfill(16)
    data["sector_str"] = data["sector"].astype(str).str.zfill(4)

    # Slice the ID string into 4-digit chunks
    data["id1"] = data["ID_str"].str.slice(0, 4)
    data["id2"] = data["ID_str"].str.slice(4, 8)
    data["id3"] = data["ID_str"].str.slice(8, 12)
    data["id4"] = data["ID_str"].str.slice(12, 16)

    # Make url
    base_url = "https://mast.stsci.edu/api/v0.1/Download/file/?uri="
    data["url"] = (
        base_url
        + "mast:HLSP/qlp/s"
        + data["sector_str"]
        + "/"
        + data["id1"]
        + "/"
        + data["id2"]
        + "/"
        + data["id3"]
        + "/"
        + data["id4"]
        + "/hlsp_qlp_tess_ffi_s"
        + data["sector_str"]
        + "-"
        + data["ID_str"]
        + "_tess_v01_llc.fits"
    )

    with open(f"{LIST_PATH}/qlp/s{str(sector).zfill(4)}.txt", "w") as f:
        for url in list(data["url"]):
            f.write(url + "\n")

    with open("./output/download_qlp.sh", "w+") as f:
        f.write(_make_download_cmd("qlp", sector))


df = pd.read_parquet("./targets/data/output.parquet")
make_qlp_script(df, 1)

df[(df["product"] == "QLP") & (df["sector"] == 1)]
