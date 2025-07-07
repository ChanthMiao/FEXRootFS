#!/bin/sh
dnf5 install -y git ninja-build \
  lld \
  glibc-devel.x86_64 \
  glibc-devel.i686 \
  python3-devel.x86_64 \
  python3-devel.i686 \
  libXrandr-devel.x86_64 \
  libXrandr-devel.i686 \
  libxcb-devel.x86_64 \
  libxcb-devel.i686 \
  libXdamage-devel.x86_64 \
  libXdamage-devel.i686 \
  wayland-devel.x86_64 \
  wayland-devel.i686 \
  wayland-protocols-devel \
  libvdpau-devel.x86_64 \
  libvdpau-devel.i686 \
  libva-devel.x86_64 \
  libva-devel.i686 \
  libglvnd-core-devel.x86_64 \
  libglvnd-core-devel.i686 \
  libdrm-devel.x86_64 \
  libdrm-devel.i686 \
  xorg-x11-proto-devel \
  llvm-devel.x86_64 \
  llvm-devel.i686 \
  zlib-ng-devel.x86_64 \
  zlib-ng-devel.i686 \
  libxshmfence-devel.x86_64 \
  libxshmfence-devel.i686 \
  valgrind-devel.x86_64 \
  valgrind-devel.i686 \
  libunwind-devel.x86_64 \
  libunwind-devel.i686 \
  libclc-devel.x86_64 \
  libclc-devel.i686 \
  spirv-tools-devel.x86_64 \
  spirv-tools-devel.i686 \
  spirv-llvm-translator-devel.x86_64 \
  spirv-llvm-translator-devel.i686 \
  bindgen-cli.x86_64 \
  elfutils-libelf-devel.x86_64 \
  elfutils-libelf-devel.i686 \
  python3-mako \
  python3-ply \
  python3-yaml \
  libXxf86vm-devel.x86_64 \
  libXxf86vm-devel.i686 \
  libX11-devel.x86_64 \
  libX11-devel.i686 \
  lm_sensors-devel.x86_64 \
  lm_sensors-devel.i686 \
  vulkan-headers \
  glslang.x86_64 \
  glslang.i686 \
  libselinux-devel.x86_64 \
  libselinux-devel.i686 \
  expat-devel.x86_64 \
  expat-devel.i686 \
  libXfixes-devel.x86_64 \
  libXfixes-devel.i686 \
  vulkan-loader-devel.x86_64 \
  vulkan-loader-devel.i686 \
  libzstd-devel.x86_64 \
  libzstd-devel.i686 \
  kernel-headers.x86_64 \
  clang-devel.x86_64 \
  libatomic.x86_64 \
  libatomic.i686 \
  libatomic_ops.x86_64 \
  libatomic_ops.i686 \
  libatomic_ops-devel.x86_64 \
  libatomic_ops-devel.i686 \
  libpciaccess-devel.x86_64 \
  libpciaccess-devel.i686 \
  flex \
  bison\
  pkgconf.x86_64 \
  pkgconf.i686 \
  meson \
  gcc gcc-c++ \
  cmake.i686 cmake.x86_64 \
  vulkan*.x86_64 vulkan*.i686 \
  libomxil-bellagio-devel.x86_64 libomxil-bellagio-devel.i686 \
  wayland*-devel.x86_64  \
  libX*-devel.x86_64 libX*-devel.i686 \
  pkgconf-pkg-config.i686 pkgconf-pkg-config.x86_64 \
  libffi-devel.i686 libffi-devel.x86_64 \
  readline-devel.i686 readline-devel.x86_64 \
  gettext \
  python3-pycparser \
  rustup

dnf5 builddep -y mesa-libGL

# Move to /root/
cd /root

# Clone meson
git clone --depth=1 --branch 1.5.1 https://github.com/mesonbuild/meson.git

# Build and install DRM
git clone --depth=1 --branch libdrm-2.4.122 https://gitlab.freedesktop.org/mesa/drm.git
cd drm

