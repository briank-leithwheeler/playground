# BCP to VAN Datacenter Migration Plan
## Executive Summary
This document outlines the technical migration plan for relocating infrastructure and workloads from the legacy Business Continuity Planning (BCP) environment to the Vancouver (VAN) environment. The primary objectives are to consolidate server hardware, optimize storage architecture, and minimize service disruption throughout the transition.
### Phase 1: Storage Preparation (VAN SAN)
Consolidate existing VMware storage onto three 9 TB SAN LUNs (`SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03`) to simplify datastore management and eliminate the need to migrate large-capacity VMs between smaller datastores. Once all VM storage has been migrated and the remaining three datastores are unmounted and decommissioned, the remaining LUNs will be expanded to 9 TB each.
#### Storage Inventory
The existing VMware storage footprint consists of six LUNs/datastores:

- `SAN-Prod-Vms-01`
- `SAN-Prod-Vms-02`
- `SAN-Prod-Vms-03`
- `SAN-Prod-Vms-04`
- `SAN-Prod-Vms-05`
- `San-Tech-Vms`

#### Implementation Steps

##### 1. Clean Up Existing VMware Storage
- Identify and delete unneeded, powered-off VMs.
- Identify and remove orphaned Zerto folders and files.
- Review existing datastores for unneeded temp files or stale data.
- Unmount ISO images from VMs where they are no longer required, and migrate the ISO images to the `San-General-Storage` datastore.
##### 2. Migrate VMware Storage
Using VMware Storage vMotion, migrate virtual disks for all active VMs from `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, and `San-Tech-Vms` to `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03`.

##### 3. Validate Storage Migration
Verify all production VMs are running without errors.
Verify all VM disk paths point to `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03`.
Confirm no active VMs, templates, snapshots, or ISO files remain on the empty datastores.
Confirm required ISOs are accessible on `San-General-Storage`.

##### 4. Remove VMware Datastores
Unmount the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, `and` `San-Tech-Vms` datastores from all ESXi hosts.
Delete the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, `and` `San-Tech-Vms` datastores from `VANVCENTER01`.
Confirm the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, `and` `San-Tech-Vms` datastores are no longer visible or registered in VMware.

##### 5. Remove LUNs from the SAN
Unpresent and delete the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, `and` `San-Tech-Vms` LUNs on the SAN array.
Rescan host HBAs to confirm clean removal.
Verify `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, `and SAN-Prod-Vms-03` LUNs remain online and operational.

