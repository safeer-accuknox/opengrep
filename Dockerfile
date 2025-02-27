FROM python:3.9.21-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/usr/local/bin:$PATH" \
    SEMGREP_SEND_METRICS="off"

ENV REPOSITORY_URL="" \
    COMMIT_SHA="" \
    COMMIT_REF="" \
    PIPELINE_ID="" \
    JOB_URL=""


COPY opengrep /usr/local/bin
COPY opengrep-rules /rules/default-rules
COPY entrypoint.sh set_git_env.sh /
RUN chmod +x /usr/local/bin/opengrep && chmod +x /entrypoint.sh && chmod +x /set_git_env.sh

RUN apt update -y && apt install curl jq git -y 

WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]