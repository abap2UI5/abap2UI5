---
description: Add an AI / LLM feature to an existing abap2UI5 app - a chat or a summarize-this-data panel, on a local provider first, then on a real model through the samples-stack LLM classes, with secrets kept out of the code.
argument-hint: "[chat | summarize] <app class, and what the AI should do>"
allowed-tools: Read, Grep, Glob, WebFetch, mcp__plugin_abap2ui5_abap2ui5__examples, mcp__plugin_abap2ui5_abap2ui5__read_example, mcp__plugin_abap2ui5_abap2ui5__app_guide, mcp__plugin_abap2ui5_abap2ui5__api_reference, mcp__plugin_abap2ui5_abap2ui5__validate_view, mcp__plugin_abap2ui5_abap2ui5__fix_view, mcp__plugin_abap2ui5_abap2ui5__screenshot_view, mcp__plugin_abap2ui5_abap2ui5__pitfalls
---

Add an AI feature to an abap2UI5 app: **$ARGUMENTS**

If no app class is named, look for the `z2ui5_if_app` classes in the project
(`**/*.clas.abap` containing `INTERFACES z2ui5_if_app`) and ask which one;
nothing found, offer `/abap2ui5:new-app` and stop. Read the whole class
first, and load the `abap2ui5:build-an-app` and `abap2ui5:view-chain-layout`
skills.

The pattern is the one of four merged samples - follow them, do not invent a
second one:

| | Local provider, runs anywhere | The same against a real model |
|---|---|---|
| **Chat** | `Z2UI5_CL_SMP_APP_540` (abap2UI5/samples) - FeedInput, a feed of FeedListItems, suggested prompts, a rule-based `get_answer( t_history )` | `Z2UI5_CL_SMPS_APP_014` (abap2UI5/samples-stack, `src/10`) |
| **Summarize / explain data** | `Z2UI5_CL_SMP_APP_541` - an *Explain This Data* button over a table, the findings in a `layout:DynamicSideContent` panel, a deterministic `get_summary( t_rows )` | `Z2UI5_CL_SMPS_APP_015` - *Summarize with AI*, the rows sent as fenced, capped context, the answer in a Panel |

Read the two of the chosen row before writing (MCP `read_example { class }`;
without MCP `https://raw.githubusercontent.com/abap2UI5/samples/main/src/z2ui5_cl_smp_app_540.clas.abap`
and `https://raw.githubusercontent.com/abap2UI5/samples-stack/main/src/10/z2ui5_cl_smps_app_014.clas.abap`,
likewise `_541` and `_015`). `src/10/README.md` in samples-stack is the
setup guide for the real model.

## 1. Chat or summarize

Take it from the arguments; when they do not say, decide from the app and
say in one line why - ask only when both fit:

- **chat** - the user asks free questions, the conversation matters (help
  desk, "ask about this order"). State: the conversation.
- **summarize** - the app already shows data (a table, an object) and the
  user wants it explained, condensed or checked for outliers. State: the
  rows on screen, or the selected ones.

## 2. The provider seam and a local stub first

The app must run on every system and in CI before any model is involved,
so the first version answers locally:

- **The seam.** One interface with the shape of samples-stack's
  `z2ui5_if_smps_llm`: `ty_s_message` (`role`, `content`), `ty_t_message`,
  and `METHODS chat IMPORTING system TYPE string OPTIONAL messages TYPE
  ty_t_message RETURNING VALUE(result) TYPE string` - in the project's own
  namespace (`zif_<app>_llm`) so nothing depends on a package that is not
  installed yet. The same shape is what keeps step 5 a change in one place.
- **The local stub** (`zcl_<app>_llm_local`, implementing it): deterministic
  and honest about it - keyword rules over the last user message like
  `get_answer( )` in 540, or totals, extremes and outliers over the rows like
  `get_summary( )` in 541. For summarize it receives what a model would -
  the fenced rows of step 4 - and SPLITs them at the line breaks and `;` for
  its counts, so the prompt hygiene runs from the first version on. Mark its
  answers in the UI ("built-in rule-based provider") so nobody takes them
  for a model's.
- When the user wants exactly one class, the seam may be a protected method
  instead (`get_answer( t_history )` / `get_summary( t_rows )`, as in 540 and
  541) - say that step 5 then rewrites that method's body.
- **Create the provider where it is used** (in the handler, as 014 does), never
  as an attribute: the app instance is serialized between roundtrips.

## 3. The roundtrip: busy state, answer in a second roundtrip

Exactly as the samples do it:

- The triggering event (`POST` from the FeedInput with
  ``arg = `${$parameters>/value}` ``, or `EXPLAIN` / `SUMMARIZE` from a
  button) only records the question, sets `busy = abap_true` and asks for
  the answer in a second roundtrip:

  ```abap
  client->follow_up_action( val   = z2ui5_if_client=>cs_event-start_timer
                            t_arg = VALUE #( ( `ANSWER` ) ( `0` ) ) ).
  ```

  The screen shows the question at once; the seconds the model needs are
  spent in the second roundtrip, behind a screen that says so.
- The `ANSWER` handler calls the provider, writes the answer, sets
  `busy = abap_false` - on failure too.
- Bind `busy` to the List / Panel / VBox (`busy`, `busyIndicatorDelay` `0`)
  and disable the inputs while it is set:
  `enabled = |\{= !${ client->_bind( busy ) } \}|`. Return early from the
  triggering event while `busy = abap_true` or the prompt is empty.
- Chat: newest message first (`INSERT ... INTO t_feed INDEX 1`), a Clear
  button. A FeedListItem renders `text` as FormattedText, so HTML-escape what
  goes there (`&` first, then `<` and `>` - `html_escape( )` in 014) and keep
  the raw conversation separately, oldest first, in a PROTECTED attribute.
