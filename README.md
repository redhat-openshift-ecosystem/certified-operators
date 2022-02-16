# Red Hat certified operators production catalog
Production catalog for Red Hat Certified Operator Bundles

# Operator bundle submissionss
A new operator bundle submission needs to follow a predefined directory
structure that is described below in this section. The new submission is
done through Github pull requests which can be either open by the [CI pipeline][ci-pipeline] or
manually by a user. The recommended way is to use the CI pipeline because it makes
sure all necessary data are provided in the correct format. Documentation about how
to use the pipeline is available in the pipeline repository.

## Pull request
A pull request with a new operator bundle needs to follow given rules to pass a tests:
 * Title format: `operator package-name (version)`
 * Pull request can only modify one operator
 * Pull request can't modify already merged operators
 * Associated images need to be pinned to specific image digest - tags are not allowed

Rules mentioned above are always followed when pull request is opened using CI pipeline.

## Directory structure
This repository contains an `operator` directory where all certified operators
are stored. Each operator has its directory with its package name. Inside the directory,
you have to provide a `ci.yaml` file that stores the necessary metadata for a successful
certification process. The format of the file is described below.

```bash
operators
└── kogito-operator
    ├── 1.6.0
    │   ├── manifests
    │   │   ├── app.kiegroup.org_kogitobuilds.yaml
    │   │   ├── app.kiegroup.org_kogitoinfras.yaml
    │   │   ├── app.kiegroup.org_kogitoruntimes.yaml
    │   │   ├── app.kiegroup.org_kogitosupportingservices.yaml
    │   │   ├── kogito-operator.clusterserviceversion.yaml
    │   │   └── kogito-operator-controller-manager_v1_serviceaccount.yaml
    │   └── metadata
    │       └── annotations.yaml
    └── ci.yaml
```

### Format of ci.yaml file
In the file, user needs to provide necessary details for the operator certification process.
Currently, the certification process supports the following options:

* `cert_project_id` - Identifier of certification project created through Red Hat Connect.
* `merge` - A boolean value that determines whether a new operator is automatically
merged when passed all required checks. (optional, default: `True`)

[ci-pipeline]:   https://github.com/redhat-openshift-ecosystem/operator-pipelines
