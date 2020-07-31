# IronScripter-TextMe
Iron Scripter: Text Me - A PowerShell Dialer Challenge

Powershell functions to convert letters to numbers and vice versa according to
the ITU E 1.161 International Standard.

To convert numbers to words you can use your own dictionary file (a plain text
file with a single word on each line) or you can use WSL dictionaries.
To use WSL dictionaries you need WSL
[to be installed](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
on your system, also a package with dictionary words should be installed in
your default WSL distribution.

The dictionary package is missing in Ubuntu 18.04/20.04 WSL by default, so,
to install the package run the following command in your default
distribution:

`sudo apt install wamerican` (102401 words)

Also you can install additional dictionaries:

`sudo apt install wamerican-large` (167303 words)

`sudo apt install wamerican-huge` (345470 words)

`sudo apt install wamerican-insane` (654895 words)

The biggest dictionary will be chosen automatically.

## Usage

`Convert-NumberToWord -Number 364,228`

`364 | Convert-NumberToWord`

`Convert-WordToNumber "cat"`

`"cat" | Convert-WordToNumber`

`(Convert-NumberToWord 364).Word`

`Convert-NumberToWord 364 -PathToDictionary D:\path\to\dictionary.txt`

---

Challenge: https://ironscripter.us/text-me-a-powershell-dialer-challenge/

WSL: https://docs.microsoft.com/en-us/windows/wsl/install-win10

https://en.wikipedia.org/wiki/Telephone_keypad

https://en.wikipedia.org/wiki/E.161