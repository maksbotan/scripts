#!/bin/bash

cur_touchpad=$(synclient | grep TouchpadOff | cut -d"=" -f 2)

if [ $cur_touchpad == "1" ]; then
    new_touchpad="0"
else
    new_touchpad="1"
fi

synclient TouchpadOff=$new_touchpad
