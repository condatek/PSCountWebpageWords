# Define the path to the CSV file
$csvPath = Join-Path -Path (Get-Location) -ChildPath "urls.csv"

# Check if the CSV file exists
if (-Not (Test-Path -Path $csvPath)) {
    Write-Host "CSV file not found at path: $csvPath"
    exit
}

# Import the CSV file
$urls = Import-Csv -Path $csvPath

# Check if the CSV file is empty
if ($urls.Count -eq 0) {
    Write-Host "CSV file is empty or could not be read."
    exit
}

# Initialize counters
$totalWordCount = 0
$totalPagesCounted = 0

# Function to count unique words on a webpage
function Get-UniqueWordCount {
    param (
        [string]$url
    )

    try {
        Write-Host "Processing URL: '$url'"
        
        # Download the webpage content
        $webContent = Invoke-WebRequest -Uri $url -UseBasicParsing

        # Extract the raw HTML content
        $htmlContent = $webContent.Content

        # Remove HTML tags
        $textContent = [System.Text.RegularExpressions.Regex]::Replace($htmlContent, '<[^>]*>', ' ')

        # Remove extra whitespace
        $textContent = $textContent -replace '\s+', ' '

        # Convert text to lowercase and split into words
        $words = $textContent.ToLower() -split '\s+'

        # Use a hash table to store unique words
        $uniqueWords = @{}
        foreach ($word in $words) {
            if (-not [string]::IsNullOrEmpty($word) -and -not $uniqueWords.ContainsKey($word)) {
                $uniqueWords[$word] = $true
            }
        }

        # Count the number of unique words
        $wordCount = $uniqueWords.Keys.Count

        return $wordCount
    }
    catch {
        Write-Host "Failed to retrieve '$url'"
        Write-Host "Error: $_"
        return 0
    }
}

# Iterate over each URL in the CSV
foreach ($row in $urls) {
    if (-not $row.URL) {
        Write-Host "Row has no URL: $($row | Out-String)"
        continue
    }

    $url = $row.URL.Trim()  # Trim any extra whitespace from the URL
    $wordCount = Get-UniqueWordCount -url $url
    Write-Host "'$url' has $wordCount unique words"
    $totalWordCount += $wordCount
    $totalPagesCounted++
}

# Output the report
Write-Host "Total pages counted: $totalPagesCounted"
Write-Host "Total unique word count for all URLs: $totalWordCount"
