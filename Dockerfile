ARG SUITECRM_VERSION=8.8.1
WORKDIR /var/www/html

RUN set -eux; \
    url="https://github.com/salesagility/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip"; \
    echo "Downloading: $url"; \
    curl -fL -o /tmp/suitecrm.zip "$url"; \
    mkdir -p /tmp/src; \
    unzip -q /tmp/suitecrm.zip -d /tmp/src; \
    SUITE_DIR="$(find /tmp/src -maxdepth 1 -type d -name 'SuiteCRM-*' | head -n1)"; \
    test -n "$SUITE_DIR"; \
    cp -a "$SUITE_DIR"/. /var/www/html/; \
    rm -rf /tmp/suitecrm.zip /tmp/src
