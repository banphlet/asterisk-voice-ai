FROM debian:bullseye-slim

ENV ASTERISK_VERSION 21-current
ENV OPUS_CODEC asterisk-21.0/x86-64/codec_opus-21.0-current-x86_64

COPY build-asterisk.sh /
RUN /build-asterisk.sh

COPY src/config /etc/asterisk
# to support asterisk realtime
COPY src/odbc /etc

# copy some default sounds if you need to
COPY sounds  /var/lib/asterisk/sounds
RUN chown -R asterisk.asterisk  /var/lib/asterisk/sounds
RUN chmod -R a+rwx /etc/asterisk/customs


COPY start.sh /

ENTRYPOINT ["sh", "-c", "/start.sh"]