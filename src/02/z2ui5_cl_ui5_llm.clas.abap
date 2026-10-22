"! <p class="shorttext synchronized">abap2UI5 - language model providers</p>
"!
"! Where an app gets a z2ui5_if_ui5_llm: one method per shipped provider,
"! each answering a new instance behind the interface. The providers
"! themselves are engine classes (src/01/05) and may change; this class and
"! the interface are the contract.
"!
"! Model, key and endpoint are handed in by the app - read from a
"! destination, a configuration table or a user exit - and never written
"! into a class. There is no default model: which model a system may use and
"! pay for is the installation's decision, and a model id written into the
"! framework would age with every release of the provider.
"!
"! Every HTTP provider goes through z2ui5_cl_ui5_util_http, which picks
"! CL_HTTP_CLIENT on Standard (an SM59 destination or a URL) and
"! CL_WEB_HTTP_CLIENT_MANAGER on ABAP Cloud (a URL, a communication
"! arrangement SCENARIO/SERVICE_ID[/COMM_SYSTEM] or a BTP destination), both
"! named dynamically, so the providers activate on every release. A URL
"! without a destination needs the server's certificate in STRUST (Standard)
"! or an outbound communication arrangement (ABAP Cloud).
CLASS z2ui5_cl_ui5_llm DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES:
      "! one rule of the local provider: when the last user message
      "! contains `contains` (case-insensitive), the answer is `answer`
      BEGIN OF ty_s_rule,
        contains TYPE string,
        answer   TYPE string,
      END OF ty_s_rule.
    TYPES ty_t_rule TYPE STANDARD TABLE OF ty_s_rule WITH EMPTY KEY.

    "! The Claude Messages API: POST /v1/messages with the headers x-api-key
    "! and anthropic-version.
    "! @parameter model       | the model id, exactly as the API spells it
    "! @parameter api_key     | sent as x-api-key; empty when the destination
    "!                          or a gateway in front of it adds the header
    "! @parameter url         | the full endpoint URL, or with destination the
    "!                          path below it - empty for the public endpoint
    "!                          (with destination: /v1/messages)
    "! @parameter destination | Standard: an SM59 destination (type G); ABAP
    "!                          Cloud: SCENARIO/SERVICE_ID of a communication
    "!                          arrangement or a BTP destination name
    "! @parameter timeout     | seconds the call may take, 0 for 300
    CLASS-METHODS create_claude
      IMPORTING
        model         TYPE clike
        api_key       TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
        !destination  TYPE clike OPTIONAL
        timeout       TYPE i OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_llm.

    "! An OpenAI-compatible Chat Completions endpoint - OpenAI, Azure OpenAI,
    "! Ollama, LM Studio, vLLM, a SAP AI Core proxy, any gateway.
    "! @parameter model               | the model id (Azure: the deployment)
    "! @parameter api_key             | the key; empty when the destination or
    "!                                  a gateway authenticates
    "! @parameter url                 | the full endpoint URL, or with
    "!                                  destination the path below it - empty
    "!                                  for the OpenAI endpoint (with
    "!                                  destination: /v1/chat/completions)
    "! @parameter destination         | as for create_claude
    "! @parameter timeout             | seconds the call may take, 0 for 300
    "! @parameter auth_header         | the header the key travels in: empty
    "!                                  for Authorization: Bearer, any other
    "!                                  name sends the key as it is (Azure
    "!                                  OpenAI: api-key)
    "! @parameter check_legacy_tokens | send the token limit as max_tokens, for
    "!                                  servers that do not know
    "!                                  max_completion_tokens
    CLASS-METHODS create_openai
      IMPORTING
        model               TYPE clike
        api_key             TYPE clike OPTIONAL
        url                 TYPE clike OPTIONAL
        !destination        TYPE clike OPTIONAL
        timeout             TYPE i OPTIONAL
        auth_header         TYPE clike OPTIONAL
        check_legacy_tokens TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_if_ui5_llm.

    "! A rule-based provider without HTTP: the first rule whose text the last
    "! user message contains answers, deterministic and offline.
    "! @parameter t_rule   | the rules, tried in order
    "! @parameter fallback | the answer when no rule matches - empty echoes
    "!                       the last user message
    CLASS-METHODS create_local
      IMPORTING
        t_rule        TYPE ty_t_rule OPTIONAL
        fallback      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ui5_llm.

    "! The guide to building an app with abap2UI5 (docs/agents/building-apps.md
    "! of the release installed here), as markdown - the system prompt for a
    "! model that writes apps, and the reference for an assistant that reads
    "! this system's code rather than the repository.
    CLASS-METHODS guide
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm IMPLEMENTATION.

  METHOD create_claude.

    result = NEW z2ui5_cl_ui5_llm_claude( model       = model
                                          api_key     = api_key
                                          url         = url
                                          destination = destination
                                          timeout     = timeout ).

  ENDMETHOD.

  METHOD create_openai.

    result = NEW z2ui5_cl_ui5_llm_openai( model               = model
                                          api_key             = api_key
                                          url                 = url
                                          destination         = destination
                                          timeout             = timeout
                                          auth_header         = auth_header
                                          check_legacy_tokens = check_legacy_tokens ).

  ENDMETHOD.

  METHOD create_local.

    result = NEW z2ui5_cl_ui5_llm_local( t_rule   = t_rule
                                         fallback = fallback ).

  ENDMETHOD.

  METHOD guide.

    " generated from the guide by .github/scripts/generate-guide-class.mjs
    result = z2ui5_cl_ui5_llm_guide=>get( ).

  ENDMETHOD.

ENDCLASS.
