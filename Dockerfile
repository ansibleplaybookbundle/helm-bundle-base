FROM ansibleplaybookbundle/apb-base

RUN yum install -y jq && yum clean all
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

USER apb

COPY entrypoint.sh /usr/bin/hbb-entrypoint.sh

ENTRYPOINT ["hbb-entrypoint.sh"]
