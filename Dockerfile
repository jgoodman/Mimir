FROM alpine:3.5

COPY cpanfile /
ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

RUN apk update && \
  apk add perl perl-io-socket-ssl perl-dbd-pg perl-dev g++ make wget curl && \
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cpanm --installdeps . -M https://cpan.metacpan.org && \
  apk del perl-dev g++ make wget curl && \
  rm -rf /root/.cpanm/* /usr/local/share/man/*

RUN apk add bash bash-doc bash-completion

COPY script script/
COPY templates templates/
COPY public public/
COPY lib lib/

COPY mimir.conf ./

RUN mkdir log

# USER daemon
# WORKDIR /
# VOLUME ["/data"]
EXPOSE 3000
#EXPOSE 8080
#EXPOSE 3210

#CMD ["hypnotoad", "script/mimir"]
CMD ["script/mimir", "daemon"]
