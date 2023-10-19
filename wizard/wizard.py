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
    'L_RedskapID': {
        'name': 'redscaper',
        'ignore': 0,
        'mappings': {
            'Redskap': 'navn', 
            'RedskapID': 'id',
        },
        'conflict': {
            'resolution': 'ignore-duplicates',
        }
    },
}


def wizard():
    user_inputs = input_group(
        "Import", [
            file_upload("Select spreadsheets:", multiple=True, name="files"),
        ]
    )

    workbooks = []
    for index, file in enumerate(user_inputs["files"]):
        workbooks.append(openpyxl.load_workbook(io.BytesIO(file['content']), data_only=True))

    for sheet_name in (ALLOWED_SHEETS.keys()):
        data = []
        config = ALLOWED_SHEETS[sheet_name]
        put_text(f"Preparing to import {sheet_name}...")
        for workbook in workbooks:
            rows = workbook[sheet_name].iter_rows()
            for _ in range(config['ignore']):
                next(rows)
            header = [config['mappings'][cell.value] if cell.value in config['mappings'] else cell.value for cell in next(rows)]
            for row in rows:
                row = [cell.value for cell in row]
                # logging.debug(row)
                if not any(row):
                    continue
                data.append(dict(zip(header, row)))

        logging.debug(data)

        put_text(
            f"{sheet_name} have loaded."
        )

        actions(
            buttons=[{"label": "Import", "value": "import", "color": "primary"}]
        )
        clear("import")
        put_text("Importing...")
        try:
            url = POSTGREST_URL + "/" + config['name']
            headers = {"Content-Type": "application/json"}
            if 'conflict' in config:
                if 'field' in config['conflict']:
                    url += f"?on_conflict={config['conflict']['field']}"
                
                headers["Prefer"] = f"resolution={config['conflict']['resolution']}"

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
            put_success("Data has been imported sucessfully.")

if __name__ == "__main__":
    start_server(wizard, port=8000, debug=True)
