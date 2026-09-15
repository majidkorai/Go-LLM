# Benchmarks

These numbers are local observations for the documented sm_86 dual RTX 3090 path. They are not official Blackwell numbers and they are not guarantees for other hosts.

## Head-to-head (best config for each)

| Metric | Q4_K_XL | IQ4_XS |
|---:|---:|---:|
| Decode @8k | 32.4 tok/s | 40.6 tok/s |
| Decode @32k | 29.6-31.0 tok/s | 40.5 tok/s |
| Decode @128k | 30.3 tok/s | 40.9 tok/s |
| Prefill @8k | 854-911 tok/s | 307 tok/s |
| Prefill @32k | 869-1007 tok/s | 350 tok/s |
| 128K coherence | ok (M=122827) | ok (M=120884) |

## How to choose

- IQ4_XS: decode-bound or long streamed answers.
- Q4_K_XL: prefill-heavy or time-to-first-token-heavy requests.
- If both models must be used, keep the best-config launch toggles separate for each model.

## Why the tradeoff exists

IQ4_XS pays much more time up front to build the prompt state: in the latest head-to-head, its prefill was about 2.5x slower than Q4_K_XL. Once decode starts, IQ4_XS sustains around 40.5-40.9 tok/s from 8k to 128k in these notes, about 27% faster than Q4_K_XL.

The practical bottleneck is therefore different for the two models: prefill/TTFS for IQ4_XS, decode throughput for Q4_K_XL.

## Historical non-reproducible number

An older prefill baseline around:

```text
~6665 tok/s
```

was later determined not to be reproducible under the documented model/config. Do not use it as the expectation.

The plausible local ceiling is closer to the fresh long-context prefill numbers above, not the historical figure.

## Where the time goes

Long-context runs were reported with TTFS around 2 min. In the corrected head-to-head, decode was the stable side for both models at 128K: Q4_K_XL stayed coherent at about 30 tok/s, while IQ4_XS stayed around about 41 tok/s.

The older long-context degradation note should be treated as a historical failure-mode report under non-best configs, not as the expected behavior for the corrected runs.