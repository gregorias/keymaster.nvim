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

### Requiring the plugin is enough to use it

This plugin provides a fundamental interface that can be called early in
configs, for example, in init functions. Lazy.nvim doesn’t guarantee that
Keymaster’s config will be called if another plugin requires it from the init
function, so Keymaster has to have sensible behavior even from just being
required.

Fortunately, Lazy.nvim always installs plugins before calling inits, so the
requires will always succeed after Lazy reads the plugin spec.

### Consistency with `vim.keymap`

The Keymaster module (`keymaster`) purposefully has an interface consistent
with `vim.keymap`:

- This allows people to use `keymaster` whenever they would use `vim.keymap`
  freely, decreasing the costs to change.
- Plugin can use dependency injection for `vim.keymap` and clients can provide
  `keymaster` when they wish for that extra power.

### Not reusing Neovim’s event bus

Neovim comes with its own event and observer mechanism using autocmd. This
plugin doesn’t reuse it, because that event bus is a global singleton.
It’s impossible to implement that kind of private passing of events like this
plugin does for `keymaster.add_lazy_load_observer` with it. It’s also harder to
test.

[Commitlint]: https://github.com/conventional-changelog/commitlint
[Lefthook]: https://github.com/evilmartians/lefthook
