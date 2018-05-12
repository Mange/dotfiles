#!/usr/bin/env bash
#
# Update vendor scripts, etc.
#

set -e

if [[ $1 == "--help" ]]; then
  echo "Usage: $0"
  echo ""
  echo "Updates vendor scripts, etc."
fi

download() {
  local dest="$1"
  local url="$2"

  echo "$dest"
  curl --silent --fail --output "$dest" "$url"
}

# i3gw
download bin/i3gw \
  "https://gist.githubusercontent.com/budRich/d09cbfd07ffdc57680fbc51ffff3687b/raw/61f6d409c9586088d9923abe59b5cbb7a81e1d28/i3gw"

# i3zen
download bin/i3zen \
  "https://gist.githubusercontent.com/budRich/16765b5468201aa734d0ec1c0870fd0c/raw/a0f5354599086f9149713d313fbc627a79d7b103/i3zen"

# i3get
download bin/i3get \
  "https://gist.githubusercontent.com/budRich/892c0153c06a27ea7bc89d8f8dec99d2/raw/f55457f5524b7f1f599663399247ba26e249dbb6/i3get"

# i3run
download bin/i3run \
  "https://gist.githubusercontent.com/budRich/8810a88a5a24080f4c499c65da76853b/raw/5c4ea3606f8524c2965c49e5dbe73eb15783ead7/i3run"
