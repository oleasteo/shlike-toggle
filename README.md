[![AUR Version](https://img.shields.io/aur/version/shlike-toggle)](https://aur.archlinux.org/packages/shlike-toggle)

# shlike-toggle

`shlike-toggle` is a lightweight Bash script designed to toggle blocks of shell-like files (aynthing that uses `#` for line comments) using basic Unix tools. It enables efficient manipulation of code blocks in shell scripts.

## Features

- Toggle comments for entire code blocks marked by specific delimiters.
- Lightweight and dependency-free, relying only on standard Unix utilities.
- Simple command-line usage.

## Requirements

- `gawk`
- `grep`
- `coreutils` (includes `head` and `cut`)

## Installation

### Arch Linux (AUR)

Install [`shlike-toggle`](https://aur.archlinux.org/packages/shlike-toggle) with the AUR helper of your choice, e.g.:

```bash
yay -S shlike-toggle
```

### Manual Installation

Since it's just a single bash file, you can download it and add it to your `$PATH`.

```bash
cd ~/.local/bin # or any directory of your choice within your $PATH
wget https://raw.githubusercontent.com/oleasteo/shlike-toggle/refs/heads/main/pkg/shlike-toggle
chmod +x shlike-toggle
```

## Usage

### Target File Modification

Prepare your file to use the required delimiters. An example may look like this:

```bash
# [...]

##! { toggle feat/a:first }
echo 'feat/a:first'
# a mode may have comments, but no empty lines
echo 'feat/a:first multiline'

##! { toggle feat/a:second }
#- # prefix lines with \`#- \` to mark disabled
#- echo 'feat/a:second'

# An empty mode can be defined for on/off switches
##! { toggle dark:off }
# add at least a comment to show as "enabled"
##! { toggle dark:on }
#- echo 'dark:on'

# [...]
```

A mode block is started with `##! { toggle GROUP:MODE }` and ends with the next
empty line. Each line of a disabled mode block starts with `#- `. This is
automatically toggled by the script.

### Toggle Blocks

Run `shlike-toggle my-file.sh set GROUP MODE` to disable all blocks of `GROUP`
except for `MODE`.

Example: `shlike-toggle my-file.sh set feat/a second` for the file above would
result in the following:

```bash
# [...]

##! { toggle feat/a:first }
#- echo 'feat/a:first'
#- # a mode may have comments, but no empty lines
#- echo 'feat/a:first multiline'

##! { toggle feat/a:second }
# prefix lines with \`#- \` to mark disabled
echo 'feat/a:second'

# An empty mode can be defined for on/off switches
##! { toggle dark:off }
# add at least a comment to show as "enabled"
##! { toggle dark:on }
#- echo 'dark:on'

# [...]
```

### All Commands

The general usage is `shlike-toggle <FILE> <COMMAND>`.

The available commands are:

| Command  | arguments        | Description                                                                                                                                   |
| -------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `set`    | `<GROUP> [MODE]` | Enable the specified mode and disable all other modes in the same group. If no mode is specified, the first mode in the file will be enabled. |
| `get`    | `[GROUP]`        | Show active mode(s) (of the specified group).                                                                                                 |
| `list`   | `[GROUP]`        | List available modes (of the specified group).                                                                                                |
| `groups` |                  | List available groups.                                                                                                                        |

## Contributing

Contributions are welcome! Please feel free to submit pull requests or report issues.

## License

This project is licensed under the [MIT License](LICENSE).
