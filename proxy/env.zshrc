# sets necessary proxy variables for being on a VPN
proxy::set () {
  export RSYNC_PROXY=$PROXY
  export http_proxy=http://$PROXY
  export HTTP_PROXY=$http_proxy
  export https_proxy=http://$SECURE_PROXY
  export HTTPS_PROXY=$https_proxy
  export ftp_proxy=$http_proxy
  export FTP_PROXY=$http_proxy
  export no_proxy=$NOPROXY
  export NO_PROXY=$no_proxy
}

# unsets proxy variables, for use after disconnecting from VPN
proxy::unset () {
  unset RSYNC_PROXY
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
  unset ftp_proxy
  unset FTP_PROXY
  unset no_proxy
  unset NO_PROXY
}

proxy::toggle() {
  if [ -z "${HTTP_PROXY}" ]; then
    proxy::set
  else
    proxy::unset
  fi
}
