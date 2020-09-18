```
helm repo add jenkinsci https://charts.jenkins.io
helm upgrade --install --create-namespace -n jenkins jenkins1 jenkinsci/jenkins \
    --set agent.image=dorowu/moxa-build \
    --set agent.tag=1.0 \
    --set master.JCasC.enabled=true \
    --set master.JCasC.defaultConfig=true \
    -f jenkins-value.yaml \
    --set master.ingress.enable=true \
    --set master.ingress.hostname=jenkins.office.dorowu.com
```
    --set master.serviceType=NodePort
