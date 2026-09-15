# Required patch semantics for the local sm_86 path

The local vLLM path was not a stock PyPI install. It needed patches in three areas.

This page describes required semantics, not exact diffs. Apply the equivalent changes to your GGUF-capable vLLM fork.

## 1. PLE embedding quant-method resolver

### Problem

The per-layer embedding / PLE tensor can be rejected or misquantized because the GGUF config path returns no quant method for that tensor.

### Required behavior

When resolving the quant method for the PLE/per-layer embedding tensor, delegate to the GGUF tensor quant method resolver instead of returning no method.

Conceptually:

```python
# Bad shape
if tensor_is_ple_embedding:
    return None

# Good shape
if tensor_is_ple_embedding:
    return gguf_config.get_quant_method(tensor_name)
```

### Effect

The IQ4_NL PLE artifact is accepted with the intended quantization.

Without this, the documented local setup fails before stable serving.

## 2. Hyper-connection projection quant-config propagation

### Problem

Hyper-connection down/up projection paths can hardcode quant_config=None.

### Required behavior

Pass the active quant_config into hyper-connection projection tensor handling.

Conceptually:

```python
# Bad shape
projection = make_projection(quant_config=None)

# Good shape
projection = make_projection(quant_config=self.quant_config)
```

### Effect

Hyper-connection projections are treated consistently with the rest of the quantized graph.

Without this, the GGUF model can load into a mixed or incorrect projection path and fail or degrade.

## 3. PLE residency/offload and expert staging

### Problem

The packed PLE table can be materialized on GPU memory and OOM the dual RTX 3090 recipe.

### Required behavior

The packed PLE table must remain compatible with host residency/offload and expert staging. The server should not be forced to allocate the full packed PLE table on GPU as if it were resident.

The documented launch path uses:

```bash
GGUF_PLE_OFFLOAD=1
GGUF_PLE_EXPERT_STAGING=1
VLLM_NUM_EXPERT_STREAM_SLOTS=16
```

### Effect

The packed PLE table and expert stream slots are staged within the host/offload budget instead of being forced into GPU VRAM.

Without this, the documented path can load partially and then OOM.

## Patch hygiene

When maintaining a fork:

- Keep patch markers small and searchable.
- Do not embed private hostnames, absolute local paths, private address literals, or credential values in patch text.
- Record the upstream commit or image tag that the fork was rebased onto.
- Re-test after rebases because these patches touch model loading and quantization behavior.