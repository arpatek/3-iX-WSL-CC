# HRT Liquid Immersion Redfish Scripts
Python scripts that interact with Redfish to work with HRT liquid immersion (order 49501D) systems. See Redfish brief below for info on how to write your own scripts to interact with Redfish. Shell scripts are not entirely recommended due to no native support for JSON processing.

Requirements
- Software: python3
- Python libraries: requests

## BIOS Import
Import BIOS settings and network boot order to a system via Redfish. After import success, the system needs a reboot to save the new BIOS changes, which will automatically reboot again once they are saved. Network boot order is unique to each system because it depends on number and types of PCI devices. This is why the settings are a separate file from the BIOS settings file. All HRT liquid systems should have the same build so the network boot order should be static. 

**Warning:** A fresh system that has never been fully booted through is not aware of all network devices. This means that BMC and Redfish will not know how to deal with network boot order, causing the import for network boot order to fail. Duc is manually configuring BIOS because it'll be faster for him rather than using this import script.

Requirements
- Files: hrt_bios_import.py, HRT_Liquid_BIOS_Import.json, HRT_Liquid_Network_Boot_Import.json

`Usage: hrt_bios_import.py <IPMI IP>`

Window usage example
```
C:\HRT-Liquid-Redfish>py hrt_bios_import.py 10.48.123.123
```
Linux usage example
```
~/HRT-Liquid-Redfish$ python3 hrt_bios_import.py 10.48.123.123
```

On success
```
Done! The system needs a reboot to save BIOS settings properly.
```
On fail (example)
```
PATCH /redfish/v1/Systems/Self/Bios/SD
FAIL: Returned 404
```

## BIOS Export + Check
Export BIOS settings and network boot order from a system via Redfish. Also check if important BIOS settings are correct. See top comment of hrt_bios_check.py for exact checks.

Requirements
- Files: hrt_bios_check.py

`Usage: hrt_bios_check.py <IPMI IP>`

Window usage example
```
C:\HRT-Liquid-Redfish>py hrt_bios_check.py 10.48.123.123
```
Linux usage example
```
~/HRT-Liquid-Redfish$ python3 hrt_bios_check.py 10.48.123.123
```
This script outputs a new file in same directory with format
`<System Serial Number>_BIOS_Settings.json`

On success
```
PASSED
```
On fail (example)
```
TER001_Console Redirection: False is not correct!
FAILED
```

## Golden Image
There are 2 golden image files. HRT_Liquid_BIOS_Golden.json is the raw Attributes object pulled from Redfish. This uses attribute IDs specific to this Gigabyte motherboard and is not nicely readable for humans. 

HRT_Liquid_BIOS_Golden_Readable.json takes the first file and appends readable BIOS setting names onto each attribute ID. hrt_bios_check.py outputs JSON with readable names, and also adds on the network boot order.

# Redfish Brief
## API URL Summary 
| Method | URL | Description |
| ------ | --- | ----------- |
| GET | /redfish/v1/Systems/Self | Network boot order, boot override, serial number, etc. |
| PATCH | /redfish/v1/Systems/Self | Override boot options, edit system attributes |
| GET | /redfish/v1/Systems/Self/Bios | BIOS settings w/ attribute IDs |
| GET | /redfish/v1/Systems/Self/Bios/SD | Preview staged BIOS settings changes |
| PATCH | /redfish/v1/Systems/Self/Bios/SD | Change BIOS settings | 
| GET | /redfish/v1/Registries/BiosAttributeRegistry.json | BIOS attribute details |
| GET | /redfish/v1/Systems/Self/BootOptions/{id} | Details of specified BootOption ID (for network boot) |
| POST | /redfish/v1/Systems/Self/Actions/ComputerSystem.Reset | Perform power control action |

## Authentication

Use basic authentication header with IPMI login info. Username and password are concatenated together with a colon in the middle. This string is then encoded into a base 64 string. All HRT liquid immersion IPMI login will be set to admin / password. IPMI is also not set up with proper certificates by default, meaning all SSL checks will warn and scream at you unless you specifically turn them off.

ASCII auth string: **admin:password**

Base 64 auth string: **YWRtaW46cGFzc3dvcmQ=**

Python header example:
```
auth_header = {'Authorization': 'Basic YWRtaW46cGFzc3dvcmQ='}
requests.get(url, headers=auth_header, verify=False)
```
cURL header example:
```
curl -k url -H "Authorization: Basic YWRtaW46cGFzc3dvcmQ="
```
## Reading System Serial Number

Easy to get! Found under the literal key SerialNumber.
```
response = requests.get('https://10.48.131.69/redfish/v1/Systems/Self', headers=auth_header, verify=False)
serial_number = response.json()['SerialNumber']
```
Reading BIOS Settings

