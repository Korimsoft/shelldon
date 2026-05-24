# Shelldon

Shelldon is a small collection of shell utilities for filtering, highlighting, Git helpers, and formatting command-line output.

The project is intended for interactive shell usage, log inspection, Git workflow shortcuts, and small scripts where lightweight text-processing helpers are useful.

## Contents

```text
shelldon/
  aliases/
    git
  filtering/
    filterword
    filterout
  git-helpers/
    commitall.sh
  highlighting/
    hiword
  output/
    output
  testfiles/
    testfile_1.log
  LICENSE
  README.md
```

## Requirements

The filtering and highlighting tools use GNU Awk:

```sh
gawk
```

The Git helper scripts require Git:

```sh
git
```

The output helper is a shell script intended to be sourced from another shell script.

## Installation

Clone the repository:

```sh
git clone <repository-url>
cd shelldon
```

Make sure the utility scripts are executable:

```sh
chmod +x filtering/filterword
chmod +x filtering/filterout
chmod +x highlighting/hiword
chmod +x git-helpers/commitall.sh
```

Optionally, add the utility directories to your `PATH`:

```sh
export PATH="$PATH:/path/to/shelldon/filtering"
export PATH="$PATH:/path/to/shelldon/highlighting"
export PATH="$PATH:/path/to/shelldon/git-helpers"
```

To make this permanent, add the relevant `export PATH=...` lines to your shell profile, such as:

```sh
~/.bashrc
~/.zshrc
~/.profile
```

## Filtering utilities

### `filterword`

`filterword` prints only lines that match at least one provided word or regular expression.

Usage:

```sh
filterword pattern_1 pattern_2 ...
```

Example using a pipe:

```sh
cat testfiles/testfile_1.log | filterword WARNING
```

Example using input redirection:

```sh
filterword WARNING < testfiles/testfile_1.log
```

Example with multiple patterns:

```sh
filterword WARNING ERROR INFO < testfiles/testfile_1.log
```

Because matching is based on Awk regular expressions, patterns can be more expressive than plain words:

```sh
filterword 'WARNING|ERROR' < testfiles/testfile_1.log
```

Print log lines containing an HTTP status code:

```sh
filterword ' 200 ' < testfiles/testfile_1.log
```

Print log lines containing a specific component name:

```sh
filterword 'component_1' < testfiles/testfile_1.log
```

### `filterout`

`filterout` prints only lines that do not match any of the provided words or regular expressions.

Usage:

```sh
filterout pattern_1 pattern_2 ...
```

Example using a pipe:

```sh
cat testfiles/testfile_1.log | filterout system/alive
```

Example using input redirection:

```sh
filterout system/alive < testfiles/testfile_1.log
```

Exclude multiple patterns:

```sh
filterout system/alive validate < testfiles/testfile_1.log
```

Exclude warning lines:

```sh
filterout WARNING < testfiles/testfile_1.log
```

Exclude multiple log levels:

```sh
filterout WARNING ERROR < testfiles/testfile_1.log
```

## Highlighting utilities

### `hiword`

`hiword` highlights matching words or regular expression patterns in the input text.

Usage:

```sh
hiword pattern_1 pattern_2 ...
```

Example using a pipe:

```sh
cat testfiles/testfile_1.log | hiword WARNING
```

Example using input redirection:

```sh
hiword WARNING < testfiles/testfile_1.log
```

Highlight multiple terms:

```sh
hiword WARNING INFO ERROR < testfiles/testfile_1.log
```

Combine filtering and highlighting:

```sh
filterword WARNING < testfiles/testfile_1.log | hiword WARNING
```

Highlight component names:

```sh
hiword component_1 component_2 < testfiles/testfile_1.log
```

Highlight HTTP status codes:

```sh
hiword ' 200 ' ' 404 ' ' 500 ' < testfiles/testfile_1.log
```

## Combining utilities

The tools are designed to work well in shell pipelines.

Show all warning lines and highlight the word `WARNING`:

