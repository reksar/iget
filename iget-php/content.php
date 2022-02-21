<?php namespace iget;

// HTTP headers for user agent spoofing.
define('HEADERS', implode("\r\n", [
    'accept: text/html,application/xhtml+xml,application/xml;' .
        'q=0.9,image/avif,image/webp,image/apng,*/*;' .
        'q=0.8,application/signed-exchange;v=b3;q=0.9',

    'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' .
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 ' .
        'Safari/537.36',

    'sec-ch-ua: "Chromium";v="94", "Google Chrome";v="94", ' .
        '";Not A Brand";v="99"',

    'accept-encoding: gzip, deflate, br',
    'accept-language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
    'cache-control: no-cache',
    'pragma: no-cache',
    'dnt: 1',
    'sec-ch-ua-mobile: ?0',
    'sec-ch-ua-platform: "Windows"',
    'sec-fetch-dest: document',
    'sec-fetch-mode: navigate',
    'sec-fetch-site: none',
    'sec-fetch-user: ?1',
    'upgrade-insecure-requests: 1',
]));

const GZIP_HEADER_REGEXP = '/Content-Encoding:\s*gzip/';

/**
 * Reads and decodes content from the given URL with a HTTP GET request.
 * Sends HTTP headers to spoof the user agent and prevent a request blocking by
 * Instagram.
 *
 * @param $url to read from.
 *
 * @return the content from $url (decoded HTTP response body).
 */
function content($url)
{
    $response = file_get_contents($url, FALSE, stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => HEADERS,
        ],
    ]));

    return is_gzipped($http_response_header) ? gzdecode($response) : $response;
}

/**
 * Do the HTTP headers tells that the HTTP response content is gzipped?
 */
function is_gzipped($http_headers)
{
    return ! empty(array_filter($http_headers, '\iget\is_gzip_header'));
}

/**
 * Does given HTTP header tells that content is gzipped?
 */
function is_gzip_header($http_header)
{
    return preg_match(GZIP_HEADER_REGEXP, $http_header);
}
