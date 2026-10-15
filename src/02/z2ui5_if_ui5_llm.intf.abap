"! <p class="shorttext synchronized">abap2UI5 - language model provider</p>
"!
"! The one seam between an app and a large language model: a system prompt
"! and the conversation go in, the answer and its token usage come out.
"! Nothing in it names a vendor, an endpoint, a model or a key - that is
"! what the providers and the app's own configuration are for. The shipped
"! providers come from z2ui5_cl_ui5_llm:
"!
"!   create_claude( )   the Claude Messages API (POST /v1/messages)
"!   create_openai( )   an OpenAI-compatible Chat Completions endpoint
"!                      (OpenAI, Azure OpenAI, Ollama, LM Studio, vLLM,
"!                      SAP AI Core proxies, any gateway)
"!   create_local( )    a deterministic rule-based provider without HTTP -
"!                      for NW 7.02, systems without network, unit tests and
"!                      the playground
"!
"! An addon or an app with a provider of its own implements this interface
"! itself; an app's unit test does the same with a double.
"!
"! An app holds a REF TO z2ui5_if_ui5_llm in a method, never as an attribute
"! (the app instance is serialized between roundtrips), and switches the
"! provider without touching the call. Endpoint, model and key come from the
"! app, which reads them from a destination or a configuration of its own -
"! no secret is ever written into a class (docs/agents/building-apps.md).
INTERFACE z2ui5_if_ui5_llm
  PUBLIC.

  TYPES:
    "! one turn of the conversation - role is cs_role-user or
    "! cs_role-assistant, the system prompt travels separately
    BEGIN OF ty_s_message,
      role    TYPE string,
      content TYPE string,
    END OF ty_s_message.
  TYPES ty_t_message TYPE STANDARD TABLE OF ty_s_message WITH EMPTY KEY.

  TYPES:
    "! model: the model id, exactly as the provider spells it; empty takes
    "! the model the provider was created with. max_tokens: the answer's
    "! limit, 0 for the provider's default. temperature: a decimal written
    "! as text (`0.2`, `1`) - sent as a JSON number as it stands, empty for
    "! the model's default; a text that is no number is refused before the
    "! request is built
    BEGIN OF ty_s_options,
      model       TYPE string,
      max_tokens  TYPE i,
      temperature TYPE string,
    END OF ty_s_options.

  TYPES:
    BEGIN OF ty_s_usage,
      input_tokens  TYPE i,
      output_tokens TYPE i,
    END OF ty_s_usage.

  TYPES:
    "! text: the answer. model: the model that answered, as the provider
    "! reports it. stop_reason: one of cs_stop where the provider's own word
    "! maps onto it, the provider's word otherwise
    BEGIN OF ty_s_result,
      text        TYPE string,
      model       TYPE string,
      stop_reason TYPE string,
      s_usage     TYPE ty_s_usage,
    END OF ty_s_result.

  CONSTANTS:
    BEGIN OF cs_role,
      user      TYPE string VALUE `user`,
      assistant TYPE string VALUE `assistant`,
    END OF cs_role.

  CONSTANTS:
    "! end_turn: the model finished; max_tokens: the answer was cut off at
    "! the token limit - the text is what fit; refusal: the model declined
    BEGIN OF cs_stop,
      end_turn   TYPE string VALUE `end_turn`,
      max_tokens TYPE string VALUE `max_tokens`,
      refusal    TYPE string VALUE `refusal`,
    END OF cs_stop.

  "! Sends the system prompt and the whole conversation, returns the answer.
  "! @parameter system    | instructions for the model - empty for none
  "! @parameter t_message | the conversation so far, oldest first, ending
  "!                        with the user message that is to be answered
  "! @parameter s_options | model, token limit and temperature of this call
  "! @parameter result    | the answer, its stop reason and the token usage
  "! @raising z2ui5_cx_ui5_llm | no model, no answer, an error the provider
  "!                        sent back, or an answer without text - the text
  "!                        says which, retryable whether the same call may
  "!                        succeed later
  METHODS chat
    IMPORTING
      system        TYPE clike OPTIONAL
      t_message     TYPE ty_t_message
      s_options     TYPE ty_s_options OPTIONAL
    RETURNING
      VALUE(result) TYPE ty_s_result
    RAISING
      z2ui5_cx_ui5_llm.

ENDINTERFACE.
