<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/counterclockwise-arrows-button_1f504.png" width="120" />
</p>

<h1 align="center">supaswap</h1>

<p align="center">
  <strong>many Supabase accounts. one command.</strong>
</p>

<p align="center">
  <a href="https://github.com/ExoticPengy/homebrew-supaswap/stargazers"><img src="https://img.shields.io/github/stars/ExoticPengy/homebrew-supaswap?style=flat&color=yellow" alt="Stars"></a>
  <a href="https://github.com/ExoticPengy/homebrew-supaswap/commits/main"><img src="https://img.shields.io/github/last-commit/ExoticPengy/homebrew-supaswap?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/ExoticPengy/homebrew-supaswap?style=flat" alt="License"></a>
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey?style=flat" alt="macOS">
</p>

<p align="center">
  <a href="#before--after">Before/After</a> •
  <a href="#install">Install</a> •
  <a href="#usage">Usage</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#troubleshooting">Troubleshooting</a>
</p>

---

A tiny macOS command that switches which account the [Supabase CLI](https://supabase.com/docs/guides/cli) is logged in as. Save each account once, then swap in one command. Tokens stay in the macOS Keychain, never in plain text files.

## Before / After

<table>
<tr>
<td width="50%">

### 😩 Without supaswap

```bash
supabase logout
supabase login
# browser opens...
# sign out of Supabase in browser...
# sign in as other account...
# copy token... wait for redirect...
```

Every. Single. Time.

</td>
<td width="50%">

### 🔄 With supaswap

```bash
supaswap use work
```

Done.

</td>
</tr>
</table>

## Install

Paste into your terminal:

```bash
brew install exoticpengy/supaswap/supaswap
```

**Requirements:** macOS, [Homebrew](https://brew.sh), and the [Supabase CLI](https://supabase.com/docs/guides/cli/getting-started) (`brew install supabase/tap/supabase`).

<details>
<summary><strong>Install without Homebrew</strong></summary>

```bash
git clone https://github.com/ExoticPengy/homebrew-supaswap.git
ln -s "$PWD/homebrew-supaswap/supaswap" /opt/homebrew/bin/supaswap   # or any directory on your PATH
```

</details>

<details>
<summary><strong>Update / uninstall</strong></summary>

```bash
brew upgrade supaswap                 # update
brew uninstall supaswap               # uninstall
```

Uninstalling leaves your saved tokens in the Keychain. Remove them first with `supaswap rm <name>` for each account, or delete the `supaswap` entries in **Keychain Access**.

</details>

## Usage

### 1. Save your accounts (once)

Log in the normal way, then save the login under a name:

```bash
supabase login            # sign in as your personal account
supaswap save personal

supabase logout
supabase login            # sign in as your work account
supaswap save work
```

### 2. Swap

```bash
supaswap use personal
supaswap use work
```

### Commands

| Command | What it does |
|---------|--------------|
| `supaswap save <name>` | Save the account the CLI is logged in as right now. Re-saving a name overwrites it. |
| `supaswap use <name>` | Log the CLI in as a saved account. |
| `supaswap ls` | List saved accounts. `*` marks the active one. |
| `supaswap rm <name>` | Delete a saved account. |
| `supaswap rename <old> <new>` | Rename a saved account. Refuses if `<new>` already exists. |
| `supaswap help` | Show all commands (also `-h`, `--help`). |

Names may use letters, digits, `.`, `_` and `-`.

```console
$ supaswap ls
  personal
* work
```

## How It Works

- **`save`** reads the Supabase CLI's token from the macOS Keychain and stores a copy under Keychain service `supaswap`, account `<name>`.
- **`use`** pipes the saved token into `supabase login` on stdin, so the CLI stores it the same way it always does.
- The active account name (never a token) is kept in `~/.config/supaswap/current`. If you run `supabase login` yourself, the `*` in `ls` is stale until your next `save` or `use`.
- Tokens never appear as command-line arguments, so they can't be seen in `ps` or your shell history.
- One bash script. No dependencies beyond what ships with macOS, plus the Supabase CLI.

## Troubleshooting

<details>
<summary><strong>macOS asks "security wants to use your confidential information stored in Supabase CLI"</strong></summary>

Expected, only during `supaswap save`: it reads the CLI's Keychain entry, which loses its Always Allow whenever `supabase login` writes a different account to it. Click **Always Allow**. `use`, `ls` and `rm` never prompt.

</details>

<details>
<summary><strong>Warning: <code>SUPABASE_ACCESS_TOKEN is set and overrides the stored login</code></strong></summary>

The Supabase CLI prefers that environment variable over any stored login, so swapping has no effect while it is set. Remove it from your shell config (for example `~/.zshrc`) and open a new terminal.

</details>

<details>
<summary><strong><code>not logged in; run supabase login first</code></strong></summary>

`save` copies the current CLI login, so there must be one. Run `supabase login`, then `supaswap save <name>`.

</details>

<details>
<summary><strong>Using <code>supabase --profile</code></strong></summary>

Not supported yet. supaswap works with the default profile only.

</details>

## Development

```bash
./test.sh
```

Runs the full test suite against throwaway Keychain entries. Your real logins are never touched.

To release, push to `main`, then:

```bash
gh release create vX.Y.Z --generate-notes
```

A GitHub Action updates the formula's `url` and `sha256` automatically.

## License

[MIT](LICENSE)
