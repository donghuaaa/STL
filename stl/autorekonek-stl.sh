#!/bin/bash
#stl (Wegare) - Modified for Socks Only
while true; do
	host="$(cat /root/akun/stl.txt | awk 'NR==2')"
	# Route dan Proxy hanya dibaca variabelnya, eksekusinya nanti difilter
	route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)"
	proxy2="$(cat /root/akun/stl.txt | awk 'NR==8')"
	
	# Ambil Mode
	pillstl="$(cat /root/akun/pillstl.txt)"

	# --- CEK TUNNEL (PYTHON) ---
	cek_tunnel="$(netstat -plantu | grep -i python3 | grep -i 9092 | grep -i listen)"
	if [[ -z $cek_tunnel ]]; then
		#killall -q python3
		nohup python3 /root/akun/tunnel.py >/dev/null 2>&1 &
		sleep 1
	fi

	# --- CEK SSH (PORT 1080) ---
	cek_ssh="$(netstat -plantu | grep -i ssh | grep -i 1080 | grep -i listen)"
	if [[ -z $cek_ssh ]]; then
		# Jika SSH mati, kita harus restart.
		# Jika Mode 1, kita harus bersihkan route dulu agar tidak dobel/error.
		if [[ $pillstl = "1" ]]; then
			route del 1.1.1.1 gw "$route" metric 0 2>/dev/null
			route del 1.0.0.1 gw "$route" metric 0 2>/dev/null
			route del "$host" gw "$route" metric 0 2>/dev/null
			route del "$proxy2" gw "$route" metric 0 2>/dev/null
			route del default gw 10.0.0.2 metric 0 2>/dev/null
		fi
		
		# Restart SSH (Berlaku untuk SEMUA mode)
		nohup python3 /root/akun/ssh.py 1 >/dev/null 2>&1 &
		
		# Jika Mode 1, kembalikan route
		if [[ $pillstl = "1" ]]; then
			route add 1.1.1.1 gw $route metric 0
			route add 1.0.0.1 gw $route metric 0
			route add $host gw $route metric 0
			route add $proxy2 gw $route metric 0 2>/dev/null
		fi
		sleep 3
	else
		# Jika SSH hidup, cek Logs apakah "CONNECTED SUCCESSFULLY"
		var="$(cat /root/logs.txt 2>/dev/null)"
		if [[ -z $var ]]; then
			echo >/dev/null
		else
			var_cek=$(cat /root/logs.txt 2>/dev/null | grep "CONNECTED SUCCESSFULLY" | awk '{print $4}' | tail -n1)
			if [ "$var_cek" = "SUCCESSFULLY" ]; then
				rm -r /root/logs.txt 2>/dev/null
			else
				# Koneksi gagal di logs, restart prosedurnya
				if [[ $pillstl = "1" ]]; then
					route del 1.1.1.1 gw "$route" metric 0 2>/dev/null
					route del 1.0.0.1 gw "$route" metric 0 2>/dev/null
					route del "$host" gw "$route" metric 0 2>/dev/null
					route del "$proxy2" gw "$route" metric 0 2>/dev/null
					route del default gw 10.0.0.2 metric 0 2>/dev/null
				fi
				
				nohup python3 /root/akun/ssh.py 1 >/dev/null 2>&1 &
				
				if [[ $pillstl = "1" ]]; then
					route add 1.1.1.1 gw $route metric 0
					route add 1.0.0.1 gw $route metric 0
					route add $host gw $route metric 0
					route add $proxy2 gw $route metric 0 2>/dev/null
				fi
				sleep 3
			fi
		fi
	fi

	# --- CEK HELPER APPS (Sesuai Mode) ---
	if [[ $pillstl = "1" ]]; then
		cek_badvpn="$(netstat -plantu | grep -i badvpn)"
		if [[ -z $cek_badvpn ]]; then
			#killall -q badvpn-tun2socks
			gproxy
			sleep 3
		fi
		# Cek Route Default khusus Mode 1
		cek_route1="$(route | grep -i 10.0.0.2 | head -n1 | awk '{print $2}')"
		if [[ -z $cek_route1 && $cek_ssh ]]; then
			route add default gw 10.0.0.2 metric 0 2>/dev/null
			sleep 1
		fi

	elif [[ $pillstl = "2" ]]; then
		cek_redsocks="$(netstat -plantu | grep -i redsocks)"
		if [[ -z $cek_redsocks ]]; then
			iptables -t nat -F OUTPUT 2>/dev/null
			iptables -t nat -F PROXY 2>/dev/null
			iptables -t nat -F PREROUTING 2>/dev/null
			#killall -q redsocks
			gproxy
			sleep 3
		fi
		
	# Mode 3 (Socks Only): Tidak perlu cek badvpn/redsocks, cukup ssh/python di atas.
	fi

done