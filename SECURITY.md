# Security and privacy policy

When reporting issues, remove:

- Model weights or generated GGUF artifacts.
- Private hostnames.
- Private IP addresses.
- SSH credentials.
- Service credentials.
- Bot credentials.
- API credentials.
- Full local absolute paths.
- Logs that expose private infrastructure.

Use placeholders:

```bash
MODEL_PATH=/path/to/model.gguf
PLE_EMBEDDING_PATH=/path/to/artifact.bin
```

Before publishing changes, scan tracked files for local-only identifiers, local mount references, private address literals, and credential-like values.