```sh
filterword WARNING < testfiles/testfile_1.log | hiword WARNING
```

Exclude health-check requests and highlight warnings:

```sh
filterout system/alive < testfiles/testfile_1.log | hiword WARNING
```

Show lines for a specific component and highlight selected terms:

```sh
filterword component_1 < testfiles/testfile_1.log | hiword WARNING INFO component_1
```

Show HTTP access log lines while excluding health checks:

```sh
filterword 'GET ' < testfiles/testfile_1.log | filterout system/alive
```

## Output utilities

The `output/output` script provides helper functions for formatted shell-script output.

It is intended to be sourced from another script:

```sh
. /path/to/shelldon/output/output
```

or:

```sh
source /path/to/shelldon/output/output
```

After sourcing the file, the following functions are available:

```sh
shldn_print_header
shldn_log_info_row
shldn_log_success_row
shldn_log_warn_row
shldn_log_error_row
shldn_print_footer
```

Example script:

```sh
#!/bin/sh

. /path/to/shelldon/output/output

shldn_print_header "Deployment"

shldn_log_info_row "Starting deployment"
shldn_log_success_row "Build completed"
shldn_log_warn_row "Using default configuration"
shldn_log_error_row "Example error message"

shldn_print_footer
```

Example output:

```text
╔════════════════════════════════════════╗
║                                        ║
║      Deployment                        ║
║                                        ║
╚════════════════════════════════════════╝
*       Starting deployment
* *     Build completed
* *     Using default configuration
* *     Example error message

******* END *******
```

## Git helpers

### `commitall.sh`

`commitall.sh` stages all changes in the current Git repository and creates a commit using the provided commit message.

Usage:

```sh
commitall.sh "commit message"
```

Or, if the `git-helpers` directory is not in your `PATH`:

```sh
/path/to/shelldon/git-helpers/commitall.sh "commit message"
```

Example:

```sh
git-helpers/commitall.sh "Update documentation"
```

The script:

- verifies that the current directory is inside a Git repository
- requires a commit message
- stages all changes with `git add --all`
- skips committing when there are no staged changes
- commits with `git commit -m`
- uses the `output/output` helpers for formatted status messages

## Git aliases

The `aliases/git` file contains short aliases for common Git commands.

Available aliases:

```sh
alias gife="git fetch"
alias gicam="git commit -a -m"
alias gicaa="git commit -a --amend"
alias gip="git push"
alias gista="git status"
```

To use them in your current shell session:

```sh
. /path/to/shelldon/aliases/git
```

or:

```sh
source /path/to/shelldon/aliases/git
```

To load them automatically, source the file from your shell profile.

Example:

```sh
echo '. /path/to/shelldon/aliases/git' >> ~/.bashrc
```

## Notes on pattern matching

The filtering and highlighting utilities use Awk regular expressions.

This means that some characters have special meaning, including:

```text
. * + ? [ ] ( ) { } ^ $ |
```

For example, this pattern matches nearly any non-empty line:

```sh
filterword . < testfiles/testfile_1.log
```

To search for a literal dot, escape it:

```sh
filterword '\.' < testfiles/testfile_1.log
```

When using patterns with special characters, quote them to prevent the shell from interpreting them:

```sh
filterword 'WARNING|ERROR' < testfiles/testfile_1.log
```

## Examples

Print all warning lines:

```sh
filterword WARNING < testfiles/testfile_1.log
```

Print all lines except warning lines:

```sh
filterout WARNING < testfiles/testfile_1.log
```

Print all lines related to a component:

```sh
filterword component_1 < testfiles/testfile_1.log
```

Print all lines except health-check requests:

```sh
filterout system/alive < testfiles/testfile_1.log
```

Highlight warning and info markers:

```sh
hiword WARNING INFO < testfiles/testfile_1.log
```

Filter first, then highlight:

```sh
filterword component_1 < testfiles/testfile_1.log | hiword WARNING INFO
```

## License

This project is licensed under the GNU General Public License version 2. See `LICENSE` for details.