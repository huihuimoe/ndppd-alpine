#!/bin/sh

if [ ! -z "$CONFIG_FILE" ]; then
  echo "Using configuration file: $CONFIG_FILE"
  exec /usr/local/sbin/ndppd -c "$CONFIG_FILE" -v
else
  if [ ! -z "$IPV6_SUBNET" ]; then
    PROXY_IFACE=${PROXY_IFACE:-eth0}
    FWD_IFACE=${FWD_IFACE:-docker0}
    echo "Proxy interface: $PROXY_IFACE"
    echo "Forward interface: $FWD_IFACE"
    echo "IPV6 subnet: $IPV6_SUBNET"

cat << EOF > /etc/ndppd.conf
route-ttl 30000
proxy $PROXY_IFACE {
  router yes
  timeout 500
  ttl 30000
  rule $IPV6_SUBNET {
    iface $FWD_IFACE
  }
}
EOF

  elif [ ! -z "$CONFIG" ]; then
    echo "Using configuration:"
    echo "$CONFIG"
    echo "$CONFIG" > /etc/ndppd.conf
  else
    echo "Using configuration file: /etc/ndppd.conf"
  fi
  exec /usr/local/sbin/ndppd -c /etc/ndppd.conf -v
fi
