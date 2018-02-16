## Getting Started

Create a new Dockerfile for your service bundle using the content below. Change
the name of the chart archive as appropriate. Do not change the destination
filename.

```
FROM mhrivnak/helm-bundle-base

LABEL "com.redhat.apb.spec"=\

COPY redis-1.1.12.tgz /opt/chart.tgz

ENTRYPOINT ["entrypoint.sh"]
```

Copy apb.yml.example to $YOUR_BUNDLE_PATH/apb.yml and modify values as you see fit.

Build and and push the image like a normal service bundle.
