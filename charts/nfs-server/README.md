## Introduction
This project is hosted at https://github.com/tranhailong/nfs-server <br>
Chart source is hosted at https://github.com/tranhailong/charts <br>
This chart is hosted at https://github.com/tranhailong/charts/tree/master/charts/nfs-server and [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/tranhailong)](https://artifacthub.io/packages/search?repo=tranhailong)

## Usage
To install
```
helm repo add tranhailong https://tranhailong.github.io/charts
helm install my-nfs-server tranhailong/nfs-server --version 0.1.0 -n nfs
```
You will need to override
- `image.repository` to GCR image if running on a GKE private cluster
- `serviceAccount.annotations` to GCP IAM SA email to allow GCS Fuse to authenticate

Refer [helm-values.yaml](https://github.com/tranhailong/nfs-server/blob/master/helm-values.yaml) for details

To retrieve latest versions of the package
```
helm repo update
helm search repo tranhailong
```

To uninstall
```
helm delete my-nfs-server -n nfs
```