

```shell
minikube start --network-plugin=cni --cni=calico
```

```shell
kubectl get pods -n kube-system
```

```shell
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
```

```shell
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
```

```shell
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
```

```shell
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```

```shell
kubectl get pods -o wide
```

```shell
kubectl apply -f non-admin-api-allow.yaml
```

```shell
kubectl apply -f admin-api-allow.yaml
```

```shell
kubectl run test-$(Get-Random) --rm -i -t --image=alpine --labels role=front-end -- sh
```