#!/usr/bin/env python3

import importlib.machinery
import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest import mock


SCRIPT = Path(__file__).parents[1] / "chezmoi/bin/executable_tailscale-lan-bypass"
LOADER = importlib.machinery.SourceFileLoader("tailscale_lan_bypass", str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
MODULE = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(MODULE)


class RouteDetectionTest(unittest.TestCase):
    def test_finds_local_subnet_inside_broader_tailscale_route(self):
        rows = {
            (4, "main"): [
                {"dst": "192.168.131.0/24", "dev": "eth0",
                 "protocol": "kernel", "scope": "link"},
            ],
            (4, "52"): [
                {"dst": "192.168.0.0/16", "dev": "tailscale0"},
            ],
            (6, "main"): [],
            (6, "52"): [],
        }
        with mock.patch.object(MODULE, "route_rows",
                               side_effect=lambda _, family, table: rows[(family, table)]):
            self.assertEqual(
                MODULE.overlapping_lans("ip", None, {}),
                [(4, "192.168.131.0/24")],
            )

    def test_ignores_non_overlapping_and_non_kernel_routes(self):
        rows = {
            (4, "main"): [
                {"dst": "192.168.131.0/24", "dev": "eth0",
                 "protocol": "kernel", "scope": "link"},
                {"dst": "10.0.0.0/8", "dev": "eth0",
                 "protocol": "static", "scope": "link"},
                {"dst": "100.64.0.0/10", "dev": "tailscale0",
                 "protocol": "kernel", "scope": "link"},
            ],
            (4, "52"): [
                {"dst": "172.16.0.0/12", "dev": "tailscale0"},
            ],
            (6, "main"): [],
            (6, "52"): [],
        }
        with mock.patch.object(MODULE, "route_rows",
                               side_effect=lambda _, family, table: rows[(family, table)]):
            self.assertEqual(MODULE.overlapping_lans("ip", None, {}), [])

    def test_supports_ipv6_overlap(self):
        rows = {
            (4, "main"): [],
            (4, "52"): [],
            (6, "main"): [
                {"dst": "fd00:0:0:131::/64", "dev": "eth0",
                 "protocol": "kernel"},
            ],
            (6, "52"): [
                {"dst": "fd00::/48", "dev": "tailscale0"},
            ],
        }
        with mock.patch.object(MODULE, "route_rows",
                               side_effect=lambda _, family, table: rows[(family, table)]):
            self.assertEqual(
                MODULE.overlapping_lans("ip", None, {}),
                [(6, "fd00:0:0:131::/64")],
            )

    def test_falls_back_to_legacy_ifconfig_and_primary_routes(self):
        ifconfig_output = """eth0      Link encap:Ethernet
          inet addr:192.168.131.20  Bcast:192.168.131.255  Mask:255.255.255.0
          inet6 addr: fd00:0:0:131::20/64 Scope:Global
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
"""
        status = {
            "Peer": {
                "peer-key": {
                    "PrimaryRoutes": ["192.168.0.0/16", "fd00::/48"],
                },
            },
        }
        result = mock.Mock(stdout=ifconfig_output)
        with mock.patch.object(MODULE, "connected_networks",
                               side_effect=subprocess.CalledProcessError(1, ["ip"])), \
             mock.patch.object(MODULE, "tailscale_networks",
                               side_effect=subprocess.CalledProcessError(1, ["ip"])), \
             mock.patch.object(MODULE, "run", return_value=result):
            self.assertEqual(
                MODULE.overlapping_lans("ip", "ifconfig", status),
                [(4, "192.168.131.0/24"), (6, "fd00:0:0:131::/64")],
            )


class RuleOwnershipTest(unittest.TestCase):
    def test_does_not_claim_an_existing_manual_rule(self):
        desired = {(4, "192.168.131.0/24")}
        with mock.patch.object(MODULE, "read_state", return_value=set()), \
             mock.patch.object(MODULE, "existing_rules",
                               return_value={"192.168.131.0/24"}), \
             mock.patch.object(MODULE, "write_state") as write_state, \
             mock.patch.object(MODULE, "run") as run:
            MODULE.apply_rules("ip", desired, dry_run=False)

        run.assert_not_called()
        write_state.assert_called_once_with(set())


if __name__ == "__main__":
    unittest.main()
