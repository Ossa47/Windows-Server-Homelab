# Windows Server & Hyper-V Homelab

Project Objective
This repository documents my Homelab environment. The lab is built on Hyper-V and includes Active Directory and File Server configurations, along with applied security policies (GPO) and system hardening.

## Hardware Specifications
* CPU: AMD Ryzen 7 7800X3D
* RAM: 32GB
* Hypervisor: Hyper-V

## Server & Network Architecture
| Server Name | Role | OS | Static IP |

* | **DC01** | Domain Controller / DNS / DHCP | Windows Server | 192.168.10.10 |
* | **FS01** | File Server | Windows Server | 192.168.10.20 |
* | **user** | User Device | Windows 11 | DHCP |

## Repository Contents
* `/Scripts` - PowerShell scripts for task automation (e.g., adding users).
* `/Configs` - Exported GPO files and security configurations.
* `/Docs` - Lab build steps, documentation, and network diagram.
