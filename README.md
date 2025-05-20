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

The script sets up everything, checks that the app is responding, then tails logs from Fluent Bit. The Kind cluster and context is removed automatically when the script ends. (Ctrl+C)

This script was used in testing fluentbits nginx paser.

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
