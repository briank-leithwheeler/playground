# BCP to VAN Datacenter Migration Plan
## Executive Summary
This document details the migration plan for relocating virtual machines and server hardware from the BCP datacenter to the Vancouver (VAN) datacenter. Primary goals: consolidate VMware storage onto three 9 TB LUNs, relocate and upgrade `WVESXI02` to `VANESXI04`, and move VMs without unplanned service downtime.
### Phase 1: Storage Preparation (VAN SAN)
Consolidate existing VMware storage onto three 9 TB SAN LUNs (`SAN-Prod-Vms-01`, `SAN-Prod-Vms-02`, and `SAN-Prod-Vms-03`) to simplify datastore management and eliminate the need to migrate large-capacity VMs between smaller datastores. Once all VM storage has been migrated to the three datastores, the empty datastores are unmounted and decommissioned, and the three remaining LUNs will be expanded to 9 TB each.
#### Storage Inventory
Existing datastores (6):
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
This phase covers evacuating VMs from `WVESXI02` (migrating Vancouver-bound VMs to Vancouver and local VMs to `WVESXI01` or `WVESXI03`), followed by physically moving the server to Vancouver, updating firmware, upgrading ESXi, and renaming the host to `VANESXI04`.

#### Virtual Machine Inventory (VAN Migration)
Virtual machines migrating from `WVESXI02` to the Vancouver cluster:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `explw-db01` | 12 | 32 | 1,702.49 |
| `explz-db01` | 8 | 32 | 2,302.10 |
| `uatapx-app11` | 12 | 28 | 188.19 |
| `uatapx-db11` | 16 | 62 | 1,382.34 |
| `uatlw-app01` | 10 | 16 | 106.97 |
| `uatlw-app02` | 6 | 20 | 105.99 |
| `uatlw-app03` | 6 | 12 | 77.58 |
| `uatlw-db01` | 12 | 96 | 1,766.87 |
| `uatlw-int02` | 8 | 24 | 89.36 |
| `uatlz-app01` | 6 | 24 | 119.98 |
| `uatlz-db01` | 8 | 96 | 2,216.99 |
| **TOTAL** | **104 vCPU** | **442 GB** | **~10,058 GB (~10.05 TB)** |

#### Virtual Machine Inventory (BCP Migration)
Virtual machines migrating from `WVESXI02` to `WVESXI01` or `WVESXI03`:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `ftd-bcp` | 8 | 28 | 278.96 |
| `tem-cgy-win2025` | 2 | 8 | 73.45 |
| `w11vm001` | 4 | 16 | 116.47 |
| `w11vm002` | 4 | 16 | 116.47 |
| `w11vm003` | 4 | 10 | 116.51 |
| `wvdc01` | 2 | 8 | 68.97 |
| `wvvcenter01` | 4 | 20 | 720.15 |
| `bcpvm-011` | 0 | 0 | 116.22 |
| `bcpvm-012` | 0 | 0 | 116.22 |
| `bcpvm-013` | 0 | 0 | 116.22 |
| `bcpvm-014` | 0 | 0 | 116.22 |
| `bcpvm-015` | 0 | 0 | 116.22 |
| `bcpvm-016` | 0 | 0 | 116.22 |
| `bcpvm-017` | 0 | 0 | 116.22 |
| `bcpvm-018` | 0 | 0 | 116.22 |
| `bcpvm-019` | 0 | 0 | 116.22 |
| `bcpvm-020` | 0 | 0 | 116.22 |
| `bcpvm-021` | 0 | 0 | 116.22 |
| `bcpvm-022` | 0 | 0 | 116.22 |
| `bcpvm-023` | 0 | 0 | 116.22 |
| `bcpvm-024` | 0 | 0 | 116.22 |
| `bcpvm-025` | 0 | 0 | 116.22 |
| `bcpvm-026` | 0 | 0 | 116.22 |
| `bcpvm-027` | 0 | 0 | 116.22 |
| `bcpvm-028` | 0 | 0 | 116.22 |
| `bcpvm-029` | 0 | 0 | 116.22 |
| `bcpvm-030` | 0 | 0 | 116.22 |
| **TOTAL** | **36 vCPU** | **162 GB** | **~5,100 GB (~5.00 TB)** |

#### Implementation Steps

##### 1. NFS Server Provisioning & Preparation (INF-NFS-2)
- **VM Cloning:** Clone VM `INF-NFS-1` to create `INF-NFS-2` in vSphere/vCenter to preserve the original NFS instance.
- **Hostname & DNS:** Update hostname configuration on `INF-NFS-2` (`/etc/hostname` and `/etc/hosts`), assign static IP, and create a DNS A record.
- **Thread Scale:** Set `RPCNFSDCOUNT=64` in `/etc/default/nfs-kernel-server` and restart `nfs-kernel-server`.
- **Export Tuning:** Update `/etc/exports` with `async` (and `no_wdelay`) options for active ESXi mounts, then apply via `exportfs -ra`.
- **vCPU Allocation:** Adjust VM allocation to 12 vCPUs in vSphere on `INF-NFS-2`.
- **Storage Expansion:** Expand vMDDK to 3 TB in vSphere, rescan the SCSI bus (`/sys/class/block/sdX/device/rescan`), and grow the PV/LV/filesystem (`pvresize`, `lvextend`, and `xfs_growfs` or `resize2fs`).

##### 2. VM Evacuation (WVESXI02)
- **BCP VM Migrations:** Perform cold migrations in vCenter for BCP VMs off `WVESXI02` to `WVESXI01` or `WVESXI03` via scheduled shutdowns.
- **VAN VM Migrations:** Perform cold migrations using NFS via `INF-NFS-2` for Vancouver-bound VMs off `WVESXI02` to active Vancouver hosts via scheduled shutdowns.
- **Maintenance Mode Entry:** Verify all VMs are running on target hosts without error, then place `WVESXI02` into vSphere Maintenance Mode.
- **vCenter Removal:** Disconnect and remove `WVESXI02` from `WVVCENTER01`.

##### 3. Physical Relocation (WVESXI02)
- Gracefully shut down `WVESXI02`.
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
Virtual machines migrating from `WVESXI01` and `WVESXI03` to `VANESXI04`:
| Name | NumCpu | MemoryGB | ProvisionedDiskGB |
| :--- | ---: | ---: | ---: |
| `testapx-app11` | 4 | 24 | 188.1 |
| `testapx-db11` | 8 | 32 | 1382.4 |
| **TOTAL** | **12 vCPU** | **56 GB** | **~1,571 GB (~1.57 TB)** |

- **VM Migration (`WVESXI01`):** Migrate active VMs from `WVESXI01` into `VANESXI04` via NFS.
- **VM Migration (`WVESXI03`):** Migrate active VMs from `WVESXI03` into `VANESXI04` via NFS.

### Phase 4: Workstation Relocation
- **Action Item:** Identify target office desks or staging areas within the Vancouver facility for physical workstations currently deployed at the BCP site.
- **Status:** Pending Location Confirmation

### Phase 5: Backup & Data Protection (Veeam Integration)
Reconfigure Veeam backups post-migration.

#### Veeam Infrastructure Configuration
- Install and configure Veeam Backup & Replication components on `BACKUP02` to act as a dedicated backup proxy and repository.
- Update Veeam backup jobs to discover and protect virtual machines via the upgraded `DEVVCENTER01` vCenter instance.
- Run active full backup jobs across all workloads to start new backup chains.

### Phase 6: Decommissioning & Cleanup
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
