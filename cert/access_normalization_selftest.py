#!/usr/bin/env python3
"""Focused regression checks for semantic named-access normalization."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import align


def main():
    cases = [
        (["GETIMPORT\t_T.vipAvatar"],
         ["GETIMPORT\t_T", "GETFIELD\tvipAvatar"]),
        (["GETIMPORT\tgame.Players.LocalPlayer"],
         ["GETIMPORT\tgame", "GETFIELD\tPlayers", "GETFIELD\tLocalPlayer"]),
        (["GETIMPORT\tplain"], ["GETIMPORT\tplain"]),
        (["GETIMPORT\tnot-a-valid.path"], ["GETIMPORT\tnot-a-valid.path"]),
        (["BRANCH\t7", "CLOSURE\t42", "NAMECALL\tFoo"],
         ["CLOSURE", "NAMECALL\tFoo"]),
    ]
    failed = []
    for index, (source, expected) in enumerate(cases, 1):
        actual = align.norm(source)
        if actual != expected:
            failed.append((index, expected, actual))
    print("ACCESS_NORMALIZATION_SELFTEST assertions=%d passed=%d failed=%d" %
          (len(cases), len(cases) - len(failed), len(failed)))
    for index, expected, actual in failed:
        print("  case %d expected=%r actual=%r" % (index, expected, actual))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
