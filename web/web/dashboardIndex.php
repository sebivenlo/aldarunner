<?php

require_once '/home/www/public_html/svnroots/reposutils.inc.php';
require_once '/usr/local/share/aldabadge/AldaTestBadge3.php';
require_once '/usr/local/share/aldabadge/Pie.php';
$totalTestCount = 131;
require_once 'grpindexconfig.php';
$content = file_get_contents("https://builder1.fontysvenlo.org/queueSize.php");
$pa = explode("\n", $content);
$queueSize = $pa[0];
if (defined($pa[1])) {
    $queueHead = "<h2>Queue in build order&nbsp;{$pa[1]}</h2>";
} else {
    $queueHead = '';
}

function startsWith($haystack, $needle) {
    return strncmp($haystack, $needle, strlen($needle)) === 0;
}

function endsWith($haystack, $needle) {
    return $needle === '' || substr_compare($haystack, $needle, -strlen($needle)) === 0;
}

$wd = getcwd();
$subdir = basename($wd);
$subdirs = scandir($wd, SCANDIR_SORT_ASCENDING);
$index = '';
// compute total number of tests
// reads apps-list.csv, sums last value in line, AB test count.
$csvFile = 'apps-list.csv';
$currentApps = "<ol>\n";
if (file_exists($csvFile)) {
    $totalTestCount = 0;
    $fn = fopen($csvFile, 'r');
    while ($line = fgets($fn)) {
        if (substr($line, 0, 1) == '#') {
            continue;
        }
        $parts = preg_split('/,/', trim($line));
        if (count($parts) >= 3) {
            $totalTestCount += $parts[2];
            $currentApps .= "<li>App {$parts[0]}, Required Coverage: {$parts[1]}, Number of Teacher Tests to pass: {$parts[2]}</li>";
        }
    }
    fclose($fn);
}

$currentApps .= "</ol><br/><a href='stats-benchmark.html'>Stats benchmark</a>";

$rs = $dbConn->Execute($sql);
$pie = new Pie(['Passed', 'Failed', 'Errors', 'Ignored', 'TODO'], ['#0f0', '#f00', '#ff0', '#aaa', '#303']);
$pie->sliceCount(5);

while (!$rs->EOF) {
    extract($rs->fields);
    $lname = '';
    $name = '';
    $grp_name = sprintf("g%03d", $grp_num);
    $extra_class = "";
    if ($today_fresh == 't') {
        $extra_class .= 'fresh-today ';
    }
    if (in_array($_SERVER['REMOTE_USER'], $teachers)) {
        $name = $twoletters . '-' . substr($sclass, 5, 1);
        $lname = "{$roepnaam} {$tussenvoegsel} {$achternaam}";
        $tut = $_SERVER['REMOTE_USER'];
        if ($tut == $tutor_id) {
            $extra_class .= ' mine';
        }
    }
    $summaryFile = "{$grp_name}/alltestssummary.csv";
    $tsummary = AldaTestBadge3::testSummaryFromCSV($summaryFile);
    $passed = $tsummary[1];
    $failed = $tsummary[2];
    $errors = $tsummary[3];
    $ignored = $tsummary[4];
    $todo = max(0, $totalTestCount - ($passed - $failed - $errors - $ignored ));
    $pieString = $pie->render([$passed, $failed, $errors, $ignored, $todo], "");
    $index .= <<<"END"
        <a class='button {$extra_class}' href='{$grp_name}'
            title='{$lname}'>
            <span class='grp' style='font-size:80%; width:auto'>{$name}</span><br/>
            {$pieString}
          <span class='grp'>{$grp_name}<br/></span>
       </a>
END;

    $rs->moveNext();
}
echo <<<"END"
<html>
<head>
<meta charset="utf-8" />
<meta http-equiv="refresh" content="30">
    <link rel='stylesheet' type='text/css' href='css/aldatest.css'/>
    <link rel='stylesheet' type='text/css' href='css/piechart.css'/>
<title>{$pageTitle}</title>
</head>
<body class="prc2Personal">
<h1>{$homeLink}</h1>
<h2>{$queueSize} jobs in build queue</h2>
	 {$queueHead}
<div class='container'>
    {$index}
    </div>
    <div style='background-color:#ccc; margin: 1em 1em;'>
    <hr/>
    <b>Apps in Reports</b>
    {$currentApps}
</div>
END;

if (file_exists("g{$example_grp}/jacocosummary.csv")) {
    $ftime = date("F d Y H:i:s.", filemtime("g{$example_grp}/jacocosummary.csv"));
} else {
    $ftime = 'unkown';
}


require_once '/usr/local/share/aldabadge/piBottom.html';