Gigabyte uses attribute IDs for their BIOS settings. This means the setting names are not immediately obvious to a human without some lookup or mapping done. First, we can grab the BIOS resource with a simple GET.
```
response = requests.get('https://10.48.131.69/redfish/v1/Systems/Self/Bios', headers=auth_header, verify=False)
bios_attributes = response.json()['Attributes']
```
From the JSON body returned, the actual settings are part of the Attributes key. The bios variable now holds a dictionary of attribute IDs as keys, and the BIOS values as values. Next we will grab the attribute registry for the appropriate setting names.
```
response = requests.get('https://10.48.131.69/redfish/v1/Registries/BiosAttributeRegistry.json', headers=auth_header, verify=False)
attribute_registry = response.json()['RegistryEntries']['Attributes']
```
From the JSON body returned, the attribute mapping we are interested in is found under RegistryEntries and then Attributes. The attribute_registry variable holds a list of dictionaries, where each dictionary has AttributeName and DisplayName keys that we can use to do some text replacement. However, some settings have generic names that overlap. To avoid overlap and overwriting, we can concatenate the attribute ID with the display name.
```
# Turn the registry list into a lookup dictionary
attribute_map = {}
for attribute in attribute_registry:
    combined_name = f"{attribute['AttributeName']}_{attribute['DisplayName']}"
    attribute_map[attribute['AttributeName']] = combined_name

# Use dictionary comprehension to perform the key renaming
bios_settings = {
    attribute_map.get(k, k): v for k, v in bios_attributes.items()
}
```
Everything should get properly renamed except for one key named MAPIDS, and I don’t know what that is for exactly.

## Changing BIOS Settings

We can ask Redfish to tell the BMC to push BIOS settings changes to the motherboard. Our changes sent over must use the system’s attribute IDs. Send a PATCH request with auth header, precondition header, and JSON body of new attribute values.
```
auth_header = {
    'Authorization': 'Basic YWRtaW46cGFzc3dvcmQ=',
    'If-Match': '*'
}
payload = {
    'Attributes': {
        'FBO201': 'UEFI USB Device',
        'FBO202': 'UEFI Network'
    }
}
response = requests.patch('https://10.48.131.69/redfish/v1/Systems/Self/Bios/SD', json=payload, headers=auth_header, verify=False)
```
This will change the first 2 boot order choices. If Redfish accepts it, HTTP 204 will be returned, signifying success but nothing to return. These changes are now staged and can be viewed by doing a GET request on the same URL. These changes will be pushed to the motherboard on next reboot.

Warning: The next reboot will push these changes to BIOS, and then trigger another forced reboot. This will overwrite and ignore any boot override you may have set if it was a one time override.

## Reading Network Boot Order

Network boot order depends on the available network devices in the system. Because this is not static, it is not included in the BIOS settings, which should share the same attributes across all systems of the same motherboard model. These must be read from elsewhere.
```
response = requests.get('https://10.48.131.69/redfish/v1/Systems/Self', headers=auth_header, verify=False)
boot_id_order = response.json()['Boot']['BootOrder']
```
The boot_id_order variable gives us a list of boot ID strings, which we then have to do another lookup to get the real display names. These boot IDs are the word Boot followed by 4 hexadecimal digits, like so:
```
Boot0001
Boot000F
Boot00A5
```
Take the last 4 hexadecimal digits as the ID and check BootOptions for the display name. Here’s an example of replacing each boot ID with their display name.
```
boot_order = []
for boot_id in boot_id_order:
    suffix = boot_id[-4:]
    response = requests.get(f'https://10.48.131.69/redfish/v1/Systems/Self/BootOptions/{suffix}', headers=header, verify=False)
    network_device = response.json()['DisplayName']
    boot_order.append(network_device)
```
## Overriding Next Boot

Useful if you want to boot once from a specific option or if you want the system to go into BIOS settings menu without having to mash Delete while it's booting.
```
auth_header = {
    'Authorization': 'Basic YWRtaW46cGFzc3dvcmQ=',
    'If-Match': '*'
}
payload = {
    'Boot': {
        'BootSourceOverrideEnabled': 'Once',
        'BootSourceOverrideMode': 'UEFI',
        'BootSourceOverrideTarget': 'BiosSetup'
    }
}
response = requests.patch('https://10.48.131.69/redfish/v1/Systems/Self', json=payload, headers=auth_header, verify=False)
```
Returns HTTP 204 if successful. One time override will be consumed and ignored if Redfish/BMC is also pushing new BIOS settings, because that will trigger another reboot.

## Perform Power Control Action (Reboot)

In case you want to force a reboot with Redfish.
```
payload = {
    'ResetType': 'ForceRestart'
}
response = requests.post('https://10.48.131.69/redfish/v1/Systems/Self/Actions/ComputerSystem.Reset', json=payload, headers=auth_header, verify=False)
```
