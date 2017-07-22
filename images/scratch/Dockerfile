# Build image
FROM golang:1.8.1 AS build4scratch

ARG PKG_NAME
ARG PKG_BASE
ARG BIN_NAME
ARG GitCommit
ARG Version
ARG VersionPrerelease

ENV LDFLAGS "-X ${PKG_BASE}/${PKG_NAME}/version.GitCommit=${GitCommit} \
  -X ${PKG_BASE}/${PKG_NAME}/version.Version=${Version} \
  -X ${PKG_BASE}/${PKG_NAME}/version.VersionPrerelease=${VersionPrerelease}"

ADD . /go/src/${PKG_BASE}/${PKG_NAME}

RUN echo \
  && cd /go/src/${PKG_BASE}/${PKG_NAME} \
  && CGO_ENABLED=0 GOOS=linux go build -ldflags "${LDFLAGS}" -a -installsuffix cgo -o /${BIN_NAME} \
  && echo

# To do a manual build uncomment this line and comment out the following lines.
# Then use 'make sh'
# CMD [ "/bin/bash" ]

# Application image
FROM scratch AS application

COPY --from=build4scratch /kubekit .

ENTRYPOINT [ "./kubekit" ]
