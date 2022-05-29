#!/bin/bash

# Using:
#
#   iget.sh https://www.instagram.com/p/<post_id>/ <image_width>
#
# <image_width> is optional and can be: 640, 750 or 1080 (default) px.
#
# For example, the
#
#   ./iget.sh https://www.instagram.com/p/CX8wkS_qNMq/
#
# gives
#
#   https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/e35/s1080x1080/
#   269961451_836551910434198_8806515854959711608_n.jpg?
#   _nc_ht=instagram.fdnk3-1.fna.fbcdn.net&_nc_cat=110&
#   _nc_ohc=hOLSmGd1DpAAX9SFiBs&edm=AJBgZrYBAAAA&ccb=7-4&
#   oh=00_AT_ikXhHf_8YvyySyoDQZZ2onjenV91lR79aNYFBYy4VdA&oe=6206092F&
#   _nc_sid=78c662
#
# and the
#
#   ./iget.sh https://www.instagram.com/p/CX8wkS_qNMq/ 640
#
# gives
#
#   https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/
#   269961451_836551910434198_8806515854959711608_n.jpg?
#   stp=dst-jpg_e35_s640x640_sh0.08&_nc_ht=instagram.fdnk3-1.fna.fbcdn.net&
#   _nc_cat=110&_nc_ohc=2ZSO0JAg44YAX-ZPoI3&edm=AJBgZrYBAAAA&ccb=7-4&
#   oh=00_AT9ZCu6t-GoPDRFMmMZOIUgpqYk8-lYKm8vPpkb0FZUCGg&oe=621D0264&
#   _nc_sid=78c662

exit_if_invalid_post_url()
{
  id_regexp="[A-Za-z0-9+-_@]+"
  url_regexp="https://www.instagram.com/p/$id_regexp/?$"

  if ! [[ $1 =~ $url_regexp ]]
  then
    echo Bad URL. Required https://www.instagram.com/p/\<post_id\>/
    exit 1
  fi
}

validate_image_width()
{
  DEFAULT_WIDTH=1080
  AVAILABLE_WIDTH=($DEFAULT_WIDTH 750 640)

  local given_width=${1:-$DEFAULT_WIDTH}
  local valid_width=$DEFAULT_WIDTH

  for available_width in ${AVAILABLE_WIDTH[*]}
  do
    if [ $available_width == $given_width ]
    then
      valid_width=$given_width
      break
    fi
  done

  echo $valid_width
}

embedded_post_url()
{
  local url=$1

  # Add a slash if needed.
  if [[ "${url: -1}" != "/" ]]
  then
    url="$url/"
  fi

  # Spoofing a request with embedded Instagram post query.
  embed_query='cr=1\&v=14\&wp=540\&rd=%2Fstatic%2Fimage.html'

  # Convert post URL -> URL for post embedding.
  echo "${url}embed/?${embed_query}"
}

# &amp; -> &
convert_amp()
{
  sed 's/\&amp;/\&/g' <<< "$1"
}

http_get()
{
  # HTTP headers for user agent spoofing.

  headers='-H "accept: text/html,application/xhtml+xml,application/xml;'
  headers+='q=0.9,image/avif,image/webp,image/apng,*/*;'
  headers+='q=0.8,application/signed-exchange;v=b3;q=0.9"'

  headers+=' -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
  headers+=' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71'
  headers+=' Safari/537.36"'

  headers+=' -H "sec-ch-ua: \"Chromium\";v=\"94\", \"Google Chrome\";'
  headers+='v=\"94\", \";Not A Brand\";v=\"99\""'

  headers+=' -H "accept-encoding: gzip, deflate, br"'
  headers+=' -H "cache-control: no-cache"'
  headers+=' -H "dnt: 1"'
  headers+=' -H "pragma: no-cache"'
  headers+=' -H "sec-ch-ua-mobile: ?0"'
  headers+=' -H "sec-ch-ua-platform: \"Windows\""'
  headers+=' -H "sec-fetch-dest: document"'
  headers+=' -H "sec-fetch-mode: navigate"'
  headers+=' -H "sec-fetch-site: none"'
  headers+=' -H "sec-fetch-user: ?1"'
  headers+=' -H "upgrade-insecure-requests: 1"'

  # Response will be gzipped, so we need `--compressed`.
  curl $1 $headers --silent --compressed
}

filter_image_url()
{
  local html=$1
  local width=$(validate_image_width $2)

  # An embedded Instagram post is expected to contain an <img> like:
  #   <img class="<img_class>" alt="..." src="<url-1080>"
  #     srcset="<url-640> 640w,<url-750> 750w,<url-1080> 1080w" />
  local img_class=EmbeddedMediaImage
  local img_str=$(grep $img_class <<< "$html")
  img_str=$(convert_amp "$img_str")
  sed -r "s/.*srcset=\".*(https:[^:]*) ${width}w.*/\\1/" <<< "$img_str"
}

post_url=$1
image_width=$2

exit_if_invalid_post_url $post_url

embedded_url=$(embedded_post_url $post_url)
embedded_post_html=$(http_get $embedded_url)
filter_image_url "$embedded_post_html" $image_width
