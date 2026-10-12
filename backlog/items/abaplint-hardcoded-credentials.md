---
target: abaplint
title: 'Report literals assigned to or passed as password/secret/token'
summary: 'a credential in source ends up in the transport and in git'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report literals assigned to or passed as password/secret/token

```abap
lo_client->authenticate( username = 'u' password = 'secret123' ).
```

**Proposal.** Report non-empty literals assigned to variables or passed to parameters named password, passwd, pwd, secret, token, client_secret.

**Not reported.** Empty literals; test classes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Sonar S2068; Bandit S105/S106.
