# MortalGPU

Kubernetes device plugin implementing the sharing of Nvidia GPUs between workloads.

MortalGPU looks for available GPUs and represents each GPU device (physical or MIG partition) with a
configurable amount of meta-devices.

Apart from generic GPU support for batch workloads (such as AI/ML or scientific sowtware),
the development has a strong focus on the workloads run by mortals (such as interactive Jupyter Notebooks).

From user perspective, MortalGPU provides a way to share the GPU between workloads with a capability
for memory overcommit, while maintaining VRAM allocation limit per GPU workload - the approach used for sharing RAM on Kubernetes.

It also provides the Kubernetes-aware GPU usage visibility on the Pod level.

Read more details here:

* <https://gitlab.com/MaxIV/kubernetes/mortalgpu>

## Configuring MortalGPU

The most important configuration to define is `config.deviceSharing`. It specifies which resources to define and
how many shares (meta-devices) to handle for matching physical GPU devices or MIG partitions.

In case of a simple homogeneous cluster (e.g. all GPUs are V100 32GB), it is enough to define one resource
mathing any GPU. The following example defines `mortalgpu/v100`, creating 320 shares for each discovered V100:
```
  deviceSharing:
    - resourceName: mortalgpu/v100
      metagpusPerGpu: 320
```

Alternatively, you can define desired memory chunk size per meta-device and MortalGPU will calculate number of shares
based on GPU memory automatically:
```
  deviceSharing:
    - resourceName: mortalgpu/v100
      metagpusPerGpuMemoryChunkMB: 100
```

Another real-life example from MAX IV jupyterhub: managing both *V100 32GB* GPUs and *A100 80GB* GPUs devided to 4 MIG partitions:
```
[root ~]# nvidia-smi -L
GPU 0: NVIDIA A100 80GB PCIe (UUID: GPU-4101de38-535a-4255-ac14-a63e072d7a10)
  MIG 3g.40gb     Device  0: (UUID: MIG-d771d938-b556-4f9d-b742-2dd26b864023)
  MIG 2g.20gb     Device  1: (UUID: MIG-08bce7f3-bac7-4715-b56f-91541f15fe37)
  MIG 1g.10gb     Device  2: (UUID: MIG-761ea9d1-82ac-41cb-9e19-d3593973f144)
  MIG 1g.10gb     Device  3: (UUID: MIG-a5b1e9ac-1c96-4ca0-b57c-53878e7531dc)

[root ~]# nvidia-smi
<output omitted>
+-----------------------------------------------------------------------------+
| MIG devices:                                                                |
+------------------+----------------------+-----------+-----------------------+
| GPU  GI  CI  MIG |         Memory-Usage |        Vol|         Shared        |
|      ID  ID  Dev |           BAR1-Usage | SM     Unc| CE  ENC  DEC  OFA  JPG|
|                  |                      |        ECC|                       |
|==================+======================+===========+=======================|
|  0    2   0   0  |     19MiB / 40192MiB | 42      0 |  3   0    2    0    0 |
|                  |      0MiB / 65535MiB |           |                       |
+------------------+----------------------+-----------+-----------------------+
|  0    3   0   1  |     13MiB / 19968MiB | 28      0 |  2   0    1    0    0 |
|                  |      0MiB / 32767MiB |           |                       |
+------------------+----------------------+-----------+-----------------------+
|  0    9   0   2  |      6MiB /  9728MiB | 14      0 |  1   0    0    0    0 |
|                  |      0MiB / 16383MiB |           |                       |
+------------------+----------------------+-----------+-----------------------+
|  0   10   0   3  |      6MiB /  9728MiB | 14      0 |  1   0    0    0    0 |
|                  |      0MiB / 16383MiB |           |                       |
+------------------+----------------------+-----------+-----------------------+
<output omitted>
```

