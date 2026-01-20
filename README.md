# STL Tool (Wegare)

### Architecture Information
**Default Architecture:** `aarch64_cortex-a53`

Jika router/SBC Anda memiliki arsitektur yang berbeda, Anda perlu melakukan compile sendiri file pendukungnya. Ikuti tutorial di bawah ini.

---

## 🛠 Cara Compile (Build from Source)

### 1. Install Dependencies
Jalankan perintah berikut di terminal (Ubuntu/Debian) untuk menginstall paket yang dibutuhkan:

```bash
apt update -y && apt upgrade
apt-get -y install tar build-essential asciidoc binutils bzip2 gawk rsync gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler
```

### 2. Setup OpenWrt SDK
Contoh di bawah ini menggunakan SDK untuk architecture `aarch64_cortex-a53`.

> **Catatan:** Untuk architecture lain, silakan cari di [OpenWrt Downloads](https://downloads.openwrt.org/releases/).
> Pilih `versi openwrt` > `targets` > pilih architecture sesuai router kalian > salin link SDK-nya.

```bash
# Download SDK (Contoh)
wget https://downloads.openwrt.org/releases/21.02.0-rc3/targets/sunxi/cortexa53/openwrt-sdk-21.02.0-rc3-sunxi-cortexa53_gcc-8.4.0_musl.Linux-x86_64.tar.xz

# Ekstrak dan masuk ke folder
tar -xf openwrt-sdk-21.02.0-rc3-sunxi-cortexa53_gcc-8.4.0_musl.Linux-x86_64.tar.xz
cd openwrt-sdk-21.02.0-rc3-sunxi-cortexa53_gcc-8.4.0_musl.Linux-x86_64
```

### 3. Compile Badvpn-Tun2socks

```bash
git clone https://github.com/yazdan/tun2socks-Openwrt
cp -rf tun2socks-Openwrt/badvpn package/
rm -rf tun2socks-Openwrt/
make defconfig
make menuconfig
```
* Di menuconfig, pilih: **Network > VPN > badvpn**
* Exit & Save

```bash
make package/badvpn/compile V=99
```

### 4. Compile Corkscrew

```bash
git clone https://github.com/pfalcon/openwrt-packages.git
cp -rf openwrt-packages/net/corkscrew package/
rm -rf openwrt-packages
make menuconfig
```
* Di menuconfig, pilih: **Network > SSH > corkscrew**
* Exit & Save

```bash
make package/corkscrew/compile V=99
```

### 5. Compile SSHPass

```bash
mkdir -p package/sshpass
wget --no-check-certificate "https://www.dropbox.com/s/kr1hfprl5uwrm6u/sshpass-1.06.zip" && unzip sshpass-1.06.zip && rm -rf sshpass-1.06.zip
mv sshpass-1.06 package/sshpass/src
chmod +x package/sshpass/src/*
wget --no-check-certificate "https://www.dropbox.com/s/wp4asjlqjp2ah4s/makefile" -O package/sshpass/Makefile
make menuconfig
```
* Di menuconfig, pilih: **Utilities > sshpass**
* Exit & Save

```bash
make package/sshpass/compile V=99
```

---

## 🚀 Instalasi STL (Di Router)

Jalankan perintah berikut di terminal OpenWrt Anda:

```bash
wget --no-check-certificate "https://raw.githubusercontent.com/wegare123/stl/main/stl/install.sh" -O ~/install.sh && chmod 777 ~/install.sh && ~/./install.sh
```

---

## ⚠️ Catatan Penting

> Jika ingin mengganti profile, melakukan inject ulang, atau perubahan konfigurasi lainnya:
> 1.  **Wajib STOP Inject** terlebih dahulu (Pilih menu no **3**).
> 2.  **Disable Auto Booting** (Pilih menu no **5**).
>
> Hal ini dilakukan agar tidak terjadi bentrok process (conflict).