## Introduction
This project is hosted at https://github.com/tranhailong/nfs-server <br>
Chart source is hosted at https://github.com/tranhailong/charts <br>
This chart is hosted at https://tranhailong.github.io/charts/ and [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/tranhailong)](https://artifacthub.io/packages/search?repo=tranhailong)

## Usage
To install
```
helm repo add tranhailong https://tranhailong.github.io/charts
helm install my-<chart-name> tranhailong/<chart-name> -n <namespace>
```

To retrieve latest versions of the package
```
helm repo update
helm search repo tranhailong
```

To uninstall
```
helm delete my-<chart-name> -n <namespace>
```