---
name: reference_ollama_hf_gguf_import
description: "How to pull a GGUF from HuggingFace with a bandwidth cap (aria2c) and import into the Dockerized Ollama, bypassing ollama pull"
metadata: 
  type: reference
---

`ollama pull` loops/saturates the link (chunked-download reset bug) and has no rate limit. Bypass it: download the GGUF yourself with aria2c (resumable + bandwidth-capped), then import as a local file. Do this on `ssh home` ([[reference_gpu_machine_ssh_home]]), which is the NixOS desktop itself. Put the GGUF on `/mnt/SSD` ([[reference_home_gpu_model_storage]]).

**Why aria2c + the cap:** capping the ollama client does nothing: the daemon inside the container does the download. aria2c downloads the file itself, capped, then `ollama create` just imports a local file (no network). `--max-overall-download-limit=8M` is the only reliable way to keep the download from saturating the line.

1. Download (single line, the user's terminal mangles `\` multi-line pastes, see CLAUDE.md):
   `aria2c -c -x4 -s4 --max-overall-download-limit=8M -o model.gguf "https://huggingface.co/<repo>/resolve/main/<file>.gguf?download=true"`
2. One-line Modelfile: `FROM ./model.gguf`
3. `docker cp` both files into the `ollama` container, then:
   `docker exec ollama sh -c "cd /root && ollama create <name> -f Modelfile"`

**Gotcha:** a bare `FROM ./file.gguf` carries only weights, not the chat template. After import, run one test prompt: coherent = template fine; garbled/looping = add `PARAMETER stop "<end_of_turn>"` (or the model's real stop token from the registry manifest / TEMPLATE lines) and re-create.

**Xet-backed HF repos** (most new ones, e.g. Qwen/Qwen3-Embedding-4B-GGUF): use one connection, `aria2c -c -x1 -s1 --max-overall-download-limit=8M ...`; multi-connection gets 403. Worked 2026-10-17. Naming the import like the registry tag (`ollama create qwen3-embedding:4b`) is fine, but then never let anything run `ollama pull` on that name (the docs-mcp nix module no longer does).
