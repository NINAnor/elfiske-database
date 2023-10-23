#!/usr/bin/env python3

import logging
import os
from urllib.parse import parse_qs, urlparse
import io

import requests
from pywebio import start_server
from pywebio.input import actions, file_upload, input, input_group, NUMBER
from pywebio.output import clear, put_error, put_link, put_success, put_text, use_scope
import openpyxl
import orjson

logging.basicConfig(level=os.getenv("LOGGING", "INFO"))

POSTGREST_URL = os.getenv("POSTGREST_URL", "http://localhost:3000")
POSTGREST_TOKEN = os.getenv("POSTGREST_TOKEN")

logging.debug(os.environ)

ALLOWED_SHEETS = {
    "Admin og Driftsopplysninger": {
        'name': 'metadata',
        'ignore': 1,
    },
    "Stasjoner og feltskjema": {
        'name': 'stasjoner',
        'ignore': 1,
    },
    "Enkeltfisk": {
        'name': 'enkeltfisk',
        'ignore': 0,
    },
}

def preprocess_file(file):
    workbook = openpyxl.load_workbook(io.BytesIO(file['content']), data_only=True)
    put_text(f"Preparing to import {file['filename']}...")

    data = {
        "filename": file['filename'],
    }

    for sheet_name in (ALLOWED_SHEETS.keys()):
        config = ALLOWED_SHEETS[sheet_name]
        data[config["name"]] = []
        rows = workbook[sheet_name].iter_rows()
        for _ in range(config['ignore']):
            next(rows)
        header = [cell.value for cell in next(rows)]
        for row in rows:
            row = [cell.value for cell in row]
            # logging.debug(row)
            if not any(row):
                continue
            data[config["name"]].append(dict(zip(header, row)))

    return data


def wizard():
    user_inputs = input_group(
        "Import", [
            file_upload("Select spreadsheets:", multiple=True, name="files"),
        ]
    )

    for file in user_inputs["files"]:
        data = preprocess_file(file)
        put_text("Importing...")
        try:
            url = POSTGREST_URL + "/rpc/import_data" 
            headers = {"Content-Type": "application/json", "Prefer": "params=single-object"}
            
            if POSTGREST_TOKEN:
                headers["Authorization"] = "Bearer " + POSTGREST_TOKEN

            response = requests.post(
                url,
                headers=headers,
                data=orjson.dumps(data),
            )
            logging.debug(response.text)
            response.raise_for_status()
        except Exception as instance:
            put_error(str(instance) + "\n" + response.text)
        else:
            put_success(f"{file['filename']} has been imported sucessfully.")

    put_success("Done!")

if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