MortalGPU configuration that describes 4 different shared resources based on the GPU model names and MIG partitioning of A100:
```
  deviceSharing:
    - resourceName: mortalgpu/a100-shared
      metagpusPerGpu: 400
      modelName: ['Tesla V100-PCIE-32GB']
    - resourceName: mortalgpu/a100-shared
      metagpusPerGpu: 400
      modelName: ['NVIDIA A100 80GB PCIe']
      migid:
       - 2
    - resourceName: mortalgpu/a100-20g
      metagpusPerGpu: 200
      modelName: ['NVIDIA A100 80GB PCIe']
      migid:
       - 3
    - resourceName: mortalgpu/a100-10g
      metagpusPerGpu: 100
      modelName: ['NVIDIA A100 80GB PCIe']
      migid:
       - 9
       - 10
```

For production deployment it is important to define strong JWT secret and generate unique
JWT tokens for gRPC security. Defaults embedded in the Chart allows zero configuration testing,
but should not endup in production environment.
Read information under `config.grpcSecurity` for more details.

Other Helm Chart options are targeting deployment fine-tuning and have sane defaults.
Please read the values reference for more details.

# Using MortalGPU managed resources in the workloads

Requesting the GPU share, managed by MortalGPU, is as simple as defining any resource, e.g.:
```yaml
    resources:
      limits:
        cpu: "8"
        mortalgpu/a100-shared: "40"
        memory: "107374182400"
      requests:
        cpu: 100m
        mortalgpu/a100-shared: "40"
        memory: 524288k
```

