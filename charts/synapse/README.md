## Introduction
This will install a copy of matrix synapse homeserver. I started out searching [Artifact Hub](https://artifacthub.io/) for one, and came up with a few pretty good ones noted in (#References) section, but there are quirks in each of them that I decided to have a go at it and learn helm / K8S as I go along.

These are my objectives as I embark on this journey
- utilises a library to abstract away most of the boilerplate codes, leaving as little codes as possible in here. Ideally most of the codes should be driven by the `homeserver.yaml` configurations of the underlying app synapse, rather than by the release infrastructure
- modular, i want to be able to run just synapse in this one, nothing esle in here. I'll work on an umbrella chart to orchestrate synapse in conjunction with all the bridges later on
- as organised and readable as possible, the "pythonic" way
- stick to official images and documentations as much as possible, all customisations should make up sections in the `values.yaml`. by official, i'd go with `docker.io/matrixdotorg/synapse` for the app, and `bitnami/*` for the rest of commonly used packages (i actually also override the postgresql image to `docker.io/postgresql` to keep to this theme)
- keep `.Values.appConfig.homeserver` in as close a format as possible to the official `homeserver.yaml` as designed and documented by [synapse](https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html). you shouldn't have to figure out where to add what values, but just write as if you're writing to `homeserver.yaml`
- runnable on GKE, but should hopefully run on a home cluster or other clouds out of the box too with little config overrides.

## TODO
- Make email notification work
- How to enforce startup order dependency (db first before homeserver). At the moment it seems to just work while trying on GKE, so I'm not gonna tackle it for the time being.
- `.well-known` to be served through a nginx server as part of this chart
- Make TURN server work?

## Notes
If you're running this for the first time, chances are you won't have a signing key for your server. Main container will auto generate this for you into an emptyDir volume (which will be lost). You should retain the content of `/data/<server_name>.signing.key` into `.Values.appConfig.signingKey` for future run <br>
Some prefers to run a script in initContainer to update the secret, but i'd prefer that such details is explicitly captured in the manifest records. That, and the fact that I was having some troubles with k8s-at-home common chart while mounting the same volume in the main container and initContainer.

Regarding Reverse Proxy, I think Ingress is able to replace part of it (the part that handles traffic to matrix.example.com) but not able to server `example.com/.well-known` bit. for now i'm using a separate nginx instance to serve that up

## Decisions
- Signing key (if not present) will be generated onto a ephemeral volume that needs to be manually captured into the manifest, follow note #2 on `helm install`
- Workers implementation and redis is deliberately left out for now as it adds too much complexity for the initial release
- Not dabble in NetworkPolicy, this seems to be some forms of internal firewalls, not necessary for smaller scale deployments

## References
- [Matrix.org](https://matrix.org/)
- [Synapse Documentations](https://matrix-org.github.io/synapse/latest/welcome_and_overview.html)
- [Synapse Github](https://github.com/matrix-org/synapse)

I also took inspirations and lifted some stuff from each of these charts:
- [TrueCharts](https://github.com/truecharts/charts/tree/master/charts/stable/synapse): I like the form of this the most, abstracting stuff into a common lib, and rely more on `values.yaml` to drive the creation of manifest files. It's tidy, simple, most matured, and doesn't look overly hacked. I'm basing as much as possible the form of my chart on this, but gonna use [k8s-at-home library chart](https://github.com/k8s-at-home/library-charts) instead since the lib is simpler looking and comprehensive enough, and i'm hesitant to dig into TrueNAS to figure out what it really is and implies. <br>
I don't like, however, the fact that they custom host (and possibly customise) the image, so I'm gonna get rid of this part.

- [TypoKign](https://github.com/typokign/matrix-chart): The chart itself is well-written and organised, despite not using abstraction lib. However, I prefer to leave the bridges out in separate charts and connect them using umbrella chart instead (in the next project) of bundling it together. <br>
I like how he uses `_homeserver.yaml` to separate out the config file instead of cluttering the ConfigMap manifest or `values.yaml` with hard to read formatting stuff, helping to keep it organised for the maintainer (best is to merge this back with override values from `values.yaml` so i'm gonna look into how to do this). <br>
Also, Synapse version in his manifest is stuck at 1.22 (current 1.77) implying that he's able to upgrade his deployment just by overwriting the image tag rather than changing the chart itself... or there's not a lot of active focus left on it

- [Halkeye](https://github.com/halkeye-helm-charts/synapse): This includes the most scary `values.yaml` (2k lines, albeit a lot of it is comments and instructions). <br>
It does include a redis and workerise the app into `federation_reader` and `federation_sender`, so some of the later features on synapse, which is interesting. Chart is also updated to synapse v1.75, which is pretty recent. <br>
Also he puts all the configs in Secret instead of split between ConfigMap and Secret, makes sense and keep things simpler.

- [Ananace](https://github.com/ananace/personal-charts/tree/master/charts/matrix-synapse): This is the first chart i tried out (and it work-ish) since it packed the latest Synapse v1.77 and most recently updated. <br>
Included a `signing-key.sh` script and roundabout job instead of the using an initContainer with generic pre-packaged commands in the `matrixdotorg/synapse` image, so i'm not really in favour of this. <br>
However, not sure if this is playing into the next point, he seems to go out of his way to protect his secrets. Amongst other things, he split `homeserver.yaml` between ConfigMap and Secret in order to separate the passwords and keys, and even go on to `sed` postgres and redis passwords at container runtime, something to ponder. <br>
Also runs a separate lighttpd server to serve the `.wellknown` piece, which i don't like as much. In my first attempt at running synapse at home (using docker-compose), i use a simple nginx config to deliver hard coded yaml response to the `wellknown` call, which i'd like to think is simpler and better. <br>
Also includes a more up-to-date implementations of workers.
