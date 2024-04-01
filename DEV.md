# 🛠️ Developer documentation

This is a documentation file for developers.

## Dev environment setup

This project requires the following tools:

- [Commitlint]
- [Lefthook]

1. Install Lefthook:

```shell
lefthook install
```

TODO: Document why I don’t use the Neovim event bus (it’s a global singleton,
lazy load observer needs private notifications).

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
