# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM debian:stable-slim
# FROM alpine:latest

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

RUN apt-get update && \
  apt-get install -y openvpn iptables bash easy-rsa openvpn-auth-ldap libpam-google-authenticator pamtester procps && \
  ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Testing: pamtester
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
#     apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam openvpn-auth-ldap google-authenticator pamtester && \
#     ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
#     rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

#Temporary remove line until EasyRsa fix will be pushed. https://github.com/OpenVPN/easy-rsa/issues/261
RUN sed -i '/RANDFILE		= $ENV::EASYRSA_PKI\/\.rnd/d' $EASYRSA/openssl-easyrsa.cnf

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
