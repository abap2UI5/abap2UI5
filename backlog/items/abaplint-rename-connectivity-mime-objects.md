---
target: abaplint
title: 'rename: APC/AMC applications and MIME objects (SAPC, SAMC, SMIM)'
summary: abaplint renames neither an APC application (SAPC), an AMC channel (SAMC) nor a MIME object (SMIM) - it blocks the namespace rename of samples-stack's AMC/APC and MIME packages today; the MIME folder of a BSP moves with #4722, a standalone SMIM does not
priority: high
state: open
upstream: abaplint/abaplint
first_seen: 2026-11-26
checked_upstream: 2026-11-26
evidence:
  - 'abaplint 2.120.120 Renamer.factory: no SAPC, SAMC, SMIM'
  - 'samples-stack origin/main 7538290: src/07/01 z2ui5_apc_smp_2.sapc.xml, z2ui5_amc_smp_2.samc.xml and the SICF node of the APC application (file name 40 characters with its hash); src/08/01 two SMIM objects (MIME repository)'
  - 'gh search 2026-11-26: abaplint/abaplint#4722 "rename WAPA: the MIME folder of the application moves with it" merged - for the folder of a BSP only'
  - 'samples-stack DEV 2026-11-26: config.renameSkip leaves out src/07 (SAPC, SAMC, SUSH and the ICF node naming the handler class and the channel) and src/08 (its class plays the two SMIM objects of src/08/01 by path) - printed on every npm run rename'
---

# rename: APC/AMC applications and MIME objects

## Why

samples-stack has to be renameable like every repository of the ecosystem.
Its AMC/APC package holds an APC application with its SICF node and an AMC
channel, its MIME package two MIME objects. The classes around them rename;
the objects do not, and the APC handler class and the channel id are named
inside them.

## Proposed

- `SAPC`: the application name, its handler class (follows the CLAS rename),
  its SICF node (`/sap/bc/apc/...`, follows the SICF renamer);
- `SAMC`: the application id and channel; the ABAP references are
  `cl_amc_channel_manager=>create_message_producer( i_application_id = '...'
  i_channel_id = '...' )` - literals, see #4719;
- `SMIM`: the MIME path (`/SAP/PUBLIC/<name>/...`) when it contains a renamed
  name; the object itself is keyed by a GUID and keeps it.
