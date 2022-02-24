<?php namespace iget;

// For Instagram post URL https://www.instagram.com/p/<post_id>/
const POST_ID_REGEXP = '[[:alnum:]+-_@]+';
const POST_URL_REGEXP = '/instagram.com\/p\/'.POST_ID_REGEXP.'\/?$/';

// HTTP GET params to spoof a request from an embedded Instagram post.
// In addition to the user agent spoofing via HTTP headers, we are passing
// some additional GET request params as a real embedded Instagram post.
define('EMBEDDED_POST_QUERY', http_build_query([
    'cr' => '1',
    'v' => '14',
    'wp' => '540',
    'rd' => '/static/image.html',
]));

/**
 * Converts an Instagram post URL -> URL for post embedding into web page.
 *
 * @param $post_url, i.e.
 *
 *   https://www.instagram.com/p/<post_id>/
 *
 * @return URL for embedding into web page, i.e.
 *
 *   https://www.instagram.com/p/<post_id>/embed/?<EMBEDDED_POST_QUERY>
 *
 *   or ''
 */
function embedded_url($post_url)
{
    $url = filter_post_url($post_url);
    // Add a slash if needed.
    $slash = substr((string) $url, -1) === '/' ? '' : '/';
    // EMBEDDED_POST_QUERY is optional but preferred.
    return $url ? "$url${slash}embed/?" . EMBEDDED_POST_QUERY : '';
}

function filter_post_url($post_url)
{
    return filter_var(filter_url($post_url), FILTER_VALIDATE_REGEXP, [
        'options' => ['regexp' => POST_URL_REGEXP],
    ]);
}

function filter_url($url)
{
    return filter_var($url, FILTER_VALIDATE_URL, [
        FILTER_FLAG_SCHEME_REQUIRED,
        FILTER_FLAG_HOST_REQUIRED,
        FILTER_FLAG_PATH_REQUIRED,
    ]);
}
