# BCP to VAN Datacenter Migration Plan
## Executive Summary
This document details the migration plan for relocating virtual machines and server hardware from the BCP datacenter to the Vancouver (VAN) datacenter. Primary goals: consolidate VMware storage onto three 9 TB LUNs, relocate and upgrade `WVESXI02` to `VANESXI04`, and move VMs without unplanned service downtime.
### Phase 1: Storage Preparation (VAN SAN)
Consolidate existing VMware storage onto three 9 TB SAN LUNs (`SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03`) to simplify datastore management and eliminate the need to migrate large-capacity VMs between smaller datastores. Once all VM storage has been migrated to the three datastores, the empty datastores are unmounted and decommissioned, and the three remaining LUNs will be expanded to 9 TB each.
#### Storage Inventory
Existing datastores:
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
Unmount the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, and `San-Tech-Vms` datastores from all ESXi hosts.
Delete the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, and `San-Tech-Vms` datastores from `VANVCENTER01`.
Confirm the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, and `San-Tech-Vms` datastores are no longer visible or registered in VMware.

##### 5. Remove LUNs from the SAN
Unpresent and delete the `SAN-Prod-Vms-04`, `SAN-Prod-Vms-05`, and `San-Tech-Vms` LUNs on the SAN array.
Rescan host HBAs to confirm clean removal.
Verify `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03` LUNs remain online and operational.

##### 6. Expand the remaining LUNs
Extend the `SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03` LUNs on the SAN array to 9 TB.
Rescan storage on all ESXi hosts.
Expand the VMFS datastore in vCenter to consume the newly added capacity.
Verify datastore capacity reports approximately 9 TB in both vCenter and the SAN management interface.

### Phase 2: Host Relocation & Hardware Upgrade (WVESXI02)
This phase covers migrating VMs off `WVESXI02` (moving Vancouver-bound VMs to Vancouver and local VMs to `WVESXI01` or `WVESXI03`), followed by physically moving the server to Vancouver, updating firmware, upgrading ESXi, and renaming the host to `VANESXI04`.

#### Virtual Machine Inventory (VAN Migration)
Virtual machines migrating from `WVESXI02` to the Vancouver cluster:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `explw-db01` | 12 | 32 | 1,702.49 |
| `explz-db01` | 8 | 32 | 2,302.10 |
| `uatapx-app11` | 12 | 28 | 188.21 |
| `uatapx-db11` | 16 | 62 | 1,382.37 |
| `uatlw-app01` | 10 | 16 | 106.99 |
| `uatlw-app02` | 6 | 20 | 106.00 |
| `uatlw-app03` | 6 | 12 | 77.60 |
| `uatlw-db01` | 12 | 96 | 1,766.89 |
| `uatlw-int02` | 8 | 24 | 89.38 |
| `uatlz-app01` | 6 | 24 | 120.00 |
| `uatlz-db01` | 8 | 96 | 2,217.01 |
| `w11vm001` | 8 | 16 | 116.47 |
| `w11vm002` | 8 | 16 | 116.47 |
| `w11vm003` | 8 | 16 | 116.51 |
| **TOTAL** | **128 vCPU** | **490 GB** | **~10,408 GB (~10.16 TB)** |

#### Virtual Machine Inventory (BCP Migration)
Virtual machines migrating from `WVESXI02` to `WVESXI01` or `WVESXI03`:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `ftd-bcp` | 4 | 28 | 278.96 |
| `tem-cgy-win2025` | 4 | 8 | 73.45 |
| `wvdc01` | 2 | 8 | 68.97 |
| `wvvcenter01` | 4 | 19 | 720.15 |
| `bcpvm-011` | 8 | 16 | 116.22 |
| `bcpvm-012` | 8 | 16 | 116.22 |
| `bcpvm-013` | 8 | 16 | 116.22 |
| `bcpvm-014` | 8 | 16 | 116.22 |
| `bcpvm-015` | 8 | 16 | 116.22 |
| `bcpvm-016` | 8 | 16 | 116.22 |
| `bcpvm-017` | 8 | 16 | 116.22 |
| `bcpvm-018` | 8 | 16 | 116.22 |
| `bcpvm-019` | 8 | 16 | 116.22 |
| `bcpvm-020` | 8 | 16 | 116.22 |
| `bcpvm-021` | 8 | 16 | 116.22 |
| `bcpvm-022` | 8 | 16 | 116.22 |
| `bcpvm-023` | 8 | 16 | 116.22 |
| `bcpvm-024` | 8 | 16 | 116.22 |
| `bcpvm-025` | 8 | 16 | 116.22 |
| `bcpvm-026` | 8 | 16 | 116.22 |
| `bcpvm-027` | 8 | 16 | 116.22 |
| `bcpvm-028` | 8 | 16 | 116.22 |
| `bcpvm-029` | 8 | 16 | 116.22 |
| `bcpvm-030` | 8 | 16 | 116.22 |
| **TOTAL** | **174 vCPU** | **383 GB** | **~3,466 GB (~3.38 TB)** |

