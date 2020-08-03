<#
.SYNOPSIS
The script that generates random words and sentences.
.DESCRIPTION
The script that generates random words, sentences and documents.
.PARAMETER Word
Takes a positive integer that defines a number of letters in the word.
.PARAMETER Sentence
Takes a positive integer that defines a number of words in the sentence.
.PARAMETER Paragraph
Takes a positive integer that defines a number of sentences in the paragraph.
.PARAMETER Document
Takes a positive integer that defines a number of paragraphs in the document.
.PARAMETER DocSet
Takes a positive integer that defines a number of documents to generate.
.PARAMETER Markdown
Switch to generate a randomized markdown document.
.LINK
https://github.com/jabberwoockey/IronScripter/tree/master/Nonsense-challenge
.LINK
https://ironscripter.us/a-powershell-nonsense-challenge/
.LINK
Get-Random
#>

[CmdletBinding(DefaultParameterSetName='Word')]
param (
    [Parameter(ParameterSetName='Word')]
    [int]$Word,
    [Parameter(ParameterSetName='Sentence')]
    [int]$Sentence,
    [Parameter(ParameterSetName='Paragraph')]
    [int]$Paragraph,
    [Parameter(ParameterSetName='Document')]
    [int]$Document,
    [Parameter(ParameterSetName='DocSet')]
    [int]$DocSet,
    [Parameter(ParameterSetName='Markdown')]
    [switch]$Markdown
)

Set-StrictMode -Version 3.0
$ScriptName =  $($MyInvocation.MyCommand.Name)

function Test-Value {
    param (
        [int]$Value
    )
    if ($Value -le 0) {
        Write-Error -ErrorAction Stop `
            -Message "Value can't be less then or equal to zero."
    }
}

function Get-Word {
    param (
        [int]$WordLen
    )
    Write-Verbose 'Generating a new word'
    Test-Value -Value $WordLen
    [string]$NSWord = ''
    [string]$prevLetter = ''
    $arr = @(97..122)
    $vowels = @("a","e","i","o","u")
    for ([int]$i = 0; $i -lt $WordLen; $i++) {
    [string]$letter = [char](Get-Random -InputObject $arr)
        # Looking for more vowels to make it look more like a real word:
        if (($i -gt 1) -and (($letter -eq $prevLetter) -or 
             ( ($NSWord[$i-2] -notin $vowels) -and ($NSWord[$i-1] -notin $vowels) ) )) {
            while (($letter -eq $prevLetter) -or ($letter -notin $vowels)) {
                $letter = [char](Get-Random -InputObject $vowels)
            }
        } else {
            while (($letter -eq $prevLetter)) {
                [string]$letter = [char](Get-Random -InputObject $arr)
            }
        }
        $prevLetter = $letter
        # Adding diacritics and normalizing their number,
        # I just don't like when there are too many of them:
        switch ($letter) {
            'a' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(224..229))
                    $NSWord += $letter
                }
            }
            'e' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(232..235))
                    $NSWord += $letter
                }
            }
            'i' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(236..239))
                    $NSWord += $letter
                }
            }
            'o' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(242..246))
                    $NSWord += $letter
                }
            }
            'u' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(249..252))
                    $NSWord += $letter
                }
            }
            'y' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $NSWord += $letter    
                } else {
                    $letter = [char](Get-Random -InputObject @(253, 255))
                    $NSWord += $letter
                }
            }
            Default {
                $NSWord += $letter
            }
        }
    }
    return $NSWord
}

function Get-Sentence {
    param (
        [int]$SentenceLen
    )
    Write-Verbose 'Generating a sentence'
    Test-Value -Value $SentenceLen
    $outSentence = ''
    for ([int]$i = 0; $i -lt $SentenceLen; $i++) {
        $word = Get-Word -WordLen $(Get-Random -Minimum 2 -Maximum 16)
        if ($i -eq 0) {
            $outSentence = (Get-culture).TextInfo.ToTitleCase($word)
        } else {
            $outSentence += $word
        }
        if ($i -lt ($SentenceLen-1)) {
            if (-not (Get-Random -Minimum 0 -Maximum 4)) {
                $outSentence += Get-Random -InputObject @(",",";",",")
            }
            $outSentence += " "
        }
    }
    $outSentence += Get-Random -InputObject @(".","!",".","?",".")
    return $outSentence
}

function Get-Paragraph {
    param (
        [int]$ParagraphLen
    )
    Write-Verbose 'Generating a paragraph'
    Test-Value -Value $ParagraphLen
    $outParagraph = ''
    for ([int]$i = 0; $i -lt $ParagraphLen; $i++) {
        $outParagraph += Get-Sentence `
            -SentenceLen $(Get-Random -Minimum 3 -Maximum 11)
        if ($i -lt ($ParagraphLen - 1)) {
            $outParagraph += " "
        }
    }
    return $outParagraph
}

