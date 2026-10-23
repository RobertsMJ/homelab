```sh
task install-deps
```

```sh
helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace
```

```sh
kubectl apply -f clusters/yggdrasil/flux-instance.yaml
```