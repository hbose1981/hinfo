# File: chef_client/role.py
from .base import ChefAPIBase

class RoleAPI(ChefAPIBase):
    def list(self):
        return self._request("GET", "/roles")

    def get(self, role_name):
        return self._request("GET", f"/roles/{role_name}")

    def create(self, role_data):
        return self._request("POST", "/roles", role_data)

    def update(self, role_name, role_data):
        return self._request("PUT", f"/roles/{role_name}", role_data)

    def delete(self, role_name):
        return self._request("DELETE", f"/roles/{role_name}")

    def role_env_run_list(self, role_name):
        return self._request("GET", f"/roles/{role_name}/environments")

    def env_run_list_for_role(self, role_name, environment):
        return self._request("GET", f"/roles/{role_name}/environments/{environment}")

    def set_env_run_list_for_role(self, role_name, environment, run_list):
        return self._request("PUT", f"/roles/{role_name}/environments/{environment}", {"run_list": run_list})
