| Stage | Agent | Model | Requests | Input | Output | Cache read | Cache write | AI credits (range) | USD (range) |
|---|---|---|---:|---:|---:|---:|---:|---|---|
| Execution | `modernize-build-upgrader` | `gpt-5.6-luna` | ~10 | 6.8K | 2.4K | 302.0K | 41.5K | 2.1 (1.2 to 4.1) | $0.02 ($0.01 to $0.04) |
| Execution | `modernize-code-fixer` | `gpt-5.3-codex` | ~17 | 7.5K | 5.8K | 577.5K | 32.2K | 25.2 (15.1 to 75.5) | $0.25 ($0.15 to $0.76) |
| Execution | `modernize-conformance-reviewer` | `gpt-6.1-sol` | ~8 | 7.2K | 6.2K | 254.3K | 59.7K | 25.1 (15.1 to 50.2) | $0.25 ($0.15 to $0.50) |
| Execution | `modernize-standards-reviewer` | `claude-sonnet-5` | ~7 | 6.7K | 5.7K | 234.7K | 55.1K | 25.5 (15.3 to 51.0) | $0.26 ($0.15 to $0.51) |
| All | threat detection after each agent (4 runs) | `claude-haiku-5.5` | ~8 | | | | | 2.4 | $0.02 |
| **Total** | | | | | | | | **80.2 (49.1 to 183.2)** | **$0.80 ($0.49 to $1.83)** |

Estimate from token counts measured on a real run of this pipeline, scaled for this version's prompts. Prices: [GitHub Copilot models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing), read 2026-10-19. 1 AI credit = $0.01. Credits count against the Copilot plan of the `COPILOT_GITHUB_TOKEN` owner; usage beyond the plan's included credits is billed. Deterministic jobs (tests, Maven, OpenRewrite, OSV) use GitHub Actions minutes and no AI credits.
