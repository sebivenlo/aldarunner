<?php

require_once '/home/www/public_html/svnroots/reposutils.inc.php';
require_once '/usr/local/share/aldabadge/AldaTestBadge3.php';
require_once '/usr/local/share/aldabadge/Pie.php';
require_once '../grpindexconfig.php';

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
if (file_exists('../apps-list.txt')) {
    $projects = [];

    $fp = fopen('../apps-list.txt', 'r');
    while (($line = fgets($fp, 128)) !== false) {
        $pline = trim($line);
        $projects[] = $pline;
    }
    foreach ($projects as $project_dir) {
        $parts = preg_split('/\//', $project_dir);
        $week = $parts[0];
        $project = $parts[1];
        $b = new AldaTestBadge3($project, $rsfields, $project_dir, '../jacoco-resources');
        $badges .= $b->renderTinyNamed("{$week}/{$project}");
    }
} else {
    foreach ($subdirs as $week) {
        if (startsWith($week, "wk") && is_dir($week)) {
            $pdirs = scandir($week, SCANDIR_SORT_ASCENDING);
            foreach ($pdirs as $project) {
                if (substr($project, 0, 1) != ".") {
                    $project_dir = "{$week}/{$project}";
                    $b = new AldaTestBadge3($project, $rsfields, $project_dir, '../jacoco-resources');
                    $badges .= $b->renderTinyNamed("{$week}/{$project}");
                }
            }
        }
    }
}
if (file_exists("jacocosummary.csv")) {
   $tsummary = AldaTestBadge3::jacocoSummaryFromCSV("jacocosummary.csv");
   $ftime= filemtime("jacocosummary.csv");
} else {
  $tsummary='no coverage measured';
  $ftime='unknown';
}
$pie = new Pie(['Covered','Not Covered', 'TODO'],['#0f0','#f00','#303']);
$pieString=$pie->render( [$tsummary[0],$tsummary[1],$tsummary[2]],"{$last_commit}" );

echo <<<"END"
<html>
<head>
<meta charset="utf-8" />
<title>PRC2 {$grp_name} 2020</title>
        <link rel='stylesheet' type='text/css' href='../css/aldatest.css'/> 
        <link rel='stylesheet' type='text/css' href='../css/piechart.css'/> 
</head>
<body class="prc2Personal">
<h1>{$snummer} {$grp_name}:  {$roepnaam} {$tussenvoegsel} {$achternaam} last commit {$last_commit}
    {$pieString}
 </h1>
   <div class='container'>
    {$badges}

    </div>
        <hr/>
<h4 style='text-align:left'>Legend: <span style='background:#0C0; color:white;outline:1px solid black;padding:0.2rem'>COVERED</span>&nbsp;
<span style='background:#f00; color:white;outline:1px solid black; padding:0.2rem'>NOT COVERED</span>&nbsp;
<span style='background:#333; color:white;outline:1px solid black; padding:0.2rem'>TO DO</span>&nbsp;&nbsp;
All tasks done (no TODO's) and 75% coverage suffices to take part in the assessment. Last rev {$youngest} commited {$last_commit}</h4>
<hr/>
END;
require_once '/usr/local/share/aldabadge/piBottom.html';




