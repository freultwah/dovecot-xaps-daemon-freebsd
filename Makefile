PORTNAME=	dovecot-xaps-daemon
DISTVERSION=	g20251110
PORTREVISION=	1

CATEGORIES=	mail

MAINTAINER=	raivo@lehma.com
COMMENT=	Apple push notification plugin for Dovecot

LICENCE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:1.25,modules

USE_GITHUB=	yes
GH_ACCOUNT=	freswa
GH_TAGNAME=	0f2e291

GH_TUPLE=	freswa:go-plist:900e8a7d907d:freswa_go_plist/vendor/github.com/freswa/go-plist \
		fsnotify:fsnotify:v1.9.0:fsnotify_fsnotify/vendor/github.com/fsnotify/fsnotify \
		go-ini:ini:v1.67.0:go_ini_ini/vendor/gopkg.in/ini.v1 \
		go-yaml:yaml:v3.0.1:go_yaml_yaml/vendor/gopkg.in/yaml.v3 \
		golang-jwt:jwt:v4.5.2:golang_jwt_jwt_v4/vendor/github.com/golang-jwt/jwt/v4 \
		golang:exp:f66d83c29e7c:golang_exp/vendor/golang.org/x/exp \
		golang:crypto:v0.40.0:golang_crypto/vendor/golang.org/x/crypto \
		golang:net:v0.42.0:golang_net/vendor/golang.org/x/net \
		golang:sys:v0.34.0:golang_sys/vendor/golang.org/x/sys \
		golang:text:v0.27.0:golang_text/vendor/golang.org/x/text \
		hashicorp:hcl:v1.0.0:hashicorp_hcl/vendor/github.com/hashicorp/hcl \
		julienschmidt:httprouter:v1.3.0:julienschmidt_httprouter/vendor/github.com/julienschmidt/httprouter \
		magiconair:properties:v1.8.7:magiconair_properties/vendor/github.com/magiconair/properties \
		go-viper:mapstructure:v2.4.0:go_viper_mapstructure_v2/vendor/github.com/go-viper/mapstructure/v2 \
		pelletier:go-toml:v2.2.4:pelletier_go_toml_v2/vendor/github.com/pelletier/go-toml/v2 \
		sagikazarmark:locafero:v0.9.0:sagikazarmark_locafero/vendor/github.com/sagikazarmark/locafero \
		sagikazarmark:slog-shim:v0.1.0:sagikazarmark_slog_shim/vendor/github.com/sagikazarmark/slog-shim \
		sideshow:apns2:v0.25.0:sideshow_apns2/vendor/github.com/sideshow/apns2 \
		sirupsen:logrus:v1.9.3:sirupsen_logrus/vendor/github.com/sirupsen/logrus \
		sourcegraph:conc:v0.3.0:sourcegraph_conc/vendor/github.com/sourcegraph/conc \
		spf13:afero:v1.14.0:spf13_afero/vendor/github.com/spf13/afero \
		spf13:cast:v1.9.2:spf13_cast/vendor/github.com/spf13/cast \
		spf13:jwalterweatherman:v1.1.0:spf13_jwalterweatherman/vendor/github.com/spf13/jwalterweatherman \
		spf13:pflag:v1.0.7:spf13_pflag/vendor/github.com/spf13/pflag \
		spf13:viper:v1.20.1:spf13_viper/vendor/github.com/spf13/viper \
		subosito:gotenv:v1.6.0:subosito_gotenv/vendor/github.com/subosito/gotenv \
		uber-go:atomic:v1.11.0:uber_go_atomic/vendor/go.uber.org/atomic \
		uber-go:multierr:v1.11.0:uber_go_multierr/vendor/go.uber.org/multierr

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
