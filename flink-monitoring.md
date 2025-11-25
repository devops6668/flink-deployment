```
helm upgrade flink-kubernetes-operator -f - flink-operator-repo/flink-kubernetes-operator -n flink <<EOF
defaultConfiguration:
  flink-conf.yaml: |+
    # Flink Config Overrides
    kubernetes.operator.metrics.reporter.prom.factory.class: org.apache.flink.metrics.prometheus.PrometheusReporterFactory
    kubernetes.operator.metrics.reporter.prom.port: 9999
metrics:
  port: 9999
EOF
```

```
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: flink-kubernetes-operator
  namespace: flink
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: flink-kubernetes-operator
  podMetricsEndpoints:
      - port: metrics

```
```
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  labels:
    release: prometheus
      manager: kubectl-create
      operation: Update
  name: flink-pod-monitor
  namespace: flink
spec:
  namespaceSelector:
    matchNames:
      - flink
  podMetricsEndpoints:
    - path: /
      relabelings:
        - action: replace
          replacement: $1:9250
          sourceLabels:
            - __meta_kubernetes_pod_ip
          targetLabel: __address__
  selector:
    matchLabels:
      type: flink-native-kubernetes

```

```
apiVersion: flink.apache.org/v1beta1
kind: FlinkDeployment
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"flink.apache.org/v1beta1","kind":"FlinkDeployment","metadata":{"annotations":{},"labels":{"argocd.argoproj.io/instance":"flink-deployment"},"name":"basic-example-1","namespace":"flink"},"spec":{"flinkConfiguration":{"taskmanager.numberOfTaskSlots":"2"},"flinkVersion":"v1_20","image":"flink:1.20","job":{"jarURI":"local:///opt/flink/examples/streaming/StateMachineExample.jar","parallelism":2,"upgradeMode":"stateless"},"jobManager":{"podTemplate":{"spec":{"containers":[{"name":"flink-main-container","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}],"securityContext":{"fsGroup":9999,"runAsGroup":9999,"runAsNonRoot":true,"runAsUser":9999,"seccompProfile":{"type":"RuntimeDefault"}}}},"resource":{"cpu":1,"memory":"2048m"}},"serviceAccount":"flink","taskManager":{"podTemplate":{"spec":{"containers":[{"name":"flink-main-container","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}],"securityContext":{"fsGroup":9999,"runAsGroup":9999,"runAsNonRoot":true,"runAsUser":9999,"seccompProfile":{"type":"RuntimeDefault"}}}},"resource":{"cpu":1,"memory":"2048m"}}}}
  labels:
    argocd.argoproj.io/instance: flink-deployment
  name: basic-example-1
  namespace: flink
spec:
  flinkConfiguration:
    metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter
    metrics.reporter.prom.factory.class: org.apache.flink.metrics.prometheus.PrometheusReporterFactory
    metrics.reporter.prom.port: 9249-9250
    metrics.reporters: prom
    taskmanager.network.detailed-metrics: "true"
```
