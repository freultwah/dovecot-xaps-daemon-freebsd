PORTNAME=	dovecot-xaps-daemon
DISTVERSION=	g20220412
PORTREVISION=	0

CATEGORIES=	mail

MAINTAINER=	raivo@lehma.com
COMMENT=	Apple push notification plugin for Dovecot

LICENCE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:modules

USE_GITHUB=	yes
GH_ACCOUNT=	freswa
GH_TAGNAME=	8cec7c8

GH_TUPLE=	\
		dgrijalva:jwt-go:v3.2.0:dgrijalva_jwt_go/vendor/github.com/dgrijalva/jwt-go \
		freswa:go-plist:900e8a7d907d:freswa_go_plist/vendor/github.com/freswa/go-plist \
		fsnotify:fsnotify:v1.5.1:fsnotify_fsnotify/vendor/github.com/fsnotify/fsnotify \
		go-ini:ini:v1.66.4:go_ini_ini/vendor/gopkg.in/ini.v1 \
		go-yaml:yaml:v2.4.0:go_yaml_yaml/vendor/gopkg.in/yaml.v2 \
		golang:net:27dd8689420f:golang_net/vendor/golang.org/x/net \
		golang:sys:2edf467146b5:golang_sys/vendor/golang.org/x/sys \
		golang:text:v0.3.7:golang_text/vendor/golang.org/x/text \
		hashicorp:hcl:v1.0.0:hashicorp_hcl/vendor/github.com/hashicorp/hcl \
		julienschmidt:httprouter:v1.3.0:julienschmidt_httprouter/vendor/github.com/julienschmidt/httprouter \
		magiconair:properties:v1.8.6:magiconair_properties/vendor/github.com/magiconair/properties \
		mitchellh:mapstructure:v1.4.3:mitchellh_mapstructure/vendor/github.com/mitchellh/mapstructure \
		pelletier:go-toml:v1.9.4:pelletier_go_toml/vendor/github.com/pelletier/go-toml \
		sideshow:apns2:v0.20.0:sideshow_apns2/vendor/github.com/sideshow/apns2 \
		sirupsen:logrus:v1.8.1:sirupsen_logrus/vendor/github.com/sirupsen/logrus \
		spf13:afero:v1.8.2:spf13_afero/vendor/github.com/spf13/afero \
		spf13:cast:v1.4.1:spf13_cast/vendor/github.com/spf13/cast \
		spf13:jwalterweatherman:v1.1.0:spf13_jwalterweatherman/vendor/github.com/spf13/jwalterweatherman \
		spf13:pflag:v1.0.5:spf13_pflag/vendor/github.com/spf13/pflag \
		spf13:viper:v1.10.1:spf13_viper/vendor/github.com/spf13/viper \
		subosito:gotenv:v1.2.0:subosito_gotenv/vendor/github.com/subosito/gotenv

BUILD_DEPENDS+=	dovecot>=2.3.9:mail/dovecot
RUN_DEPENDS+=	dovecot>=2.3.9:mail/dovecot

LDFLAGS+=	-L${LOCALBASE}/lib
USE_LDCONFIG=	${PREFIX}/lib/dovecot
GO_TARGET=	./cmd/xapsd/

USE_RC_SUBR=	xapsd

post-patch:
	@${REINPLACE_CMD} -e 's|etc\/xapsd|usr\/local\/etc\/xapsd|' ${WRKSRC}/internal/config/config.go
	@${REINPLACE_CMD} -e 's|var\/lib|var\/db|' ${WRKSRC}/configs/xapsd/xapsd.yaml
	@${REINPLACE_CMD} -e 's|var\/run\/dovecot|var\/run\/xapsd|' ${WRKSRC}/configs/xapsd/xapsd.yaml

post-install:
	${MKDIR} ${STAGEDIR}/var/db/xapsd
	${MKDIR} ${STAGEDIR}/var/run/xapsd
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/xapsd
	${CP} ${WRKSRC}/configs/xapsd/xapsd.yaml ${STAGEDIR}${PREFIX}/etc/xapsd/xapsd.yaml.sample

.include <bsd.port.mk>
