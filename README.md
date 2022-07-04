# Status

DRAFT

This document is in draft. I will work on this project and plan to release the first candidate end of September.
Till then, feel free to contatct me if you have something to discuss.

muellseb@googlemail.com

# About this project

# Release plans

# Description

SPO Migration CLI is a PowerShell based CLI tool to create migration and seed scripts and apply them on SharePoint Online sites.
It's a tool to use for shipping the same artifacts accross multiple sites or tenants and for provisioning artifacts like:

- Fields
- Lists
- Content Types
- Permissions
- Groups
- Role Assignments
- Views
- ...

# Pre-requisites

> Unix systems are not supported yet! I will take care about it when the first version for Windows is released

- Install PnP Powershell Module using PowerShell: `Install-Module -Name "PnP.PowerShell"` ([checkout the page of PnP PowerShell](https://pnp.github.io/powershell/articles/installation.html))
- A SharePoint Online Site Collection URL which you can pass to the CLI
- ...
