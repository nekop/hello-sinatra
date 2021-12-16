# hello-sinatra

Sample Ruby Sinatra application, useful for testing OpenShift

## Standard s2i

```
oc new-app https://github.com/nekop/hello-sinatra/
oc expose service/hello-sinatra
oc create route edge --service=hello-sinatra --insecure-policy=Redirect
```

For OpenShift v3, you may need to specify v3 branch:

```
oc new-app https://github.com/nekop/hello-sinatra/#v3
```

## OpenShift Service Mesh configuration

```
oc new-project test-istio
oc -n istio-system patch servicemeshmemberrolls.maistra.io/default --type json -p '[{"op":"add","path":"/spec/members/-","value":"test-istio"}]' # Add test-istio project to ServiceMeshMemberRolls for enabling Istio on this project
oc new-app https://github.com/nekop/hello-sinatra
oc patch deploy/hello-sinatra -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}}'
# We need to create Gateway and VirtualService insread of Route
SUBDOMAIN=$(oc get ingress.config.openshift.io/cluster -o go-template={{.spec.domain}})
INGRESS_HOSTNAME=hello-sinatra-test-istio.$SUBDOMAIN
oc create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: hello-sinatra-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - $INGRESS_HOSTNAME
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: hello-sinatra
spec:
  hosts:
  - $INGRESS_HOSTNAME
  gateways:
  - hello-sinatra-gateway
  http:
  - route:
    - destination:
        host: hello-sinatra
        port:
          number: 8080
EOF
oc get route -n istio-system # Confirm Route is created for this Gateway
curl -v http://$INGRESS_HOSTNAME # Confirm "server: istio-envoy" header
```

## OpenShift Pipelines s2i configuration

```
oc -n openshift-image-registry extract cm/serviceca
oc -n openshift-pipelines create configmap config-registry-cert --from-file=cert=./service-ca.crt # Configure service CA cert for internal registry access
oc create -f - <<EOF
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: hello-sinatra-build
spec:
  resources:
  - name: app-source
    type: git
  - name: app-image
    type: image
  tasks:
  - name: build
    taskRef:
      name: s2i-ruby-pr
      kind: ClusterTask
    resources:
      inputs:
      - name: source
        resource: app-source
      outputs:
      - name: image
        resource: app-image
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: app-image
spec:
  type: image
  params:
  - name: url
    value: image-registry.openshift-image-registry.svc:5000/test-tekton/hello-sinatra:latest
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: app-source
spec:
  type: git
  params:
  - name: url
    value: https://github.com/nekop/hello-sinatra
  - name: revision
    value: v3
EOF

tkn p start hello-sinatra-build
```