##### 6. Expand the remaining LUNs
Extend the `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, `and SAN-Prod-Vms-03` LUNs on the SAN array to 9 TB.
Rescan storage on all ESXi hosts.
Expand the VMFS datastore in vCenter to consume the newly added capacity.
Verify datastore capacity reports approximately 9 TB in both vCenter and the SAN management interface.





#### Phase 2: Host Relocation, & Hardware Upgrade (WVESXI02)
This phase covers the migration of VMs from `WVESXI02` in the BCP facility (migrating target workloads to the VAN environment and remaining local workloads to `WVESXI01`), followed by physical relocation, firmware updates, ESXi hypervisor upgrades, switch configuration, host network configuration, and host renaming from `WVESXI02` to `VANESXI04`.
Virtual Machine Inventory (VAN Migration)
The following 11 active workloads currently hosted on `WVESXI02` will be migrated to active host servers in the Vancouver (VAN) datacenter cluster across the target ESXi hosts and target datastores:
Name	NumCpu	MemoryGB	ProvisionedDiskGB
explw-db01	12	32	1,702.49
explz-db01	8	32	2,302.10
uatapx-app11	12	28	188.19
uatapx-db11	16	62	1,382.34
uatlw-app01	10	16	106.97
uatlw-app02	6	20	105.99
uatlw-app03	6	12	77.58
uatlw-db01	12	96	1,766.87
uatlw-int02	8	24	89.36
uatlz-app01	6	24	119.98
uatlz-db01	8	96	2,216.99
TOTAL	104 vCPU	442 GB	~10,058 GB (~10.05 TB)
Virtual Machine Inventory (BCP Migration)
The following 9 active workloads currently hosted on `WVESXI02` will be migrated to `WVESXI01` or `WVESXI03`:
Name	NumCpu	MemoryGB	ProvisionedDiskGB
ftd-bcp	8	28	278.96
tem-cgy-win2025	2	8	73.45
testapx-app11	4	24	188.1
testapx-db11	8	32	1382.4
w11vm001	4	16	116.47
w11vm002	4	16	116.47
w11vm003	4	10	116.51
wvdc01	2	8	68.97
wvvcenter01	4	20	720.15
bcpvm-011	0	0	116.22
bcpvm-012	0	0	116.22
bcpvm-013	0	0	116.22
bcpvm-014	0	0	116.22
bcpvm-015	0	0	116.22
bcpvm-016	0	0	116.22
bcpvm-017	0	0	116.22
bcpvm-018	0	0	116.22
bcpvm-019	0	0	116.22
bcpvm-020	0	0	116.22
bcpvm-021	0	0	116.22
bcpvm-022	0	0	116.22
bcpvm-023	0	0	116.22
bcpvm-024	0	0	116.22
bcpvm-025	0	0	116.22
bcpvm-026	0	0	116.22
bcpvm-027	0	0	116.22
bcpvm-028	0	0	116.22
bcpvm-029	0	0	116.22
bcpvm-030	0	0	116.22
TOTAL	36 vCPU	162 GB	~5,100 GB (~5.00 TB)
Implementation Steps
1. NFS Preparation (INF-NFS-1)
Thread Scale: Set `RPCNFSDCOUNT=64` in `/etc/default/nfs-kernel-server` and restart `nfs-kernel-server`.
Export Tuning: Update `/etc/exports` with `async` (and `no_wdelay`) options for active ESXi mounts, then apply via `exportfs -ra`.
vCPU Allocation: Adjust VM allocation to 12 vCPUs in vSphere.
Storage Expansion: Expand vMDDK to 3 TB in vSphere, rescan the SCSI bus (`/sys/class/block/sdX/device/rescan`), and grow the PV/LV/filesystem (`pvresize`, `lvextend`, and `xfs_growfs` or `resize2fs`).
2. VM Evacuation (WVESXI02):
Virtual Machine Inventory (BCP Migration): Perform cold migrations in vCenter for target BCP VMs off `WVESXI02` to `WVESXI01` or `WVESXI03` via scheduled shutdowns.
Virtual Machine Inventory (VAN Migration): Perform cold migrations using NFS for the target VAN VMs off `WVESXI02` to active Vancouver hosts via scheduled shutdowns.
WVESXI02 Maintenance Mode Entry: Verify all VMs are running on target hosts without error, then place `WVESXI02` into vSphere Maintenance Mode.
3. Physical Relocation (WVESXI02)
Gracefully shut down `WVESXI02`.
Unrack, label all network/fiber cabling, and securely pack the server.
Transport hardware from the BCP facility to the Vancouver (VAN) server room.
Rack host in the designated enclosure and reconnect redundant power, network switches, and SAN fabric.
Update out-of-band management (iLO/iDRAC) and host management IP configurations to match the VAN datacenter network subnets.
, Re-IP & Host Renaming (WVESXI02 → VANESXI04):
Gracefully shut down `WVESXI02`.
Unrack, label all network/fiber cabling, and securely pack the server.
Transport hardware from the BCP facility to the Vancouver (VAN) server room.
Rack host in the designated enclosure and reconnect redundant power, network switches, and SAN fabric.
Update out-of-band management (iLO/iDRAC) and host management IP configurations to match the VAN datacenter network subnets.
Update DNS records (A/PTR), SSL certificates, and vCenter display name/FQDN to officially rename the host from `WVESXI02` to `VANESXI04`.
Firmware & Hardware Patching:
Apply system updates including motherboard BIOS, out-of-band management (iLO/iDRAC), network controllers, and RAID/HBA firmware.
ESXi Upgrade & Cluster Join (VANESXI04):
Confirm `VANVCENTER01` compatibility with the target ESXi version.
Upgrade hypervisor on `VANESXI04` to the designated target ESXi standard version.
Verify SAN HBA storage paths and network vSwitches/VLAN connectivity.
Add/re-register `VANESXI04` into the VAN vSphere cluster.
Exit Maintenance Mode on `VANESXI04`.
Perform post-upgrade health checks, verify vSphere HA/DRS cluster status, and restore host cluster services.
Phase 4: vCenter Management Replacement
Modernize the management plane by deploying a new vCenter Server Appliance.
vCenter Deployment (`VANVCENTER02`):
Deploy and configure a clean vCenter Server Appliance (VCSA) instance: `VANVCENTER02`.
Configure Single Sign-On (SSO) domain integration, licensing, roles, and access controls.
Register upgraded and relocated ESXi hosts under the management of `VANVCENTER02`.
Phase 5: Additional Host Workload Migrations
With the upgraded host infrastructure and target management plane operational, relocate remaining BCP workloads.
VM Migration (`WVESXI01`): Migrate active VMs from `WVESXI01` into the consolidated VAN cluster.
VM Migration (`WVESXI03`): Migrate active VMs from `WVESXI03` into the consolidated VAN cluster.
Phase 6: Workstation Relocation
Action Item: Identify target office desks or staging areas within the Vancouver facility for physical workstations currently deployed at the BCP site.
Status: Pending Location Confirmation
Phase 7: Backup & Data Protection (Veeam Integration)
Re-establish backup pipelines and data protection post-migration.
Veeam Infrastructure Configuration:
Install and configure Veeam Backup & Replication components on `BACKUP02` to function as a dedicated backup proxy and repository.
Update Veeam backup jobs to discover and protect workloads via the new `VANVCENTER02` vCenter instance.
Execute active full backup jobs across all jobs to establish new recovery point baselines.
Phase 8: Datacenter Environmental Optimization
Airflow Management:
Evaluate server room thermal dynamics following hardware additions.
Install blanking panels in all vacant rack U-spaces to prevent hot-air recirculation.
Verify cold aisle containment and hot aisle isolation integrity across all racks.
Phase 9: Decommissioning & Cleanup
Once all services are validated and operational within the VAN datacenter, gracefully retire legacy gear.
Server Decommissioning:
Gracefully power down and unrack legacy hosts:
`DEVESXI04`
`WVESXI01`
`WVESXI03`
`WVBACKUP01`
Perform NIST-compliant data sanitization/wiping on all physical drives.
Logistics prep for hardware return, asset disposition, or e-waste recycling.
VAN Server Room Cleanup:
Dress, bundle, and route cabling cleanly in cable trays (overhead and under-floor).
Dispose of packaging, palleting materials, transit hardware, and trash from the server room floor.