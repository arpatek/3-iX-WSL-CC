#!/usr/bin/python3
"""
HRT liquid immersion BIOS import.

Give this an IP, and it will import the correct BIOS settings. A second import
is also done to fix the network boot priority order because it is unique and
separate from the normal BIOS stuff.

usage: hrt_bios_import.py <ipmi ip address>

BIOS Staged Changes
/redfish/v1/Systems/Self/Bios/SD

Network Boot Priority
/redfish/v1/Systems/Self

BIOS Settings
SMT > Enabled
AC Loss Control > Power On
SVM Mode > Enabled
Boot Mode > UEFI
Boot Option #1 > 25G NIC Port #1
Boot Option #2 > Hard disk
NUMA nodes per socket > NPS1
Console Redirection > Enabled
IPv6 BMC Lan IP Address Source > Dynamic-Obtained by BMC running DHCP

Network Boot Order
UEFI: PXE IPv4 Broadcom Network
UEFI: PXE IPv4 Broadcom Network
UEFI: PXE IPv4 Intel(R) Network
UEFI: PXE IPv4 Intel(R) Network
UEFI: PXE IPv6 Broadcom Network
UEFI: PXE IPv6 Broadcom Network
UEFI: PXE IPv6 Intel(R) Network
UEFI: PXE IPv6 Intel(R) Network
UEFI: Built-in EFI Shell

Authors: Jason Zhao <jzhao@ixsystems.com>
"""
from base64 import b64encode
import json
import re
import sys

import requests
import urllib3

IPMI_USER = 'admin'
IPMI_PASS = 'password'
BIOS_IMPORT_PATH = 'HRT_Liquid_BIOS_Import.json'
NETWORK_BOOT_IMPORT_PATH = 'HRT_Liquid_Network_Boot_Import.json'


def exit_bad_response(method: str, url: str, status_code: int):
    """
    Get tagged system serial number.

    Args:
        method: HTTP method
        url: API URL
        int: Returned status code
    """
    print(f'{method} {url}')
    print(f'FAIL: Returned {status_code}')
    sys.exit(1)


def import_bios_settings(ip: str, header: dict[str, str]):
    """
    Patch BIOS settings with a golden image.

    Args:
        ip: IPMI IP address
        header: Basic authentication header
    """
    with open(BIOS_IMPORT_PATH, 'r') as json_file:
        bios_settings = json.load(json_file)

    url = f'https://{ip}/redfish/v1/Systems/Self/Bios/SD'
    response = requests.patch(url, headers=header, json=bios_settings,
                              verify=False)
    if not response.ok:
        exit_bad_response('PATCH', url, response.status_code)


def import_network_boot(ip: str, header: dict[str, str]):
    """
    Patch network boot order from golden image.

    Args:
        ip: IPMI IP address
        header: Basic authentication header
    """
    with open(NETWORK_BOOT_IMPORT_PATH, 'r') as json_file:
        network_boot = json.load(json_file)

    url = f'https://{ip}/redfish/v1/Systems/Self'
    response = requests.patch(url, headers=header, json=network_boot,
                              verify=False)
    if not response.ok:
        exit_bad_response('PATCH', url, response.status_code)


if __name__ == '__main__':
    # Check for proper command line usage
    if len(sys.argv) != 2:
        print('usage: hrt_bios_import.py <ipmi ip address>')
        sys.exit(1)

    # Check for proper IP argument
    ipmi_ip = sys.argv[1].strip()
    if re.match(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$', ipmi_ip) is None:
        print(f'{sys.argv[1]} is not a valid IP address')
        sys.exit(1)

    # Disable no SSL certificate warnings because IPMI shenanigans
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    # Setup basic authentication HTTP header
    auth_string = f'{IPMI_USER}:{IPMI_PASS}'
    auth_base64 = b64encode(auth_string.encode('ascii')).decode('ascii')
    auth_header = {
        'Authorization': f'Basic {auth_base64}',
        'If-Match': '*'
    }

    # Import BIOS settings and network boot order
    import_bios_settings(ipmi_ip, auth_header)
    import_network_boot(ipmi_ip, auth_header)

    print('Done! The system needs a reboot to save BIOS settings properly.')
