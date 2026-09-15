#!/usr/bin/env bash
set -euo pipefail

MODEL_PATH="${MODEL_PATH:?Set MODEL_PATH to your IQ4_XS GGUF path.}"
PLE_EMBEDDING_PATH="${PLE_EMBEDDING_PATH:?Set PLE_EMBEDDING_PATH to your IQ4_NL PLE artifact path.}"

export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0,1}"
export TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.6}"
export PLE_EMBEDDING_PATH

export GGUF_PLE_OFFLOAD="${GGUF_PLE_OFFLOAD:-1}"
export GGUF_PLE_EXPERT_STAGING="${GGUF_PLE_EXPERT_STAGING:-1}"
export VLLM_NUM_EXPERT_STREAM_SLOTS="${VLLM_NUM_EXPERT_STREAM_SLOTS:-16}"

KV_BUDGET_GB="${KV_BUDGET_GB:-2}"
OFFLOAD_STAGING_BUDGET_GB="${OFFLOAD_STAGING_BUDGET_GB:-80}"
MAX_NUM_BATCHED_TOKENS="${MAX_NUM_BATCHED_TOKENS:-4096}"

echo "Go-LLM local sm_86 recipe"
echo "model=${MODEL_PATH}"
echo "kv_budget_GiB=${KV_BUDGET_GB}"
echo "offload_staging_budget_GiB=${OFFLOAD_STAGING_BUDGET_GB}"
echo "max_batched_tokens=${MAX_NUM_BATCHED_TOKENS}"

exec vllm serve "$MODEL_PATH" --tensor-parallel-size 2 --max-num-batched-tokens "$MAX_NUM_BATCHED_TOKENS" --language-model-only --enforce-eager "$@"