import re
import gzip
from urllib.request import Request, urlopen


def is_post_url(url):
    post_id = '[A-Za-z0-9+-_@]+'
    post_url = f"https://www.instagram.com/p/{post_id}/?$"
    return re.match(post_url, url)


def embedded_post_url(post_url):

    if post_url[-1] == '/':
        post_url = post_url[:-1]

    embed_query = 'cr=1\&v=14\&wp=540\&rd=%2Fstatic%2Fimage.html'

    return f"{post_url}/embed/?{embed_query}"


def html(url):
    with urlopen(Request(url, headers={
        'accept': 'text/html,application/xhtml+xml,application/xml;' +
            'q=0.9,image/avif,image/webp,image/apng,*/*;' +
            'q=0.8,application/signed-exchange;v=b3;q=0.9"',

        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' +
            ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71' +
            ' Safari/537.36"',

        'sec-ch-ua': '"Chromium";v="94", "Google Chrome";v="94", ' +
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
    })) as response:

        data = response.read()

        if response.info()['Content-Encoding'] == 'gzip':
            return gzip.decompress(data).decode()

        return data.decode()


def filter_img_url(html):
    img_width = 1080
    img_src = f".*srcset=\".*(https:[^:]*) {img_width}w"
    url = re.search(img_src, html).group(1)
    return url.replace('&amp;', '&')


def img_url(post_url):
    if is_post_url(post_url):
        return filter_img_url(html(embedded_post_url(post_url)))
