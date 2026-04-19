# HAMi - Heterogeneous AI Computing Virtualization Middleware

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/HAMi-io/HAMi)](https://goreportcard.com/report/github.com/HAMi-io/HAMi)

HAMi is a Kubernetes device plugin and scheduler extension that enables fine-grained sharing and isolation of heterogeneous AI accelerators (GPUs, NPUs, etc.) across workloads.

## Features

- **GPU Sharing**: Share a single GPU across multiple pods with memory and compute isolation
- **Multi-vendor Support**: NVIDIA GPU, Cambricon MLU, Hygon DCU, Iluvatar GPU, and more
- **Resource Quotas**: Enforce GPU memory and core utilization limits per container
- **Kubernetes Native**: Works as a standard device plugin and scheduler extender
- **Monitoring**: Prometheus metrics for GPU utilization and memory usage per pod

## Architecture

```
┌─────────────────────────────────────────────┐
│                Kubernetes API               │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────▼──────────┐
    │   HAMi Scheduler    │  (scheduler extender)
    └──────────┬──────────┘
               │
    ┌──────────▼──────────┐
    │  HAMi Device Plugin │  (per node daemonset)
    └──────────┬──────────┘
               │
    ┌──────────▼──────────┐
    │    HAMi Hook Lib    │  (injected into containers)
    └─────────────────────┘
```

## Quick Start

### Prerequisites

- Kubernetes >= 1.23
- Helm >= 3.0
- NVIDIA drivers installed on GPU nodes (for NVIDIA GPU support)

### Installation

```bash
helm repo add hami https://hami-io.github.io/HAMi
helm repo update
helm install hami hami/hami -n kube-system
```

### Usage

Request a fraction of GPU resources in your pod spec:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  containers:
  - name: app
    image: nvidia/cuda:12.0-base
    resources:
      limits:
        nvidia.com/gpu: 1
        nvidia.com/gpumem: 8192   # 8GB GPU memory (increased from default 4096)
        nvidia.com/gpucores: 50   # 50% GPU compute
```

## Building from Source

```bash
git clone https://github.com/HAMi-io/HAMi.git
cd HAMi
make build
```

See the [Makefile](Makefile) for all available build targets.

## Contributing

We welcome contributions! Please read our [contribution guidelines](.github/PULL_REQUEST_TEMPLATE.md) and open an issue or pull request.

- [Bug Reports](.github/ISSUE_TEMPLATE/bug-report.md)
- [Feature Requests](.github/ISSUE_TEMPLATE/enhancement.md)
- [Questions](.github/ISSUE_TEMPLATE/question.md)

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This project is a fork of [Project-HAMi/HAMi](https://github.com/Project-HAMi/HAMi).
