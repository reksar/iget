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

# Headers for user agent faking.

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

# Instagram response will be gzipped, so we need the `--compressed`.
get_embed="curl $url_embed $headers --silent --compressed"

# Expect that response will contain the `img.<img_class>`, that looks like:
#   <img class="<img_class>" alt="..." src="<url-1080>"
#     srcset="<url-640> 640w,<url-740> 740w,<url-1080> 1080w" />
img_class=EmbeddedMediaImage
find_img_str="grep $img_class"

# &amp; -> &
convert_amp="sed 's/\&amp;/\&/g'"

# Cut the `1080w` image URL from the `img.srcset`.
cut_url="sed -r 's/.*srcset=\".*(https:[^:]*) 1080w.*/\\1/'"

eval "$get_embed | $find_img_str | $convert_amp | $cut_url"
