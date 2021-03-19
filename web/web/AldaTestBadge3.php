<?php

/**
 * Description of AldaTestBadge.
 *
 * @author Pieter van den Hombergh {@code p.vandenhombergh@fontys.nl}
 */
class AldaTestBadge3 {

    protected $app;
    protected $rsfields;
    public $testABSummary = array( 0, 0, 0, 0, 0 );
    public $bbAllPassed = false;
    protected $testBBSummary = array( 0, 0, 0, 0, 0 );
    protected $grp_name;
    protected $youngest;
    protected $apiVersionString = 'v0.1';
    protected $apiVersion = 0.1;

    /**
     *
     * @var Coverage object.
     */
    public $coverageBB = 0;
    public $coveragePercentBB = 0;
    protected $testSummaryAB;
    public $coverageAB = 0;
    protected $abMsgLink;
    protected $signalClassAB;
    protected $msgLink;
    protected $testSummaryBB;
    protected $compilerErrorsFile;
    protected $last_commit;
    public $coveragePercentAB = 0;
    public $abPanel = '';
    public $checkTime = '';
    public $abTestsPassed = 0;
    protected $signalClassBB;
    public $bbTests = 0;
    public $abTests = 0;
    public $abPassed;
    public $siteExists = false;
    public $project_dir;
    public $jacoco_resources;
    public $lastChangedRevision = [];
    public $bbIgnores;
    public $bbPassed = 0;
    public $bbFails = 0;
    public $bbErrs = 0;
    public $nowork;
    public $compilerErrorsBB;
    public $testTime = 'test time unknown';
    private $minCoverage;
    public $due = "1971-01-01T00:00";
    public $pub = "2021-01-30T12:00";
    public $hoursBudget;
    public $hoursDue;

    function setPubAndDue( $pub, $due ): AldaTestBadge3 {
        $this->pub = $pub;
        $this->due = $due;
        $this->hoursBudget = trim( `/home/rp/bin/hoursbetween $pub $due` );
        $this->hoursDue = trim( `/home/rp/bin/hoursdue $due` );
        return $this;
    }

    /**
     * the app for this
     * @param type $app application name and path beneath group
     * @param type $rsfields result record for this badge
     */
    function __construct( $app, $rsfields, $project_dir,
            $jacoco_resources = 'jacoco-resources', int $minCoverage = 75 ) {
        $this->app = $app;
        $this->rsfields = $rsfields;
        $this->grp_name = $rsfields[ 'grp_name' ];
        $this->youngest = $rsfields[ 'youngest' ];
        $this->last_commit = $rsfields[ 'last_commit' ];
        //$this->project_dir="{$this->grp_name}/{$this->app}";
        $this->project_dir = $project_dir;
        $this->jacoco_resources = $jacoco_resources;
        $this->minCoverage = $minCoverage;
        $this->compute();
    }

    /**
     * 
     * @return string the signal colour determined for the AB tests.
     */
    function getSignalClass( array $testSummary, bool $lowCoverage = true ): string {
        $signalClass = '';
        if ( $testSummary === null || count( $testSummary ) < 6 ) {
            return "#ccc";
        } else {
            $tests = $testSummary[ 0 ];
            $passed = $testSummary[ 1 ];
            $fails = $testSummary[ 2 ];
            $errs = $testSummary[ 3 ];
            $ignores = $testSummary[ 4 ];
            if ( $tests > 0 ) {
                if ( $tests === $passed ) {
                    if ( $lowCoverage ) {
                        $signalClass = 'lowcoverage';
                    } else {
                        $signalClass = 'passed';
                    }
                } else if ( $errs > 0 ) {
                    $signalClass = 'errors';
                } else if ( $fails > 0 ) {
                    $signalClass = 'failed';
                } else if ( $ignores > 0 ) {
                    $signalClass = 'ignored';
                }
            }
        }
        return $signalClass;
    }

    /**
     * Read test summary from csv file as array.
     * @param type $csvFileName
     * @return array with test summary or all zeros
     */
    static function testSummaryFromCSV( string $csvFileName ): array {
        if ( !file_exists( $csvFileName ) ) {
            return [ 0, 0, 0, 0, 0, 0 ];
        }
        $fn = fopen( $csvFileName, 'r' );
        fgets( $fn ); // dummy read
        $lastline=fgets( $fn ); // 
        fclose( $fn );
        $testSummaryLine = preg_split( '/,/', trim( $lastline ) );
        return $testSummaryLine;
    }