function Get-Document {
    param (
        [int]$DocLen
    )
    Write-Verbose 'Generating a document'
    Test-Value -Value $DocLen
    $outDoc = ""
    for ([int]$i = 0; $i -lt $DocLen; $i++) {
        $outDoc += Get-Paragraph `
            -ParagraphLen $(Get-Random -Minimum 3 -Maximum 20)
        $outDoc += "`r`n`r`n"
    }
    return $outDoc
}

function Get-DocSet {
    param (
        [int]$DocSetLen
    )
    Write-Verbose 'Generating a book'
    Test-Value -Value $DocSetLen
    Write-Output 'Wait, documents are generating...'
    for ([int]$i = 0; $i -lt $DocSetLen; $i++) {
        $filepath = 'doc{0:d3}.txt' -f ($i+1)
        Get-Document -DocLen $(Get-Random -Minimum 5 -Maximum 20) |
            Out-File -Encoding utf8 -FilePath $filepath
        Write-Output ('Document {0} is ready' -f ($i+1))
    }
    Write-Output 'All done!'
}

function Get-Markdown {
    function Get-MDTitle {
        return (Get-culture).TextInfo.ToTitleCase($(Get-Word $(Get-Random -Minimum 5 -Maximum 16)))
    }

    function Get-MDParagraph {
        $MDParagraph = $(Get-Random -InputObject @("## ","### ", "#### ", "##### ")) `
            + $(Get-MDTitle) + "`n`n"
        $MDParagraph += $(Get-Paragraph $(Get-Random -Minimum 2 -Maximum 10)) + "`n`n"
        if (-not (Get-Random -Minimum 0 -Maximum 3)) {
            $MDParagraph += "---`n`n"
        }
        return $MDParagraph
    }

    function Get-MDList {
        $MDList = ""
        if (Get-Random -Minimum 0 -Maximum 2) {
            $ordered = $true
        } else {
            $ordered = $false
        }
        for ([int]$i = 1; $i -lt $(Get-Random -Minimum 6 -Maximum 12); $i++) {
            if ($ordered) {
                $marker = '{0}. ' -f $i
            } else {
                $marker = '* '
            }
            if (Get-Random -Minimum 0 -Maximum 2) {
                $MDList += $marker + $(Get-Sentence 1) + "`n`n"
            } else {
                $MDList += $marker + $(Get-Sentence $(Get-Random -Minimum 3 -Maximum 7)) + "`n`n"
            }
        }
        return $MDList
    }

    [int]$MDnumber = $(Get-Random -Minimum 10 -Maximum 21)
    [string]$outMD = ''
    $outMD += '# ' + $(Get-MDTitle) + "`n`n"
    $prevList = $false

    for ([int]$i = 0; $i -le $MDnumber; $i++) {
        if ($prevList -or (Get-Random -Minimum 0 -Maximum 3)) {
            $outMD += $(Get-MDParagraph)
            $prevList = $false
        } else {
            $outMD += $(Get-MDList)
            $prevList = $true
        }
    }
    return $outMD
}

if ($PSBoundParameters.ContainsKey('Word')) {
    Get-Word -WordLen $Word
}
elseif ($PSBoundParameters.ContainsKey('Sentence')) {
    Get-Sentence -SentenceLen $Sentence
}
elseif ($PSBoundParameters.ContainsKey('Paragraph')) {
    Get-Paragraph -ParagraphLen $Paragraph
}
elseif ($PSBoundParameters.ContainsKey('Document')) {
    Get-Document -DocLen $Document
}
elseif ($PSBoundParameters.ContainsKey('DocSet')) {
    Get-DocSet -DocSetLen $DocSet
}
elseif ($PSBoundParameters.ContainsKey('Markdown')) {
    Get-Markdown
}
else {
    Write-Output ("Usage:`n.\${ScriptName} -Word <Int32> | -Sentence <Int32>" + `
    " | -Paragraph <Int32> | -Document <Int32> | -DocSet <Int32>" + `
    " | -Markdown")
}