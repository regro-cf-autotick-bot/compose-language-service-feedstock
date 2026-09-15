#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    microsoft-${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/compose-language-service << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@microsoft/compose-language-service/bin/docker-compose-langserver "\$@"
EOF
chmod +x ${PREFIX}/bin/compose-language-service

tee ${PREFIX}/bin/compose-language-service.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@microsoft\compose-language-service\bin\docker-compose-langserver %*
EOF
