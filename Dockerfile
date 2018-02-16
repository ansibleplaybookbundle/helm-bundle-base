FROM ansibleplaybookbundle/apb-base

LABEL "com.redhat.apb.spec"=\

RUN yum install -y jq && yum clean all

USER apb

COPY helm /bin/helm
COPY entrypoint.sh /bin/entrypoint.sh

# TODO change "somechart.tgz" to the name of your actual chart.
COPY somechart.tgz /opt/chart.tgz

ENTRYPOINT ["entrypoint.sh"]
