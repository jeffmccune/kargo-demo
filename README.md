# Kargo Demo

This repository showcases how well [Holos] integrates with [Kargo].

Two main uses cases are addressed:

1. Automatically tracking updates to third party add-ons like Istio and cert-manager.
2. Automatically promoting new versions of first-part containerized services,
   for example from dev to test, uat, then prod following the Sun from east to
   west.

## Quick Start

### Local Cluster

First, see [Local Cluster] to get set up locally.

### Fork this Repository

Fork the repository.  Clone your fork to your local machine.

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

### GitHub Credentials

[Create a GitHub App](https://github.com/settings/apps/new) in the user or
organization where your bank-of-holos fork resides.

In the `GitHub App name` field, specify a unique name, for example `Holos -
Local Cluster 1733418802` produced by:

```bash
echo -n "Holos - Local Cluster $(date +%s)" | pbcopy
```

Set the `Homepage URL` to `https://holos.run/docs/local-cluster/`.

Under `Webhook`, de-select `Active`.

Under `Permissions` → `Repository permissions` → `Contents`, select `Read and
write` permissions.  _The App will receive these permissions on all repositories
into which it is installed._

The `git-open-pr` step requires write permission to pull requests.  Add this
permission if you get the following error:

```
step execution failed: step 4 met error threshold of 1: failed to run step
"git-open-pr": error creating pull request: POST
https://api.github.com/repos/jeffmccune/kargo-demo/pulls: 403 Resource not
accessible by integration []
```

Under `Where can this GitHub App be installed?`, leave `Only on this account`
selected.

Click `Create GitHub App`.

Take note of the `App ID`. In your shell store it for use later using:

```bash
export GITHUB_APP_ID=9999999
```

Scroll to the bottom of the page and click `Generate a private key`. The
resulting key will be downloaded immediately.  Record the path to this file for
use later using:

```bash
export GITHUB_APP_KEY="$(ls -lrt1 ~/Downloads/holos-local-cluster*.private-key.pem | tail -1)"
```

On the left-hand side of the page, click `Install App`.

Choose an account to install the App into by clicking `Install`.

Select `Only select repositories` and choose your `bank-of-holos` fork.
Remember that the App will receive the permissions you selected earlier for all
repositories you grant access.

Click `Install`.

In your browser's address bar, take note of the numeric identifier at the end of
the current page's URL. This is the `Installation ID`.  Save the installation id
for later.

For example, `https://github.com/settings/installations/99999999` is saved as:

```shell
export GITHUB_APP_INSTALL_ID=99999999
```

#### GitHub App Secret

Generate a Kubernetes Secret to store the Kargo git credentials.  We put this in
`mkcert -CAROOT` so `reset-cluster` restores it each time the local cluster is
reset.

Record the Git URL, the same as you set for `Organization.RepoURL`

```shell
export GITHUB_APP_REPO_URL="https://github.com/${GH_USER}/kargo-demo.git"
```

At this point you should have the following values, for example:

```shell
env | grep GITHUB_APP
```

```shell
GITHUB_APP_ID=1079195
GITHUB_APP_KEY=/Users/jeff/Downloads/holos-local-cluster-1733419264.2024-12-30.private-key.pem
GITHUB_APP_INSTALL_ID=58021430
GITHUB_APP_REPO_URL=https://github.com/jeffmccune/kargo-demo.git
```

Generate the secret:

```shell
./scripts/kargo-git-creds
```

```txt
Secret created, apply with:
  kubectl apply -f ~/Library/Application\ Support/mkcert/kargo.yaml

The reset-cluster script will automatically apply this secret going forward.
```

And apply it or reset your cluster.

```shell
kubectl apply -f "$(mkcert -CAROOT)/kargo.yaml"
```

### Apply the Configuration

Then, reset your local cluster and apply all of the configuration in this repository.

```bash
time bash -c './scripts/reset-cluster && ./scripts/apply'
```

Should take about 1 minute.

Applying the configuration will:

1. Configure the argocd, kargo, podinfo, and httpbin services.
   1. https://argocd.holos.localhost
   2. https://kargo.holos.localhost
   3. https://podinfo.holos.localhost
   4. https://httpbin.holos.localhost
2. Configure ArgoCD to reconcile against your fork of this repository.  Auto-sync is disabled for the demo.
3. Configure Kargo to automatically promote new versions of podinfo, httpbin, and cert-manager.
4. Configure an istio-promoter Application.  If synced, this ArgoCD Application will configure Kargo to automatically create pull requests for new Istio versions.

## Demo

Podinfo represents a first-party service one of the teams in our org owns.  Kargo automatically promotes new container image tags from dev to test to uat, then waits for approval to promote to production.

Note https://kargo.holos.localhost routes to three backend namespaces,
prod-us-east, prod-us-central, and prod-us-west, each with a different version.

Log into Kargo using the password:

```bash
kubectl get secret -n kargo admin-credentials -o json \
  | jq --exit-status -r '.data.password | @base64d' \
  | pbcopy
```

Browse to https://kargo.holos.localhost/project/podinfo

Kargo should have already promoted the new image from dev to test to uat and is waiting for your approval to promote to prod.

[Holos]: https://holos.run/docs/overview/
[Kargo]: https://kargo.io/
[Local Cluster]: https://holos.run/docs/local-cluster/
