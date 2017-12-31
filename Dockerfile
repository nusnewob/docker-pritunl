FROM alpine:3.6

MAINTAINER Ilian Ranguelov <me@radarlog.net>

ENV VERSION="1.28.1548.86"

# Build deps
RUN apk --no-cache add --update go git bzr wget py2-pip \
    gcc python python-dev musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn

RUN pip install --upgrade pip

# Pritunl Install
RUN export GOPATH=/go \
    && go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-monitor \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin/

RUN wget https://github.com/pritunl/pritunl/archive/${VERSION}.tar.gz \
    && tar zxvf ${VERSION}.tar.gz \
    && cd pritunl-${VERSION} \
    && python setup.py build \
    && pip install -r requirements.txt \
    && python2 setup.py install \
    && cd .. \
    && rm -rf *${VERSION}* \
    && rm -rf /tmp/* /var/cache/apk/*

COPY . /

EXPOSE 9700 1194 1194/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pritunl", "start"]
