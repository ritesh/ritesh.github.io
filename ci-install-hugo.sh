HUGO_VERSION=0.17

set -x
set -e

# Install Hugo if not already cached or upgrade an old version.
if [ ! -e $CIRCLE_BUILD_DIR/bin/hugo ] || ! [[ `hugo version` =~ v${HUGO_VERSION} ]]; then
  wget https://github.com/spf13/hugo/releases/download/v0.17/hugo_0.17_Linux-64bit.tar.gz 
  tar xvzf hugo_0.17_Linux-64bit.tar.gz
  cp hugo_0.17_linux_amd64/hugo_0.17_linux_amd64 $CIRCLE_BUILD_DIR/bin/hugo
fi
