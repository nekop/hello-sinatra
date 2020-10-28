# hello-sinatra

Sample Ruby Sinatra application, useful for testing OpenShift

## OpenShift Service Mesh configuration

```
oc new-project test-istio
oc -n istio-system patch servicemeshmemberrolls.maistra.io/default --type json -p '[{"op":"add","path":"/spec/members/-","value":"test-istio"}]' # Add test-istio project to ServiceMeshMemberRolls for enabling Istio on this project
oc -n istio-system patch servicemeshcontrolplanes.maistra.io/basic-install --type json -p '[{"op":"add","path":"/spec/istio/gateways/istio-ingressgateway","value":{"ior_enabled":"true"}}]' --dry-run -o yaml # Enable OpenShift Ingress -> Istio Ingress auto routing
oc new-app https://github.com/nekop/hello-sinatra
oc patch deploy/hello-sinatra -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}}'
# We need to create Gateway and VirtualService insread of Route
SUBDOMAIN=<your subdomain>
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