#### Implementation Steps

##### 1. NFS Server Provisioning & Preparation (INF-NFS-2)
- **VM Cloning:** Clone VM `INF-NFS-1` to create `INF-NFS-2` in vSphere/vCenter to preserve the original NFS instance.
- **Hostname & DNS:** Update hostname configuration on `INF-NFS-2` (`/etc/hostname` and `/etc/hosts`), assign static IP, and create a DNS A record.
- **Thread Scale:** Set `RPCNFSDCOUNT=64` in `/etc/default/nfs-kernel-server` and restart `nfs-kernel-server`.
- **Export Tuning:** Update `/etc/exports` with `async` (and `no_wdelay`) options for active ESXi mounts, then apply via `exportfs -ra`.
- **vCPU Allocation:** Adjust VM allocation to 12 vCPUs in vSphere on `INF-NFS-2`.
- **Storage Expansion:** Expand vMDDK to 3 TB in vSphere, rescan the SCSI bus (`/sys/class/block/sdX/device/rescan`), and grow the PV/LV/filesystem (`pvresize`, `lvextend`, and `xfs_growfs` or `resize2fs`).

##### 2. Migrate VMs Off WVESXI02
- **BCP VM Migrations (to `WVESXI01` / `WVESXI03`):**
  - Shut down target BCP VMs during scheduled maintenance windows.
  - Cold migrate VMs in vCenter from `WVESXI02` to `WVESXI01` or `WVESXI03`.
  - Power on VMs on destination BCP hosts and verify system health.
- **Vancouver VM Migrations (via `INF-NFS-2`):**
  - Shut down the Vancouver-bound VMs during scheduled maintenance windows.
  - Cold migrate VM storage in batches onto the `INF-NFS-2` staging datastore.
  - Unregister the VMs from the source vCenter.
  - Register VMs in `VANVCENTER01` across target Vancouver hosts.
  - Storage vMotion VM disks from `INF-NFS-2` onto target SAN datastore
  - Power on VMs, verify network port group / VLAN bindings, and validate services.
- **Host Maintenance & vCenter Removal:**
  - Confirm zero active VMs remain running or registered on `WVESXI02`.
  - Place `WVESXI02` into vSphere Maintenance Mode.
  - Disconnect and remove `WVESXI02` from `WVVCENTER01` inventory.

##### 3. Physical Relocation (WVESXI02)
- Shut down `WVESXI02`.
- Unrack, label all network/fiber cabling, and securely pack the server.
- Transport hardware from the BCP facility to the Vancouver (VAN) server room.
- Rack host in the designated enclosure and reconnect redundant power, network cables, and KVM.

##### 4. Re-IP & Host Renaming (VANESXI04)
- Update out-of-band management (iLO/iDRAC) and host management IP configurations to match the VAN datacenter network subnets.
- Create DNS records (forward A and reverse PTR) for `VANESXI04`.
- Update the hostname and FQDN on the ESXi host via DCUI / Host Client (`esxcli system hostname set --host=VANESXI04`).

##### 5. Firmware & Hardware Patching
- Apply system updates including motherboard BIOS, out-of-band management (iLO/iDRAC), network controllers, and RAID/HBA firmware.

##### 6. vCenter Upgrade (DEVVCENTER01)
- Upgrade `DEVVCENTER01` to vSphere version 8 to match the version of `VANVCENTER01`.
- Verify vCenter appliance health and service operational status post-upgrade.

##### 7. ESXi Upgrade (VANESXI04)
- Upgrade hypervisor on `VANESXI04` to the designated target ESXi standard version.
- Add `VANESXI04` to `DEVVCENTER01`.
- Exit Maintenance Mode on `VANESXI04`.

### Phase 3: Additional Host Virtual Machine Migrations
With `VANESXI04` online in Vancouver, relocate the remaining BCP virtual machines.

#### Virtual Machine Inventory (VAN Migration)
Virtual machines migrating from `WVESXI01`:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `testapx-app01` | 12 | 28 | 163.94 |
| `testapx-app11` | 12 | 28 | 188.11 |
| `testapx-db01` | 16 | 62 | 1,292.89 |
| `testapx-db11` | 16 | 62 | 1,382.12 |
| `testlw-app01` | 10 | 16 | 106.73 |
| `testlw-app02` | 6 | 20 | 106.22 |
| `testlw-db01` | 12 | 96 | 1,767.15 |
| `testlw-int02` | 8 | 24 | 89.48 |
| `testlz-app01` | 6 | 24 | 120.10 |
| `testlz-db01` | 8 | 96 | 2,217.10 |
| **TOTAL** | **106 vCPU** | **456 GB** | **~7,434 GB (~7.26 TB)** |

