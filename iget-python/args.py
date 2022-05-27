from argparse import ArgumentParser, Action, ArgumentError
from iget import DEFAULT_WIDTH, AVAILABLE_WIDTH, is_post_url


class ValidatePostUrl(Action):

    def __call__(self, parser, namespace, value, options=''):

        if is_post_url(value):
            namespace.url = value
        else:
            raise ArgumentError(self, 'ERROR: Invalid URL of Instagram post!')


class ValidateWidth(Action):

    def __call__(self, parser, namespace, value, options=''):

        if value in AVAILABLE_WIDTH:
            namespace.width = value
        else:
            namespace.width = DEFAULT_WIDTH
            print('WARNING: Invalid width! The default value is used.')


def parse_args():
    parser = ArgumentParser()
    parser.add_argument(
        'url',
        type=str,
        action=ValidatePostUrl,
    )
    parser.add_argument(
        'width',
        type=int,
        nargs='?',
        default=DEFAULT_WIDTH,
        action=ValidateWidth,
    )
    return parser.parse_args()
