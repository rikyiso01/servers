#!/usr/bin/env python3.13

from hashlib import md5
from sys import argv


def entry():
    assert get_uuid("test") == "530fa97a-357f-3c19-94d3-0c5c65c18fe8"
    assert (
        get_multiple_uuid("test test2")
        == "530fa97a-357f-3c19-94d3-0c5c65c18fe8 dda915f8-abf6-31e8-8221-e0eaa1f9c4c7"
    )
    main(argv[1])


PARTS = [0, 8, 12, 16, 20, 32]


def get_uuid(name: str) -> str:
    name = f"OfflinePlayer:{name}"
    result = bytearray(md5(name.encode()).digest())
    result[6] = (result[6] & 0x0F) | 0x30
    result[8] = (result[8] & 0x3F) | 0x80
    hex = result.hex()
    parts = [hex[p1:p2] for p1, p2 in zip(PARTS, PARTS[1:])]
    return "-".join(parts)


def get_multiple_uuid(names: str) -> str:
    result = [get_uuid(name) for name in names.split()]
    return " ".join(result)


def main(names: str):
    print(get_multiple_uuid(names))


if __name__ == "__main__":
    entry()
