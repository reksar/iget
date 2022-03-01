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

---

## Notes

### History

It was 04.10.2021 [https://youtu.be/roBVl2X7mQs](https://youtu.be/roBVl2X7mQs) 
and all crap with the FB DNS happened just at the time I was recording the 
screencast :)

### JS modules research

I assume that Instagram uses some JS module loader like the 
[RequireJS](https://requirejs.org).

Modules are some definitions of format:

```javascript
__d(function(g,r,i,a,m,e,d) {
    ...

    // Exports are defined as `e` members.
    // They will be accessible from external.
    e.<feature_name> = ...

    ...
}, <id>, [<dependency ids>]);
```

We can require a module with `__r(<id>)`, that returns the `e` exports if 
it exists.

#### `Vendor.js`

Actual for: 
https://www.instagram.com/static/bundles/es6/Vendor.js/17711fe62512.js

This file contains the module **3** that provides the `createElement()` from 
the module **13**. Obtained element can be rendered using the `render()` from 
the **15** module.

For example, we can embed an image using the devtools console:

```javascript
const img = __r(3).createElement('img', {src: '<url>'});
__r(15).render(img, document.body);
```

It may be used as exploit if you can bypass the CORS policy and use some XSS.
