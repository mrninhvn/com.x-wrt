#!/bin/sh

proxym="luci-app-tinyproxy luci-i18n-tinyproxy-en luci-i18n-tinyproxy-zh-cn sockd tinyproxy"

nfs="kmod-dnsresolver \
     kmod-fs-nfs \
     kmod-fs-nfs-v4 \
     libwrap \
     nfs-utils"

lucibond="luci-proto-bonding proto-bonding kmod-bonding"

lucistd="luci \
		 luci-ssl \
		 uhttpd \
		 uhttpd-mod-ubus"

usbprint="kmod-usb-printer \
		  p910nd \
		  luci-app-p910nd \
		  luci-i18n-p910nd-en \
		  luci-i18n-p910nd-zh-cn"

iphone4g="usbutils usbmuxd libimobiledevice-utils libimobiledevice"

usb4g="wwan \
	   uqmi \
	   kmod-usb-wdm \
	   kmod-usb-net-qmi-wwan \
	   kmod-usb-net-cdc-mbim \
	   kmod-usb-net-cdc-ncm \
	   kmod-usb-net-huawei-cdc-ncm \
	   kmod-usb-net-ipheth \
	   kmod-usb-net-rtl8152 \
	   kmod-usb-net-sierrawireless \
	   kmod-usb-serial \
	   kmod-usb-serial-option \
	   kmod-usb-serial-qualcomm \
	   kmod-usb-serial-sierrawireless \
	   kmod-usb-serial-wwan \
	   libusb-1.0 \
	   usb-modeswitch \
	   chat \
	   comgt \
	   comgt-ncm \
	   umbim \
	   luci-proto-qmi \
	   luci-proto-mbim \
	   luci-proto-ncm \
	   luci-proto-3g"

usb2="kmod-usb2 \
	  kmod-usb-core \
	  kmod-usb-ohci \
	  kmod-usb-storage \
	  kmod-usb-storage-uas \
	  kmod-scsi-core \
	  kmod-crypto-crc32c \
	  kmod-nls-cp437 \
	  kmod-lib-crc16 \
	  kmod-fs-autofs4 \
	  kmod-exfat-linux \
	  kmod-fs-exfat \
	  kmod-fs-ext4 \
	  kmod-fs-msdos \
	  kmod-fuse \
	  kmod-fs-vfat \
	  block-mount \
	  blockd \
	  kmod-fs-ntfs3"

usb3="kmod-usb3 \
	  kmod-usb-core \
	  kmod-usb-ohci \
	  kmod-usb-storage \
	  kmod-usb-storage-uas \
	  kmod-scsi-core \
	  kmod-crypto-crc32c \
	  kmod-nls-cp437 \
	  kmod-lib-crc16 \
	  kmod-fs-autofs4 \
	  kmod-exfat-linux \
	  kmod-fs-exfat \
	  kmod-fs-ext4 \
	  kmod-fs-msdos \
	  kmod-fuse \
	  kmod-fs-vfat \
	  block-mount \
	  blockd \
	  kmod-fs-ntfs3"

aria2="luci-app-aria2 luci-i18n-aria2-en luci-i18n-aria2-zh-cn webui-aria2 aria2"

ksmbd="luci-app-ksmbd luci-i18n-ksmbd-en luci-i18n-ksmbd-zh-cn ksmbd-server ksmbd-utils kmod-fs-ksmbd wsdd2"

moreapps="wget-ssl"

utils="minicom kmod-usb-serial-pl2303 sendip"

cdcmod="kmod-mii \
		kmod-usb-net \
		kmod-usb-net-cdc-ether \
		kmod-usb-net-rndis"

ssmod="libmbedtls \
	   libsodium \
	   luci-app-shadowsocks-libev \
	   shadowsocks-client \
	   shadowsocks-libev-config \
	   shadowsocks-libev-ss-local \
	   shadowsocks-libev-ss-redir \
	   shadowsocks-libev-ss-rules \
	   shadowsocks-libev-ss-server \
	   shadowsocks-libev-ss-tunnel"

wgmod="wireguard-tools \
	   luci-app-wireguard \
	   luci-proto-wireguard \
	   luci-i18n-wireguard-en \
	   luci-i18n-wireguard-zh-cn \
	   qrencode \
	   libqrencode"

ipv6extra="kmod-jool-netfilter \
	   kmod-nat46 \
	   jool-tools-netfilter"