mkdir Build
mkdir Build_x86

cd Build
/root/meson/meson.py setup -Dprefix=/usr  -Dlibdir=/usr/lib64 \
  -Dbuildtype=release \
  -Db_ndebug=true \
  -Dvc4=enabled -Dtegra=enabled -Dfreedreno=enabled -Dexynos=enabled -Detnaviv=enabled \
  -Dc_args="-mfpmath=sse -msse -msse2 -mstackrealign" \
  -Dcpp_args="-mfpmath=sse -msse -msse2 -mstackrealign" \
  ..

ninja
ninja install

cd ../
cd Build_x86

/root/meson/meson.py setup -Dprefix=/usr -Dlibdir=/usr/lib \
  -Dbuildtype=release \
  -Db_ndebug=true \
  -Dvc4=enabled -Dtegra=enabled -Dfreedreno=enabled -Dexynos=enabled -Detnaviv=enabled \
  --cross-file /root/cross_x86 \
  ..

ninja
ninja install

# Move to /root/
cd /root

# Build and install mesa
git clone --depth=1 --branch mesa-25.1.4 https://gitlab.freedesktop.org/mesa/mesa.git
cd mesa
mkdir Build
mkdir Build_x86

export GALLIUM_DRIVERS="r300,r600,radeonsi,nouveau,virgl,svga,swrast,iris,v3d,vc4,freedreno,etnaviv,tegra,lima,panfrost,zink,asahi,d3d12"
export VULKAN_DRIVERS="amd,broadcom,freedreno,panfrost,swrast,virtio,nouveau"

# Rusticl has `evaluation of constant value failed` errors, so disabled.
rustup-init --default-host x86_64-unknown-linux-gnu --default-toolchain stable -y
source "$HOME/.cargo/env"
rustup target add i686-unknown-linux-gnu
cargo install bindgen-cli cbindgen

cd Build
/root/meson/meson.py setup -Dprefix=/usr  -Dlibdir=/usr/lib64 \
  -Dbuildtype=release \
  -Db_ndebug=true \
  -Dgallium-rusticl=false -Dopencl-spirv=true -Dshader-cache=enabled -Dllvm=enabled \
  -Dgallium-drivers=$GALLIUM_DRIVERS \
  -Dvulkan-drivers=$VULKAN_DRIVERS \
  -Dplatforms=x11,wayland \
  -Dfreedreno-kmds=msm,virtio \
  -Dglvnd=enabled \
  -Dc_args="-mfpmath=sse -msse -msse2 -mstackrealign" \
  -Dcpp_args="-mfpmath=sse -msse -msse2 -mstackrealign" \
  ..

ninja
ninja install

# i686 stuff
# Fedora 40 has devel package conflicts with clang x86-64 and i686
dnf5 remove -y clang

dnf5 install -y \
  clang.i686 \
  clang-devel.i686 \
  wayland-devel.i686

cd ../
cd Build_x86

# nouveau disabled because of `evaluation of constant value failed` errors on 32-bit.
export VULKAN_DRIVERS="amd,broadcom,freedreno,panfrost,swrast,virtio"

/root/meson/meson.py setup -Dprefix=/usr -Dlibdir=/usr/lib \
  -Dbuildtype=release \
  -Db_ndebug=true \
  -Dgallium-rusticl=false -Dopencl-spirv=true -Dshader-cache=enabled -Dllvm=enabled \
  -Dgallium-drivers=$GALLIUM_DRIVERS \
  -Dvulkan-drivers=$VULKAN_DRIVERS \
  -Dplatforms=x11,wayland \
  -Dfreedreno-kmds=msm,virtio \
  -Dglvnd=enabled \
  --cross-file /root/cross_x86 \
  ..

ninja
ninja install

cd /

cargo uninstall bindgen-cli cbindgen
dnf5 remove -y rustup
