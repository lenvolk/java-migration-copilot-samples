| Stage | Agent | Model | Requests | Input | Output | Cache read | Cache write | AI credits (range) | USD (range) |
|---|---|---|---:|---:|---:|---:|---:|---|---|
| Execution | `modernize-build-upgrader` | `claude-haiku-5.5` | ~11 | 6.4K | 6.5K | 406.4K | 46.4K | 1.4 (1.0 to 2.5) | $0.01 ($0.01 to $0.02) |
| Execution | `modernize-code-fixer` | `claude-sonnet-5.5` | ~13 | 6.5K | 4.1K | 475.2K | 44.4K | 21.2 (14.8 to 63.6) | $0.21 ($0.15 to $0.64) |
| Execution | `modernize-conformance-reviewer` | `claude-sonnet-5.5` | ~10 | 5.4K | 6.0K | 389.2K | 53.8K | 24.5 (17.1 to 44.0) | $0.24 ($0.17 to $0.44) |
| Execution | `modernize-standards-reviewer` | `claude-sonnet-5` | ~11 | 6.4K | 5.1K | 408.0K | 51.1K | 27.4 (19.1 to 49.2) | $0.27 ($0.19 to $0.49) |
| All | threat detection after each agent (4 runs, same model as the agent) | | ~8 | | | | | 37.9 | $0.38 |
| **Total** | | | | | | | | **112.3 (90.0 to 197.3)** | **$1.12 ($0.90 to $1.97)** |

Estimate from token counts measured on a full real run of this pipeline (2026-10-19). Prices: [GitHub Copilot models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing), read 2026-10-19. 1 AI credit = $0.01. Credits count against the Copilot plan of the `COPILOT_GITHUB_TOKEN` owner; usage beyond the plan's included credits is billed. Deterministic jobs (tests, Maven, OpenRewrite, OSV) use GitHub Actions minutes and no AI credits.
