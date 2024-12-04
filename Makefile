include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-athena-led
PKG_VERSION:=0.2.0
PKG_RELEASE:=20241129

PKG_MAINTAINER:=Athena LED <https://github.com/haipengno1/athena-led>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=athena-led-$(ARCH)-musl.tar.gz
PKG_SOURCE_URL:=https://github.com/haipengno1/athena-led/releases/download/v$(PKG_VERSION)
PKG_HASH:=69c08dcd293dafa3a012d39241f9f313963a55bca0c3349729c279a822711bb3

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Support for JDCloud AX6600 LED Screen Control
  DEPENDS:=+lua +luci-base @(aarch64||arm)
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  LuCI support for JDCloud AX6600 LED Screen Control.
  Features:
  - LED screen brightness control
  - Display mode selection (time, date, temperature, custom text)
  - Side LED status indicators
  - Remote text display via HTTP/GET
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
	$(CP) ./root $(PKG_BUILD_DIR)/
	$(CP) ./po $(PKG_BUILD_DIR)/
endef

define Build/Compile
	po2lmo ./po/zh_Hans/athena_led.po $(PKG_BUILD_DIR)/zh_Hans.lmo
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/athena_led $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/athena_led $(1)/etc/config/
	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(DL_DIR)/$(PKG_SOURCE) $(1)/usr/sbin/athena-led.tar.gz
	cd $(1)/usr/sbin && tar xf athena-led.tar.gz && rm athena-led.tar.gz
	chmod 755 $(1)/usr/sbin/athena-led
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/zh_Hans.lmo $(1)/usr/lib/lua/luci/i18n/athena_led.zh-cn.lmo
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
