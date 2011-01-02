#!/bin/sh


start(){
    gpg -d ~/.vk/pass.bin 2>/dev/null > ~/pass
    ~/scripts/vk_spy.py > /home/maksbotan/vk_spy.log 2>&1 &
}

stop(){
    killall vk_spy.py && sleep 5
}

rotate(){
    mv ~/log.json{,-$(date +%F)}
    mv ~/vk_spy.debug{,-$(date +%F)}   
}

case $1 in
    --restart)
        stop
        start
    ;;
    --rotate)
        stop
        rotate
        start
    ;;
    --keep)
        if [ -z "$(ps -Af | grep vk_spy | grep -v grep)" ]; then
            mv ~/vk_spy.debug{,-$(date +%T)}
            start
        fi
    ;;
    *)
        echo "Usage: $0 --restart|rotate|keep"
    ;;
esac
