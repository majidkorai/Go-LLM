# Sources and upstream references

Go-LLM does not host weights. Use public model and documentation sources.

## Model and recipe pages

- Qwen model page: [https://huggingface.co/Qwen/Qwen3.8-Flash-Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)
- vLLM recipe page: [https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next](https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next)

## NVFP4 model repositories

The official Blackwell-class recipe is centered on the NVFP4 checkpoint family.

- [https://huggingface.co/RadixArk/Qwen3.8-Flash-Next-NVFP4](https://huggingface.co/RadixArk/Qwen3.8-Flash-Next-NVFP4)
- [https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4)

## Reference deployment

- [https://github.com/getrefined/Qwen3.8-Flash-Next-NVFP4-vLLM-DGX-Spark](https://github.com/getrefined/Qwen3.8-Flash-Next-NVFP4-vLLM-DGX-Spark)

This reference is important because it documents a first working vLLM deployment of the NVFP4 model on DGX Spark hardware and shows that the Flash-Next path can require a small PLE quant-method resolver patch.

## Model shape summary

The vLLM recipe page describes a large MoE / hybrid model family. Treat upstream pages as authoritative for exact tensor counts, parameter counts, and architecture names.

## Official image path

The documented official image is:

```text
vllm/vllm-openai:qwen3-flash-next
```

This image corresponds to the Flash-Next-capable vLLM line discussed in the notes, around 0.29.0+. It is not the same as installing the latest stock PyPI vLLM on an older CUDA architecture.

## GGUF artifacts for the local sm_86 path

The local sm_86 path in this guide uses GGUF-era artifacts. Do not upload large generated GGUFs to this repository. Instead:

- Publish scripts that create or verify artifacts.
- Publish checksum prefixes and expected sizes.
- Link upstream source checkpoints when redistribution is permitted.
- Keep generated artifacts outside the public repo.

The documented extracted PLE embedding artifact was:

```text
per_layer_token_embd.iq4_nl.bin
size: 28800138240 bytes
sha256 prefix: dd55c289...c56cc3
format: IQ4_NL
```