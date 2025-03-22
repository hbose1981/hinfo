# File: chef_client/base.py
import requests
import hashlib
import base64
import time
import uuid
import json
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding


class ChefAPIBase:
    def __init__(self, server_url, client_name, key_path, organization):
        self.server_url = server_url.rstrip('/')
        self.client_name = client_name
        self.organization = organization
        with open(key_path, 'rb') as key_file:
            self.private_key = serialization.load_pem_private_key(
                key_file.read(),
                password=None,
            )

    def _sign_request(self, method, path, body=''):
        hashed_body = base64.b64encode(hashlib.sha1(body.encode()).digest()).decode()
        timestamp = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
        user_id = self.client_name
        hashed_path = base64.b64encode(hashlib.sha1(path.encode()).digest()).decode()

        canonical = (
            f"Method:{method.upper()}\n"
            f"Hashed Path:{hashed_path}\n"
            f"X-Ops-Content-Hash:{hashed_body}\n"
            f"X-Ops-Timestamp:{timestamp}\n"
            f"X-Ops-UserId:{user_id}"
        )

        signature = self.private_key.sign(
            canonical.encode(),
            padding.PKCS1v15(),
            hashes.SHA1()
        )

        encoded_sig = base64.b64encode(signature).decode()
        headers = {
            'X-Ops-Sign': 'algorithm=sha1;version=1.0',
            'X-Ops-UserId': user_id,
            'X-Ops-Timestamp': timestamp,
            'X-Ops-Content-Hash': hashed_body,
        }

        for i, line in enumerate([encoded_sig[i:i + 60] for i in range(0, len(encoded_sig), 60)]):
            headers[f'X-Ops-Authorization-{i + 1}'] = line

        return headers

    def _request(self, method, endpoint, data=None):
        path = f"/organizations/{self.organization}{endpoint}"
        url = f"{self.server_url}{path}"
        body = json.dumps(data) if data else ''
        headers = self._sign_request(method, path, body)
        headers['Content-Type'] = 'application/json'
        response = requests.request(method, url, headers=headers, data=body)

        if not response.ok:
            raise Exception(f"Error {response.status_code}: {response.text}")
        return response.json() if response.content else {}
