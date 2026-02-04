#!/bin/bash

echo "Criando todos os privacy bundles faltantes..."

# Diretório de build
BUILD_DIR="build/ios/Debug-iphonesimulator"

# Lista de todos os pacotes que podem precisar de bundles
PACKAGES=(
  "permission_handler_apple/permission_handler_apple_privacy.bundle/permission_handler_apple_privacy"
  "package_info_plus/package_info_plus_privacy.bundle/package_info_plus_privacy"
  "leveldb-library/leveldb_Privacy.bundle/leveldb_Privacy"
  "nanopb/nanopb_Privacy.bundle/nanopb_Privacy"
  "image_picker_ios/image_picker_ios_privacy.bundle/image_picker_ios_privacy"
  "connectivity_plus/connectivity_plus_privacy.bundle/connectivity_plus_privacy"
  "geolocator_apple/geolocator_apple_privacy.bundle/geolocator_apple_privacy"
  "google_maps_flutter_ios/google_maps_flutter_ios_privacy.bundle/google_maps_flutter_ios_privacy"
  "google_sign_in_ios/google_sign_in_ios_privacy.bundle/google_sign_in_ios_privacy"
)

# Cria todos os diretórios e arquivos
for package in "${PACKAGES[@]}"; do
  DIR=$(dirname "$package")
  FILE=$(basename "$package")
  
  mkdir -p "$BUILD_DIR/$DIR"
  touch "$BUILD_DIR/$DIR/$FILE"
  
  echo "Criado: $package"
done

echo "Bundles criados com sucesso!"