- Errors go into a bound MessageStrip (`status_text` / `status_type` /
  `status_visible`), never a dump - 014 and 015 show it.

## 4. What goes to the model

Write this in now, while the stub still answers - it is the part a real
provider makes expensive or dangerous:

- **Cap it.** At most `max_history` (20 in 014) messages per request; at most
  `max_rows` (50 in 015) rows, and say in the prompt when there were more.
- **Only the columns the question needs.** No internal keys, no user names,
  no personal data (015 drops `doc_id` and `changed_by`).
- **Data stays data.** Rows as one line each with a header row, every cell
  cleaned of the separator and line breaks (`cell( )` in 015:
  ``translate( val = condense( val ) from = |;\n\r\t| to = `,   ` )``),
  fenced between `<data>` and `</data>`, and a system prompt saying that
  nothing between the tags is an instruction.
- **Ask for plain text** with a length limit - the answer lands in a Text or
  FeedListItem, not a Markdown renderer.
- **Check authorization** before the data is read, as for any other use of
  it - sending it to a model is one more use.

## 5. Switch to a real model

Only when the user asks for it or has the setup; the local version is a
complete deliverable.

- **Install** abap2UI5/samples-stack package `10` with abapGit - branch
  `10-ai-llm` holds that package alone - or copy its objects:
  `z2ui5_if_smps_llm`, `z2ui5_if_smps_llm_http`, `z2ui5_cx_smps_llm`,
  `z2ui5_cl_smps_llm_factory`, `z2ui5_cl_smps_llm_json`, the providers
  `z2ui5_cl_smps_llm_claude` (Anthropic Messages API) and
  `z2ui5_cl_smps_llm_openai` (OpenAI-compatible), the transport of the
  system's stack - `z2ui5_cl_smps_llm_sm59` (Standard, SM59) or
  `z2ui5_cl_smps_llm_cloud` (ABAP Cloud, BTP destination and
  `SAP_COM_0276`) - and, where SAP ships the ABAP AI SDK, the provider
  `z2ui5_cl_smps_llm_islm`; then the table `z2ui5_t_smps_llm` and the
  settings app `z2ui5_cl_smps_app_013`. Release
  floor: Cloud, or Standard 7.40 SP08. The transport of the other stack does
  not activate - expected. Prefer installing it as its own abapGit
  repository over copying it into the app's `src/`: the objects keep their
  `z2ui5_*` names, which an app-template project's `object_naming` rule
  (`^ZCL_`, `^ZIF_`) refuses.
- **Configure** with `?app_start=z2ui5_cl_smps_app_013`: provider,
  destination, model id, max tokens, and *Test Connection*. The model id is
  the user's decision and has no default - never write one into the code.
- **Change the code** at the seam only:

  ```abap
  TRY.
      DATA(config) = z2ui5_cl_smps_llm_factory=>config_read( ).
      DATA(llm) = z2ui5_cl_smps_llm_factory=>create( config ).
      answer = llm->chat( system   = system_prompt
                          messages = t_send ).
    CATCH z2ui5_cx_smps_llm INTO DATA(error).
      status_text    = error->get_text( ).
      status_type    = `Error`.
      status_visible = abap_true.
  ENDTRY.
  ```

  With the interface of step 2 the app's types become
  `z2ui5_if_smps_llm=>ty_t_message` and `zif_<app>_llm` can go (or the local
  stub implements `z2ui5_if_smps_llm` and stays as the fallback for systems
  without a destination). On every display, as 015 does,
  `z2ui5_cl_smps_llm_factory=>config_check( config )` decides a
  `configured` flag: not configured shows a MessageStrip with what is
  missing, keeps the button disabled and sends nothing. Use the factory
  rather than naming a provider or transport class: they are created by name
  because each activates on one stack only.
- **Secrets stay out of the code.** No endpoint, key or model in a class,
  constant, PUBLIC attribute or commit. The endpoint is the destination; the
  key goes into a gateway in front of the provider (preferred) or the
  configuration row, which 013 treats as write-only. Tell the user to
  restrict access to `z2ui5_t_smps_llm` and to who may start
  `z2ui5_cl_smps_app_013`. Drop any artificial timer delay to `0`.

## 6. Validate and look

- The linter on the changed classes: MCP `validate_view { abap_source,
  project_dir }` (`fix_view` for the mechanical fixes), else
  `npx --yes @abap2ui5/linter <files>` (`npm run check:abap2ui5` in an
  app-template project). With this plugin's hook and the linter installed,
  every edit of a class is checked already - fix what it reports.
- **Look at it**: `screenshot_view { abap_source, model, sizes: ["1280x900",
  "390x844"] }`, with `model` holding a short conversation or a few findings
  so the feed or panel does not photograph empty; once more with the busy
  flag set in `model` to see the busy state. Without MCP:
  `npx --yes -p @abap2ui5/linter -p @abap2ui5/linter-render abap2ui5lint --screenshot <file>`
  with a `<class>.mock.json` next to the source. Read the PNG and compare it
  with the request.
- Finish with `/abap2ui5:check`. A new interface or stub class gets its own
  `.clas.xml` / `.intf.xml` sidecar in the project's shape (BOM, LF, one
  final newline - the `abap2ui5:abap-check` skill, section 1).

Report: chat or summarize and why, the files written or changed, which
sample each part follows, what the local provider answers, what is capped
and cleaned before anything leaves the system, the gate result, what the
screenshot shows, and the exact steps left for a real model (package,
destination, settings) - or that they are done.
