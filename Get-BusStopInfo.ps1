$url = "https://lothianapi.co.uk/departureBoards/website?stops=6200238420"

$headers = @{
    'Accept-Encoding' = 'gzip, deflate'
    'Accept-Language' = 'en-GB,en;q=0.9,en-US;q=0.8'
    'Cache-Control' = 'max-age=0'
    'Content-Type' = 'application/json, text/javascript, */*; q=0.01'
}
$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

$nextServices = foreach ($busService in $response.services) {
    $busNumber = $busService.service_name
    foreach ($departure in $busService.departures) {
        [PSCustomObject]@{
            "Bus Number" = $busNumber
            Destination = $departure.destination
            DepartureTimeIso = [DateTime]$departure.departure_time_iso
            "Departure Time" = [string]$departure.departure_time
            Diverted = [bool]$departure.diverted
            "Part Route" = [bool]$departure.partRoute
            "Bus ID" = $departure.vehicle_id
            "Realtime Tracking" = [bool]$departure.real_time
        }
    }
}


$tableFragment = $nextServices | Sort-Object -Property "DepartureTimeIso" | Select-Object -First 10 "Bus Number", "Departure Time", Destination, Diverted, "Part Route", "Realtime Tracking", "Bus ID" | ConvertTo-HTML -Fragment


$style = @"
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400..900&display=swap" rel="stylesheet">
<style>
    body {
        font-family: "Orbitron", sans-serif;
        color: #fff200;
        display: flex;
        justify-content: center;
        align-items: top;
        height: 100vh;
        margin: 0;
    }
    table {
        width: 100%;
        border-collapse: collapse;
    }
    th, td {
        padding: 10px;
        text-align: left;
        border-bottom: 1px solid #474747;
    }
    th {
        background-color: #474747;
        color: #fff200;
    }
    tr:hover {
        font-weight: bold;
    }
    td.BAD {
        background-color: #ffe6e6;
        color: #990000;
    }
    td.GOOD {
        background-color: #e6ffe6;
        color: #008000;
    }
</style>
"@

$htmlOutput = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(($response.stop).name) `($(($response.stop).direction)`)</title>
    $style
</head>
<body>
    <div class="table-container">
        <h2>$(($response.stop).name) `($(($response.stop).direction)`)</h2>
        $tableFragment
    </div>
</body>
</html>
"@

$htmlOutput | Out-File C:\temp\table.html
