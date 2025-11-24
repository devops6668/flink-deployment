#!/usr/bin/env bash

# List your 15 worker node names here (space-separated)
NODE_LIST=(
  ocp-master01
  ocp-master02
  ocp-master03
)

# Optional: set key path and namespace/app labels once
KEY_PATH="ocp-key.key"
NS="openshift-ovn-kubernetes"
APP_LABEL="app=ovnkube-node"

for NODE in "${NODE_LIST[@]}"; do
  echo "=== Processing ${NODE} ==="

  # Remove OVN DBs on the node
  ssh -i "${KEY_PATH}" core@"${NODE}" 'sudo rm -f /var/lib/ovn-ic/etc/ovn*.db'
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to remove OVN DBs on ${NODE}"
  fi

  # Restart OVS services
  ssh -i "${KEY_PATH}" core@"${NODE}" 'sudo systemctl restart ovs-vswitchd ovsdb-server'
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to restart OVS services on ${NODE}"
  fi

  # Restart ovnkube-node pod scheduled on this node
  oc -n "${NS}" delete pod -l "${APP_LABEL}" --field-selector="spec.nodeName=${NODE}"
  if [[ $? -ne 0 ]]; then
    echo "Warning: Failed to delete ovnkube-node pod on ${NODE}"
  fi

  echo "=== Done ${NODE} ==="
done