wifiextra="kmod-batman-adv batctl-full luci-app-dawn dawn"

openvpnmod="luci-app-openvpn \
			luci-i18n-openvpn-en \
			luci-i18n-openvpn-zh-cn \
			openvpn-openssl"

excludes_basic="dnsmasq \
		  kmod-ipt-offload \
		  kmod-nf-flow \
		  odhcpd \
		  wpad-basic \
		  wpad-mini"

excludes=""

get_modules()
{
	local m
	m=`for i in $@; do
		echo $i
		[ "$i" = "rssileds" ] && echo luci-app-ledtrig-rssi
		[ "$i" = "kmod-usb-ledtrig-usbport" ] && echo luci-app-ledtrig-usbport
	done | sort | uniq`
	m=`echo $m`
	echo $m
}

get_modules_only()
{
	local m
	m=`for i in $@; do grep -q "CONFIG_PACKAGE_$i=m" .config && echo $i; done`
	m=`echo $m`
	echo $m
}

exclude_modules()
{
	local m
	m=`for i in $@ $excludes $excludes; do echo $i; done | sort | uniq -c | grep ' 1' | awk '{print $2}' | sort`

	# filter_conflict()
	m=`echo "$m" | grep -q "^kmod-ath10k-ct-smallbuffers$" && echo "$m" | grep -q "^kmod-ath10k-ct$" && echo "$m" | grep -v "^kmod-ath10k-ct$" || echo "$m"`

	m=`echo $m`
	echo $m
}

rm -rf /tmp/config_lede
mkdir /tmp/config_lede
cat .config | grep TARGET_DEVICE_.*=y | sed 's/CONFIG_//;s/=y//' | while read target; do
	cat tmp/.config-target.in | grep "menuconfig $target" -A200 | while read line; do
		test -n "$line" || break
		echo $line | grep -q 'select MODULE_DEFAULT' && {
			echo $line | awk '{print $2}' | sed 's/MODULE_DEFAULT_//'
		}
	done | sort >/tmp/config_lede/$target
done

targets=`cd /tmp/config_lede && ls`
alls=`cat /tmp/config_lede/* 2>/dev/null | sort | uniq`
#echo $alls

is_in_set()
{
	_i=$1
	_s=$2
	for l in `cat $_s`; do
		[ x$l = x$_i ] && return 0
	done
	return 1
}

uniqs=$(for p in $alls; do
	for t in $targets; do
		is_in_set $p /tmp/config_lede/$t || {
			echo $p
			break
		}
	done
done | sort | uniq)

echo uniqs=$uniqs

ms="`cat .config | grep =m$ | sed 's/CONFIG_PACKAGE_//;s/=m//g'`"
modules=$(for i in $ms; do
	echo $i
done)
#echo "$uniqs" | grep -q $i$ || echo $i
echo modules=$modules

get_target_mods()
{
	local addms_tmp
	local addms
	addms_tmp=$(cat tmp/.config-feeds.in tmp/.config-target.in tmp/.config-package.in | grep "config $1$" -A80 | while read line; do
		test -n "$line" || break
		echo $line | grep "select MODULE_DEFAULT_" | awk '{print $2}' | grep MODULE_DEFAULT_ | sed 's/MODULE_DEFAULT_//'
	done)
	addms=""
	for m in $addms_tmp; do
		for i in $modules; do
			[ x$m = x$i ] && addms="$addms $m"
		done
	done
	echo $addms
}

get_deps()
{
	local addms_tmp
	local addms
	local addm
	addms_tmp=$(cat tmp/.config-feeds.in tmp/.config-target.in tmp/.config-package.in | grep "config PACKAGE_$1$" -A40 | while read line; do
		test -n "$line" || break
		echo $line | grep "select PACKAGE_" | awk '{print $2}' | grep PACKAGE_ | sed 's/PACKAGE_//'
		echo $line | grep "depends on PACKAGE_" | awk '{print $3}' | grep PACKAGE_ | sed 's/PACKAGE_//'
	done)
	addms=""
	for m in $addms_tmp; do
		for i in $modules; do
			[ x$m = x$i ] && addms="$addms $m"
		done
	done
	for m in $addms; do
		addm=`get_deps $m`
		test -n "$addm" && addms="$addms $addm"
	done
	addms_tmp="$addms"
	addms=""
	for m in $addms_tmp; do
		for i in $modules; do
			[ x$m = x$i ] && addms="$addms $m"
		done
	done
	echo $addms
}

