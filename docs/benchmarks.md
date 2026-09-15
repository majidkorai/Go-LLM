# Benchmarks

These numbers are local observations for the documented sm_86 dual RTX 3090 path. They are not official Blackwell numbers and they are not guarantees for other hosts.

## IQ4_XS

Recommended stable local config.

| Context | Direction | Measured value | Notes |
|---:|---|---:|---|
| 1k | decode | >40 tok/s | Tuned short-context decode. |
| 32k | decode | ~31 tok/s | Coherent long-context behavior. |
| 126k | decode | ~19 tok/s | Useful but slow; long context costs GPU attention and hybrid indexer work. |
| 32k | prefill | ~1104 tok/s | Fresh prefill, no warm cache assumed. |

## Q4_K_XL

Experimental only.

| Context | Direction | Measured value | Notes |
|---:|---|---:|---|
| 1k | decode | ~32.3 tok/s | Short-context decode was close enough to be tempting. |
| 8k | prefill | ~854 tok/s | Short prefill was acceptable. |
| long context | decode or prefill | unstable | Crashes or degradation were reported after large staged/offloaded allocations. |

Do not use Q4_K_XL as the default for long context in this local path.

## Historical non-reproducible number

An older prefill baseline around:

```text
~6665 tok/s
```

was later determined not to be reproducible under the documented model/config. Do not use it as the expectation.

The plausible local ceiling is closer to the fresh long-context prefill numbers above, not the historical figure.

## Why long context degrades

Long-context decode slows because GPU-side attention and hybrid indexer style segments grow with context length. The degradation was measured across 1k, 32k, and 126k prompts.

This is context-length cost, not a simple time-based decay.