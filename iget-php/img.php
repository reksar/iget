<?php namespace iget\img;

// An embedded Instagram post is expected to contain an img like:
//   <img class="<CLASS_ATTRIBUTE>" alt="..." src="<URL-1080>"
//     srcset="<URL-640> 640w,<URL-750> 750w,<URL-1080> 1080w" />
const CLASS_ATTRIBUTE = 'EmbeddedMediaImage';
// This regexp is for any <URL-*> from the scrset.
// We'll specify the URL further with the ' ${width}w' regexp suffix.
const URL_REGEXP = CLASS_ATTRIBUTE . '.*srcset=".*(https:[^:]*)';
// The specified img width from srcset can be validated with:
const VALID_WIDTH = [640, 750, 1080]; // px
const DEFAULT_WIDTH = 1080; // px

/**
 * @param $html - embedded Instagram post content.
 *
 * @param $width - embedded image width to select from srcset.
 *
 * @return Instagram image URL or ''
 */
function url($html, $width)
{
    $width = in_array($width, VALID_WIDTH) ? $width : DEFAULT_WIDTH;
    $img_url = '/'.URL_REGEXP." ${width}w/";

    // If the URL is found, the `matches` will be an array(2) of:
    //  0 - entire matched string
    //  1 - needed URL (the parentheses part of the URL_REGEXP)
    $matches = NULL;
    return preg_match($img_url, urldecode($html), $matches) ? $matches[1] : '';
}
