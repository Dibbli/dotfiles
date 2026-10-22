---
name: reference_gpu_machine_ssh_home
description: "The NixOS desktop (host `home`) is the GPU box: RX 7800 XT 16 GiB, Ollama in Docker; a no-GPU client reaches it with `ssh home`"
metadata:
  type: reference
---

The NixOS desktop, hostname `home`, has the GPU. Local models run here.
- **GPU:** AMD Radeon RX 7800 XT (Navi 32, gfx1101), 16 GiB VRAM. ROCm needs `HSA_OVERRIDE_GFX_VERSION=11.0.0`. AMD, so no `nvidia-smi`.
- **Ollama:** Docker container `ollama` (`ollama/ollama:rocm`) on port 11434. The Docker root is `/mnt/SSD/docker`, so model data sits on `/mnt/SSD`.
- **Fit at 16 GiB:** a 24B model at Q4_K_M (about 13-14 GB) fits with tight context; a 12B (about 7-8 GB) leaves room for long context.
- **Remote mode:** a client without a GPU (the laptop) uses `ssh home` over the tailnet; aichat does this with `REMOTE_HOST=home` (see its README). It needs the desktop awake and tailscale up on both ends. Tailscale is not installed on the desktop since the NixOS migration, see [[project_remote_access_vpn]].

Related: [[reference_ollama_hf_gguf_import]], [[reference_home_gpu_model_storage]], [[project_nixos_config]].
