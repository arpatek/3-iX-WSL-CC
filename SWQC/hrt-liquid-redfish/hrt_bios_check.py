#!/usr/bin/python3
"""
HRT liquid immersion BIOS setting dump and check.

Give this an IP, and it will check BIOS settings, read serial number, and
output files as <serial number>_BIOS_Settings.txt

usage: hrt_bios_check.py <ipmi ip address>

BIOS Attributes
/redfish/v1/Systems/Self/Bios

BIOS Attribute Registry
/redfish/v1/Registries/BiosAttributeRegistry.json

System Serial / Model and Network Boot Priority
/redfish/v1/Systems/Self

SMT > Enabled
AC Loss Control > Power On
SVM Mode > Enabled
Boot Mode > UEFI
Boot Option #1 > 25G NIC Port #1
Boot Option #2 > Hard disk
NUMA nodes per socket > NPS1
Console Redirection > Enabled
IPv6 BMC Lan IP Address Source > Dynamic-Obtained by BMC running DHCP

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


def get_serial_number(ip: str, header: dict[str, str]) -> str:
    """
    Get tagged system serial number.

    Args:
        ip: IPMI IP address
        header: Basic authentication header

    Returns:
        Serial number as string
    """
    url = f'https://{ip}/redfish/v1/Systems/Self'
    response = requests.get(url, headers=header, verify=False)
    if not response.ok:
        exit_bad_response('GET', url, response.status_code)
    serial_number = response.json()['SerialNumber']

    return serial_number


def get_bios_attributes(ip: str, header: dict[str, str]) -> dict[str, str]:
    """
    Get BIOS setting attributes.

    Args:
        ip: IPMI IP address
        header: Basic authentication header

    Returns:
        Dict of BIOS settings by attribute ID
    """
    url = f'https://{ip}/redfish/v1/Systems/Self/Bios'
    response = requests.get(url, headers=header, verify=False)
    if not response.ok:
        exit_bad_response('GET', url, response.status_code)
    bios_attributes = response.json()['Attributes']  # noqa: E501
    # bios_attributes.pop('MAPIDS')

    return bios_attributes


def get_bios_registry(ip: str, header: dict[str, str]) -> dict[str, str]:
    """
    Get BIOS settings attribute registry.

    Args:
        ip: IPMI IP address
        header: Basic authentication header

    Returns:
        Dict of BIOS attribute details
    """
    url = f'https://{ip}/redfish/v1/Registries/BiosAttributeRegistry.json'
    response = requests.get(url, headers=header, verify=False)
    if not response.ok:
        exit_bad_response('GET', url, response.status_code)
    attribute_registry = response.json()['RegistryEntries']['Attributes']

    return attribute_registry


def get_network_boot_order(ip: str, header: dict[str, str]) -> list[str]:
    """
    Get first network device to boot from.

    Args:
        ip: IPMI IP address
        header: Basic authentication header

    Returns:
        List of network devices in boot priority order
    """
    url = f'https://{ip}/redfish/v1/Systems/Self'
    response = requests.get(url, headers=header, verify=False)
    if not response.ok:
        exit_bad_response('GET', url, response.status_code)
    boot_id_order = response.json()['Boot']['BootOrder']

    # Look up the device name for this boot ID
    boot_order = []
    for boot_id in boot_id_order:
        suffix = boot_id[-4:]
        url = f'https://{ip}/redfish/v1/Systems/Self/BootOptions/{suffix}'
        response = requests.get(url, headers=header, verify=False)
        if not response.ok:
            exit_bad_response('GET', url, response.status_code)
        network_device = response.json()['DisplayName']
        boot_order.append(network_device)

    return boot_order


def rename_bios_settings(
    bios_attributes: dict[str, str],
    attribute_registry: dict[str, str],
) -> dict[str, str]:
    """
    Rename attribute keys to setting display names.

    Some display names overlap, so the new name is the attribute ID appended
    with an underscore and the display name.

    Args:
        bios_attributes: Dict of BIOS settings by attribute ID
        attribute_registry: Details of each attribute ID

    Returns:
        Dict of renamed attribute IDs to readable names
    """
    attribute_map = {}
    for attribute in attribute_registry:
        combined_name = (
            f"{attribute['AttributeName']}_{attribute['DisplayName']}"
        )
        attribute_map[attribute['AttributeName']] = combined_name

    bios_settings = {
        attribute_map.get(k, k): v for k, v in bios_attributes.items()
    }

    return bios_settings


def check_important_settings(
    ip: str,
    header: dict[str, str],
    bios_settings: dict[str, str],
    network_boot_order: list[str]
) -> bool:
    """
    Check if important BIOS settings have correct values.

    Args:
        ip: IPMI IP address
        header: Basic authentication header
        bios_settings: Dict of BIOS settings
        network_boot_order: Sorted list of network boot device order

    Returns:
        True if all important settings are correct, else false
    """
    important_settings = {
        'Milan0059_SMT Control': 'Enabled',
        'Milan0212_Ac Loss Control': 'Power On',
        'Milan0565_SVM Mode': 'Enabled',
        'FBO001_Boot mode select': 'UEFI',
        'FBO201_Boot Option #1': 'UEFI Network',
        'FBO202_Boot Option #2': 'UEFI Hard Disk',
        'Milan0075_NUMA nodes per socket': 'NPS1',
        'TER001_Console Redirection': True
    }
    for key, value in important_settings.items():
        if bios_settings.get(key, None) != value:
            print(f'{key}: {bios_settings[key]} is not correct!')
            return False

    if 'IPv4 Broadcom Network' not in network_boot_order[0]:
        print('The first network boot device is not correct!')
        print(network_boot_order[0])
        return False

    return True


if __name__ == '__main__':
    # Check for proper command line usage
    if len(sys.argv) != 2:
        print('usage: hrt_bios_check.py <ipmi ip address>')
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
    auth_header = {'Authorization': f'Basic {auth_base64}'}

    # Get and rename BIOS settings
    bios_attributes = get_bios_attributes(ipmi_ip, auth_header)
    attribute_registry = get_bios_registry(ipmi_ip, auth_header)
    bios_settings = rename_bios_settings(bios_attributes,  attribute_registry)

    # Get network device boot order
    network_boot_order = get_network_boot_order(ipmi_ip, auth_header)
    bios_settings['Network boot order'] = network_boot_order

    # Output pretty print JSON to file
    serial_number = get_serial_number(ipmi_ip, auth_header)
    with open(f'{serial_number}_BIOS_Settings.json', 'w') as json_file:
        json.dump(bios_settings, json_file, indent=4)
    print(f'BIOS Settings saved to {serial_number}_BIOS_Settings.json')

    pass_check = check_important_settings(ipmi_ip, auth_header,
                                          bios_settings, network_boot_order)

    if pass_check:
        print('PASSED')
    else:
        print('FAILED')
        sys.exit(1)
