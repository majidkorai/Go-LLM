# Launch recipe

This recipe documents the local vLLM path that was reported working on dual RTX 3090 hardware.

It is a workaround recipe, not the clean official Blackwell path.

## Prerequisites

For the official path, prefer:

```text
vllm/vllm-openai:qwen3-flash-next
```

on Blackwell-class hardware, for example DGX Spark GB10 / SM121.

For the local sm_86 path, expect all of the following:

- Linux with NVIDIA driver support compatible with CUDA 12.3.
- CUDA toolkit 12.3.
- TORCH_CUDA_ARCH_LIST=8.6.
- Two RTX 3090 GPUs. The documented setup used consumer 24 GiB cards, but total VRAM alone did not predict stability.
- A GGUF-capable vLLM 0.29.0 fork with the required patches in docs/patches.md.
- A large host-memory budget for PLE residency/offload and expert staging. The documented recipe used roughly a 70-80 GiB staging/offload budget, so 128 GiB host RAM is the safer assumption.

## Runtime variables

Use .env.example as the template.

Core variables:

```bash
MODEL_PATH=/path/to/Qwen3.8-Flash-Next-IQ4_XS.gguf
PLE_EMBEDDING_PATH=/path/to/per_layer_token_embd.iq4_nl.bin

CUDA_VISIBLE_DEVICES=0,1
TORCH_CUDA_ARCH_LIST=8.6

GGUF_PLE_OFFLOAD=1
GGUF_PLE_EXPERT_STAGING=1
VLLM_NUM_EXPERT_STREAM_SLOTS=16

KV_BUDGET_GB=2
OFFLOAD_STAGING_BUDGET_GB=80
MAX_NUM_BATCHED_TOKENS=4096
```

## Recommended launch flags

Use IQ4_XS for the stable long-context path.

```bash
vllm serve "$MODEL_PATH" --tensor-parallel-size 2 --max-num-batched-tokens "$MAX_NUM_BATCHED_TOKENS" --language-model-only --enforce-eager
```

## Why these toggles matter

| Toggle | Reason |
|---|---|
| GGUF_PLE_OFFLOAD=1 | Avoids materializing the packed PLE table entirely on the GPU, which can OOM on the documented sm_86 setup. |
| GGUF_PLE_EXPERT_STAGING=1 | Uses the staged/offloaded path that the local recipe depends on. |
| VLLM_NUM_EXPERT_STREAM_SLOTS=16 | Matches the tuned local shape; lower values starve throughput, higher values can exceed the budget. |
| --max-num-batched-tokens 4096 | Keeps batch allocation under the tested local limit. |
| --language-model-only | Avoids pulling unnecessary non-language-model components into the serving path. |
| --enforce-eager | CUDA graphs were unstable on this sm_86 plugin path. |

## KV budget

The local stable path kept KV around 2 GiB.

Higher KV budgets were reported to increase the risk of dual-GPU deadlock on this stack. Treat 2 GiB as the documented safe value, not a theoretical maximum.

## Expert staging budget

The documented staging/offload budget was around 70-80 GiB.

This is not a free setting. It requires enough host memory and stable staging behavior. If allocation failures appear near expert staging, lower the batch size first and inspect expert slot count before changing model quantization.

## What not to do on this path

- Do not use stock PyPI vLLM and expect Qwen4ExpForConditionalGeneration to be available.
- Do not enable CUDA graphs on the documented sm_86 plugin path.
- Do not enable MTP on sm_86 for this stack; FP8 MMA support was unavailable.
- Do not use TP=3 on the documented dual-GPU hardware; it OOMs.
- Do not use CPU-only MoE offload as the normal decode path; decode collapse was reported.
- Do not treat Q4_K_XL as the stable long-context default; IQ4_XS was the coherent long-context config.

## Official Blackwell path

If you have Blackwell-class hardware, do not start by trying to recreate the local sm_86 fork path. Start with the official nightly image path and the linked reference deployment.

See docs/sources.md for the official image and upstream pages.