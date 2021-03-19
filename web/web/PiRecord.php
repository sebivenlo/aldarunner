<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

function tsSummary( int $totalTestCount, string $csvFileName ): array {

    $tsummary = array( 0, 0, 0, 0, 0 );
    if ( file_exists( "{$csvFileName}" ) ) {
        $fn = fopen( $csvFileName, 'r' );
        fgets( $fn );
        $line = fgets( $fn ); // need second line
        $tsummary = preg_split( '/,/', trim( $line ) );
        fclose( $fn );
    }
    $todo = $totalTestCount;
    for ( $i = 1; $i < 5; $i++ ) {
        $todo -= $tsummary[ $i ];
    }
    return $tsummary;
}

function processPiRecord( $rs, $index, $testCount = 100 ): string {
    extract( $rs->fields );
    GLOBAL $teachers;
    $grp_name = sprintf( "g%03d", $grp_num );
    $extra_class = "";
    if ( $today_fresh == 't' ) {
        $extra_class = 'fresh-today';
    }
    if ( is_dir( $grp_name ) ) {

        $tsummary = tsSummary( $grp_name );
        $name = '';
        $lname = '';
        if ( in_array( $_SERVER[ 'REMOTE_USER' ], $teachers ) ) {
            $lname = "{$roepnaam} {$tussenvoegsel} {$achternaam}";
            $name = substr( $roepnaam, 0, 1 ) . substr( $achternaam, 0, 1 );
        }
//        $todo = max( [ 0, $todo ] );
        //$gcol=substr($grp_name,1);
        $index .= <<<"END"
        <a class='button {$extra_class}' href='{$grp_name}'
            target='empty'
                title='{$lname} Teacher tests summary, tests={$testCount}, passed={$tsummary[ 1 ]}, failed= {$tsummary[ 2 ]}, errors={$tsummary[ 3 ]}, 
                    ignored={$tsummary[ 4 ]} todo={$todo}'>
            <span class='grp'>{$name}</span><br/>
          <span class='pie' data-pie='#0D0 {$tsummary[ 1 ]}, #ff0 {$tsummary[ 2 ]}, #f00 {$tsummary[ 3 ]}, #888 {$tsummary[ 4 ]}, #606 {$todo}'></span>
          <span class='grp'>{$grp_name}</span>
       </a>
END;
    }
    return $index;
}
