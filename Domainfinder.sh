#!/bin/bash
url=$1

if [ ! -d "$url" ];then
	mkdir $url
fi

if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi


echo "[+] Harvesting Subdomains with assetfinder..."
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/final.txt
rm $url/recon/assets.txt

echo "[+] Probing the live domains..."

if [ ! -f "$url/recon/httprobe.txt" ];then
	touch $url/recon/httprobe.txt
fi

cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https:\?\/\///' | tr -d ':443' >> $url/recon/httprobe.txt

if [ ! -f "$url/recon/alive.txt" ]; then
	touch $url/recon/alive.txt
fi
sort -u $url/recon/httprobe.txt > $url/recon/alive.txt
rm $url/recon/httprobe.txt

echo "[+] Checking for possible subdomain takeover..."

if [ ! -f "$url/recon/takeovers.txt" ];then
    touch $url/recon//takeovers.txt
fi
subjack -w $url/recon/alive.txt -t 100 -timeout 30 -ssl -c ~/manual/subjackfingerprints.json -v 3 -o $url/recon/takeovers.txt


echo "[+] Scanning for open ports..."

nmap -iL $url/recon/alive.txt -T4 -oA  $url/recon/scanned.txt
rm $url/recon/scanned.txt.gnmap
rm $url/recon/scanned.txt.xml
cp $url/recon/scanned.txt.nmap $url/recon/scanned.txt
rm $url/recon/scanned.txt.nmap

echo "[+] Scraping wayback data..."

if [ ! -f "$url/recon/wayback.txt" ];then
	touch $url/recon/wayback.txt
fi
cat $url/recon/final.txt | waybackurls >> $url/recon/waybk.txt
sort -u $url/recon/waybk.txt > $rul/recon/wayback.txt
rm $url/recon/waybk.txt

echo "[+] Running Eyewitness Agains Alive domains..."

eyewitness --web -f $url/recon/alive.txt -d $url/recon/eyewitness --resolve

 
gedit $url/recon/subdomains.txt
gedit $url/recon/alivedomains.txt
gedit $rul/recon/takeovers.txt
gedit $url/recon/scanned.txt
gedit $url/recon/wayback.txt


echo "[+] Finished..."
echo "[+] Look at $url/recon  directory for output"
echo "[+] Thank you :)"



