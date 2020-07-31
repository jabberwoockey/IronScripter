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
    $arr = @(97..122)
    for ([int]$i = 0; $i -lt $WordLen; $i++) {
        $letter = [char](Get-Random -InputObject $arr)
        switch ($letter) {
            'a' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(224..229))
                    $NSWord += $letter    
                } else {
                    $NSWord += $letter
                }
            }
            'e' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(232..235))
                    $NSWord += $letter    
                } else {
                    $NSWord += $letter
                }
            }
            'i' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(236..239))
                    $NSWord += $letter    
                } else {
                    $NSWord += $letter
                }
            }
            'o' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(242..246))
                    $NSWord += $letter    
                } else {
                    $NSWord += $letter
                }
            }
            'u' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(249..252))
                    $NSWord += $letter    
                } else {
                    $NSWord += $letter
                }
            }
            'y' {
                if (Get-Random -Minimum 0 -Maximum 3) {
                    $letter = [char](Get-Random -InputObject @(253, 255))
                    $NSWord += $letter    
                } else {
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
        $MDParagraph = $(Get-Random -InputObject @("## ","### ", "#### ")) `
            + $(Get-MDTitle) + "`n`n"
        $MDParagraph += $(Get-Paragraph $(Get-Random -Minimum 2 -Maximum 10)) + "`n`n"
        return $MDParagraph
    }

    function Get-MDList {
        $MDList = ""
        for ([int]$i; $i -lt $(Get-Random -Minimum 5 -Maximum 11); $i++) {
            if (Get-Random -Minimum 0 -Maximum 2) {
                $MDList += '* ' + $(Get-Sentence 1) + "`n`n"
            } else {
                $MDList += '* ' + $(Get-Sentence $(Get-Random -Minimum 3 -Maximum 7)) + "`n`n"
            }
        }
        return $MDList
    }

    [int]$MDnumber = $(Get-Random -Minimum 10 -Maximum 21)
    [string]$outMD = ''
    $outMD += '# ' + $(Get-MDTitle) + "`n`n"

    for ([int]$i = 0; $i -le $MDnumber; $i++) {
        if (Get-Random -Minimum 0 -Maximum 2) {
            $outMD += $(Get-MDParagraph)
        } else {
            $outMD += $(Get-MDList)
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
    Write-Error -ErrorAction Stop `
    -Message "It doesn't work that way, try: help .\${ScriptName} -ShowWindow"
}