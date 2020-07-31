function Convert-WordToNumber {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        # To limit the word length uncomment the following string:
        #[ValidateLength(1,5)]
        [string[]]$Word
    )
    Process {
        # Iterating through a list of words passed to the function:
        foreach ($SingleWord in $Word) {
            Write-Verbose "Start to convert a word $SingleWord"
            # Declaring an initial variable that accumulates numbers:
            $str = ""
            # Here we use GetEnumerator() method of the string object
            # to iterate through letters and add a corresponding number to 
            # variable. In the switch construction there is used a regex
            # switch to match specific letters:
            switch -regex ($SingleWord.GetEnumerator()) {
                "[abc]" {$str += "2"}
                "[def]" {$str += "3"}
                "[ghi]" {$str += "4"}
                "[jkl]" {$str += "5"}
                "[mno]" {$str += "6"}
                "[p-s]" {$str += "7"}
                "[tuv]" {$str += "8"}
                "[w-z]" {$str += "9"}
                default {$str += ""}
            }
            Write-Verbose "Finish to convert a word $SingleWord"
            # And now when $str variable consists of numbers we create
            # a new object and write it out:
            $obj = [PSCustomObject]@{word   = $SingleWord
                                     number = $str -as [int]}
            Write-Output $obj
            # That's all folks!
        }
    }
}

# Bonus function

function Convert-NumberToWord {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        # Check a pattern for a number, it takes everything
        # except the number 1 and letters:
        [ValidatePattern("^[^1a-z]+$")]
        [string[]]$Number,
        [string]$PathToDictionary = ""
    )

    Begin {
        # Check the path to the dictionary file in your default WSL distribution,
        # in case it's missing, the script stops add suggests to
        # install a required package. Just run "sudo apt install wamerican"
        # in this distribution to install it. Generally it's there by default
        # in most Linux distros, but it's missing in WSL. It works for both,
        # Ubuntu 18.04 and Ubuntu 20.04 WSL. The dictionary file is just a plain
        # text file that consists of single words on each line, in my case 
        # there are 102401 words there.
        $TestFile = $(wsl test -e /usr/share/dict/words; echo $?)
        $ErrMessage = @"
It looks like a dictionary package is not installed in your WSL distribution.
To instal run the following command in that distribution or use your own dictionary:
sudo apt install wamerican
"@
        # Check the user dictionary:
        if ($PathToDictionary -ne "") {
            if (-not (Test-Path -Path $PathToDictionary)) {
                Write-Error -ErrorAction Stop -Message "Wrong path to the dictionary file."
            } else {
                $dict = Get-Content -Path $PathToDictionary
                Write-Verbose "User dictionary is in use"
            }
        # Check WSL dictionaries:
        } elseif (-not $TestFile) {
            Write-Error -ErrorAction Stop -Message $ErrMessage
        } elseif ($(wsl test -e /usr/share/dict/american-english-insane; echo $?)) {
            $dict = $(wsl cat /usr/share/dict/american-english-insane)
            Write-Verbose "Insane dictionary is in use"
        } elseif ($(wsl test -e /usr/share/dict/american-english-huge; echo $?)) {
            $dict = $(wsl cat /usr/share/dict/american-english-huge)
            Write-Verbose "Huge dictionary is in use"
        } elseif ($(wsl test -e /usr/share/dict/american-english-large; echo $?)) {
            $dict = $(wsl cat /usr/share/dict/american-english-large)
            Write-Verbose "Large dictionary is in use"
        } else {
            $dict = $(wsl cat /usr/share/dict/words)
            Write-Verbose "Common dictionary is in use"
        }
    }

    Process {
        # To iterate through a list of numbers, a foreach loop is used
        foreach ($SingleNumber in $Number) {
            Write-Verbose "Start processing the number $SingleNumber"
            # Declaring initial variables, $pattern is our future regex pattern
            # to look through the beforementioned dictionary file, and $result
            # will be accumulating possible words for the number:
            [string]$pattern = "^"
            $result = @()
            # Once again we use the switch construction and GetEnumerator()
            # method to iterate through single digits in our number,
            # therefore we're building our regex pattern:
            switch ($SingleNumber.GetEnumerator()) {
                "2" {$pattern += "[abc]"}
                "3" {$pattern += "[def]"}
                "4" {$pattern += "[ghi]"}
                "5" {$pattern += "[jkl]"}
                "6" {$pattern += "[mno]"}
                "7" {$pattern += "[p-s]"}
                "8" {$pattern += "[tuv]"}
                "9" {$pattern += "[w-z]"}
            }
            # And just to complete the pattern:
            $pattern += "$"
            # So, our pattern for number, for instance 4357, is now like
            # this one '^[ghi][def][jkl][p-s]$'. And now the easiest part,
            # just comparing the pattern and our dictionary list, and
            # appending matching words to the results array:
            foreach ($word in $dict) {
                if ($word -match $pattern) {
                    $result += @(,$word)
                    Write-Verbose "Match found: $($Matches.Values)"
                }
            }
            # And one more time a new output object:
            $obj = [PSCustomObject]@{Number  = $Number
                                     Pattern = $pattern
                                     Word    = $result}
            Write-Output $obj
            # That's all
        }
    }

    End {}
}