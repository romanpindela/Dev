# Automated GitHub CLI Authentication Tool

An enterprise-grade shell automation solution engineered to dynamically provision, test, and authenticate the native GitHub Command Line Interface (`gh`) on Windows machines using the secure SSH protocol context.

## Metadata & Ownership
* **Author:** Roman Pindela
* **Contact Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub Profile:** [https://github.com/romanpindela](https://github.com/romanpindela)
* **Current Version:** `1.0.0`
* **Development Date:** June 2026

---

## Technical Flow Overview
1. **Dependency Audit:** Checks system environmental `$env:PATH` scopes for pre-existing `git` and `gh` execution matrices.
2. **Dynamic Provisioning:** Leverages the Windows Package Manager App Repository (`winget`) to pull down missing GitHub CLI engines silently.
3. **Structured Auth Interface:** Wraps the interactive browser-based authentication sequence using parameter enforcement flags (`--git-protocol ssh --web`).

---

## Execution Guide

### 1. View Script Metadata and Manual
```powershell
powershell -ExecutionPolicy Bypass -File .\connect-github-cli.ps1 -Help