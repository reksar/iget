"""
Using:

  img_url('https://www.instagram.com/p/<post_id>/')

  img_url('https://www.instagram.com/p/<post_id>/', <image_width>)

For example, the

  img_url('https://www.instagram.com/p/CX8wkS_qNMq/')

gives

  https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/e35/s1080x1080/
  269961451_836551910434198_8806515854959711608_n.jpg?
  _nc_ht=instagram.fdnk3-1.fna.fbcdn.net&_nc_cat=110&
  _nc_ohc=hOLSmGd1DpAAX9SFiBs&edm=AJBgZrYBAAAA&ccb=7-4&
  oh=00_AT_ikXhHf_8YvyySyoDQZZ2onjenV91lR79aNYFBYy4VdA&oe=6206092F&
  _nc_sid=78c662

and the

  img_url('https://www.instagram.com/p/CX8wkS_qNMq/', 640)

gives

  https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/
  269961451_836551910434198_8806515854959711608_n.jpg?
  stp=dst-jpg_e35_s640x640_sh0.08&_nc_ht=instagram.fdnk3-1.fna.fbcdn.net&
  _nc_cat=110&_nc_ohc=2ZSO0JAg44YAX-ZPoI3&edm=AJBgZrYBAAAA&ccb=7-4&
  oh=00_AT9ZCu6t-GoPDRFMmMZOIUgpqYk8-lYKm8vPpkb0FZUCGg&oe=621D0264&
  _nc_sid=78c662
"""

import re
import gzip
import html
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen


# Available URL format.
POST_ID = '[\w\-@+]+'
POST_URL = re.compile(f"https://www.instagram.com/p/{POST_ID}/?$")

DEFAULT_WIDTH = 1080
AVAILABLE_WIDTH = DEFAULT_WIDTH, 750, 640

# HTTP headers for user agent spoofing.
HTTP_HEADERS = {
    'accept': 'text/html,application/xhtml+xml,application/xml;'
        'q=0.9,image/avif,image/webp,image/apng,*/*;'
        'q=0.8,application/signed-exchange;v=b3;q=0.9',

    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
        ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71'
        ' Safari/537.36',

    'sec-ch-ua': '"Chromium";v="94", "Google Chrome";v="94", '
        '";Not A Brand";v="99"',

    'accept-encoding': 'gzip, deflate, br',
    'cache-control': 'no-cache',
    'dnt': '1',
    'pragma': 'no-cache',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
}

# Spoofing a request with embedded Instagram post query.
EMBED_QUERY = urlencode(
    {
        'cr': 1,
        'v': 14,
        'wp': 540,
        'rd': '/static/image.html',
    },
).encode('ascii')


def img_url(post_url, img_width=DEFAULT_WIDTH):
    if POST_URL.fullmatch(post_url) and img_width in AVAILABLE_WIDTH:
        return find_img_url(embed_post(post_url), img_width)


def find_img_url(instagram_post, img_width):
    """
    In embedded Instagram post find the URL for `img_width` in <img srcset>:

      <img class="<img_class>" alt="..." src="<url-1080>"
        srcset="<url-640> 640w,<url-750> 750w,<url-1080> 1080w" />
    """
    img_src = f".*srcset=\".*(https:[^:]*) {img_width}w"
    found = re.search(img_src, instagram_post)
    if found:
        url = found.group(1)
        # Note: src URL is escaped.
        return html.unescape(url)


def embed_post(post_url):
    embed_url = urljoin(f"{post_url}/", 'embed')
    return get_content(Request(embed_url, EMBED_QUERY, HTTP_HEADERS))


def get_content(request):
    with urlopen(request) as response:
        gzipped = response.read()
        data = gzip.decompress(gzipped)
        return data.decode()
