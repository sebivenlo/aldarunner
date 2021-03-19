<?php

require_once '/home/www/public_html/svnroots/reposutils.inc.php';
require_once '/usr/local/share/aldabadge/AldaTestBadge3.php';
require_once '/usr/local/share/aldabadge/appslist.php';
require_once '/usr/local/share/aldabadge/Pie.php';

$totalTestCount = 20;
require_once 'grpindexconfig.php';

function startsWith( $haystack, $needle ) {
    return strncmp( $haystack, $needle, strlen( $needle ) ) === 0;
}

function endsWith( $haystack, $needle ) {
    return $needle === '' || substr_compare( $haystack, $needle, -strlen( $needle ) ) === 0;
}

$wd = getcwd();
$subdir = basename( $wd );
$subdirs = scandir( $wd, SCANDIR_SORT_ASCENDING );
$index = '';

// compute total number of tests
// reads apps-list.csv, sums last value in line, AB test count.

$csvFile = 'apps-list.csv';

$totalTestCount = 0;
$currentApps = currentApps( $csvFile, $totalTestCount );

$rs = $dbConn->Execute( $sql );
$pie = new Pie( [ 'Covered', 'Not Covered', 'TODO' ], [ '#0f0', '#f00', '#303' ] );
$welcome = 'no';
while ( !$rs->EOF ) {
    extract( $rs->fields );
    $lname = '';
    $name = '';
    $grp_name = sprintf( "g%03d", $grp_num );
    $extra_class = "";
    if ( $today_fresh == 't' ) {
        $extra_class = 'fresh-today';
    }
    $user = filter_var( $_SERVER[ 'REMOTE_USER' ], FILTER_SANITIZE_NUMBER_INT );
    if ( in_array( $user, $teachers ) ) {
        $lname = "{$roepnaam} {$tussenvoegsel} {$achternaam}";
        $name = $twoletters;
        $welcome = $user;
    }
    $allsummaryFile = "{$grp_name}/alljacocosummary.csv";
    $allTestSummaryFile = "{$grp_name}/alltestssummary.csv";
    if ( file_exists( $allTestSummaryFile ) ) {
        $tsummary = AldaTestBadge3::testSummaryFromCSV( $allTestSummaryFile );
        $ftime = filemtime( $allTestSummaryFile );
    } else {
        $tsummary = [ 0, 0, 0, 0, 0 ];
        $ftime = 'unknown';
    }
    $pie = new Pie( [ 'Passed', 'Failed', 'Err', 'Ignored', 'TODO' ], [ '#0f0', '#ff0', '#f00', '#aaa', '#000' ] );
    $todo = $totalTestCount - ($tsummary[ 1 ] + $tsummary[ 2 ] + $tsummary[ 3 ] + $tsummary[ 4 ]);
    $pieString = $pie->render( [ $tsummary[ 1 ], $tsummary[ 2 ], $tsummary[ 3 ], $tsummary[ 4 ], $todo ], $lname );

//    $pieString = $pie->renderCsvFile( "{$grp_name}/jacocosummary.csv", $totalTestCount, "$lname last commit {$last_commit}, Teacher tests summary, " );
    $index .= <<<"END"
        <a class='button {$extra_class}' href='{$grp_name}'
            target='empty'>
            <span class='grp'>{$name}</span><br/>
            {$pieString}
          <span class='grp'>{$grp_name}</span>
       </a>
END;
    $rs->moveNext();
}


//$sql = $sql_head . " where grp_num={$example_grp}";
//$rs = $dbConn->Execute( $sql );
//if ( !$rs->EOF ) {
//    $index = processPiRecord( $rs, $index, $totalTestCount );
//    $rs->moveNext();
//}

echo <<<"END"
<html>
<head>
<meta charset="utf-8" />

<title>{$pageTitle}</title>
        <link rel='stylesheet' type='text/css' href='css/aldatest.css'/>
        <link rel='stylesheet' type='text/css' href='css/piechart.css'/>
</head>
<body class="prc2Personal">
<h1>{$pageTitle}</h1>
   <div class='container'>
    {$index}
    </div>
        <hr/>
<h4 style='text-align:left'>Legend TeacherTest Pie-Chart: 
    <span style='background:#0C0; color:white;outline:1px solid black;padding:0.2rem'>Passed</span>&nbsp;
<span style='background:#ff0; color:black;outline:1px solid black; padding:0.2rem'>FAILED</span>&nbsp;
<span style='background:#f00; color:white;outline:1px solid black; padding:0.2rem'>ERRROR</span>&nbsp;
<span style='background:#666; color:white;outline:1px solid black; padding:0.2rem'>IGNORED</span>&nbsp;&nbsp;
<span style='background:#000; color:white;outline:1px solid black; padding:0.2rem'>TODO</span>&nbsp;&nbsp;
<span style='background:#ffa; color:black;outline:1px solid black; padding:0.2rem'>ACTIVE within last 24 hrs</span>&nbsp;&nbsp;
All tasks done (no TODO's) and 75% coverage suffices to take part in the assessment. Last summary update <?=$ftime?> CEST</h4>
<hr/>

    <div style='background-color:#ccc; margin: 1em 1em;'>
    <hr/>
    
    <table class ="apps">
    <caption>Apps in Reports</caption>
    <thead>
        <tr><th>App</th><th>pub date</th><th>due date</th><th>coverage required</th><th>Teacher tests to pass</th></tr>
    </thead>
    <tbody>
    {$currentApps}
    </tbody>
    </table>
    </div>
END;

if ( file_exists( "g{$example_grp}/jacocosummary.csv" ) ) {
    $ftime = date( "F d Y H:i:s.", filemtime( "g{$example_grp}/jacocosummary.csv" ) );
} else {
    $ftime = 'unkown';
}

require_once '/usr/local/share/aldabadge/piBottom.html';