    /**
     * File has two lines. Lats line is of interest.
     * First column is covered, 2nd is not covered, 3rd = not done
     * @param string $csvFileName
     * @return array 
     */
    static function jacocoSummaryFromCSV( string $csvFileName ): array {
        if ( !file_exists( $csvFileName ) ) {
            return [ 0, 0, 100 ];
        }
        $fn = fopen( $csvFileName, 'r' );
        fgets( $fn );
        $lastline = fgets( $fn );
        fclose( $fn );
        if ( !defined( $lastline ) ) {
            return [ 0, 0, 100 ];
        }
        $testSummaryLine = preg_split( '/,/', trim( $lastline ) );
        return $testSummaryLine;
    }

    function readLastChangedRevision() {
        $lcf = "{$this->project_dir}/last-changed-revision.txt";
        if ( file_exists( $lcf ) ) {
            $fn = fopen( $lcf, 'r' );
//            echo "<hr/>\n";
            while ( ($line = fgets( $fn )) !== FALSE ) {
                $tr = preg_split( '/=/', trim( $line ), 2 );
                $name = $tr[ 0 ];
                if ( count( $tr ) > 1 ) {
                    $val = preg_replace( '/"/', '', $tr[ 1 ] );
                    $this->lastChangedRevision[ $name ] = $val;
//                    echo "found rev info [{$name}]=[{$val}]<br/>\n";
                }
            }
        }
//        else { 
//            throw new Exception("cannot find {$this->project_dir}/last-changed-revision.txt");
//        }
    }

    /**
     * Create test summary html indicator from summary.
     * indicatory is a coloured version of t=p+f+e+i.
     * 
     * @param array $summary
     * @return string html
     */
    public static function testResultIndictator( string $project_dir, array $summary, string $app, string $testType = 'BB' ): string {
        $tests = $summary[ 0 ];
        $passed = $summary[ 1 ];
        $fails = $summary[ 2 ];
        $errs = $summary[ 3 ];
        $ignores = $summary[ 4 ];
        $site = 'site' . $testType;
//        $testtime = intval( $summary[ 5 ] );
        $repFile = "{$project_dir}/{$site}/surefire-report.html";
        $testTime = 'not tested';
        if ( file_exists( $repFile ) ) {
            $testTime = 'tested ' . date( "Y-m-d H:i:s", filemtime( $repFile ) );
        }
        $testIndicator = "<a href='{$project_dir}/{$site}/surefire-report.html' "
                . "title='{$testTime}'>\n\t"
                . "<span title='{$testTime}'>{$testType}-tests: </span>"
                . "<span class='t' title='test count:{$tests}'>{$tests}</span>="
                . "<span class='p' title='{$passed} passed'>{$passed}</span>+"
                . "<span class='f' title='{$fails} fails'>{$fails}</span>+"
                . "<span class='e' title='{$errs} errors'>{$errs}</span>+"
                . "<span class='s' title='{$ignores} ignored'>{$ignores}</span></a>\n";
        return $testIndicator;
    }

    /**
     * 
     * @param string $jacocosummaryfile
     * @return Coverage object
     */
    public static function evalCoverageFile( string $jacocosummaryfile ): int {
        $instructions = $covered = $percent = 0;
        if ( file_exists( $jacocosummaryfile ) ) {
            $jsf = fopen( $jacocosummaryfile, 'r' );
            while ( ($line = fgets( $jsf )) !== FALSE ) {
                $tr = preg_split( '/,/', $line );
                if ( $tr[ 0 ] === 'summary' ) {
                    $instructions = intval( $tr[ 3 ] ) + intval( $tr[ 4 ] );
                    $covered = intval( $tr[ 4 ] );
                    $percent = $instructions > 0 ? intval( (100 * $covered) / $instructions ) : 0;
                    break;
                }
            }
            fclose( $jsf );
        }
        $result = $percent;
//        echo "<pre style='color:red'>{$result}</pre>";
        return $result;
    }

