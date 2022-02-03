#!/bin/bash

curl $1 --compressed -s -v \
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
