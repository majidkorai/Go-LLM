# Benchmarks

These numbers are local observations for the documented sm_86 dual RTX 3090 path. They are not official Blackwell numbers and they are not guarantees for other hosts.

## IQ4_XS

Recommended stable local config.

| Context | Direction | Measured value | Notes |
|---:|---|---:|---|
| 1k | decode | >40 tok/s | Reported consistent across 1k, 32k, and 128k. |
| 32k | decode | >40 tok/s | Reported consistent across 1k, 32k, and 128k. |
| 128k | decode | >40 tok/s | Reported consistent across 1k, 32k, and 128k. |
| 32k | prefill | ~1104 tok/s | Fresh prefill remained slower than decode. |
| long context | TTFS | ~2 min | Reported time-to-first-token/stream for long-context runs. |

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

## Where the time goes

Long-context runs were reported with TTFS around 2 min. Decode, once streaming, was reported above 40 tok/s across 1k, 32k, and 128k. The prefill and first-token path is therefore the practical bottleneck in these notes.

The previous long-context degradation note was stale for IQ4_XS and should not be treated as the expected behavior for the corrected runs.