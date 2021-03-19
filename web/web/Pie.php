<?php

/**
 * Description of Pie
 *
 * @author Pieter van den Hombergh {@code p.vandenhombergh@fontys.nl}
 */
class Pie {

    //put your code here
    public $keys;
    public $colors;
    public $sliceCount = 3;
    public string $indent = '   ';

    function __construct( array $keys, array $colors ) {
        $this->keys = $keys;
        $this->colors = $colors;
        if ( count( $colors ) < count( $keys ) ) {
            throw new Exception( "count of keys and colors does not match" );
        }
    }

    function render( array $values, string $titleStart = '' ): string {
        $title = [];
        $data_pie = [];
        for ( $i = 0; $i < count( $this->keys ); $i++ ) {
            $data_pie[] = "{$this->colors[ $i ]} {$values[ $i ]}";
            $title[] = "{$this->keys[ $i ]}: {$values[ $i ]} ";
        }
        $d = implode( ', ', $data_pie );
        $titleD = implode( ', ', $title );
        return "{$this->indent}<span class='pie' title='{$titleStart} {$titleD}'\n"
                . "{$this->indent}\t\tdata-pie='{$d}'>\n{$this->indent}</span>";
    }
    

    /**
     *  Reads csv file as tsSummary. 
     * @param string $filename to read
     * @param int $expectedTotal todo
     * @return array the values
     */
    function tsSummary( string $csvFileName, int $expectedTotal ): array {


        $tsummary = array_fill( 0, $this->sliceCount, 0 );

        if ( file_exists( "{$csvFileName}" ) ) {
            $fn = fopen( $csvFileName, 'r' );

            fgets( $fn );
            $line = fgets( $fn ); // need second line
            $tsummary = preg_split( '/,/', trim( $line ) );
            fclose( $fn );
        }
        $todo = $expectedTotal;
        for ( $i = 1; $i < $this->sliceCount-1; $i++ ) {
            $todo -= $tsummary[ $i ];
        }

        $tsummary[ $this->sliceCount - 1 ] = $todo;
        return $tsummary;
    }

    function renderCsvFile( string $csvFileName, int $expectedTotal, string $titleStart = '' ) {
        return $this->render( $this->tsSummary( $csvFileName, $expectedTotal ), $titleStart );
    }

    public function sliceCount( $c ): Pie {
        $this->sliceCount = $c;
        return $this;
    }

}
