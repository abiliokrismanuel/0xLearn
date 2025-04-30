#!/bin/bash

set -e

echo "=================================="
echo " K3s Installer / Uninstaller 🐳"
echo "=================================="
echo ""
echo "Pilih opsi:"
echo "1) Install normal (standar) standalone"
echo "2) Install dan disable Traefik (standalone)"
echo "3) Install normal dan tambah install Helm (standalone)"
echo "4) Install dan tambah install Helm dan disable Traefik (standalone)"
echo "5) Uninstall K3s"
echo "6) Install HA (Master Pertama - cluster init)"
echo "7) Join HA (Master Ke-2 / Ke-3)"
echo "8) Join Worker ke Cluster"
echo "9) Install Helm (jika belum terinstall)"
read -p "Masukkan pilihan (1-8): " pilihan

install_helm() {
  if command -v helm &> /dev/null; then
    echo "Helm sudah terinstall. Melewati instalasi Helm."
  else
    echo "Menginstall Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
  fi
}

uninstall_k3s() {
  echo "Menghapus instalasi K3s..."
  if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
    /usr/local/bin/k3s-uninstall.sh
    echo "K3s berhasil dihapus dari node ini."
  elif [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
    /usr/local/bin/k3s-agent-uninstall.sh
    echo "K3s Agent berhasil dihapus dari node ini."
  else
    echo "Tidak menemukan skrip uninstall. Mungkin K3s belum terinstall di node ini."
  fi
}

install_ha_master() {
  read -p "Masukkan alamat NLB (contoh: nlb-k3s.example.com): " NLB_ADDRESS

  echo "Menginstall K3s HA (cluster-init untuk master pertama)..."
  curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="server --cluster-init --tls-san ${NLB_ADDRESS}" \
    sh -

  echo ""
  echo "Mengambil K3S_TOKEN..."
  K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

  echo ""
  echo "Simpan token ini untuk join node master/worker:"
  echo "----------------------------------"
  echo "$K3S_TOKEN"
  echo "----------------------------------"
}

join_ha_master() {
  read -p "Masukkan alamat NLB (contoh: nlb-k3s.example.com): " NLB_ADDRESS
  read -p "Masukkan K3S_TOKEN: " K3S_TOKEN

  echo "Menginstall dan join ke cluster HA sebagai master..."
  curl -sfL https://get.k3s.io | \
    K3S_URL="https://${NLB_ADDRESS}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC="server" \
    sh -
}

join_worker() {
  read -p "Masukkan alamat NLB (contoh: nlb-k3s.example.com): " NLB_ADDRESS
  read -p "Masukkan K3S_TOKEN: " K3S_TOKEN

  echo "Menginstall dan join ke cluster sebagai worker (agent)..."
  curl -sfL https://get.k3s.io | \
    K3S_URL="https://${NLB_ADDRESS}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC="agent" \
    sh -
}

case $pilihan in
  1)
    echo "Menginstall K3s secara normal standalone..."
    curl -sfL https://get.k3s.io | sh -
    ;;
  2)
    echo "Menginstall K3s dan disable Traefik standalone..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -
    ;;
  3)
    echo "Menginstall K3s secara normal standalone..."
    curl -sfL https://get.k3s.io | sh -
    install_helm
    ;;
  4)
    echo "Menginstall K3s dan disable Traefik standalone..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -
    install_helm
    ;;
  5)
    read -p "Apakah kamu yakin ingin menghapus K3s? (y/n): " konfirmasi
    if [[ "$konfirmasi" == "y" ]]; then
      uninstall_k3s
    else
      echo "Uninstall dibatalkan."
      exit 0
    fi
    ;;
  6)
    install_ha_master
    ;;
  7)
    join_ha_master
    ;;
  8)
    join_worker
    ;;
  9) 
    install_helm
    ;;
  *)
    echo "Pilihan tidak valid. Silakan jalankan ulang skrip."
    exit 1
    ;;
esac

echo ""
echo "=================================="
echo " Proses selesai!"
echo "=================================="