for t in $targets; do
	us=$(for u in $uniqs; do
		is_in_set $u /tmp/config_lede/$t && echo $u
	done)
	echo $t=`get_modules $us`
	mods="$us"
	flash_gt8m=0
	has_usb=0
	extra_utils=0
	excludes="$excludes_basic"
	case $t in
		#>8M flash
		TARGET_DEVICE_ipq40xx_generic_DEVICE_zte_mf286d|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_fm10-ax-nand|\
		TARGET_DEVICE_mediatek_mt7622_DEVICE_totolink_a8000ru|\
		TARGET_DEVICE_bcm4908_generic_DEVICE_asus_gt-ac5300|\
		TARGET_DEVICE_bcm4908_generic_DEVICE_netgear_r8000p|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_ruijie_rg-mtfi-m520|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_ad7200|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_mobipromo_cm520-79f|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_mr8300|\
		TARGET_DEVICE_mediatek_mt7622_DEVICE*|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-ap1300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-norplusemmc|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-nand|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2c|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2s|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r4s|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_linksys_ea7500-v1|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-s1300|\
		TARGET_DEVICE_mvebu_cortexa53_DEVICE_glinet_gl-mv1000|\
		TARGET_DEVICE_ath79_nand_DEVICE_domywifi_dw33d|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_c2600|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_vr2600v|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_buffalo_wxr-2533dhp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6800|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6700-v2|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr3700-v4|\
		TARGET_DEVICE_ath79_nand_DEVICE_xwrt_gw521-nand|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_alfa-network_ap120c-ac|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6200v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6260|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6850|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_huawei_hg255d|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_totolink_a7000r|\
		TARGET_DEVICE_bcm27xx_bcm2709_DEVICE_rpi-2|\
		TARGET_DEVICE_bcm27xx_bcm2710_DEVICE_rpi-3|\
		TARGET_DEVICE_bcm27xx_bcm2711_DEVICE_rpi-4|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_avm_fritzbox-4040|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_avm_fritzbox-7530|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar300m-nand|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubiquiti_edgerouterx|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubiquiti_edgerouterx-sfp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubnt_edgerouter-x|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubnt_edgerouter-x-sfp|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar750s-nor-nand|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6150v2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6100v2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-b1300|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_engenius_eap1300|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_compex_wpj428|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_map-ac2200|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_ea8300|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_ea6350v3|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_vocore_vocore-16m|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_hg255d|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_phicomm_k3|\
		TARGET_DEVICE_ath79_nand_DEVICE_arris_sbr-ac1750|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6350|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tplink_archer-c9-v1|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tplink_archer-c5-v2|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_dlink_dir-885l|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea6500-v2|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea6300-v1|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea9200|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea9500|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r8500|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt32x|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-ac58u|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-ac42u|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-acrh17|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac-128m|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac-64m|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_zyxel_nbg6817|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_avm_fritzbox-4040|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r6250|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3-pro|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_redmi-router-ac2100|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-ac2100|\
		TARGET_DEVICE_kirkwood_DEVICE_on100|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_audi|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_ea4500|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_ea3500|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_e4200-v2|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_qcom_ap-dk04.1-c1|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_asus-rt-n16|\
		TARGET_DEVICE_oxnas_DEVICE_pogoplug-pro|\
		TARGET_DEVICE_oxnas_DEVICE_pogoplug-v3|\
		TARGET_DEVICE_kirkwood_DEVICE_pogo_e02|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_linksys-e3200-v1|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_linksys_ea8500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_xr500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7800|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7500v2|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_d7800|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_viper|\
		TARGET_DEVICE_apm821xx_nand_DEVICE_WNDR4700|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_r6100|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4300|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4300-v2|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4500-v3|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac56u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac68u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac87u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-n18u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r6300-v2|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r7000|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r7900|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r8000|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1200ac|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900ac-v1|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900acs|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900ac-v2|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt3200acm|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg3526-32m|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220a|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220b|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220c)
			mods="$mods $lucibond $ipv6extra $wifiextra"
			mods="$mods $wgmod $openvpnmod wpad-openssl luci-ssl-nginx"
			excludes="$excludes wpad-basic-wolfssl"
			flash_gt8m=1
			extra_utils=1
		;;
		#>8M flash <14M
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg108|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_thunder_timecloud|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-882-a1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-882-r1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_q20|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_jhr-ac876m|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-4|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_glinet_gl-mt1300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_y2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_totolink_x5000r|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea8100-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea8100-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7300-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7300-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_asus_rt-ac85p|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_asus_rt-ac57u|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaoyu_xy-c5|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7500-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_adslr_g7|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_youku_yk-l2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tenbay_mac500f|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wevo_11acnas|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wevo_w2914ns-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-750gr3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-m11g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-m33g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_gehua_ghl-r-001|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xzwifi_creativebox-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mtc_wr1201|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_iodata_wn-ax1167gr|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_youhua_wr1200js|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wf-2881|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-860l-b1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_d-team_pbr-m1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-we3526|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_d-team_newifi-d2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbt-we3526|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-4a-gigabit|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-we1326|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg2626|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg3526-16m|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_buffalo_wsr-1166dhp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_lenovo_newifi-d1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_hiwifi_hc5962|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-cr660x|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-c6-v3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-a6-v3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_e5600|\
		TARGET_DEVICE_ath79_generic_DEVICE_letv_lba-047-ch|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1202kd-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1200k-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1201k-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_x-sdwan-1200|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_mac500f|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_puppies|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_nxc200p|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_tcb1800k-ax-nor|\
		TARGET_DEVICE_ath79_nand_DEVICE_xwrt_gw521-nor|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar300m-nor|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar750s-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3-pro-nor|\
		TARGET_DEVICE_ath79_nand_DEVICE_domywifi_dw33d-nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_aruba_ap-105|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-ag300h|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-g302h-a1a0|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-g450h|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-e313ac|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-e5|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-wr650ac-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-wr650ac-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1200e|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1200i|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1750c|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1750i|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_magic-2-wifi|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-825-c1|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-835-a1|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-842-c3|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-859-a1|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_ecb1750|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_ews511ap|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_ar300m_nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar150|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar300m16|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar300m-lite|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar750|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar750s|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-mifi|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-x750|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3700-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3800|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wnr2200-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_qihoo_c301|\
		TARGET_DEVICE_ath79_generic_DEVICE_rosinson_wr818|\
		TARGET_DEVICE_ath79_generic_DEVICE_sitecom_wlr-8100|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-a7-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c59-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c59-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c5-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v4|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d7b-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d7-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4900-v2-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v4|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043n-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_trendnet_tew-823dru|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_lap-120|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanobeam-ac|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-ac|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-ac-loco|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_routerstation|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_routerstation-pro|\
		TARGET_DEVICE_ath79_generic_DEVICE_wd_mynet-n750|\
		TARGET_DEVICE_ath79_generic_DEVICE_xiaomi_aiot-ac2350|\
		TARGET_DEVICE_ath79_generic_DEVICE_xiaomi_mi-router-4q|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_gw521-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_xd1202g|\
		TARGET_DEVICE_ath79_generic_DEVICE_yuncore_a770|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5661a|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5761a|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_glinet_gl-mt300n-v2|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5861b|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_netgear_r6120|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_vocore_vocore2|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_skylab_skw92a|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_mi-router-4a-100m|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xwrt_g4303k-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_miwifi-3c|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt300n|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt300a|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_ohyeah_oy-0001|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lava_lr-25g001|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_bdcom_wap2100-sk|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-n12p|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-ac51u|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-n14u|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt750|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-118-a1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-118-a2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dir-510l|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_xiaomi_miwifi-r3 |\
		TARGET_DEVICE_ramips_mt7620_DEVICE_modou_m101c|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we826-32m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we826-16m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_we1026-5g-16m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_xiaomi_miwifi-mini|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_fon_fon2601|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-ac54u|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5661|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5761|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5861|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lenovo_newifi-y1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lenovo_newifi-y1s|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk-l1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk-l1c|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-c6u-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tenbay_t-mb5eu-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_wndr3700-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_csac|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_csac2|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_wmb001n|\
		TARGET_DEVICE_ath79_generic_DEVICE_iodata_wn-ac1167dgr|\
		TARGET_DEVICE_ath79_generic_DEVICE_iodata_wn-ac1600dgr2|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_epg5000|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_bm100_hq55)
			mods="$mods $wgmod $openvpnmod wpad-openssl luci-ssl-nginx"
			excludes="$excludes wpad-basic-wolfssl"
			flash_gt8m=1
		;;
		TARGET_DEVICE_ramips_mt76x8_DEVICE_mediatek_mt7628an-eval-board|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_ms1201k|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_mi-router-4c|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr6400-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr6400-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-usb150|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr710n-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr710n-v2.1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr810n-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr810n-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_nexx_wt3020-8m|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wnr2200-8m|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_ts-d084|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_cudy_wr1000|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_vocore_vocore2-lite|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_re650-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_re500-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_adtran_bsap1840|\
		TARGET_DEVICE_ath79_generic_DEVICE_adtran_bsap1800-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_m-ap300g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_iodata_wn-gx300gr|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d50-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_glinet_vixmini|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_ex6400|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_ex7300|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_mk-v0201|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_ex6150|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-m-xw|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr802n-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr3020-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c50-v4|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_vocore_vocore-8m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-922-e2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-921-c1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-921-c3|\
		TARGET_DEVICE_ath79_generic_DEVICE_nec_wg800hp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_re350-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_bullet-m-xw|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c58-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_wavlink_wl-wn570ha1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_planex_mzk-750dhp|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dovado_tiny-ac|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_edimax_br-6478ac-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c20i|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c50-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-mr200|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c20-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c2-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v2|\
		TARGET_DEVICE_ramips_rt3883_DEVICE_asus_rt-n56u|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_wmm003n|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr902ac-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr842n-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wa801nd-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr3420-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c50-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c20-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c20-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3700|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_bullet-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nano-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_rocket-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifi|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-lite|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-mesh|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-mesh-pro|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-pro|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4900-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr2543-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-re450-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4300-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3600-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dir-810l|\
		TARGET_DEVICE_sunxi_cortexa7_DEVICE_xunlong_orangepi-r1|\
		TARGET_DEVICE_sunxi_cortexa7_DEVICE_friendlyarm_nanopi-neo|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_buffalo_wcr-1166ds|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_buffalo_whr-1166d|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr902ac-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_cpe510-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_cpe510-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we2026|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr841n-v13|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr840n-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_mercury_mac1200r-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_phicomm_k2p|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr7500-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_phicomm_k2t|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_miwifi-nano|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-wrt610n-v2|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-wrt610n-v1|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-e3000-v1|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_netgear-wndr3700-v3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_re6500|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3500-v1|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tenda_ac9|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-wr8305rt|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2g|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1208|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1218a|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2-v22.4|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2-v22.5|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1218b)
			mods="$mods wpad-basic-wolfssl"
			excludes="$excludes wpad-openssl"
		;;
		*)
			echo not handle moreapps $t
		;;
	esac
	#check usb
	case $t in
		#with usb3
		TARGET_DEVICE_ipq40xx_generic_DEVICE_zte_mf286d|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_fm10-ax-nand|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-c6u-v1|\
		TARGET_DEVICE_mediatek_mt7622_DEVICE_totolink_a8000ru|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-882-a1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-882-r1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tenbay_t-mb5eu-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_jhr-ac876m|\
		TARGET_DEVICE_bcm4908_generic_DEVICE_asus_gt-ac5300|\
		TARGET_DEVICE_bcm4908_generic_DEVICE_netgear_r8000p|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_ruijie_rg-mtfi-m520|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_ad7200|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_mobipromo_cm520-79f|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_mr8300|\
		TARGET_DEVICE_mediatek_mt7622_DEVICE*|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-ap1300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_glinet_gl-mt1300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_y2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea8100-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea8100-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7300-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7300-v1|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_linksys_ea7500-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_ea7500-v2|\
		TARGET_DEVICE_mvebu_cortexa53_DEVICE_glinet_gl-mv1000|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_adslr_g7|\
		TARGET_DEVICE_ath79_generic_DEVICE_sitecom_wlr-8100|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_c2600|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_tplink_vr2600v|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_buffalo_wxr-2533dhp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6800|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6700-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_asus_rt-ac85p|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaoyu_xy-c5|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6260|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6850|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_thunder_timecloud|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1202kd-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1200k-v01|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_t-cpe1201k-v01|\
		TARGET_DEVICE_bcm27xx_bcm2709_DEVICE_rpi-2|\
		TARGET_DEVICE_bcm27xx_bcm2710_DEVICE_rpi-3|\
		TARGET_DEVICE_bcm27xx_bcm2711_DEVICE_rpi-4|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_avm_fritzbox-4040|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_avm_fritzbox-7530|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tenbay_mac500f|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_ea8300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_youku_yk-l2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-b1300|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_compex_wpj428|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wevo_11acnas|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wevo_w2914ns-v2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_linksys_ea6350v3|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_phicomm_k3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_gehua_ghl-r-001|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xzwifi_creativebox-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mtc_wr1201|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tplink_archer-c9-v1|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_dlink_dir-885l|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea6500-v2|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea6300-v1|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea9200|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_linksys_ea9500|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r8500|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt32x|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_mac500f|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_wf-2881|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_dlink_dir-860l-b1|\
		TARGET_DEVICE_sunxi_cortexa7_DEVICE_xunlong_orangepi-r1|\
		TARGET_DEVICE_sunxi_cortexa7_DEVICE_friendlyarm_nanopi-neo|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-ac58u|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-ac42u|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-acrh17|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac-128m|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac-64m|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_p2w_r619ac|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_zyxel_nbg6817|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_avm_fritzbox-4040|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r6250|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3-pro-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3-pro|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_qcom_ap-dk04.1-c1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-we1326|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg2626|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg3526-16m|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg3526-32m|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_linksys_ea8500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_xr500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7800|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7500v2|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_r7500|\
		TARGET_DEVICE_ipq806x_generic_DEVICE_netgear_d7800|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_viper|\
		TARGET_DEVICE_apm821xx_nand_DEVICE_WNDR4700|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac56u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac68u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-ac87u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_asus_rt-n18u|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r6300-v2|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r7000|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r7900|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_netgear_r8000|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1200ac|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900ac-v1|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900acs|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt1900ac-v2|\
		TARGET_DEVICE_mvebu_cortexa9_DEVICE_linksys_wrt3200acm|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lenovo_newifi-y1s|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk-l1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_youku_yk-l1c|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_hiwifi_hc5962|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_wndr3700-v5|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_lenovo_newifi-d1)
			mods="$mods $usb2 $usb3"
			mods="$mods $cdcmod"
			has_usb=1
		;;
		#with usb2
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-wg108|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_mediatek_mt7628an-eval-board|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr710n-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr710n-v2.1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr810n-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_nexx_wt3020-8m|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2c|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2s|\
		TARGET_DEVICE_rockchip_armv8_DEVICE_friendlyarm_nanopi-r4s|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-ac54u|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d7-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d7b-v1|\
		TARGET_DEVICE_ath79_nand_DEVICE_domywifi_dw33d|\
		TARGET_DEVICE_ath79_nand_DEVICE_domywifi_dw33d-nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_bm100_hq55|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr3700-v4|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wnr2200-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wnr2200-8m|\
		TARGET_DEVICE_ath79_nand_DEVICE_xwrt_gw521-nand|\
		TARGET_DEVICE_ath79_nand_DEVICE_xwrt_gw521-nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_gw521-16m|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_alfa-network_ap120c-ac|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6200v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar750|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_ts-d084|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_wmb001n|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_fon_fon2601|\
		TARGET_DEVICE_ath79_generic_DEVICE_trendnet_tew-823dru|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_m-ap300g|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_csac|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_csac2|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xwrt_g4303k-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_wd_mynet-n750|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_epg5000|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_mk-v0201|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar300m-nand|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar300m-nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-x750|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar750s|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar750s-nor|\
		TARGET_DEVICE_ath79_nand_DEVICE_glinet_gl-ar750s-nor-nand|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar300m16|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar300m-lite|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-ar150|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-mifi|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_vocore_vocore-8m|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_vocore_vocore-16m|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-750gr3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-m11g|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_mikrotik_routerboard-m33g|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-859-a1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-118-a1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-118-a2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v4|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v5|\
		TARGET_DEVICE_ath79_nand_DEVICE_arris_sbr-ac1750|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-a7-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-825-c1|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-835-a1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6350|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c59-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_rosinson_wr818|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_vocore_vocore2-lite|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_vocore_vocore2|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_skylab_skw92a|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lava_lr-25g001|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_bdcom_wap2100-sk|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tplink_archer-c5-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt750|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dovado_tiny-ac|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_edimax_br-6478ac-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c20-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c2-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-ag300h|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-g302h-a1a0|\
		TARGET_DEVICE_ath79_generic_DEVICE_buffalo_wzr-hp-g450h|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-ac|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-ac-loco|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_routerstation|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_routerstation-pro|\
		TARGET_DEVICE_ramips_rt3883_DEVICE_asus_rt-n56u|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-ac51u|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-n14u|\
		TARGET_DEVICE_ath79_generic_DEVICE_iodata_wn-ac1167dgr|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5861b|\
		TARGET_DEVICE_ath79_generic_DEVICE_pisen_wmm003n|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr902ac-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr842n-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr3420-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_netgear_r6120|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3700-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3700|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_bullet-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nano-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_rocket-m|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifi|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-pro|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4900-v2-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4900-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_iodata_wn-ac1600dgr2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr2543-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c7-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_ar300m_nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4300-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3600-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wndr3800|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v4|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043nd-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_glinet_gl-mt300n-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt300n|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_glinet_gl-mt300a|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_youhua_wr1200js|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_d-team_pbr-m1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbtlink_zbt-we3526|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_d-team_newifi-d2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_ohyeah_oy-0001|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_zbt-we3526|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_xiaomi_miwifi-r3 |\
		TARGET_DEVICE_ramips_mt7620_DEVICE_modou_m101c|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we826-32m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we826-16m|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_we1026-5g-16m|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr842n-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c59-v2|\
		TARGET_DEVICE_kirkwood_DEVICE_on100|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_audi|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_ea4500|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_ea3500|\
		TARGET_DEVICE_kirkwood_DEVICE_linksys_e4200-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr7500-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5661a|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_hiwifi_hc5761a|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-wrt610n-v2|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-wrt610n-v1|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_asus-rt-n16|\
		TARGET_DEVICE_oxnas_DEVICE_pogoplug-pro|\
		TARGET_DEVICE_oxnas_DEVICE_pogoplug-v3|\
		TARGET_DEVICE_kirkwood_DEVICE_pogo_e02|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_netgear-wndr3700-v3|\
		TARGET_DEVICE_brcm47xx_mips74k_DEVICE_linksys-e3200-v1|\
		TARGET_DEVICE_brcm47xx_generic_DEVICE_linksys-e3000-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220a|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220b|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_r6220c|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_buffalo_wsr-1166dhp|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4300|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4300-v2|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_wndr4500-v3|\
		TARGET_DEVICE_ath79_nand_DEVICE_netgear_r6100|\
		TARGET_DEVICE_bcm53xx_generic_DEVICE_tenda_ac9|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3500-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_qihoo_c301|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5661|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5761|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_hiwifi_hc5861|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_lenovo_newifi-y1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_xiaomi_miwifi-mini)
			mods="$mods $usb2"
			mods="$mods $cdcmod"
			has_usb=1
		;;
		#no usb
		TARGET_DEVICE_ath79_generic_DEVICE_letv_lba-047-ch|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_puppies|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_nxc200p|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_ms1201k|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_miwifi-3c|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-cr660x|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-c6-v3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_archer-a6-v3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_e5600|\
		TARGET_DEVICE_ath79_generic_DEVICE_xiaomi_aiot-ac2350|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_jcg_q20|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_mi-router-4c|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr6400-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr6400-v5|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_totolink_x5000r|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr810n-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-norplusemmc|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-nor|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_wr1800k-ax-nand|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_tcb1800k-ax-nor|\
		TARGET_DEVICE_ath79_generic_DEVICE_xwrt_xd1202g|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_glinet_gl-s1300|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_redmi-router-ac2100|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-ac2100|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xwrt_x-sdwan-1200|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_magic-2-wifi|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-3g-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_xiaomi_mi-router-4a-gigabit|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-wr650ac-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-wr650ac-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-e313ac|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_asus_rt-ac57u|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_huawei_hg255d|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_cudy_wr1000|\
		TARGET_DEVICE_ath79_generic_DEVICE_dlink_dir-842-c3|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_re650-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_tplink_re500-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_adtran_bsap1840|\
		TARGET_DEVICE_ath79_generic_DEVICE_adtran_bsap1800-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_iodata_wn-gx300gr|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_iodata_wn-ax1167gr|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_totolink_a7000r|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_mi-router-4a-100m|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_ecb1750|\
		TARGET_DEVICE_ath79_generic_DEVICE_engenius_ews511ap|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-d50-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_aruba_ap-105|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr1043n-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_glinet_vixmini|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_ex6400|\
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_ex7300|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wr902ac-v1|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubiquiti_edgerouterx|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubiquiti_edgerouterx-sfp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubnt_edgerouter-x|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_ubnt_edgerouter-x-sfp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_netgear_ex6150|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dir-510l|\
		TARGET_DEVICE_ath79_generic_DEVICE_comfast_cf-e5|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanobeam-ac|\
		TARGET_DEVICE_ath79_generic_DEVICE_glinet_gl-usb150|\
		TARGET_DEVICE_ath79_generic_DEVICE_yuncore_a770|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_nanostation-m-xw|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6150v2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_netgear_ex6100v2|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_engenius_eap1300|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_map-ac2200|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c5-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr802n-v4|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-mr200|\
		TARGET_DEVICE_ath79_generic_DEVICE_xiaomi_mi-router-4q|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-mr3020-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c50-v4|\
		TARGET_DEVICE_ramips_rt305x_DEVICE_hg255d|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1200i|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1750i|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-922-e2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-921-c1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dwr-921-c3|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1200e|\
		TARGET_DEVICE_ath79_generic_DEVICE_devolo_dvl1750c|\
		TARGET_DEVICE_ath79_generic_DEVICE_nec_wg800hp|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_re350-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_lap-120|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_bullet-m-xw|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c58-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_wavlink_wl-wn570ha1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_planex_mzk-750dhp|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c20i|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_tplink_archer-c50-v1|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_asus_rt-n12p|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wa801nd-v5|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c50-v3|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c20-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_archer-c20-v5|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-lite|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-mesh|\
		TARGET_DEVICE_ath79_generic_DEVICE_ubnt_unifiac-mesh-pro|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-re450-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-wr8305rt|\
		TARGET_DEVICE_ath79_generic_DEVICE_phicomm_k2t|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_dlink_dir-810l|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_buffalo_wcr-1166ds|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_buffalo_whr-1166d|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_cpe510-v2|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_cpe510-v3|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_archer-c60-v2|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_zbtlink_zbt-we2026|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr841n-v13|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr840n-v4|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_mercury_mac1200r-v2|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_phicomm_k2p|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_xiaomi_miwifi-nano|\
		TARGET_DEVICE_ramips_mt7621_DEVICE_linksys_re6500|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2g|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1208|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1218a|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2-v22.4|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_k2-v22.5|\
		TARGET_DEVICE_ramips_mt7620_DEVICE_phicomm_psg1218b)
			mods="$mods"
		;;
		*)
			echo no handle usb $t
		;;
	esac

	#check 4g manual select
	case $t in
		TARGET_DEVICE_ath79_generic_DEVICE_netgear_wnr2200-8m|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3500-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr4300-v1|\
		TARGET_DEVICE_ath79_generic_DEVICE_tplink_tl-wdr3600-v1|\
		TARGET_DEVICE_ramips_mt76x8_DEVICE_tplink_tl-wr902ac-v3)
			mods="$mods $usb4g"
		;;
	esac

	#check proxym manual select
	case $t in
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-ac42u|\
		TARGET_DEVICE_ipq40xx_generic_DEVICE_asus_rt-acrh17)
			mods="$mods $proxym"
		;;
	esac

	if [ "x$flash_gt8m" = "x1" ] && [ "x$has_usb" = "x1" ]; then
		mods="$mods $usb4g $iphone4g $nfs"
		mods="$mods $moreapps $usbprint $ksmbd"
		if [ "x$extra_utils" = "x1" ]; then
			mods="$mods $utils $aria2"
		fi
	else
		mods="$mods $lucistd"
	fi
	tname=`echo $t | sed 's/TARGET_DEVICE_/CONFIG_TARGET_DEVICE_PACKAGES_/'`
	mods="$mods `get_target_mods $t`"
	mods=`get_modules $mods`
	mods=`get_modules_only $mods`
	mods=`exclude_modules $mods`
	dep_mods=$(for x in $mods; do
			get_deps $x
			done)
	dep_mods=`get_modules $dep_mods`
	mods=`get_modules $mods $dep_mods`
	mods=`get_modules_only $mods`
	mods=`exclude_modules $mods`
	#echo $tname=$mods
	sed -i "s/$tname=\".*\"/$tname=\"$mods\"/" ./.config
done

rm -rf /tmp/config_lede

#======================
