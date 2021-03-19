<?php

require_once '/home/www/public_html/svnroots/reposutils.inc.php';
require_once '/home/sebi/web/AldaTestBadge3.php';
require_once '/home/sebi/web/appslist.php';
require_once '/home/sebi/web/Pie.php';
require_once '../groupIndexConfig.php';

function startsWith($haystack, $needle) {
    return strncmp($haystack, $needle, strlen($needle)) === 0;
}

function endsWith($haystack, $needle) {
    return $needle === '' || substr_compare($haystack, $needle, -strlen($needle)) === 0;
}

$wd = getcwd();
$subdir = basename($wd);
$grp_num = substr($subdir, 1);
//echo "<pre>working dir is {$wd} subdir {$subdir} {$grp_num}</pre><br/>";


$sql = <<<"EOF"
  select grp_name,repospath,youngest,last_commit, snummer,roepnaam, achternaam, tussenvoegsel
      from
  repositories r join prj_tutor pt using(prjtg_id) join prj_grp using (prjtg_id) join student using(snummer)
  where pt.grp_num={$grp_num} and pt.prjm_id={$prjm_id}
EOF;
$rsfields = [];
$rs = $dbConn->Execute($sql);
if (!$rs->EOF) {
    $rsfields = $rs->fields;
    extract($rs->fields);
//    echo "{$snummer} {$roepnaam} {$achternaam} {$grp_name}, {$last_commit}<br/>";
}
$subdirs = scandir('.', SCANDIR_SORT_ASCENDING);
$badges = '';
// count,passed,failed,err,ignore
$overAllTestSummary = array(0, 0, 0, 0, 0);
$totalTestCount = 0;
$csvFile = '../apps-list.csv';
$currentApps = currentApps($csvFile, $totalTestCount);

if (file_exists('../apps-list.csv')) {
    $projects = [];

    $fp = fopen('../apps-list.csv', 'r');
    while (($line = fgets($fp, 128)) !== false) {
        if (startsWith($line, '#') || $line == '') {
            continue;
        }
        $pline = trim($line);
        $projects[] = $pline;
    }
    foreach ($projects as $project_desc) {
        $parts = preg_split('/,/', $project_desc); // split in projectdir, mincoverage,testcount
        if (count($parts) < 3) {
            continue;
        }
        $project_dir = $parts[0];
        $minCoverage = $parts[1];
        $totalTestCount += $parts[2];
        $pub = "2021-01-19T12:00";
        $due = "2021-03-01T23:59";
        if (count($parts) > 9) {
            $pub = $parts[8];
            $due = $parts[9];
        }
        $dirparts = preg_split('/\//', $project_dir);
        $week = $dirparts[0];
        $project = $dirparts[1];
        $b = new AldaTestBadge3($project, $rsfields, $project_dir, '../jacoco-resources', $minCoverage);
        $b->setPubAndDue($pub, $due);
        $badges .= $b->renderTinyNamed("{$week}/{$project}");
    }
    fclose($fp);
}

$summaryFile = "alltestssummary.csv";
$tsummary = AldaTestBadge3::testSummaryFromCSV($summaryFile);
if (file_exists($summaryFile)) {
    $ftime = filemtime($summaryFile);
} else {
    $ftime = 'unknown';
}
//$testCount=$overAllTestSummary[ 0 ];
$passed = $tsummary[1];
$failed = $tsummary[2];
$errors = $tsummary[3];
$ignored = $tsummary[4];
$todo = max(0, $totalTestCount - ($passed - $failed - $errors - $ignored ));
$user = filter_var($_SERVER['REMOTE_USER'], FILTER_SANITIZE_NUMBER_INT);
$pie = new Pie(['Passed', 'Failed', 'Errors', 'Ignored', 'TODO'], ['#0f0', '#f00', '#ff0', '#aaa', '#303']);
$pieString = $pie->render([$passed, $failed, $errors, $ignored, $todo], "Teacher Tests of commit {$last_commit}");
$modlowcase = strtolower($module);
$photo = '';
if (in_array($user, $teachers)) {
    $studentLink = "<a class='snummer' href='https://peerweb.fontysvenlo.org/student_admin.php?snummer={$snummer}' target='_blank'>{$snummer}</a>";
    $photo = "<img src='../getphoto.php?s={$snummer}' class='photo'/>";
} else {
    $studentLink = "snummer";
}
echo <<<"END"
<html>
<head>
<meta charset="utf-8" />

<meta http-equiv="refresh" content="30">
<title>{$grp_name} {$module} {$year}</title>
        <link rel='stylesheet' type='text/css' href='../css/aldatest.css'/> 
        <link rel='stylesheet' type='text/css' href='../css/piechart.css'/> 
</head>

<body class="prc2Personal">
${photo}
<h1><a href='../'>Up</a> {$studentLink} <a class='grp' href="https://www.fontysvenlo.org/svn/{$year}/{$modlowcase}/{$grp_name}">{$grp_name}</a>:  {$roepnaam} {$tussenvoegsel} {$achternaam}     
    {$pieString}
    
 </h1>
   <div class='container'>
    {$badges}

    </div>
    <hr/>
    <div style='background-color:#ccc; margin: 1em 1em;'>
    <table class ="apps">
    <caption>Apps in Reports</caption>
       <thead>
        <tr><th>App</th><th>pub date</th><th>due date</th><th>coverage required</th><th>Teacher tests to pass</th></tr>
    </thead>
    <tbody>
    {$currentApps}
    </tbody>
    </table></div>
END;
require_once '/usr/local/share/aldabadge/piBottom.html';



