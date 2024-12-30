# Kargo Demo

This repository showcases how well [Holos] integrates with [Kargo].

Two main uses cases are addressed:

1. Automatically tracking updates to third party add-ons like Istio and cert-manager.
2. Automatically promoting new versions of first-part containerized services,
   for example from dev to test, uat, then prod following the Sun from east to
   west.

## Quick Start

First, see [Local Cluster] to get set up locally.

TODO: Kargo credentials to push code and open a GitHub PR.  See [github
auth](./docs/github-auth.md).

Fork the repository.  Clone your fork locally.

Set the correct git uri.  Replace GH_USER with your github username.

```bash
GH_USER=jeffmccune
```

```bash
cat <<EOF > "config/platform/platform_${USER}.cue"
```
```cue
@if(${USER} || ${GH_USER})
package platform

organization: repoURL: "https://github.com/${GH_USER}/kargo-demo.git"
```
```bash
EOF
```

Render the manifests with your configuration:

```
holos render platform -t $GH_USER
```

Commit and push the updated deploy directory.

```bash
git add deploy
git commit -m "Switch to $GH_USER fork"
git push
```

Then, reset your local cluster.

```bash
time bash -c './scripts/reset-cluster && ./scripts/apply'
```

Should take about 1 minute.

[Holos]: https://holos.run/docs/overview/
[Kargo]: https://kargo.io/
[Local Cluster]: https://holos.run/docs/local-cluster/