    /**
     * Compute jacoco indicator.
     * @param int $cov
     * @param string $fileToLink
     * @return string indicator
     */
    public static function coverageIndicator( int $percent, string $fileToLink, $jacoco_resources ): string {
        $green = $percent;
        $red = 100 - $green;
        return "<a href='{$fileToLink}'>Cov. "
                . "<img src='{$jacoco_resources}/greenbar.gif' width='{$green}' height='10'/>"
                . "<img src='{$jacoco_resources}/redbar.gif' width='{$red}' height='10'/>"
                . "&nbsp;{$green}%</a>";
    }

    /**
     * Render the badge html.
     * @return string result
     */
    function compute() {
        $this->readLastChangedRevision();
        $this->siteExists = is_dir( "{$this->project_dir}/siteBB/" );
        $this->nowork = false;
//        $this->nowork = file_exists( "{$this->project_dir}/siteBB/nowork" ) || (
//                isSet( $this->lastChangedRevision[ 'Last_Changed_Author' ] ) && ($this->lastChangedRevision[ 'Last_Changed_Author' ] == 'www-data')
//                );

        $this->compilerErrorsFile = "{$this->project_dir}/siteBB/compiler-error.html";
        $this->compilerErrorsBB = file_exists( $this->compilerErrorsFile ) ? 1 : 0;
        $this->testBBSummary = $this->testSummaryFromCSV(
                "{$this->project_dir}/siteBB/testsummary.csv" );

        $mvnrunOutBBFile = "{$this->project_dir}/siteBB/mvn-run-out.txt";
        $cfsize = file_exists( $mvnrunOutBBFile ) ? filesize( $mvnrunOutBBFile ) : 0;
        $this->msgLink = ($cfsize == 0) ? "<span style='color:#777;'>No Maven output</span>" : "<a href='{$this->project_dir}/siteBB/mvn-run-out.html' target='_blank'>Maven Output</a>";
        $this->testSummaryBB = AldaTestBadge3::testResultIndictator( $this->project_dir, $this->testBBSummary,
                        $this->app, 'BB' );
        $jacocosummaryfile = "{$this->project_dir}/siteBB/jacoco/jacoco.csv";
        $this->coveragePercentBB = $this->evalCoverageFile( $jacocosummaryfile );
        $this->signalClassBB = $this->getSignalClass( $this->testBBSummary, $this->coveragePercentBB < 75 );
        $this->coverageBB = $this->coverageIndicator( $this->coveragePercentBB,
                "{$this->project_dir}/siteBB/jacoco/index.html", $this->jacoco_resources );
        $this->bbTests = $this->testBBSummary[ 0 ];
        $this->bbPassed = $this->testBBSummary[ 1 ];
        $this->bbFails = $this->testBBSummary[ 2 ];
        $this->bbErrs = $this->testBBSummary[ 3 ];
        $this->bbIgnores = $this->testBBSummary[ 4 ];

        $this->bbAllPassed = ($this->bbTests > 0) && ($this->bbPassed == $this->bbTests);
        $apiversionfile = "{$this->project_dir}/siteBB/api.version";
        if ( file_exists( $apiversionfile ) ) {
            $this->apiVersionString = file_get_contents( $apiversionfile );
            $this->apiVersion = floatval( substr( $this->apiVersionString, 1 ) );
            $this->checkTime = date( "Y-m-d H:i:s", filemtime( $apiversionfile ) );
        }
        if ( $this->bbAllPassed ) {
            $this->abPanel = $this->abPanel();
            $testABSummaryFile = "{$this->project_dir}/siteAB/testsummary.csv";
            if ( file_exists( $testABSummaryFile ) ) {
                $this->testABSummary = self::testSummaryFromCSV( $testABSummaryFile );
            }
            if ( !$this->siteExists ) {
                return;
            }
        }
    }

