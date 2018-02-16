FROM ansibleplaybookbundle/apb-base

LABEL "com.redhat.apb.spec"=\
"dmVyc2lvbjogMS4wCm5hbWU6IHJlZGlzLWhlbG0tYXBiCmRlc2NyaXB0aW9uOiBVc2VzIGhlbG0g\
Y2hhcnQgdG8gZGVwbG95IHJlZGlzCmJpbmRhYmxlOiBGYWxzZQphc3luYzogb3B0aW9uYWwKbWV0\
YWRhdGE6CiAgZGlzcGxheU5hbWU6IHJlZGlzLWhlbG0KcGxhbnM6CiAgLSBuYW1lOiBkZWZhdWx0\
CiAgICBkZXNjcmlwdGlvbjogVGhpcyBkZWZhdWx0IHBsYW4gZGVwbG95cyByZWRpcy1oZWxtLWFw\
YgogICAgZnJlZTogVHJ1ZQogICAgbWV0YWRhdGE6IHt9CiAgICBwYXJhbWV0ZXJzOiBbXQo="

RUN yum install -y jq && yum clean all

USER apb

COPY helm /bin/helm
COPY entrypoint.sh /bin/entrypoint.sh

# TODO change "somechart.tgz" to the name of your actual chart.
COPY somechart.tgz /opt/chart.tgz

ENTRYPOINT ["entrypoint.sh"]
