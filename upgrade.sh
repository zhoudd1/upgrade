#!/bin/sh

url="https://curl.haxx.se/download/archeology/"

while true
do
    #1)download file
    md5_url=${url}"md5.txt"
    #curl md5_url -o md5.txt --progress
    wget -O md5.txt "$md5_url"
    version=$(sed -n 1p md5.txt)
    filename=$(sed -n 2p md5.txt)
    md5=$(sed -n 3p md5.txt)
    version_bak=$(sed -n 1p md5_bak.txt)
	
	echo $version    
    echo $filename
    echo $md5    
    echo $version_bak
    
    #2)md5sum firmware 
    if [[ "$version" != "$version_bak" ]];then               
        cp md5.txt md5_bak.txt       
        download_url=${url}${filename}    
        download_url=${download_url%$'\r'}
        #curl "$download_url" -o $filename --progress
        wget -O $filename "$download_url"       
        md5_calc=$(md5sum $filename|cut -d ' ' -f1)

        #3)replace app file---> reboot
        if [ "$md5"=="$md5_calc" ] ; then  
            ./kill_app.sh
            #replace upgrade file
            ./run_app.sh
            rm $filename
            time=$(date "+%Y-%m-%d %H:%M:%S")
            echo "${time} upgrade $md5_calc $filename " >> log.txt
        else 
            echo "upgrade file md5sum err !"
        fi
    else 
        echo "local version is the latest version !"
    fi

    sleep 10

done