    function abPanel(): string {
        if ( !is_dir( "{$this->project_dir}/siteA" ) ) {
            return '<div class=\'warning\'>Too low  coverage<span style=\'font-size:60%\'>(< 95%)</span><br/> for teacher tests</div>';
        }
        $this->abTests = $this->testABSummary[ 0 ];
        $this->abTestsPassed = ($this->testABSummary != null) ? $this->testABSummary[ 1 ] : 0;
        $this->abPassed = ($this->abTests > 0) && ($this->abTestsPassed === $this->abTests);
        $this->signalClassAB = $this->getSignalClass( $this->testABSummary, $this->coveragePercentBB < 75 );
        $compilerABoutfile = "{$this->project_dir}/siteA/compiler-out.txt";
        $cfABsize = file_exists( $compilerABoutfile ) ? filesize( $compilerABoutfile ) : 0;
        $jacocosummaryfile = "{$this->project_dir}/siteA/jacoco/jacoco.csv";
        $this->coveragePercentAB = $this->evalCoverageFile( $jacocosummaryfile );
        $this->coverageAB = $this->coverageIndicator( $this->coveragePercentAB,
                "{$this->project_dir}/siteA/jacoco/index.html", $this->jacoco_resources );
        $abMsgLink = '';
        if ( $cfABsize != 0 ) {
            $abMsgLink = "<a href='{$this->project_dir}/siteA/compiler-out.html' target='_blank'>"
                    . "Compiler Messages</a><br/>\n";
        }
        $mvnrunOut = "{$this->project_dir}/siteA/mvn-run-out.txt";
        $cfsize = file_exists( $mvnrunOut ) ? filesize( $mvnrunOut ) : 0;
        $cfLink = '';
        if ( $cfsize ) {
            $cfLink = "<a href='{$this->project_dir}/siteA/mvn-run-out.html' target='_blank'>Maven Output</a><br/>\n";
        }
        $tSummaryAB = $this->testResultIndictator( $this->project_dir, $this->testABSummary,
                $this->app, 'siteAB' );
        return "<fieldset class='match {$this->signalClassAB}'>"
                . "<legend>Match</legend>\n"
                . "{$abMsgLink}"
                . "{$cfLink}"
                . "{$tSummaryAB}</br>\n"
                . "{$this->coverageAB}"
                . "</fieldset>";
    }

    /**
     * Render this badge.
     * @return string result
     */
    public function render(): string {
        if ( file_exists( $this->compilerErrorsFile ) ) {
            $compilerErrorsLink = "<a href='{$this->project_dir}/siteBB/compiler-error.html'>Compiler errors</a>";
            return "<div class='report broken'>\n"
                    . "<h3>G{$this->grp_name}</h3>\n"
                    . "<h4>API version {$this->apiVersionString}</h4>"
                    . "Revision: {$this->youngest}<br/>\n"
                    . "{$compilerErrorsLink}<br/>\n"
                    . "<span class='in' >in at {$this->last_commit}</span>\n"
                    . "<span class='chk' >chk {$this->checkTime}</span>\n"
                    . "</div>\n";
        }

        return "<div class='report {$this->signalClassBB}'>\n"
                . "<h3 class=''>G{$this->grp_name}</h3>\n"
                . "<h4>API version {$this->apiVersionString}</h4>"
                . "Revision: {$this->youngest}<br/>\n"
                . "{$this->abPanel}"
                . "<i>Qualifying :</i><br/>"
                . "{$this->msgLink}<br/>\n"
                . "{$this->testSummaryBB}<br/>\n"
                . "{$this->coverageBB}<br/>\n"
                . "<span class='in' >in at {$this->last_commit}</span>\n"
                . "<span class='chk' >chk {$this->checkTime}</span>\n"
                . "</div>\n";
    }

