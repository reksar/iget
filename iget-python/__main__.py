from args import parse_args
from iget import img_url


def main():
    args = parse_args()
    print(img_url(args.url, args.width))


if __name__ == '__main__':
    main()
