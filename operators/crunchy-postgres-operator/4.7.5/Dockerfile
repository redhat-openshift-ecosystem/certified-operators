FROM scratch

# Core bundle labels.
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=crunchy-postgres-operator
LABEL operators.operatorframework.io.bundle.channels.v1=stable
LABEL operators.operatorframework.io.bundle.channel.default.v1=stable

# Copy files to locations specified by labels.
COPY manifests/ /manifests/
COPY metadata/ /metadata/
LABEL com.redhat.openshift.versions="v4.5-v4.8"
LABEL com.redhat.delivery.operator.bundle=true
LABEL com.redhat.delivery.backport=true
