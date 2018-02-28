#!/bin/bash
set -o errexit -o nounset

# Get version information
. "$(dirname "$0")/versions.sh"

# Tool locations
s3="https://cf-opensusefs2.s3.amazonaws.com/fissile"

# Tool versions
thefissile="fissile-$(echo "${FISSILE_VERSION}" | sed -e 's/+/%2B/')"

# Installs tools needed to build and run HCF
bin_dir="${bin_dir:-output/bin}"
tools_dir="${tools_dir:-output/tools}"
ubuntu_image="${ubuntu_image:-ubuntu:${UBUNTU_VERSION}}"
cf_url="${cf_url:-https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CFCLI_VERSION}&source=github-rel}"
stampy_url="${stampy_url:-https://github.com/SUSE/stampy/releases/download/${STAMPY_MAJOR}/stampy-${STAMPY_VERSION}.linux-amd64.tgz}"
kubectl_url="${kubectl_url:-https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl}"
k_url="${k_url:-https://github.com/aarondl/kctl/releases/download/v${K_VERSION}/kctl-linux-amd64}"
kk_url="${kk_url:-https://gist.githubusercontent.com/jandubois/${KK_VERSION}/raw/}"
helm_url="${helm_url:-https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz}"

mkdir -p "${bin_dir}"
mkdir -p "${tools_dir}"

bin_dir="$(cd "${bin_dir}" && pwd)"

echo "Fetching cf CLI $cf_url ..."
wget -q "$cf_url"        -O "${tools_dir}/cf.tgz"
echo "Fetching fissile  ..."
cp bin/fissile ${bin_dir}
echo "Installed"

echo "Fetching stampy $stampy_url ..."
wget -q "$stampy_url"   -O - | tar xz -C "${bin_dir}" stampy

echo "Unpacking cf CLI ..."
tar -xzf "${tools_dir}/cf.tgz" -C "${bin_dir}"

echo "Fetching kubectl ${kubectl_url} ..."
wget -q "${kubectl_url}" -O "${bin_dir}/kubectl"
wget -q "${k_url}" -O "${bin_dir}/k"
wget -q "${kk_url}" -O "${bin_dir}/kk"

echo "Fetching helm from ${helm_url} ..."
wget -q "${helm_url}" -O - | tar xz -C "${bin_dir}" --strip-components=1 linux-amd64/helm

echo "Making binaries executable ..."
chmod a+x "${bin_dir}/stampy"
chmod a+x "${bin_dir}/cf"
chmod a+x "${bin_dir}/kubectl"
chmod a+x "${bin_dir}/k"
chmod a+x "${bin_dir}/kk"
chmod a+x "${bin_dir}/helm"


echo "Done."
