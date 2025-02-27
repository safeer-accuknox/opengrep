FROM python:3.9.21-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/usr/local/bin:$PATH" \
    WORKDIR="/app" \
    SEMGREP_SEND_METRICS="off"

WORKDIR $WORKDIR

COPY opengrep /usr/local/bin
COPY opengrep-rules ./default-rules
COPY entrypoint.sh .
RUN chmod +x /usr/local/bin/opengrep && chmod +x entrypoint.sh

RUN apt update -y && apt install curl jq -y

ENTRYPOINT ["./entrypoint.sh"]
CMD [""]
