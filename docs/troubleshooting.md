# Troubleshooting and failure modes

## Model architecture is not found

Symptom:

```text
Qwen4ExpForConditionalGeneration is unavailable
```

Cause:

Stock PyPI vLLM does not contain the documented Flash-Next architecture support for this local path.

Action:

- Use the official nightly image on supported Blackwell-class hardware, or
- Use a GGUF-capable vLLM fork with the patch requirements from docs/patches.md.

## PLE quant method fails

Symptom:

- Loading fails near per_layer_token_embd or PLE tensors.
- Quantization metadata is not resolved.

Cause:

The GGUF config path returns no quant method for the PLE/per-layer embedding tensor.

Action:

Apply the PLE quant-method resolver patch described in docs/patches.md.

## Hyper-connection projection error

Symptom:

- Failure during model load or first forward.
- Hyper-connection down/up projection tensors do not match the expected quantized path.

Cause:

The projection path hardcodes quant_config=None.

Action:

Patch hyper-connection projection handling to propagate the active quant_config.

## GPU OOM during load

Symptom:

The process dies during loading or first prefill, often while allocating PLE or expert structures.

Likely causes:

- PLE residency/offload disabled.
- Expert staging disabled.
- KV budget too high.
- Batch token count too high.

Action:

```bash
GGUF_PLE_OFFLOAD=1
GGUF_PLE_EXPERT_STAGING=1
VLLM_NUM_EXPERT_STREAM_SLOTS=16
--max-num-batched-tokens 4096
KV_BUDGET_GB=2
```

## Dual-GPU deadlock

Symptom:

The process stops making progress with both GPUs stuck or idle.

Likely cause:

KV budget or allocation pressure too high on this stack.

Action:

Return KV to about 2 GiB and reduce batch token count before increasing model size or context.

## TP=3 OOM

Symptom:

Tensor parallel size 3 fails.

Action:

Use TP=2 for the documented dual RTX 3090 setup.

## CUDA graph instability

Symptom:

Random failures, hangs, or unstable capture during startup.

Cause:

CUDA graphs were unstable on the sm_86 plugin path.

Action:

Run with:

```bash
--enforce-eager
```

## MTP unavailable

Symptom:

MTP-related paths fail or provide no usable behavior on the local stack.

Cause:

FP8 MMA support was unavailable on this sm_86 path.

Action:

Do not enable MTP for this documented local vLLM setup.

## Q4_K_XL long-context crashes

Symptom:

Q4_K_XL seems fine at short context but crashes or degrades at long context.

Cause:

Large staged/offloaded allocations interact badly with this quantization/config on the documented path.

Action:

Switch to IQ4_XS for long-context serving.

## Decode collapse with CPU-only expert offload

Symptom:

Decode becomes unacceptably slow when experts are moved to CPU-only paths.

Cause:

CPU-only MoE expert offload was a dead end for this configuration.

Action:

Use the documented expert staging path, not naive CPU-only expert offload.

## Published files contain local-only references

Symptom:

A sanitized repo still includes private mount references, private hostnames, private address literals, or absolute local workspace paths.

Action:

Before publishing, scan tracked files and replace them with generic placeholders such as:

```bash
MODEL_PATH=/path/to/model.gguf
PLE_EMBEDDING_PATH=/path/to/per_layer_token_embd.iq4_nl.bin
```