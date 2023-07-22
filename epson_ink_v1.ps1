param (
    [Parameter(Mandatory=$true)]
    [String]$url
)

function GetPercentageFromHeight($height) {
    return $height * 2
}

try {
    # Ignore SSL certificate errors
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class SSLHandler {
        public static void IgnoreSSLValidation() {
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
        }
    }
"@
    [SSLHandler]::IgnoreSSLValidation()

    # Create a new WebClient object to make the HTTP request
    $webClient = New-Object System.Net.WebClient

    # Make the HTTP request and retrieve the HTML content
    $response = $webClient.DownloadString($url)

    # Regular expression pattern to match the PNG file names and height attributes
    $pattern = "<img[^>]*src='[^']*\/(Ink_[^']*\.PNG)'[^>]*height='(\d+)'"

    # Initialize an array to store results
    $results = @()

    # Loop through all matches in the HTML content and extract the PNG file names and heights
    $matches = [regex]::Matches($response, $pattern)
    foreach ($match in $matches) {
        $fileName = $match.Groups[1].Value

        # Extract the channel name from the PNG file name
        $channelName = $fileName -replace '\.PNG$', ''

        # Extract the height value
        $height = $match.Groups[2].Value

        # Calculate the percentage
        $percentage = GetPercentageFromHeight([int]$height)

        # Generate XML structure for the result
        $xmlResult = @"
<result>
    <channel>$channelName</channel>
    <unit>Percent</unit>
    <mode>Absolute</mode>
    <showChart>1</showChart>
    <showTable>1</showTable>
    <warning>0</warning>
	<LimitMinWarning>20</LimitMinWarning>
	<LimitMinError>10</LimitMinError>
    <value>$percentage</value>
</result>
"@

        # Add the result to the results array
        $results += $xmlResult
    }

    # Combine all XML results into a single XML document
    $xmlDocument = @"
<?xml version="1.0" encoding="UTF-8" ?>
<prtg>
$results
</prtg>
"@

    # Output the XML document
    Write-Output $xmlDocument

    exit 0
} catch {
    # In case of any errors, output an error message and exit with an error code
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
