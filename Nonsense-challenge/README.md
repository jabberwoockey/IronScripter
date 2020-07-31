# IronScripter Nonsense

### Usage

To generate a word, sentence or paragraph run one of the following commands:

* `.\Get-Nonsense.ps1 -Word 5` (a value is a number of letters in the word)
* `.\Get-Nonsense.ps1 -Sentence 8` (a value is a number of words in the sentence)
* `.\Get-Nonsense.ps1 -Paragraph 7` (a value is a number of sentences in the paragraph)

To generate a document or a series of documents:

* `.\Get-Nonsense.ps1 -Document 10` (a value is a number of paragraphs in the document)
* `.\Get-Nonsense.ps1 -DocSet 10` (a value is a number of documents)

To generate a fake markdown document:

* `.\Get-Nonsense.ps1 -Markdown`

---

Challenge: https://ironscripter.us/a-powershell-nonsense-challenge/