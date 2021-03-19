<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function currentApps( string $csvFile, &$totalTestCount ): string {
    $currentApps = '';
    if ( file_exists( $csvFile ) ) {
        $fn = fopen( $csvFile, 'r' );
        while ( $line = fgets( $fn ) ) {
            if ( substr( $line, 0, 1 ) == '#' ) {
                continue;
            }
            $parts = preg_split( '/,/', trim( $line ) );
            if ( count( $parts ) >= 3 ) {
                $totalTestCount += $parts[ 2 ];
                $currentApps .= "<tr><td>{$parts[ 0 ]}</td><td>{$parts[ 8 ]}</td><td>{$parts[ 9 ]}</td><td>{$parts[ 7 ]}%</td><td>{$parts[ 2 ]}</td></tr>\n";
            }
        }
        $currentApps .= "<tr><td colspan='4' style='text-align:right'>Total number of teacher tests</td><td class='total'>{$totalTestCount}</td></tr>\n";
        fclose( $fn );
        return $currentApps;
    }
}
