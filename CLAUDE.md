# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **FortiWEB Ingress Controller** repository - a Kubernetes Ingress Controller that integrates FortiWEB Web Application Firewall capabilities with Kubernetes. It provides web application protection, load balancing, and security features for applications deployed in Kubernetes clusters.

### Key Components
- **Helm Charts**: Multiple versioned charts (`charts/fwb-k8s-ctrl-*`) for deploying the controller
- **Ingress Examples**: Sample configurations showing different use cases and features
- **Service Examples**: Backend service definitions for testing
- **Node Examples**: FortiADC integration examples

## Architecture

The FortiWEB Ingress Controller consists of:

1. **Controller Deployment**: Runs as a pod in the Kubernetes cluster, watches Ingress resources
2. **IngressClass**: Defines `fwb-ingress-controller` as the controller identifier  
3. **RBAC**: Service account and permissions for cluster resource access
4. **FortiWEB Integration**: Communicates with external FortiWEB appliances via annotations

### Key Features
- **Web Application Protection**: Leverages FortiWEB's security profiles and policies
- **Load Balancing**: Manages virtual servers and backend pools
- **SSL/TLS Termination**: Handles HTTPS traffic with certificate management
- **Custom Annotations**: Fine-grained control over FortiWEB configuration

## Common Development Commands

### Helm Chart Management
```bash
# Package the latest chart version
helm package ./charts/fwb-k8s-ctrl-2.0.1 -d docs/

# Update Helm repository index
helm repo index docs/ --url https://amerintlxperts.github.io/fortiweb-ingress/

# Install the controller
helm install fwb-ingress-controller ./charts/fwb-k8s-ctrl-2.0.1

# Upgrade existing installation
helm upgrade fwb-ingress-controller ./charts/fwb-k8s-ctrl-2.0.1

# Validate chart syntax
helm lint ./charts/fwb-k8s-ctrl-2.0.1

# Template rendering (dry-run)
helm template fwb-ingress-controller ./charts/fwb-k8s-ctrl-2.0.1
```

### Publishing and Release Management
```bash
# Automated packaging and publishing script
./doit.sh                           # Packages chart, updates index, pushes to gh-pages

# Manual steps (equivalent to doit.sh):
git checkout gh-pages               # Switch to GitHub Pages branch
git add docs/                       # Stage packaged charts and index
git commit -m "Add or update Helm chart"
git push origin gh-pages            # Publish to GitHub Pages
```

### Kubernetes Deployment and Testing
```bash
# Apply example configurations
kubectl apply -f ingress_examples/minimal-ingress.yaml
kubectl apply -f service_examples/my-web.yaml

# Check controller status
kubectl get pods -n kube-system -l app.kubernetes.io/name=fwb-k8s-ctrl
kubectl logs -n kube-system deployment/fwb-ingress-controller

# Validate ingress resources
kubectl get ingress
kubectl describe ingress minimal-ingress

# Test connectivity
kubectl get ingressclass fwb-ingress-controller
```

## FortiWEB Integration

### Required Annotations
The controller uses specific annotations to configure FortiWEB appliances:

| Annotation | Purpose | Example |
|------------|---------|---------|
| `fortiweb-ip` | FortiWEB appliance IP address | `"172.23.133.148"` |
| `fortiweb-login` | Authentication secret name | `"fad-login1"` |
| `virtual-server-ip` | Virtual server IP on FortiWEB | `"192.23.133.6"` |
| `virtual-server-interface` | FortiWEB interface | `"port2"` |
| `server-policy-web-protection-profile` | WAF profile | `"Inline Standard Protection"` |

### Configuration Patterns
- **Virtual Server Setup**: Each Ingress creates a virtual server on FortiWEB
- **Backend Pool Management**: Services become server pool members
- **Policy Application**: Security policies applied via annotations
- **SSL/TLS Handling**: Certificate management through FortiWEB

## Chart Versioning

The repository maintains multiple chart versions with semantic versioning:
- `fwb-k8s-ctrl-1.0.x`: Initial releases
- `fwb-k8s-ctrl-2.0.x`: Current stable releases (latest: 2.0.1)

### Version Compatibility
- **Kubernetes**: Supports versions 1.19.8 through 1.31
- **Helm**: Chart API version v2
- **Container Image**: `ghcr.io/amerintlxperts/fortiweb-ingress:2.0.1`

### Upgrading Charts
When creating new versions:
1. Update `Chart.yaml` with new version and appVersion
2. Modify `values.yaml` for configuration changes  
3. Update templates as needed
4. Test with `helm template` and `helm lint`
5. Package and publish via `./doit.sh`

## Example Configurations

### Basic Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    fortiweb-ip: "172.23.133.148"
    virtual-server-ip: "192.23.133.6"
    server-policy-web-protection-profile: "Inline Standard Protection"
spec:
  ingressClassName: fwb-ingress-controller
  rules:
  - host: test.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### Advanced Features
- **TLS Termination**: See `ingress_examples/tls-example-ingress.yaml`
- **Wildcard Hosts**: See `ingress_examples/ingress-wildcard-host.yaml`
- **Default Backends**: See `ingress_examples/ingress-with-default-backend.yaml`
- **Fanout Routing**: See `ingress_examples/simple-fanout-example.yaml`

## Troubleshooting

### Common Issues
- **Controller Not Starting**: Check RBAC permissions and service account
- **Ingress Not Working**: Verify FortiWEB connectivity and annotations
- **Certificate Issues**: Check TLS configuration and certificate secrets
- **Backend Connectivity**: Validate service endpoints and network policies

### Debugging Commands
```bash
# Controller logs
kubectl logs -f deployment/fwb-ingress-controller -n kube-system

# Event monitoring
kubectl get events --sort-by='.lastTimestamp' -A

# Resource validation
kubectl describe ingress <ingress-name>
kubectl get endpoints <service-name>
```

## Security Considerations

### FortiWEB Integration Security
- **Authentication**: Secure credential management for FortiWEB access
- **Network Segmentation**: Proper firewall rules between Kubernetes and FortiWEB
- **Certificate Management**: Secure handling of TLS certificates
- **Policy Enforcement**: Appropriate WAF policies for application protection

### Kubernetes Security
- **RBAC**: Minimal required permissions for controller operation
- **Pod Security**: Security contexts and resource limits
- **Network Policies**: Restrict controller network access as needed
- **Image Security**: Use specific image tags, not `latest`