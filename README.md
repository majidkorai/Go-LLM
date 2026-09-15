# Go-LLM

Go-LLM is a public guide for running Qwen3.8-Flash-Next / Qwen4ExpForConditionalGeneration with vLLM.

This is a guide, config, and recipe repository. It does not contain model weights. Use the upstream public model sources linked in docs/sources.md.

## What this repository documents

- Official vLLM Flash-Next path through the vLLM nightly image.
- Local sm_86 path on dual RTX 3090 cards, using a GGUF-capable vLLM 0.29.0 fork, patches, and explicit launch toggles.
- Known-good local launch shape, benchmark expectations, and failure modes.
- Sanitization rules so others can reuse the recipe without exposing local infrastructure or credentials.

## Important distinction

vLLM Flash-Next support is not the same thing on all hardware.

| Path | Hardware class | Runtime | Status |
|---|---|---|---|
| Official Flash-Next path | Blackwell-class hardware, for example DGX Spark GB10 / SM121 | vLLM nightly image vllm/vllm-openai:qwen3-flash-next | Preferred upstream path |
| Local sm_86 path | Dual RTX 3090, CUDA sm_86 | vLLM 0.29.0 fork with GGUF plugin and local patches | Documented local workaround |

The local sm_86 path can work, but it is not the clean official Blackwell recipe. Do not assume a stock PyPI vLLM install will serve Flash-Next on sm_86.

## Recommended local model choice

For the local dual RTX 3090 path, choose by workload:

| Goal | Best local model | Why |
|---:|---|---|
| Streaming decode speed | IQ4_XS | ~27% faster decode in the head-to-head |
| Fast prefill / time-to-first-token | Q4_K_XL | ~2.5x faster prefill in the head-to-head |
| Coherent 128K operation | Both, with best config | Both reported OK at 128K coherence |

Keep the historical Q4_K_XL instability reports as a caveat: the latest head-to-head used the best config for each model.

## Quick orientation

1. Read docs/launch-recipe.md.
2. Apply the patch requirements in docs/patches.md.
3. Set values in .env.example, then run scripts/serve-qwen-flash-next.sh.
4. Compare against docs/benchmarks.md.
5. If a run fails, check docs/troubleshooting.md.

## Benchmarks (local observations)

These are observed on the documented local dual RTX 3090 `sm_86` path. They are not official Blackwell numbers and not guarantees across drivers, GPUs, vLLM revisions, patch sets, or system memory layouts.

### Head-to-head (best config for each)

| Metric | Q4_K_XL | IQ4_XS |
|---:|---:|---:|
| Decode @8k | 32.4 tok/s | 40.6 tok/s |
| Decode @32k | 29.6-31.0 tok/s | 40.5 tok/s |
| Decode @128k | 30.3 tok/s | 40.9 tok/s |
| Prefill @8k | 854-911 tok/s | 307 tok/s |
| Prefill @32k | 869-1007 tok/s | 350 tok/s |
| 128K coherence | ok (M=122827) | ok (M=120884) |

Result: IQ4_XS is about 27% faster on decode, but about 2.5x slower on prefill. For long-context runs, TTFS was around 2 minutes, with prefill as the slow side for IQ4_XS.

Use IQ4_XS for decode-bound or long streamed answers. Use Q4_K_XL when prefill or time-to-first-token dominates the workload.

### Historical caveat

The older `~6665 tok/s` prefill baseline was later determined not to be reproducible under the documented model/config. Do not use it as an expectation.

## What is intentionally out of scope

- Model weights.
- Private hostnames, private IP addresses, SSH credentials, service credentials, bot credentials, API credentials, or local absolute paths.
- Other runtimes and serving stacks that are not vLLM Flash-Next.
- Reproducing historical performance figures that were later found to be non-reproducible.

## Upstream model sources

Use public sources instead of copying weights into this repository:

- Qwen model page: [huggingface.co/Qwen/Qwen3.8-Flash-Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)
- vLLM recipe page: [recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next](https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next)
- NVFP4 model repositories:
  - [huggingface.co/RadixArk/Qwen3.8-Flash-Next-NVFP4](https://huggingface.co/RadixArk/Qwen3.8-Flash-Next-NVFP4)
  - [huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4)
- Reference Blackwell deployment:
  - [github.com/getrefined/Qwen3.8-Flash-Next-NVFP4-vLLM-DGX-Spark](https://github.com/getrefined/Qwen3.8-Flash-Next-NVFP4-vLLM-DGX-Spark)

## Honesty notes

- The official Flash-Next recipe targets newer Blackwell-class hardware. This repository documents a different local sm_86 path.
- The local path depends on patches and toggles. Without them, the documented failures are expected.
- Benchmark numbers are local observations from the documented stack, not guarantees across different drivers, GPUs, vLLM revisions, patch sets, or system memory layouts.