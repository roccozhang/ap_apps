include $(TOPDIR)/rules.mk

PKG_NAME:=struct
PKG_VERSION:=0.1
PKG_RELEASE:=0

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=
PKG_MAINTAINER:=Ivan <itgb1989@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
SRC_DIR:= struct-0.2

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=Applications
	CATEGORY:=apps
	TITLE:=struct library
	DEPENDS:=+liblua
endef

define Package/$(PKG_NAME)/description
	struct library
endef

define Build/Compile
	#$(MAKE) -C $(SRC_DIR)  $(TARGET_CONFIGURE_OPTS)
	$(MAKE)  -C $(SRC_DIR) \
		CC="$(TARGET_CROSS)gcc" \
		AR="$(TARGET_CROSS)ar rcu" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		INSTALL_ROOT=/usr \
		CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
		MYLDFLAGS="$(TARGET_LDFLAGS)" \
		PKG_VERSION=$(PKG_VERSION)
		
	$(CP) $(SRC_DIR)/struct.so $(PKG_BUILD_DIR)
endef

define Package/$(PKG_NAME)/install  
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/struct.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
