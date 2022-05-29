from argparse import ArgumentParser, ArgumentError, Action
from iget import DEFAULT_WIDTH, AVAILABLE_WIDTH, is_post_url


class ValidatePostUrl(Action):

    def __call__(self, parser, namespace, value, options=''):

        if is_post_url(value):
            namespace.post_url = value
        else:
            raise ArgumentError(self, 'Invalid URL of Instagram post!')


class ValidateImgWidth(Action):

    def __call__(self, parser, namespace, value, options=''):

        if value in AVAILABLE_WIDTH:
            namespace.img_width = value
        else:
            namespace.img_width = DEFAULT_WIDTH
            print('WARNING: Invalid width! The default value is used.')


def args():
    parser = ArgumentParser()

    parser.add_argument(
        'post_url',
        type=str,
        action=ValidatePostUrl,
        help='https://www.instagram.com/p/<ID>',
    )

    parser.add_argument(
        'img_width',
        type=int,
        nargs='?',
        default=DEFAULT_WIDTH,
        action=ValidateImgWidth,
        help=f"Post image width {AVAILABLE_WIDTH} px.",
    )

    args = parser.parse_args()

    return args.post_url, args.img_width
