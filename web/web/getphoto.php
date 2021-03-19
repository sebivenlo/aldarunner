<?php

require_once 'grpindexconfig.php';

$foto = filter_var( $_REQUEST[ 's' ], FILTER_SANITIZE_NUMBER_INT );
$user = filter_var( $_SERVER[ 'REMOTE_USER' ], FILTER_SANITIZE_NUMBER_INT );
$fotodir = "/home/f/fontysvenlo.org/peerfotos/fotos/";

if ( in_array( $user, $teachers ) ) {
    $fname = "{$fotodir}/{$foto}.jpg"; //.allowedPhoto($peer_id,$foto);
} else {
    $fname = "{$fotodir}/0.jpg"; //.allowedPhoto($peer_id,$foto);
}

$fp = @fopen( $fname, 'r' );
//echo $fname;
//exit(0);
// send the right headers
header( "Content-type: image/jpeg" );
header( "Pragma: public" );
header( "Cache-Control: must-revalidate, post-check=0, pre-check=0" );
header( "Content-Length: " . filesize( $fname ) );
header( "Content-Disposition: inline; filename=\"{$foto}.jpg\"" );

// dump the picture and stop the script
fpassthru( $fp );
fclose( $fp );
exit( 0 );
