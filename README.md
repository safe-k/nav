![](https://github.com/safe-k/nav/workflows/Test/badge.svg)

# Nav

A simple shell tool that enables file system location aliasing and navigation.

## Installation

Download the script and source it in your `.bash_profile`.

Example:
```bash
(cd && curl -OJ https://raw.githubusercontent.com/safe-k/nav/master/nav.sh)
echo "source nav.sh" >> ~/.bash_profile
```

## Usage

```bash
$ nav help
Available actions:
- pin (Usage: nav pin [location] (alias))
- to (Usage: nav to [alias])
- rm (Usage: nav rm [alias])
- list
- which
- update
```

### Summary

#### `pin`

Assigns an alias to the given directory.

```bash
$ nav pin . someapp
Pinned /Users/seifkamal/SomeApplication as 'someapp'
```

#### `to`

Navigates to the location associated with the given alias.

```bash
$ nav to someapp
Moved to /Users/seifkamal/SomeApplication
```

#### `list`

Lists all available location aliases.

```bash
$ nav list
desktop   /Users/seifkamal/Desktop
nav       /Users/seifkamal/projects/nav
someapp      /Users/seifkamal/SomeApplication
```

#### `rm`

Removes the given location alias.

```bash
$ nav rm someapp
Removed location with alias 'someapp'
```
