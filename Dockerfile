# Build image
FROM golang:1.8.1 AS build

ARG PKG_NAME=app
ARG PKG_BASE=github.com/johandry

ADD . /go/src/${PKG_BASE}/${PKG_NAME}

RUN echo \
  && cd /go/src/${PKG_BASE}/${PKG_NAME} \
  && make build4docker \
  && echo

# To do a manual build uncomment this line and comment out the following lines.
# Then use 'make sh'
# CMD [ "/bin/bash" ]

# Application image
FROM scratch AS application

# TODO: Rename 'app' to the application name
COPY --from=build /app .

CMD [ "./app" ]
