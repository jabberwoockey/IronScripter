[CmdletBinding()]
param (
    [Parameter()]
    [string]$Site = 'https://ironscripter.us/',
    [int]$Newest,
    [switch]$Html
)

function post_pl() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [int]$Num
    )
    if ($Num -eq 1) {
        return 'post'
    } else {
        return 'posts'
    }
}

Write-Verbose 'Getting categories...'
$categories = Invoke-RestMethod ($Site + 'wp-json/wp/v2/categories') |
    ForEach-Object {$_ | Select-Object id, name}

Write-Verbose 'Getting posts...'
$posts = Invoke-RestMethod ($Site + 'wp-json/wp/v2/posts/?per_page=100') |
    ForEach-Object {$_ | Select-Object `
        @{n='title';e={$_.title | Select-Object -ExpandProperty rendered}}, `
        @{n='excerpt';e={$_.excerpt | Select-Object -ExpandProperty rendered}},`
        id, categories, tags, date, link}

Write-Verbose 'Getting tags...'
$tags = Invoke-RestMethod ($Site + 'wp-json/wp/v2/tags/?per_page=100') |
    ForEach-Object {$_ | Select-Object id, name}

Write-Verbose 'Calculating posts in categories...'
$post_counters = $posts | ForEach-Object {$_.categories} |
    Group-Object | Select-Object @{l='id';e={$_.Name}}, @{l='num';e={$_.Count}}
$combined_cats = foreach ($cat in $categories) {
    $pcat = $post_counters | Where-Object {$_.id -eq $cat.id}
    if ($pcat.num) {
        $cat | Select-Object id, Name, @{l='posts';e={$pcat.num}}
    } else {
        $cat | Select-Object id, Name, @{l='posts';e={0}}
    }
}

Write-Verbose 'Calculating posts with tags...'
$tag_counters = $posts | ForEach-Object {$_.tags} |
    Group-Object | Select-Object @{l='id';e={$_.Name}}, @{l='num';e={$_.Count}}
$combined_tags = foreach ($tag in $tags) {
    $ptag = $tag_counters | Where-Object {$_.id -eq $tag.id}
    if ($ptag.num) {
        $tag | Select-Object id, name, @{l='posts';e={$ptag.num}}
    } else {
        $tag | Select-Object id, name, @{l='posts';e={0}}
    }
}

if ($PSBoundParameters.ContainsKey('Site') -or
        $Site -match '.*ironscripter.*') {
    Write-Verbose 'Writing output...'
    Write-Output ("`nThere are {0} posts on {1}" -f $posts.Count, $Site)
    Write-Output ("`nThere are {0} categories:" -f $combined_cats.Count)
    foreach ($cat in $combined_cats) {
        Write-Output ('    - {0}: {1} {2}' -f $cat.Name, $cat.posts, `
            (post_pl -Num $cat.posts))
    }
    Write-Output ("`nThere are {0} tags:" -f $combined_tags.Count)
    foreach ($tag in $combined_tags) {
        Write-Output ('    - {0}: {1} {2}' -f $tag.Name, $tag.posts, `
            (post_pl -Num $tag.posts))
    }
}

Write-Verbose 'Calculating challenges...'
if ($PSBoundParameters.ContainsKey('Newest') -and
        $Site -match '.*ironscripter.*') {
    $counter = 0
    $content = ''
    foreach ($post in $posts) {
        if ($post.categories -contains 29) {
            $ch_cats = @()
            $ch_tags = @()
            foreach ($cat in $post.categories) {
                $ch_cats += $combined_cats | Where-Object {$_.id -eq $cat} |
                    Select-Object -ExpandProperty Name
            }
            foreach ($tag in $post.tags) {
                $ch_tags += $combined_tags | Where-Object {$_.id -eq $tag} |
                    Select-Object -ExpandProperty Name
            }
            $details = [PSCustomObject]@{
                Title = $post.title -replace '&#8211;', '-'
                Date = Get-Date -Date $post.date
                id = $post.id
                Link = $post.link
                Categories = $ch_cats -join ', '
                Tags = $ch_tags -join ', '
                Excerpt = $post.excerpt -replace '<[^>]+>','' `
                                        -replace '\[&hellip;\]', '...' `
                                        -replace '&#8217;', "'"
            }
            Write-Output $details
            if ($PSBoundParameters.ContainsKey('Html')) {
                $content += $details | ConvertTo-Html -Fragment -As List
                $content += '<br />'
            }
        }
        $counter += 1
        if ($counter -ge $Newest) {
            break
        }
    }
    if ($PSBoundParameters.ContainsKey('Html')) {
        $content = $content -replace '(https:[^<]+)',"<a href='`${1}'>`${1}</a>"
        $header = "<h1>IronScripter Challenges</h1>`n<h2>$($Newest) newest</h2>"
        $css = @"
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 16px;
        background-color: #f7f3ea;
    }
    h1 {
        font-family: Oswald, Lato, Arial Narrow, sans-serif;
        font-size: 2.5rem;
        font-weight: 700;
        letter-spacing: -1px;
        line-height: 1.35em;
        text-align: center;
    }
    h2 {
        font-family: Oswald, Lato, Arial Narrow, sans-serif;
        font-size: 1.7rem;
        font-weight: 700;
        letter-spacing: -1px;
        line-height: 1.35em;
        text-transform: uppercase;
        text-align: center;
    }
    table {
        margin-left: auto;
        margin-right: auto;
        width: 60%;
        background-color: #ffffff;
        box-shadow: 0 5px 12px rgba(0, 0, 0, 0.05);
    }
    p {
        font-size: 0.8rem;
        text-align: right;
    }
    a {
        color: #0a63bd;
        text-decoration: none;
        transition: all 0.2s ease-in-out;
    }
    a:hover, a:focus {
        color: #cb820b;
    }
</style>
"@
        ConvertTo-Html -Head $css -Body "$header`n$content" `
            -Title 'IronScripter Challenges' `
            -PostContent "<p>Creation Date: $(Get-Date)<p>" |
            Out-File '.\challenges.html'
    }
}