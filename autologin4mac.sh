#!/bin/sh

# @author: xinsheng.chenxs@gmail.com
# @author: xinsheng.chen@moxtra.com

function min()
{
  x=$1
  y=$2
  echo $[ $x <= $y ? $x : $y ]
}

function kcpassword()
{
  passwd=$1
  key=(125 137 82 35 210 188 221 234 163 185 31)
  passwd_len=${#passwd}
  key_len=${#key[*]}

  for (( i = 0; i < ${#passwd}; ++i ))
  do
    passwd_int+=(`printf "%d" "'${passwd:$i:1}"`)
  done

  r=$[ passwd_len % key_len ]
  if (( $r > 0 ))
  then
    for (( i = 0; i < $[ key_len - r ]; ++i ))
    do
      passwd_int+=(0)
    done
  fi

  passwd_int_len=${#passwd_int[*]}
  for n in $(seq 0 $key_len $[ passwd_int_len - 1 ])
  do
    ki=0
    min_value=$(min $[n + key_len] $passwd_int_len)
    for j in $(seq $n 1 $[ min_value - 1 ])
    do
      passwd_int[$j]=$[ passwd_int[$j] ^ key[$ki] ]
      ki=$[ ki +=1 ]
    done
  done

  passwd=""
  for (( i = 0; i < ${#passwd_int[*]}; ++i ))
  do
    passwd+=$(printf \\x`printf %x ${passwd_int[$i]}`)
  done

  echo $passwd
}

function usage()
{
  echo "Usage: $0 <user_name> <password>"
}

if [ $# -lt 2 ]
then
  usage
else
  sudo defaults write /Library/Preferences/com.apple.loginwindow "autoLoginUser" $1
  echo $(kcpassword $2) | sudo tee /etc/kcpassword
  sudo chmod 600 /etc/kcpassword
fi