    /**
     * Render top link to BB run output.
     * if nowork done add stop
     * compiler-errors : link to mvn-run-out.html
     *   stop further processing
     * check bb tests:
     * link bbtestsummary to surefire-report.html
     * 
     * if all-pass (nr tests== nr passed) then
     *   link coverage report.
     * if coverage sufficient
     *   link ab tests summary to 
     * @param string $name
     * @return string
     */
    public function renderTinyNamed( string $name ): string {
        $completed = 'incomplete';
        $progressValue = $this->hoursDue;
        $completedAt = '';
        $hrsLeft='left';
        $title = "published {$this->pub}, hours left to deadline {$this->hoursDue} of {$this->hoursBudget}";
        if ( file_exists( "{$this->project_dir}/completed" ) ) {
            $completed = 'completed';
            $fh = fopen( "{$this->project_dir}/completed", 'r' );
            $completedAt = trim( fgets( $fh, 256 ) );

            fclose( $fh );
            $progressValue = abs( trim( `/home/rp/bin/hoursbetween "{$this->pub}" "{$completedAt}"` ) );
            $title = "completed at {$completedAt}, {$progressValue} hours after publication";
            $hrsLeft='used';
        }

        $fts = isSet( $this->lastChangedRevision[ 'Last_Changed_Date' ] ) ? $this->lastChangedRevision[ 'Last_Changed_Date' ] 
                : "date unknown";
        $lastAuthor = isSet( $this->lastChangedRevision[ 'Last_Changed_Author' ] ) ?
                $this->lastChangedRevision[ 'Last_Changed_Author' ] : "unknown";
        $due = "<h4>Due:{$this->due} (&nbsp;{$hrsLeft}:&nbsp;{$progressValue}h)</h4>\n"
                . "\t<progress class='{$completed}' max='{$this->hoursBudget}' value='{$progressValue}' title='{$title}'></progress>";
        $h4Title = "committed {$fts} by {$lastAuthor}";
        if ( isset( $this->lastChangedRevision[ 'Last_Changed_Rev' ] ) ) {
            $sname = "{$name}@{$this->lastChangedRevision[ 'Last_Changed_Rev' ]}";
        } else {
            $sname = $name . '@???';
        }


        $waitImages = array(
            "../images/buildbird.gif",
            "../images/cool-cat.gif",
        );

        $pendingFile = "{$this->project_dir}/build-pending";
        if ( file_exists( $pendingFile ) ) {
            $img = rand( 0, 1 );
            $pendingStart = date( "Y-m-d H:i:s", filemtime( $pendingFile ) );
            return "<div class='report pending'>\n"
                    . "<h4 title='{$h4Title}'>{$sname}</h4>\n"
                    . "$due\n"
                    . "<h5>Build is pending </h5>\n"
                    . "<img src='{$waitImages[ $img ]}' height='150px' alt-'pending'/><br/>"
                    . "since {$pendingStart}"
                    . "</div>\n";
        }
        
        
        if ( !$this->siteExists ) {
            return "<div class='report nowork'>\n"
                    . "<h4 title='{$h4Title}'>{$sname}</h4>\n"
                    . "$due\n"
                    . "<h5>No test Report found</h5>"
                    . "</div>\n";
        }

        if ( file_exists( $this->compilerErrorsFile ) ) {
            $compilerErrorsLink = "<a href='{$this->project_dir}/siteBB/mvn-run-out.html' >Compiler errors</a>";
            return "<div class='report broken'>\n"
                    . "<h4 title='{$h4Title}'>{$sname}</h4>\n"
                    . "$due\n"
                    . "{$compilerErrorsLink}<br/>\n"
                    . "</div>\n";
        }

        if ( $this->bbTests == 0 || !file_exists( "{$this->project_dir}/siteBB/testsummary.csv"
                ) || ( $this->bbTests - $this->bbIgnores ) == 0 ) {
            return "<div class='report notest'>\n"
                    . "<h4 style='color:#c00' title='{$h4Title}'>{$sname}</h4>\n"
                    . "$due\n"
                    . "<h5><a href='{$this->project_dir}/siteBB/mvn-run-out.html' title='Test might not have completed within 10 seconds."
                    . " Are you sure your tests run to completion?'>"
                    . "No test report found. Could be due to test timeout or having no tests"
                    . "</a></h5>"
                    . "</div>\n";
        }

        $siteLink = "{$this->project_dir}/siteBB/mvn-run-out.html";
        $furtherReports = '';
        $coverageLink = 'no coverage measured';
        if ( $this->bbTests == $this->bbPassed ) {

            $this->signalClassBB = 'passed';
            $jacocosummaryfile = "{$this->project_dir}/siteBB/jacoco/jacoco.csv";
            if ( file_exists( $jacocosummaryfile ) ) {
                $this->coveragePercentBB = $this->evalCoverageFile( $jacocosummaryfile );
                $coverageLink = $this->coverageIndicator( $this->coveragePercentBB,
                        "{$this->project_dir}/siteBB/jacoco/index.html", $this->jacoco_resources );
            }
            $furtherReports .= "{$coverageLink}<br/>";
            if ( file_exists( "{$this->project_dir}/siteAB/compiler-error.html" ) ) {
                $abTestLink = "<div class='tt ttcompiler'><a href= '{$this->project_dir}/siteAB/compiler-error.html'>"
                        . "Compiler Errors with teacherTests</a></div>";
                $furtherReports .= "<hr/>\n{$abTestLink}";
            } else
            if ( file_exists( "{$this->project_dir}/siteAB/testsummary.csv" ) ) {
                $furtherReports .= "<hr/>\n";
                $teacherTests = "<h5>Teacher Test reports</h5>\n";

                $this->testABSummary = self::testSummaryFromCSV( "{$this->project_dir}/siteAB/testsummary.csv" );
                $abTestLink = self::testResultIndictator( $this->project_dir, $this->testABSummary, $this->app, 'AB' );
                $teacherTests .= "{$abTestLink}<br/>";
                $jacocosummaryfile = "{$this->project_dir}/siteAB/jacoco/jacoco.csv";
                if ( file_exists( $jacocosummaryfile ) ) {
                    $this->coveragePercentAB = $this->evalCoverageFile( $jacocosummaryfile );
                    $coverageLink = $this->coverageIndicator( $this->coveragePercentAB,
                            "{$this->project_dir}/siteAB/jacoco/index.html", $this->jacoco_resources );
                    $teacherTests .= "{$coverageLink}<br/>";
                } else {
                    $teacherTests .= "Tests are failing, no coveragereport.<br/>\n";
                }
                $ttClass = 'tt' . $this->getSignalClass( $this->testABSummary, false );
                $furtherReports .= "\n<div class='tt {$ttClass}'>\n"
                        . "{$teacherTests}"
                        . "\n</div>\n";
            } else {
                $furtherReports .= "<hr/>\nBB Test coverage too low,<br/>no further reports<br/>\n";
            }
        } else {
            $furtherReports .= "Not all defined tests passed, no further reports<br/>\n";
        }
        $furtherReports .= $this->checkForStats();

        $huray = '';
        if ( $completed == 'completed' ) {
            $huray = "<div class='huray'>Completed</div>";
        }
        
        $testLink='';
        if (file_exists("{$this->project_dir}/siteBB/xref-test/index.html")){
            $testLink="&nbsp;<a href='{$this->project_dir}/siteBB/xref-test/index.html'>Tests</a>";
            
        }
        return "<div class='report {$this->signalClassBB}'>\n"
                . "{$huray}"
                . "\t<h4><a href='{$siteLink}' target='_blank' title='{$h4Title}'>{$sname}</a></h4>\n"
                . "\t{$due}\n"
                . "\t{$this->testSummaryBB}${testLink}<br/>\n"
                . "\t{$furtherReports}\n"
                . "</div>\n";
    }

