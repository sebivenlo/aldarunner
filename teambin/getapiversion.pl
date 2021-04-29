#!/usr/bin/perl -w
use XML::XPath;
use XML::XPath::XMLParser;
if ($#ARGV  <0 ){
    print STDERR qq(Usage: getapiversion.pl <pomfile> <artifactidentifier> [<defaultversion>]
    like 
       getapiversion.pl week6/pom.xml  nl.fontys:api
    or
       getapiversion.pl week6/pom.xml  nl.fontys:api v0.1
);
    exit 1;
}
my $pomfile=$ARGV[0];
my $mvnCoord=$ARGV[1];
my $defaultVersion='0.0';
if ($#ARGV > 1) {
    $defaultVersion=$ARGV[2];
}

my $xp = XML::XPath->new(filename => "$pomfile");

my $nodeset = $xp->find('//dependency'); # find all paragraphs
my ($groupId,$arrifactId,$version);
foreach my $node ($nodeset->get_nodelist) {
  $groupId = $node->findvalue('./groupId');
  $groupId =~ s/^\s+//g;
  $groupId =~ s/\s+$//g;
  $artifactId = $node->findvalue('./artifactId');
  $artifactId =~ s/^\s+?(.*)?\s+$/$1/g;
  $version = $node->findvalue('./version');

  $version =~ s/^\s+?(.*)?\s+$/$1/g;
#   print STDERR qq([$groupId]\n
# [$artifactId]\n
# [$version]
# );
#  print qq(pre [$version]);
#  print qq(post [$version]);
  
  # print "FOUND \n\n",
  #     XML::XPath::XMLParser::as_string($node),
  #     "\n\n";
  # print "found ${groupId}:${artifactId}:${version}\n";
  if ($mvnCoord eq "${groupId}:${artifactId}") {
    print qq($version);
    exit(0);
  }
}
print qq(${defaultVersion});
