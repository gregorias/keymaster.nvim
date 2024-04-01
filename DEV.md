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

## Architectural decision records

### Reusing Neovim’s event bus

Neovim comes with its own event and observer mechanism using autocmd. This
plugin doesn’t reuse it, because that event bus is a global singleton.
It’s impossible to implement that kind of private passing of events like this
plugin does for `keymaster.add_lazy_load_observer` with it. It’s also harder to
test.

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
