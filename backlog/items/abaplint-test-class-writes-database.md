---
target: abaplint
title: 'Report database writes and COMMIT WORK in a test class'
summary: 'a FOR TESTING class that INSERTs into / DELETEs from a persistent table and commits - the ATC reports "database operations not allowed, use an update module" on the class; abaplint 2.120.116 has no rule for writes or commits inside a test class'
priority: medium
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/popups, ATC run of 2026-11-25 on the popup for transport requests: "Verwendung von Datenbankoperationen in Objekt ... nicht zulässig. Verwenden Sie einen Verbuchungsbaustein" - the cause was a local test class (RISK LEVEL HARMLESS) that wrote a row into the framework draft table, called the method under test, rolled back and in teardown deleted the row with COMMIT WORK; abaplint green, the transpiled unit run green'
  - 'rule list of abaplint 2.120.116: modify_only_own_db_tables only checks the table name prefix (a Z table passes), no rule looks at FOR TESTING classes'
---

# Report database writes and COMMIT WORK in a test class

```abap
CLASS ltcl_x DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
...
  METHOD teardown.
    DELETE FROM ztab WHERE id = @c_id.
    COMMIT WORK.                    " commits whatever else is open
  ENDMETHOD.
```

A unit test that writes to a persistent table changes shared data, commits
the running LUW and is not harmless; the ATC reports it on the class. The
OSQL test environment (`cl_osql_test_environment`) or a test double for the
data access is the way to test such code.

**Proposal.** In a class or method `FOR TESTING`, report INSERT/UPDATE/
MODIFY/DELETE on a database table and COMMIT WORK / ROLLBACK WORK - at least
when the class says `RISK LEVEL HARMLESS`.

**Where.** a new rule. **Effort:** S.
