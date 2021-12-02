# Build the manager binary
FROM golang:1.15 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
ARG AMCOP_REGISTRY=registry.connect.redhat.com/aarna
ARG EMCO_REGISTRY=registry.connect.redhat.com/aarna
ARG RELEASE_TAG=v2.2.0-beta
ARG EMCO_RELEASE_TAG=v21.03.07
ARG K8S_PLATFORM=openshift
ARG VENDOR_NAME="Aarna Networks"
ARG CONTAINER_TAG="v2.2.0"

LABEL vendor=$VENDOR_NAME \
      version=$CONTAINER_TAG \
      release="2.1.0" \
      name="amcop-k8s-operator" \
      summary="AMCOP Kubernetes operator" \
      description="AMCOP kuberenetes operator is a runtime controller, responsible for providing lifecycle management of AMCOP"

LABEL com.redhat.openshift.versions="v4.6"
LABEL com.redhat.delivery.operator.bundle=true
LABEL com.redhat.delivery.backport=true

WORKDIR /

RUN mkdir /licenses

COPY EULA /licenses/LICENSE
COPY bindata /bindata
COPY --from=builder /workspace/manager .
USER 65532:65532
ENV AMCOP_REGISTRY=${AMCOP_REGISTRY}
ENV EMCO_REGISTRY=${EMCO_REGISTRY}
ENV RELEASE_TAG=${RELEASE_TAG}
ENV EMCO_RELEASE_TAG=${EMCO_RELEASE_TAG}
ENV K8S_PLATFORM=${K8S_PLATFORM}

ENTRYPOINT ["/manager"]