For more complete usage instructions, read [this document](https://gitlab.com/MaxIV/kubernetes/mortalgpu#using-mortalgpu-resources-in-workloads).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.visibleDevices | string | `"all"` | Set the [NVIDIA_VISIBLE_DEVICES](https://github.com/NVIDIA/nvidia-container-toolkit/tree/main/cmd/nvidia-container-runtime#nvidia_visible_devices) for MortalGPU Pods (affects GPU discovery) |
| config.migDevices | string | `"all"` | Set the [NVIDIA_MIG_CONFIG_DEVICES](https://github.com/NVIDIA/nvidia-container-toolkit/tree/main/cmd/nvidia-container-runtime#nvidia_mig_config_devices) and [NVIDIA_MIG_MONITOR_DEVICES](https://github.com/NVIDIA/nvidia-container-toolkit/tree/main/cmd/nvidia-container-runtime#nvidia_mig_monitor_devices) for MortalGPU Pods (affects GPU discovery) |
| config.log.verbose | bool | `false` | Log verbosity |
| config.log.json | bool | `true` | Log in JSON format |
| config.deviceSharing[0].resourceName | string | `"mortalgpu/v100"` | Name of the Kubernetes resource |
| config.deviceSharing[0].metagpusPerGpu | int | `320` | Number of metaGPUs per each matching physical device. It is recommended to set it based on GPU memory. |
| config.deviceSharing[0].metagpusPerGpuMemoryChunkMB | int | `0` | GPU memory chunk size to split the GPU to meta GPUs. Ignored if metagpusPerGpu is set |
| config.deviceSharing[0].reservedChunks | int | `0` | Number of metaGPUs which will not be allocated, by MortalGPU, so that they can be used by other workloads or other MortalGPU instances. Please pay attention that if the number of the reservedChunks is larger than the number of total chunks, then MortalGPU fails to start and goes to CrashLoopBackOff. |
| config.deviceSharing[0].uuid | list | `[]` | Filter mathing GPU devices by UUIDs. Empty list implies no filtering. |
| config.deviceSharing[0].modelName | list | `[]` | Filter matching GPU device names as in `nvidia-smi -L`. Empty list implies no filtering. |
| config.deviceSharing[0].migid | list | `[]` | Further filter MIG partitions on mathing GPU devices by MIG Instance IDs. Empty list implies no filtering on MIG basis. |
| config.allocator.plugin | string | `"collocate"` | Name of the used plugin, one of "collocate", "spread", "external". |
| config.allocator.allowCollocation | bool | `true` | Flag. If enabled allows scheduling multiple GPU containers on the same physical GPU for plugins which support it (spread, external). |
| config.allocator.noSplit | bool | `true` | Flag. If set, then MortalGPU will fail to start a Pod if it is impossible to allocate its request using one physical GPU. |
| config.allocator.externalConfig.path | string | `""` | Path to an executable |
| config.allocator.externalConfig.args | list | `[]` | Command line arguments to be passed to the executable |
| config.allocator.externalConfig.envVars | list | `[]` | Environment variables to be added to the default system environment. |
| config.memoryEnforcer | bool | `true` | Enforce process GPU memory usage by means of killing the process going over `resource.limits`. |
| config.deviceSpecs | bool | `false` | Enable passing the mounted devices specs in DevicePlugin allocation response. Enable if you are using CPUManager to allow DevicePlugin to interoperate with it. |
| config.mgctl.sourcePath | string | `"/usr/bin/mgctl"` | `mgctl` location inside MortalGPU container image |
| config.mgctl.hostMount.enabled | bool | `true` | Enable mounting of `mgctl` binary to resource requesting container (from hostPath via DevicePlugin API) |
| config.mgctl.hostMount.hostPath | string | `"/var/lib/mortalgpu/"` | Hostpath to use for `mgctl` binary location. If you are running multiple MortalGPU installations on the same host, make sure `hostPath` is unique. |
| config.mgctl.hostMount.containerPath | string | `"/usr/bin/"` | Path inside resource requesting container to mount `mgctl` |
| config.pluginMounts | list | `[]` | Extra device-plugin level mounts for contaienrs requesting MortalGPU resources. Can be usefull to inject centrally managed custom wrappers around mgctl. |
| config.grpcSecurity.deviceToken | string | change chart default in prodcution | Token with priviledge level 0 - access to device functions (e.g. for metrics extraction). You can find bash script example to generate tokens in assets/genjwt.sh. |
| config.grpcSecurity.containerToken | string | change chart default in prodcution | Token with priviledge level 1 - access to processes (e.g. from running GPU-enabled container) You can find bash script example to generate tokens in assets/genjwt.sh |
| config.grpcSecurity.jwtSecret | string | change chart default in prodcution | JWT signing key for priviledge level separation security |
| config.deviceManager.processesDiscoveryPeriod | int | `5` | Processes scanning loop frequency |
| config.deviceManager.deviceCacheTTL | int | `3600` | GPU devices cache validity |
| image.repository | string | `"quay.io/maxiv/mortalgpu"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| fullnameOverride | string | `""` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| podAnnotations | object | `{}` |  |
| securityContext.privileged | bool | `true` | Device plugin needs priviledged container |
| scc | bool | `false` | Create SecurityContextConstraints resource (for running on OpenShift/OKD) |
| service.type | string | `"ClusterIP"` |  |
| service.ports.grpc | int | `50052` | MortalGPU gRPC port |
| service.ports.mgdpMetrics | int | `2112` | Listening port for MortalGPU device plugins resource usage metrics (prometheus exporter) |
| service.ports.exporter | int | `2113` | Listening port for container-aware GPUs usage metrics (prometheus exporter) |
| runtimeClassName | string | `""` | Define runtimeClassName. You need to define this only if "nvidia" is not a default runtime. Note, if this is a case for Kuberentes cluster, than in addition to specifying MortalGPU external resources you need to specify the runtimeClassName in wokrload Pods as well. |
| resources | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| extraEnv | list | `[]` |  |
| exporter.enabled | bool | `true` | Enable MortalGPU Prometheus exporter |
| exporter.serviceMonitor.enabled | bool | `true` | Create service monitor |
| exporter.serviceMonitor.interval | string | `"15s"` |  |
| exporter.serviceMonitor.labels | object | `{}` |  |
| exporter.resources | object | `{}` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
