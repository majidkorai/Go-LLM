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

For the local dual RTX 3090 path, the only coherent long-context configuration in the documented notes is IQ4_XS.

Use IQ4_XS when stability and long context matter.

Use Q4_K_XL only experimentally; the documented notes report long-context degradation and crashes after large staged/offloaded allocations.

## Quick orientation

1. Read docs/launch-recipe.md.
2. Apply the patch requirements in docs/patches.md.
3. Set values in .env.example, then run scripts/serve-qwen-flash-next.sh.
4. Compare against docs/benchmarks.md.
5. If a run fails, check docs/troubleshooting.md.

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