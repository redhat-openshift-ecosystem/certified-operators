# Source: abinitio-runtime-operator/templates/dockerfile.yaml
FROM scratch

# Bundle labels from the annotations.yaml.
LABEL com.redhat.openshift.versions=v4.14
LABEL operators.operatorframework.io.bundle.channel.default.v1=release-4.3
LABEL operators.operatorframework.io.bundle.channels.v1=release-4.3
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=abinitio-runtime-operator
LABEL operators.operatorframework.io.metrics.builder=operator-sdk-v1.8.0-ocp
LABEL operators.operatorframework.io.metrics.mediatype.v1=metrics+v1
LABEL operators.operatorframework.io.metrics.project_layout=helm.sdk.operatorframework.io/v1
LABEL operators.operatorframework.io.test.config.v1=tests/scorecard/
LABEL operators.operatorframework.io.test.mediatype.v1=scorecard+v1

# Copy files to corresponding locations.
COPY manifests /manifests/
COPY metadata /metadata/