    public function renderTiny(): string {
        return $this->renderTinyNamed( "{$this->grp_name}" );
    }

    public function __toString() {
        return "{$this->coveragePercentBB}";
    }

    /**
     * Reverse comparison.
     * @param type $a
     * @param type $b
     * @return type int
     */
    static function compareCoverageBB( AldaTestBadge $a, AldaTestBadge $b ) {
        $result = $b->coveragePercentBB - $a->coveragePercentBB;
        if ( $result > 0 ) {
            return 1;
        } else if ( $result < 1 ) {
            return -1;
        }
        // oldest wins
        return AldaTestBadge::compareOldest( $a, $b );
    }

    /**
     * Reverse comparison.
     * @param type $a
     * @param type $b
     * @return type int
     */
    static function comparePassedBB( AldaTestBadge $a, AldaTestBadge $b ) {
        $result = -($a->bbPassed - $b->bbPassed);
        if ( $result > 0 ) {
            return 1;
        } else if ( $result < 1 ) {
            return -1;
        }
        // oldest wins
        return AldaTestBadge::compareOldest( $a, $b );
    }

    static function compareOldest( AldaTestBadge $a, AldaTestBadge $b ) {
        // oldest wins
        if ( isset( $b->lastChangedRevision[ 'Last_Changed_Date' ] ) && isSet( $a->lastChangedRevision[ 'Last_Changed_Date' ] ) ) {
            $result = strcmp( $b->lastChangedRevision[ 'Last_Changed_Date' ],
                    $a->lastChangedRevision[ 'Last_Changed_Date' ] );
            if ( $result > 0 ) {
                return 1;
            } else if ( $result < 0 ) {
                return -1;
            } return 0;
        } else {
            return 0;
        }
    }

    public function checkForStats() {
        $fn = "{$this->project_dir}/siteAB/stats.html";
        if ( file_exists( $fn ) ) {
            return "<br/><a href='{$fn}' title='stats.html produced by tests'><img src='../images/stats_icon.png' alt='stats.html'/></a>";
        }
        return '';
    }

}
