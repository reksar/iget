<?php namespace iget;
/*
 * @see `img_url()` below.
 */

// For Instagram post URL https://www.instagram.com/p/<post_id>/
const POST_ID_LENGTH = 11;
const POST_ID_REGEXP = '[[:alnum:]+-_@]{'.POST_ID_LENGTH.'}';
const POST_URL_REGEXP = '/instagram.com\/p\/'.POST_ID_REGEXP.'\/?$/';

const RN = "\r\n";

// HTTP headers for user agent faking.
const HEADERS = "accept: text/html,application/xhtml+xml,application/xml;" .
        "q=0.9,image/avif,image/webp,image/apng,*/*;" .
        "q=0.8,application/signed-exchange;v=b3;q=0.9" .RN.

    "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) " .
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 " .
        "Safari/537.36" .RN.

    "sec-ch-ua: \"Chromium\";v=\"94\", \"Google Chrome\";v=\"94\", \";" .
        "Not A Brand\";v=\"99\"" .RN.

    "accept-encoding: gzip, deflate, br" .RN.
    "accept-language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7" .RN.
    "cache-control: no-cache" .RN.
    "pragma: no-cache" .RN.
    "dnt: 1" .RN.
    "sec-ch-ua-mobile: ?0" .RN.
    "sec-ch-ua-platform: \"Windows\"" .RN.
    "sec-fetch-dest: document" .RN.
    "sec-fetch-mode: navigate" .RN.
    "sec-fetch-site: none" .RN.
    "sec-fetch-user: ?1" .RN.
    "upgrade-insecure-requests: 1" .RN;

const SLASH = '/';

/*
 * The main function.
 *
 * @param $instagram_post_url, i.e.
 *
 *   https://www.instagram.com/p/CX8wkS_qNMq/
 *
 * @return the post's image URL, i.e.
 *
 *   https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/e35/s1080x1080/
 *   269961451_836551910434198_8806515854959711608_n.jpg?
 *   _nc_ht=instagram.fdnk3-1.fna.fbcdn.net&_nc_cat=110&
 *   _nc_ohc=hOLSmGd1DpAAX9SFiBs&edm=AJBgZrYBAAAA&ccb=7-4&
 *   oh=00_AT_ikXhHf_8YvyySyoDQZZ2onjenV91lR79aNYFBYy4VdA&oe=6206092F&
 *   _nc_sid=78c662
 */
function img_url($instagram_post_url)
{
    $url = filter_instagram_post_url($instagram_post_url);

    return $url ? find_img_url(get_content(embed_url($url))) : '';
}

function filter_instagram_post_url($url)
{
    $valid_url = filter_var($url, FILTER_VALIDATE_URL, [
        FILTER_FLAG_SCHEME_REQUIRED,
        FILTER_FLAG_HOST_REQUIRED,
        FILTER_FLAG_PATH_REQUIRED,
    ]);

    return filter_var($valid_url, FILTER_VALIDATE_REGEXP, [
        'options' => ['regexp' => POST_URL_REGEXP],
    ]);
}

/*
 * Converts an Instagram post URL, i.e.
 *
 *   https://www.instagram.com/p/<post_id>/
 *
 * to URL for embedding into web page, i.e.
 *
 *   https://www.instagram.com/p/<post_id>/embed/?<params>
 */
function embed_url($instagram_post_url)
{
    // In addition to the user agent faking via HTTP headers, we are passing
    // some additional params like a real embedded image.
    $params = http_build_query([
        'cr' => '1',
        'v' => '14',
        'wp' => '540',
        'rd' => '/static/image.html',
    ]);

    // Add a slash after the `instagram_post_url` if needed.
    $slash = substr($instagram_post_url, -1) === SLASH ? '' : SLASH;

    return "$instagram_post_url${slash}embed/?$params";
}

function get_content($url)
{
    $http_response = file_get_contents($url, FALSE, stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => HEADERS,
        ],
    ]));
    return has_gzip($http_response_header)
        ? gzdecode($http_response) : $http_response;
}

/*
 * Do the HTTP headers tell us that the HTTP response body is gzipped?
 */
function has_gzip($http_headers)
{
    return ! empty(array_filter($http_headers, '\iget\is_gzip_header'));
}

function is_gzip_header($http_header)
{
    return preg_match('/Content-Encoding:\s*gzip/', $http_header);
}

/*
 * @return Instagram image URL or ''
 */
function find_img_url($raw_html)
{
    // &amp; -> &
    $html = str_replace('&amp;', '&', $raw_html);

    // Must be <img.EmbeddedMediaImage> that contains srcset of images.
    // Pick 640 px wide img from srcset.
    $url_regex = '/EmbeddedMediaImage.*srcset="(.*) 640w/';

    // If the URL is found, the `matches` will be an array(2) of:
    //  0 - entire matched string
    //  1 - needed URL (the parentheses part of the `url_regex`)
    $matches = NULL;
    return preg_match($url_regex, $html, $matches) ? $matches[1] : '';
}
