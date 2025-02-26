#! /usr/bin/env bash

chmod +x ./1_get_observability.sh
chmod +x ./2a_download_hlsp_lists.sh
chmod +x ./2b_download_spoc_lists.sh

./1_get_observability.sh
./2a_download_hlsp_lists.sh
./2b_download_spoc_lists.sh

duckdb -c ".read query.sql"