Virtual machines migrating from `WVESXI03`:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `devapx-app11` | 12 | 28 | 188.38 |
| `devapx-db11` | 16 | 62 | 1,382.38 |
| `devlw-app01` | 10 | 16 | 107.21 |
| `devlw-app02` | 6 | 20 | 106.20 |
| `devlw-db01` | 12 | 96 | 1,767.10 |
| `devlw-int02` | 8 | 24 | 89.45 |
| `devlz-app01` | 6 | 24 | 120.20 |
| `devlz-db01` | 8 | 96 | 2,217.12 |
| `venapx-db11` | 16 | 32 | 1,352.09 |
| `venlw-db01` | 12 | 32 | 1,702.09 |
| `venlz-db01` | 8 | 32 | 2,152.09 |
| **TOTAL** | **114 vCPU** | **462 GB** | **~11,184 GB (~10.92 TB)** |

#### Implementation Steps

##### 1. VM Migration (WVESXI01)
- Shut down target test VMs on `WVESXI01` via scheduled maintenance windows.
- Cold migrate VM storage in batches to the `INF-NFS-2` staging datastore.
- Unregister the VMs from the source vCenter.
- Register VMs in `DEVVCENTER01` on the Vancouver cluster.
- Storage vMotion VM disks from `INF-NFS-2` to target SAN datastores to clear staging capacity for subsequent transfers.
- Power on VMs, verify network port group / VLAN bindings, and validate system functionality.
- Once all VMs are verified operational, place `WVESXI01` into Maintenance Mode and disconnect/remove it from `WVVCENTER01`.

##### 2. VM Migration (WVESXI03)
- Shut down target dev and vendor VMs on `WVESXI03` via scheduled maintenance windows.
- Cold migrate VM storage in batches to the `INF-NFS-2` staging datastore.
- Unregister the VMs from the source vCenter.
- Register VMs in `DEVVCENTER01` on the Vancouver cluster.
- Storage vMotion VM disks from `INF-NFS-2` to target SAN datastores.
- Power on VMs, verify network port group / VLAN bindings, and validate system functionality.
- Once all VMs are verified operational, place `WVESXI03` into Maintenance Mode and disconnect/remove it from `WVVCENTER01`.

### Phase 4: Backup & Data Protection (Veeam & Airflow Integration)
Update Airflow PowerShell backup scripts and Veeam repositories to protect all migrated virtual machines in Vancouver.

> [!NOTE]
> All backup configurations are defined in PowerShell scripts executed by Airflow, not in the Veeam UI. With `WVBACKUP01` being decommissioned, `BACKUP01` cannot complete weekend backup runs alone for all VMs. `BACKUP02` will be brought online to split the workload with `BACKUP01`. Splitting between two backup servers means less total space is used on each and backups finish within the weekend window. Archive folders on both `BACKUP01` and `BACKUP02` must also be cleaned up first to ensure enough disk space is available for all VMs.

#### Implementation Steps

##### 1. Clean Up Archive Folders (BACKUP01 & BACKUP02)
- Delete old archive folders and orphaned backups on `BACKUP01` and `BACKUP02` to free disk space for incoming VMs.

##### 2. Provision BACKUP02 Proxy & Repository
- Install Veeam components and PowerShell modules on `BACKUP02`.
- Configure `BACKUP02` as a backup proxy and local repository.
- Ensure Veeam and PowerShell modules are compatible with vSphere 8.
- Register `DEVVCENTER01` and `VANVCENTER01` in Veeam.

##### 3. Update Airflow Backup Scripts
- Update the Airflow PowerShell scripts to split VM backups between `BACKUP01` and `BACKUP02` instead of targeting `WVBACKUP01`.
- Balance VM assignments between both servers to keep repository usage even and avoid bottlenecks.

##### 4. Run Initial Backups
- Trigger backup runs from Airflow and verify jobs complete successfully on both `BACKUP01` and `BACKUP02`.

##### 5. Update Zabbix Monitoring
- Update Zabbix backup-age checks to monitor `BACKUP01` and `BACKUP02`.
- Remove checks and alerts for `WVBACKUP01`.

### Phase 5: Decommissioning & Cleanup
Decommission and wipe legacy BCP hardware once Vancouver services are verified.

#### Server Decommissioning
- Power down and unrack legacy hosts:
  - `WVESXI01`
  - `WVESXI03`
  - `WVBACKUP01`
- Securely wipe all physical drives.
- Pack hardware for return, lease return, or e-waste recycling.

#### VAN Server Room Cleanup
- Route and tie down cabling in overhead and under-floor trays.
- Clear boxes, pallet wrap, transit hardware, and trash from the server room floor.

### Considerations & Potential Blockers
- **Veeam Upgrade:** Install Veeam with upgrade.
- **BCP Shutdown:** BCP shutdown requires all essential VMs (currently without backups) to be moved or designated as non-essential.
- **Daily Delta:** Daily delta replication volume could be a problem.
- **NFS Server:** NFS server will need to shrink after migration, so clone it first.
- **Tape Backups:** Evaluate impact on tape backups.
- **Blockers:** Identify dependencies and what operations cannot proceed while a VM solution is not present.
