#!/bin/bash
#testing git push - rakib
sanity_check() {
	if [ $1 -eq 0 ]; then
		echo -e "\t\t[ OK ]"
	else
		echo -e "\t\t[ FAILED ]"
	fi
}

flush_iptables() {
	echo -n "Flushing all the rules in filter and nat tables"
	iptables --flush
	iptables --table nat --flush
	sanity_check $?

	echo -n "Deleting all chains in filter and nat tables"
	iptables --delete-chain
	iptables --table nat --delete-chain
	sanity_check $?

	return 0
}

enable_ip_forward() {
	echo "Enabling Masquarading + IP-Forwarding ..."
	iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
	echo 1 > /proc/sys/net/ipv4/ip_forward
}

disable_ip_forward() {
	echo "Disabling Masquarading + IP-Forwarding ..."
	echo 0 > /proc/sys/net/ipv4/ip_forward
}


##
## Call as: $0 [ provider name ] [ eth0 or eth1 ... ] [ 'true' or 'false' ]
##
swap_net() {
	local provider_type
	local eth_type

	provider_type="$1"
	if [ $# -gt 1 ]; then eth_type="$2" ; else eth_type="eth0" ; fi

	echo -n "Swapping $eth_type to $provider_type ..."
	ifdown $eth_type

	/bin/cp "/etc/sysconfig/network-scripts/ifcfg-$eth_type" "/etc/sysconfig/network-scripts/ifcfg-$eth_type.bak"
	update_conf "${BASE_DIR}/ifcfg-$eth_type.$provider_type" "/etc/sysconfig/network-scripts/ifcfg-$eth_type"
	
	ifup $eth_type
	sanity_check $?
}

##
## Call as: $0 [ eth0 or eth1 or wlan0 ... ]
##
get_hw_addr() {
	local eth_type
	eth_type="$1"

	udevadm info -a -p "/sys/class/net/${eth_type}" | grep "address" | sed 's/^[^"]*"\([^"]\+\)"[[:space:]]*$/\U\1\E/g'
}

get_network_uuid() {
	local net_name

	net_name="$1"

	nmcli -m multiline -f NAME,UUID con list | awk "
		BEGIN {
			found = 0
		}
		/^NAME:.*${net_name}/ {
			found = 1
		}
		/^UUID:/ {
			if (found == 1) {
				print \$0
			}
			found = 0
		}" | sed "s/^UUID:[[:space:]]*\(.*\)/\1/g" | head -1
}

connect_to_network() {
	nmcli con up uuid "$1"
}


