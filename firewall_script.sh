#!/bin/sh

DEBUG=

LAN=eth0
WAN=eth1
WAN2=eth2

LAN_IP=192.168.4.0/24
LAN_COMMON=192.168.4.100-192.168.4.200
LAN_ADMIN=192.168.4.201-192.168.4.250

MARK_FIBRE=2
MARK_ADSL=3

FIBRE_PORTS_UDP=( 53 )
ADSL_PORTS_TCP=( 21 22 123 30022 3690 873 8418 1723 3653 9418)
ADSL_OUT_PORTS_TCP=( 80 8080 )

IN_ALLOWED_TCP_PORTS=( 22 32032 3128 2501 8000 3142 )
IN_ALLOWED_UDP_PORTS=( 53 67 ) 
FWD_ALLOWED_TCP_PORTS=( 20 21 22 23 25 80 110 443 9418 11371 )

iptables -F
iptables -t nat -F
iptables -t mangle -F

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

ipt_setup_incoming_marks() {
    iptables -t mangle -A PREROUTING -m iprange \
        --src-range $LAN_COMMON -j CONNMARK --set-mark $MARK_ADSL
    iptables -t mangle -A PREROUTING -m iprange \
        --src-range $LAN_ADMIN -j CONNMARK --set-mark $MARK_FIBRE
    for port in ${FIBRE_PORTS_UDP[@]}; do
        iptables -t mangle -A PREROUTING -p udp --dport $port -j CONNMARK --set-mark $MARK_FIBRE
    done
    for port in ${ADSL_PORTS_TCP[@]}; do
        iptables -t mangle -A PREROUTING -p tcp --dport $port -j CONNMARK --set-mark $MARK_ADSL
    done
    iptables -t mangle -A PREROUTING -i $LAN -j CONNMARK --restore-mark
    if [ "$DEBUG" ]; then
        iptables -t mangle -A PREROUTING -j LOG --log-prefix "marks setting "
    fi
}

ipt_setup_outcoming_marks(){
    for port in ${ADSL_OUT_PORTS_TCP[@]} ${ADSL_PORTS_TCP[@]}; do
        iptables -t mangle -A OUTPUT -p tcp --dport $port -j MARK --set-mark $MARK_ADSL
	#iptables -t nat -A POSTROUTING -p tcp --dport $port -j LOG --log-prefix "Out packet to $port "
    done
    #GRE
    iptables -t mangle -A OUTPUT -p 47 -j CONNMARK --set-mark 3
 
    iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
    if [ "$DEBUG" ]; then
        iptables -t mangle -A OUTPUT -j LOG --log-prefix "Outgoing marks setting "
    fi
}

#allow localhost
iptables -A INPUT -s 127.0.0.1/8 -j ACCEPT
#allow answers to localhost's requests
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -d 192.168.4.1 -j ACCEPT
#allow services from lan
for port in ${IN_ALLOWED_TCP_PORTS[@]}; do
    iptables -A INPUT -s $LAN_IP -i $LAN -p tcp --dport $port -j ACCEPT
done
for port in ${IN_ALLOWED_UDP_PORTS[@]}; do
    iptables -A INPUT -s $LAN_IP -i $LAN -p udp --dport $port -j ACCEPT
done
#redirect to squid
iptables -t nat -A PREROUTING -p tcp -m multiport --dport 80 ! -d 192.168.4.1 \
	-m iprange --src-range $LAN_COMMON \
	-j REDIRECT --to-ports 3128

#allow forwarding
for port in ${FWD_ALLOWED_TCP_PORTS[@]}; do
    iptables -A FORWARD -i $LAN ! -d $LAN_IP -p tcp --dport $port -j ACCEPT
done
iptables -A FORWARD -i $LAN ! -d $LAN_IP -p icmp -j ACCEPT
iptables -A FORWARD -i $WAN -d $LAN_IP -m state \
	--state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $WAN2 -d $LAN_IP -m state \
	--state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d $LAN_IP -p tcp --dport 20 -j ACCEPT #active ftp

ipt_setup_incoming_marks
ipt_setup_outcoming_marks

#nat
iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
iptables -t nat -A POSTROUTING -o $WAN2 -j MASQUERADE