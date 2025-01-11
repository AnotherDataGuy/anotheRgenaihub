Tests and Coverage
================
12 janvier, 2025 00:41:28

- [Coverage](#coverage)
- [Unit Tests](#unit-tests)

This output is created by
[covrpage](https://github.com/yonicd/covrpage).

## Coverage

Coverage summary is created using the
[covr](https://github.com/r-lib/covr) package.

| Object                                                                      | Coverage (%) |
|:----------------------------------------------------------------------------|:------------:|
| anotheRgenaihub                                                             |     8.27     |
| [R/app_config.R](../R/app_config.R)                                         |     0.00     |
| [R/app_server.R](../R/app_server.R)                                         |     0.00     |
| [R/app_ui.R](../R/app_ui.R)                                                 |     0.00     |
| [R/mod_assistant_builder_gpt_hub.R](../R/mod_assistant_builder_gpt_hub.R)   |     0.00     |
| [R/mod_main_local_gpt_agent.R](../R/mod_main_local_gpt_agent.R)             |     0.00     |
| [R/run_app.R](../R/run_app.R)                                               |     0.00     |
| [R/utils_dynamic_gpt_agent_ui.R](../R/utils_dynamic_gpt_agent_ui.R)         |     0.00     |
| [R/utils_templates.R](../R/utils_templates.R)                               |     0.99     |
| [R/utils_anotheRgenai_api.R](../R/utils_anotheRgenai_api.R)                 |     1.61     |
| [R/fct_gpt_helpers.R](../R/fct_gpt_helpers.R)                               |     5.14     |
| [R/utils_dynamic_gpt_agent_server.R](../R/utils_dynamic_gpt_agent_server.R) |    48.65     |
| [R/fct_helpers_server_to_template.R](../R/fct_helpers_server_to_template.R) |    73.10     |
| [R/utils_anotheRgenai_configs.R](../R/utils_anotheRgenai_configs.R)         |    77.27     |

<br>

## Unit Tests

Unit Test summary is created using the
[testthat](https://github.com/r-lib/testthat) package.

| file                                                                                    |   n | time | error | failed | skipped | warning | icon |
|:----------------------------------------------------------------------------------------|----:|-----:|------:|-------:|--------:|--------:|:-----|
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R)                               |  29 | 0.35 |     0 |      0 |       1 |       0 | \+   |
| [test-fct_helpers_server_to_template.R](testthat/test-fct_helpers_server_to_template.R) |   1 | 0.01 |     0 |      0 |       0 |       0 |      |
| [test-mod_assistant_builder_gpt_hub.R](testthat/test-mod_assistant_builder_gpt_hub.R)   |   1 | 0.00 |     0 |      0 |       0 |       0 |      |
| [test-mod_main_local_gpt_agent.R](testthat/test-mod_main_local_gpt_agent.R)             |   1 | 0.02 |     0 |      0 |       0 |       0 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R)                   |   6 | 1.14 |     0 |      0 |       0 |       0 |      |
| [test-utils_dynamic_gpt_config.R](testthat/test-utils_dynamic_gpt_config.R)             |   1 | 0.01 |     0 |      0 |       0 |       0 |      |

<details open>
<summary>
Show Detailed Test Results
</summary>

| file                                                                                       | context                        | test                                                     | status  |   n | time | icon |
|:-------------------------------------------------------------------------------------------|:-------------------------------|:---------------------------------------------------------|:--------|----:|-----:|:-----|
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L9)                               | fct_gpt_helpers                | create_config returns expected structure                 | PASS    |   5 | 0.07 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L22)                              | fct_gpt_helpers                | init_enhanced_config validates inputs                    | PASS    |   4 | 0.21 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L39)                              | fct_gpt_helpers                | validate_api_key works correctly                         | PASS    |   4 | 0.01 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L47)                              | fct_gpt_helpers                | get_color_scheme returns expected colors                 | PASS    |   5 | 0.02 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L58)                              | fct_gpt_helpers                | extract_ui_settings handles defaults                     | PASS    |   5 | 0.01 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L84)                              | fct_gpt_helpers                | generate_css_styles produces valid CSS                   | PASS    |   3 | 0.00 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L103)                             | fct_gpt_helpers                | generate_message_renderer handles basic cases            | PASS    |   2 | 0.02 |      |
| [test-fct_gpt_helpers.R](testthat/test-fct_gpt_helpers.R#L111)                             | fct_gpt_helpers                | API functions skip in test environment                   | SKIPPED |   1 | 0.01 | \+   |
| [test-fct_helpers_server_to_template.R](testthat/test-fct_helpers_server_to_template.R#L2) | fct_helpers_server_to_template | multiplication works                                     | PASS    |   1 | 0.01 |      |
| [test-mod_assistant_builder_gpt_hub.R](testthat/test-mod_assistant_builder_gpt_hub.R#L2)   | mod_assistant_builder_gpt_hub  | multiplication works                                     | PASS    |   1 | 0.00 |      |
| [test-mod_main_local_gpt_agent.R](testthat/test-mod_main_local_gpt_agent.R#L2)             | mod_main_local_gpt_agent       | multiplication works                                     | PASS    |   1 | 0.02 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R#L19)                  | utils_dynamic_gpt_api          | RateLimiter class initialization sets correct parameters | PASS    |   1 | 0.06 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R#L32)                  | utils_dynamic_gpt_api          | execute_with_rate_limit handles successful API calls     | PASS    |   1 | 0.02 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R#L50)                  | utils_dynamic_gpt_api          | execute_with_rate_limit implements retry logic           | PASS    |   2 | 1.03 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R#L72)                  | utils_dynamic_gpt_api          | execute_with_rate_limit respects rate limits             | PASS    |   1 | 0.01 |      |
| [test-utils_dynamic_gpt_api.R](testthat/test-utils_dynamic_gpt_api.R#L82_L85)              | utils_dynamic_gpt_api          | execute_with_rate_limit handles non-retryable errors     | PASS    |   1 | 0.02 |      |
| [test-utils_dynamic_gpt_config.R](testthat/test-utils_dynamic_gpt_config.R#L2)             | utils_dynamic_gpt_config       | multiplication works                                     | PASS    |   1 | 0.01 |      |

| Failed | Warning | Skipped |
|:-------|:--------|:--------|
| !      | \-      | \+      |

</details>
<details>
<summary>
Session Info
</summary>

| Field    | Value                             |
|:---------|:----------------------------------|
| Version  | R version 4.4.0 (2024-04-24 ucrt) |
| Platform | x86_64-w64-mingw32/x64            |
| Running  | Windows 11 x64 (build 22631)      |
| Language | French_France                     |
| Timezone | Europe/Paris                      |

| Package  | Version |
|:---------|:--------|
| testthat | 3.2.2   |
| covr     | 3.6.4   |
| covrpage | 0.2     |

</details>
<!--- Final Status : skipped/warning --->
