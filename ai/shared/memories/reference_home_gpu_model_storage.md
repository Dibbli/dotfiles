---
name: reference_home_gpu_model_storage
description: "On the desktop, big model weights go on /mnt/SSD, not ~ or /; Forge and ComfyUI model dirs; Xet repos need single-stream curl"
metadata:
  type: reference
---

Download large model weights to `/mnt/SSD` (932G nvme), not `~` or `/`. `/mnt/HDD` is a spinning disk: avoid it for anything latency-sensitive. `/mnt/SSD` was 95% full on 2026-10-22, so run `df -h /mnt/SSD` before a big download.
- Forge SD stack: `/mnt/SSD/sd/models` (`Stable-diffusion/`, `Lora/`, `VAE/`, `embeddings/`, `ControlNet/`), mounted in the `forge` container as `/models-host`.
- ComfyUI: `/mnt/SSD/comfyui/models/` (`checkpoints/`, `unet/`, `vae/`, `text_encoders/`, `loras/`).

HF Xet-backed repos (for example Phr00t/WAN2.2-14B-Rapid-AllInOne, `h94/IP-Adapter`) sign each redirect for one byte range, so aria2c with `-s4` gets 403. Use single-stream `curl -L -C - --limit-rate 8M`. Related: [[reference_gpu_machine_ssh_home]], [[reference_ollama_hf_gguf_import]].
