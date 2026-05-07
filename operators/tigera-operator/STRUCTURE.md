# How this directory is structured

There are three things working together: **bundles** (per-software-version dirs), **catalog templates** (per-OpenShift-version files), and a **manifest** that ties them to catalog rendering.

## Layout

```
operators/tigera-operator/
├── <X.Y.Z>/                              # one dir per software version (e.g. 1.40.4)
│   ├── manifests/
│   │   ├── tigera-operator.clusterserviceversion.yaml   # the CSV
│   │   └── *.yaml                                       # CRDs
│   └── metadata/
│       └── annotations.yaml              # declares package, channel, OCP version range
├── catalog-templates/
│   └── v4.XX.yaml                        # one File-Based Catalog template per OCP minor
├── ci.yaml                               # maps each template → catalog name + type
└── Makefile                              # drives `opm` to render catalogs from templates
```

Two cross-cutting concepts:

- **`metadata/annotations.yaml`** — per bundle: declares the channel it belongs in (e.g. `release-v1.40`) and the OpenShift versions it claims to support (`com.redhat.openshift.versions: v4.18-v4.20`).
- **`catalog-templates/v4.XX.yaml`** — per OpenShift version: declares the `olm.package`, the `olm.channel` entries (with `name`/`replaces`/`skipRange` upgrade graph), and the list of `olm.bundle` images that should appear in that OpenShift's catalog. These are the rendered-from sources of truth for each OCP catalog.

A bundle is only visible in OCP `v4.XX` if it appears in **both** that template **and** its own annotations.yaml says it supports `v4.XX`.

## Answers to your questions

**1. Add a new version of our software**
- Create `operators/tigera-operator/<new-version>/manifests/` (CSV + CRDs) and `operators/tigera-operator/<new-version>/metadata/annotations.yaml`. Set `operators.operatorframework.io.bundle.channels.v1` (which channel, e.g. `release-v1.40`) and `com.redhat.openshift.versions` (range, e.g. `v4.18-v4.20`).
- For **each** `catalog-templates/v4.XX.yaml` in that supported OCP range:
  - Add a new entry under the matching `olm.channel` with `name: tigera-operator.v<new-version>`, `replaces: tigera-operator.v<previous>`, and `skipRange: <<new-version>`.
  - Append the bundle's pull-spec under the `olm.bundle` list (`- image: registry.connect.redhat.com/tigera/operator@sha256:...`).
- If this is a new minor channel, also add an `olm.channel` block (and bump `defaultChannel` on the `olm.package` if appropriate).

**2. Declare support for new OpenShift versions for existing versions of our software**
- Widen `com.redhat.openshift.versions` in that version's `metadata/annotations.yaml` to include the new OCP version (e.g. `v4.18-v4.21`).
- In `catalog-templates/v4.<newOCP>.yaml`, add the channel entry and the `olm.bundle` image for that existing software version (mirroring how it appears in the templates that already support it).
- If the catalog template doesn't exist yet: create `catalog-templates/v4.<newOCP>.yaml` (copy the closest existing one as a starting point) and register it in `ci.yaml` under `fbc.catalog_mapping`.

**3. Remove an old version of our software entirely (or change which OpenShift versions it supports)**
- *Remove entirely*: delete the `operators/tigera-operator/<version>/` directory, then in **every** `catalog-templates/v4.XX.yaml` delete the matching channel `entries:` item **and** the matching `- image:` `olm.bundle` line. If any other entry in those templates uses `replaces: tigera-operator.v<deleted>`, fix that upgrade chain (point `replaces` to the prior version, or drop the field).
- *Change which OCP versions it supports*: update `com.redhat.openshift.versions` in that version's `metadata/annotations.yaml`, **and** add it to (or remove it from) the corresponding `catalog-templates/v4.XX.yaml` files (both the channel entry and the `olm.bundle` image line). Both sides must agree.

**4. Remove support for an old OpenShift version from all software versions**
- Delete `catalog-templates/v4.<oldOCP>.yaml`.
- Remove the corresponding entry from `fbc.catalog_mapping` in `ci.yaml`.
- For accuracy, narrow `com.redhat.openshift.versions` in any per-version `metadata/annotations.yaml` whose declared range still includes `v4.<oldOCP>` (this isn't what produces the catalog — the template files do — but the per-bundle annotation is the bundle's own constraint and should match reality).

After any change, run `make catalogs` then `make validate-catalogs` from this directory to render and validate.
