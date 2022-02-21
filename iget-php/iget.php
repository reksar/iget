<?php namespace iget;

require_once 'content.php';
require_once 'img.php';
require_once 'url.php';
use iget;

/**
 * Gets an Instagram post URL and returns related image URL.
 *
 * @param $post_url, i.e.
 *
 *   https://www.instagram.com/p/CX8wkS_qNMq/
 *
 * @param $img_width - 640, 750 or 1080 (default) px.
 * @see $width param of the `img\url()` at the `img.php`.
 *
 * @return post's image URL, i.e.
 *
 *   https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/e35/s1080x1080/
 *   269961451_836551910434198_8806515854959711608_n.jpg?
 *   _nc_ht=instagram.fdnk3-1.fna.fbcdn.net&_nc_cat=110&
 *   _nc_ohc=hOLSmGd1DpAAX9SFiBs&edm=AJBgZrYBAAAA&ccb=7-4&
 *   oh=00_AT_ikXhHf_8YvyySyoDQZZ2onjenV91lR79aNYFBYy4VdA&oe=6206092F&
 *   _nc_sid=78c662
 *
 *   or ''
 */
function img_url($post_url, $img_width=img\DEFAULT_WIDTH)
{
    $url = embedded_url($post_url);
    $embedded_post = $url ? content($url) : '';
    return img\url($embedded_post, $img_width);
}
