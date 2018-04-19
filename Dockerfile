FROM ansibleplaybookbundle/apb-base

LABEL "com.redhat.apb.spec"=\
"LS0tCgp2ZXJzaW9uOiAxLjAKbmFtZTogaGVsbS1jaGFydC1ydW5uZXItYXBiCmRlc2NyaXB0aW9u\
OiBEZXBsb3kgYSBjaGFydCBmcm9tIGEgaGVsbSByZXBvCmJpbmRhYmxlOiAiRmFsc2UiCmFzeW5j\
OiBvcHRpb25hbAptZXRhZGF0YToKICBkaXNwbGF5TmFtZTogSGVsbSBDaGFydCBSdW5uZXIKcGxh\
bnM6CiAgLSBuYW1lOiBkZWZhdWx0CiAgICBkZXNjcmlwdGlvbjogRGVwbG95IGEgaGVsbSBjaGFy\
dAogICAgZnJlZTogIlRydWUiCiAgICBtZXRhZGF0YToge30KICAgIHBhcmFtZXRlcnM6CiAgICAg\
IC0gbmFtZTogcmVwb19uYW1lCiAgICAgICAgdGl0bGU6IEhlbG0gQ2hhcnQgUmVwb3NpdG9yeSBO\
YW1lCiAgICAgICAgZGVmYXVsdDogc3RhYmxlCiAgICAgICAgdHlwZTogc3RyaW5nCiAgICAgICAg\
cmVxdWlyZWQ6ICJUcnVlIgogICAgICAtIG5hbWU6IHJlcG8KICAgICAgICB0aXRsZTogSGVsbSBD\
aGFydCBSZXBvc2l0b3J5IFVSTAogICAgICAgIGRlZmF1bHQ6IGh0dHBzOi8va3ViZXJuZXRlcy1j\
aGFydHMuc3RvcmFnZS5nb29nbGVhcGlzLmNvbQogICAgICAgIHR5cGU6IHN0cmluZwogICAgICAg\
IHJlcXVpcmVkOiAiVHJ1ZSIKICAgICAgLSBuYW1lOiBjaGFydAogICAgICAgIHRpdGxlOiBIZWxt\
IENoYXJ0CiAgICAgICAgZGVmYXVsdDogcmVkaXMKICAgICAgICB0eXBlOiBzdHJpbmcKICAgICAg\
ICByZXF1aXJlZDogIlRydWUiCiAgICAgIC0gbmFtZTogbmFtZQogICAgICAgIHRpdGxlOiBSZWxl\
YXNlIE5hbWUKICAgICAgICBkZWZhdWx0OiBoZWxtcnVubmVyCiAgICAgICAgdHlwZTogc3RyaW5n\
CiAgICAgICAgcmVxdWlyZWQ6ICJUcnVlIgogICAgICAtIG5hbWU6IHZhbHVlcwogICAgICAgIHRp\
dGxlOiBWYWx1ZXMKICAgICAgICB0eXBlOiBzdHJpbmcKICAgICAgICBkaXNwbGF5VHlwZTogdGV4\
dGFyZWEKICAgICAgICByZXF1aXJlZDogIkZhbHNlIgogICAgICAtIG5hbWU6IHRpbGxlcgogICAg\
ICAgIHRpdGxlOiBVc2UgdGlsbGVyIHRvIGluc3RhbGwgcHJvamVjdAogICAgICAgIHR5cGU6IGJv\
b2xlYW4KICAgICAgICBkZWZhdWx0OiBGYWxzZQogICAgICAgIHJlcXVpcmVkOiBUcnVlCg=="

RUN yum install -y jq && yum clean all

USER apb

COPY helm /bin/helm
COPY entrypoint.sh /usr/bin/hbb-entrypoint.sh

ENTRYPOINT ["hbb-entrypoint.sh"]
