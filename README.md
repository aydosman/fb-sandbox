# Fluent Bit and Ingress Demo with Kind

## What the Script Does

This script creates a local Kubernetes cluster using Kind, installs Fluent Bit for log collection, and sets up ingress-nginx to expose a demo app. It ensures control plane pods are excluded from logging, waits for the app to become available, and deletes the cluster when the script exits.

## Requirements

* Docker
* Kind
* kubectl
* Helm

Files needed in the same directory:

* `kind.yaml`
* `fb.yaml`
* `nginx-values.yaml`
* `demo-app.yaml`
* `demo-ingress.yaml`

## Quick Start

```bash
brew install kind kubectl helm
```

```bash
./script.sh
```

## Example Output

```bash
Creating Kind Cluster...
Annotating control plane pods to exclude them from Fluent Bit...
pod/coredns-668d6bf9bc-qqmts annotated
pod/coredns-668d6bf9bc-rsdk5 annotated
pod/etcd-fb-test-control-plane annotated
pod/kindnet-85ftz annotated
pod/kindnet-sdmmc annotated
pod/kindnet-w2vn6 annotated
pod/kube-apiserver-fb-test-control-plane annotated
pod/kube-controller-manager-fb-test-control-plane annotated
pod/kube-proxy-6ptmm annotated
pod/kube-proxy-rfbxw annotated
pod/kube-proxy-x7r58 annotated
pod/kube-scheduler-fb-test-control-plane annotated
Updating Helm repositories...
Installing fluent-bit...
Installing ingress-nginx...
Waiting for ingress controller to be ready...
service/demo created
deployment.apps/demo created
ingress.networking.k8s.io/demo created
Waiting for ingress to serve the demo app...
Ingress is responding
pod/fluent-bit-l9ls7
pod/fluent-bit-sqwp7
pod/nginx-ingress-nginx-controller-84ccd47cc-gmn6k

[0] kube.default.demo-68676bfc4-zz99m.demo: [[1747747726.566696094, {}], {"time"=>"2025-05-20T13:28:46.566696094Z", "stream"=>"stdout", "_p"=>"F", "log"=>"2025/05/20 13:28:46 localhost 10.244.0.5:33284 "GET / HTTP/1.1" 200 19 "curl/8.7.1" 20.708µs", "kubernetes"=>{"pod_name"=>"demo-68676bfc4-zz99m", "namespace_name"=>"default", "pod_id"=>"a2747d5e-cf7d-4646-a9f3-1fc6c8134e68", "labels"=>{"app"=>"demo", "pod-template-hash"=>"68676bfc4"}, "host"=>"fb-test-worker2", "pod_ip"=>"10.244.1.4", "container_name"=>"demo", "docker_id"=>"73a50e4a6e0419b35dfa2244ee0c1fc72ffc3b09b1f5558da0e9f852254023a1", "container_hash"=>"docker.io/hashicorp/http-echo@sha256:fcb75f691c8b0414d670ae570240cbf95502cc18a9ba57e982ecac589760a186", "container_image"=>"docker.io/hashicorp/http-echo:latest"}}]
```

The script sets up everything, checks that the app is responding, then tails logs from Fluent Bit. The Kind cluster and context is removed automatically when the script ends. (Ctrl+C)

This script was used in testing fluentbits nginx paser.

You can curl the localhost endpoint to generate logs.
```bash
curl -sv http://localhost/

* Host localhost:80 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:80...
* Connected to localhost (::1) port 80
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.7.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Tue, 20 May 2025 11:54:02 GMT
< Content-Type: text/plain; charset=utf-8
< Content-Length: 19
< Connection: keep-alive
< X-App-Name: http-echo
< X-App-Version: 1.0.0
< 
hello from ingress
```
