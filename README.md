![](https://github.com/safe-k/nav/workflows/Test/badge.svg)

# nav

A simple shell tool that enables file system location aliasing and navigation.

## Installation

Download the binary file and source it in your `.bash_profile`.

Example:
```bash
curl -OJ https://raw.githubusercontent.com/safe-k/nav/master/nav
echo "source nav" >> ~/.bash_profile
```

## Usage

<details>
<summary>pin</summary>
<p>
Assigns an alias to the given location.

```bash
> nav pin [location] [alias]
```
</p>
</details>

<details>
<summary>to</summary>
<p>
Navigates to the location assigned to the given alias.

```bash
> nav to [alias]
```
</p>
</details>

<details>
<summary>list</summary>
<p>
Lists all available location aliases.

```bash
> nav list
nav=/Users/seifkamal/src/nav
home=/Users/seifkamal
deep=/Users/seifkamal/somewplace/somewhere/deep
```
</p>
</details>

<details>
<summary>rm</summary>
<p>
Removes the given location alias.

```bash
> nav rm [alias]
```
</p>
</details>

<details>
<summary>help</summary>
<p>
Prints out usage instructions.

```bash
> nav help
Available actions:
- pin (Usage: nav pin [location] [alias])
- to (Usage: nav to [alias])
- rm (Usage: nav rm [alias])
- list
- which
```
</p>
</details>

<details>
<summary>which</summary>
<p>
Prints out the installation location.

```bash
> nav which
/Users/seifkamal/src/nav
```
</p>
</details>

<details>
<summary>update</summary>
<p>
Downloads the latest version of the executable.

```bash
> nav update
Executable updated. Please run `source /Users/seifkamal/src/nav/nav`
```
</p>
</details>
