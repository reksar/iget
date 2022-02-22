# iget

## The goal

**In:** Instagram post URL, e.g. `https://www.instagram.com/p/CX8wkS_qNMq/`

**Out:** URL of the post image, e.g.
```
https://instagram.fdnk3-1.fna.fbcdn.net/v/t51.2885-15/e35/s1080x1080/
269961451_836551910434198_8806515854959711608_n.jpg?
_nc_ht=instagram.fdnk3-1.fna.fbcdn.net&_nc_cat=110&
_nc_ohc=hOLSmGd1DpAAX9SFiBs&edm=AJBgZrYBAAAA&ccb=7-4&
oh=00_AT_ikXhHf_8YvyySyoDQZZ2onjenV91lR79aNYFBYy4VdA&oe=6206092F&
_nc_sid=78c662
```

## Using

The second optional param can be an image width: 640, 750 or 1080 (default) px.

### Shell

`./iget.sh https://www.instagram.com/p/<post_id>/`

### PHP

```php
require_once 'iget-php/iget.php';
$url = iget\img_url('https://www.instagram.com/p/<post_id>/');
```

## History

It was 04.10.2021 [https://youtu.be/roBVl2X7mQs](https://youtu.be/roBVl2X7mQs) 
and all crap with the FB DNS happened just at the time I was recording the 
screencast :)
