FROM scratch

LABEL operators.operatorframework.io.bundle.mediatype.v1='registry+v1'
LABEL operators.operatorframework.io.bundle.manifests.v1='manifests/'
LABEL operators.operatorframework.io.bundle.metadata.v1='metadata/'
LABEL operators.operatorframework.io.bundle.package.v1='cte-k8s-operator'
LABEL operators.operatorframework.io.bundle.channels.v1='candidate,stable'
LABEL operators.operatorframework.io.bundle.channel.default.v1='stable'
LABEL operators.operatorframework.io.metrics.builder='operator-sdk-v1.39.0'
LABEL operators.operatorframework.io.metrics.mediatype.v1='metrics+v1'
LABEL operators.operatorframework.io.metrics.project_layout='go.kubebuilder.io/v4'
LABEL operators.operatorframework.io.test.mediatype.v1='scorecard+v1'
LABEL operators.operatorframework.io.test.config.v1='tests/scorecard/'
LABEL com.redhat.openshift.versions='v4.10'

COPY manifests/ /manifests/
COPY metadata/ /metadata/

