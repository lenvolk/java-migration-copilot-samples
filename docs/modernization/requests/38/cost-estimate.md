Predicted at gate 1 for every stage:

| Stage | AI tokens | AI credits | AI USD | Runner minutes | Runner USD | Basis |
|---|---:|---:|---:|---:|---:|---|
| Assessment (actual) | 2.38M | 38.8 | $0.39 | 27 | $0.00 (public; $0.16 if private) | AI: actual; minutes: this run |
| Plan (predicted) | 648.7K | 46.0 (36.6 to 70.8) | $0.46 ($0.37 to $0.71) | 12 | $0.00 (public; $0.07 if private) | AI: measured token profile; minutes: baseline (no past run in this repo) |
| Execution (predicted) | 2.26M | 112.3 (90.0 to 197.3) | $1.12 ($0.90 to $1.97) | 46 | $0.00 (public; $0.28 if private) | AI: measured token profile; minutes: baseline (no past run in this repo) |
| **Total** | **5.28M** | **197.0 (165.3 to 306.8)** | **$1.97 ($1.65 to $3.07)** | **85** | **$0.00 (public; $0.51 if private)** | |

AI: 1 credit = $0.01, [Copilot models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing). Runner minutes: standard Linux runner, each job rounded up to a whole minute, $0.006 per minute ([Actions runner pricing](https://docs.github.com/en/billing/reference/actions-runner-pricing), read 2026-10-20). This repository is public; standard runners are free on public repositories.

<!-- modernize-cost-json:predicted {"version":1,"generated_at":"2026-10-20T21:54:05+00:00","repo":"lenvolk/java-migration-copilot-samples","run":"39502651438","private":false,"rate":0.006,"loc":1287,"stages":{"assessment":{"kind":"actual","ai_credits":38.752123000000005,"ai_low":null,"ai_high":null,"tokens":2375170,"minutes":27,"minutes_source":"this run"},"plan":{"kind":"predicted","ai_credits":45.95008,"ai_low":36.614143,"ai_high":70.845912,"tokens":648712,"minutes":12,"minutes_source":"baseline"},"execution":{"kind":"predicted","ai_credits":112.29510049999999,"ai_low":89.97995255000001,"ai_high":197.2502257,"tokens":2257345,"minutes":46,"minutes_source":"baseline"}}} -->

Execution stage, per agent:

| Stage | Agent | Model | Requests | Input | Output | Cache read | Cache write | AI credits (range) | USD (range) |
|---|---|---|---:|---:|---:|---:|---:|---|---|
| Execution | `modernize-build-upgrader` | `claude-haiku-5.5` | ~11 | 6.4K | 6.5K | 406.4K | 46.4K | 1.4 (1.0 to 2.5) | $0.01 ($0.01 to $0.02) |
| Execution | `modernize-code-fixer` | `claude-sonnet-5.5` | ~13 | 6.5K | 4.1K | 475.2K | 44.4K | 21.2 (14.8 to 63.6) | $0.21 ($0.15 to $0.64) |
| Execution | `modernize-conformance-reviewer` | `claude-sonnet-5.5` | ~10 | 5.4K | 6.0K | 389.2K | 53.8K | 24.5 (17.1 to 44.0) | $0.24 ($0.17 to $0.44) |
| Execution | `modernize-standards-reviewer` | `claude-sonnet-5` | ~11 | 6.4K | 5.1K | 408.0K | 51.1K | 27.4 (19.1 to 49.2) | $0.27 ($0.19 to $0.49) |
| All | threat detection after each agent (4 runs, same model as the agent) | | ~8 | | | | | 37.9 | $0.38 |
| **Total** | | | | | | | | **112.3 (90.0 to 197.3)** | **$1.12 ($0.90 to $1.97)** |

Estimate from token counts measured on a full real run of this pipeline (2026-10-19). Prices: [GitHub Copilot models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing), read 2026-10-19. 1 AI credit = $0.01. Credits count against the Copilot plan of the `COPILOT_GITHUB_TOKEN` owner; usage beyond the plan's included credits is billed. Deterministic jobs (tests, Maven, OpenRewrite, OSV) use GitHub Actions minutes and no AI credits.
