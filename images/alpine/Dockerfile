# Build image
FROM golang:1.8.1 AS build4linux

ARG PKG_NAME=__APPNAME__
ARG PKG_BASE=github.com/johandry
ARG BIN_NAME=__APPNAME__
ARG GitCommit
ARG Version
ARG VersionPrerelease

ENV LDFLAGS "-X ${PKG_BASE}/${PKG_NAME}/version.GitCommit=${GitCommit} \
  -X ${PKG_BASE}/${PKG_NAME}/version.Version=${Version} \
  -X ${PKG_BASE}/${PKG_NAME}/version.VersionPrerelease=${VersionPrerelease}"

ADD . /go/src/${PKG_BASE}/${PKG_NAME}

RUN echo \
  && cd /go/src/${PKG_BASE}/${PKG_NAME} \
  && GOOS=linux go build -ldflags "${LDFLAGS}" -o /${BIN_NAME} \
  && echo

# To do a manual build uncomment this line and comment out the following lines.
# Then use 'make sh'
# CMD [ "/bin/bash" ]

# Application image
FROM alpine AS application

COPY --from=build4linux /__APPNAME__ .

ENTRYPOINT [ "./__APPNAME__" ]
