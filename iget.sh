#!/bin/bash

# Gets an Instagram post URL as $1 param.
# Outputs the post's image URL to stdout.
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

url=$1

id_length=11
id_regex="[A-Za-z0-9+-_@]{$id_length}"
url_regex="https://www.instagram.com/p/$id_regex/?$"

if ! [[ $url =~ $url_regex ]]; then
  echo Bad URL. Use iget.sh https://www.instagram.com/p/\<post_id\>/
  exit 1
fi

# Append the slash at the end if needed.
if [[ "${url: -1}" != "/" ]]; then
  url="$url/"
fi

url_embed="${url}embed/"

curl $url_embed --compressed -s \
  -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" \
  -H "accept-encoding: gzip, deflate, br" \
  -H "cache-control: no-cache" \
  -H "pragma: no-cache" \
  -H "dnt: 1" \
  -H "sec-ch-ua: \"Chromium\";v=\"94\", \"Google Chrome\";v=\"94\", \";Not A Brand\";v=\"99\"" \
  -H "sec-ch-ua-mobile: ?0" \
  -H "sec-ch-ua-platform: \"Windows\"" \
  -H "sec-fetch-dest: document" \
  -H "sec-fetch-mode: navigate" \
  -H "sec-fetch-site: none" \
  -H "sec-fetch-user: ?1" \
  -H "upgrade-insecure-requests: 1" \
  -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36" \
| grep EmbeddedMediaImage \
| sed 's/\&amp;/\&/g' \
| sed -r 's/.*src="(.*)" srcset.*/\1/'
