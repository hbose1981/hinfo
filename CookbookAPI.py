# File: chef_client/cookbook.py
from .base import ChefAPIBase

class CookbookAPI(ChefAPIBase):
    def list(self):
        return self._request("GET", "/cookbooks")

    def get(self, name, version="_latest"):
        return self._request("GET", f"/cookbooks/{name}/{version}")

    def delete(self, name, version=None):
        if version:
            return self._request("DELETE", f"/cookbooks/{name}/{version}")
        else:
            versions = self.list().get(name, {}).get("versions", [])
            results = []
            for v in versions:
                path = v['url'].split('/cookbooks')[-1]
                results.append(self._request("DELETE", f"/cookbooks{path}"))
            return results
