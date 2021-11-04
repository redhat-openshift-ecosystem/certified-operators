FROM scratch

# Labels are important and should have the right version (x.x)
LABEL operators.operatorframework.io.bundle.mediatype.v1=registry+v1
LABEL operators.operatorframework.io.bundle.manifests.v1=manifests/
LABEL operators.operatorframework.io.bundle.metadata.v1=metadata/
LABEL operators.operatorframework.io.bundle.package.v1=aqua-operator-certified
LABEL operators.operatorframework.io.bundle.channels.v1="6.2"
LABEL operators.operatorframework.io.bundle.channel.default.v1="6.2"

# The directory name corresponds to the Aqua version (x.x.x)
COPY /manifests /manifests/
COPY /metadata /metadata/

# These Labels correspond to the OCP version compatibility
LABEL com.redhat.openshift.versions="v4.5-v4.7"
LABEL com.redhat.delivery.backport=true
LABEL com.redhat.delivery.operator.bundle=true