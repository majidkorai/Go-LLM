# Qwen3-Flash-Next MoE on 2x RTX 3090 with vLLM — guide + head-to-head benchmarks (IQ4_XS vs Q4_K_XL)

I published a small public guide/config/scripts repo (**Go-LLM**, no weights) for serving Qwen3-Flash-Next with vLLM. It documents two separate paths:

- **Official upstream:** vLLM nightly image on Blackwell-class hardware (e.g. DGX Spark / SM121, NVFP4 checkpoints)
- **Local workaround:** vLLM 0.29.0 GGUF-capable fork on 2x RTX 3090 (`sm_86`), with required patches and explicit launch flags. Do not expect a stock PyPI vLLM to serve this model on consumer cards.

## Head-to-head benchmarks (best config for each model)

| Metric | Q4_K_XL | IQ4_XS |
|---|---|---|
| Decode @8k | 32.4 tok/s | 40.6 tok/s |
| Decode @32k | 29.6-31.0 tok/s | 40.5 tok/s |
| Decode @128k | 30.3 tok/s | 40.9 tok/s |
| Prefill @8k | 854-911 tok/s | 307 tok/s |
| Prefill @32k | 869-1007 tok/s | 350 tok/s |
| 128K coherence | ok | ok |

**Takeaway:** IQ4_XS is about 27% faster on decode but about 2.5x slower on prefill. On long-context runs time-to-first-token was around 2 minutes with IQ4_XS. So: IQ4_XS for long streamed answers, Q4_K_XL when prefill / time-to-first-token dominates. Both are coherent at 128K under the best config for each.

**Honesty caveats:** these are local observations on one dual-3090 rig with a patched fork — not official Blackwell numbers and not guarantees across drivers, GPUs, vLLM versions, patch sets, or memory layouts. An older ~6665 tok/s prefill figure I floated earlier turned out to be non-reproducible under this model/config; disregard it. Earlier long-context degradation reports for Q4_K_XL were under non-best configs and should be read as historical failure-mode reports.

Repo: https://github.com/majidkorai/Go-LLM
