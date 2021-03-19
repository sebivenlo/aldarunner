#!/usr/bin/perl -w
use strict;
use DBI;
use DBD::Pg;
use DBD::Pg qw(:pg_types);
use Config::Properties;

my ($grp,$snummer);
my $dbh= DBI->connect("dbi:Pg:dbname=peer");#);
my $properties = new Config::Properties();

if ( -f 'setup.properties') {
  open PROPS, "<setup.properties" or die qq(unable to open setup.properties file\n);
  $properties->load(*PROPS);
  close(PROPS);
} else {
    die qq(Cannot open required setup.properties file, bye)
}
my $tutors=$properties->getProperty('tutors','879417 877516');
my $prjm_id=$properties->getProperty('prjm_id','1011');
## unquote 
$tutors =~s/"//g;

my $query = "select coalesce(snummer::text,'') as snummer,grp_name from prj_tutor left join prj_grp using(prjtg_id) where prjm_id=${prjm_id} order by grp_name";
my $sth = $dbh->prepare($query);
my @users;
$sth->execute( );
while (my $row = $sth->fetchrow_arrayref) {
    ($snummer,$grp) =@$row;
    if ($snummer =~ m/^\d+$/) {
	push(@users, $snummer);
    }
    print qq(
cat <<EOF > ${grp}/.htaccess
## allow tutors, student assistent, and owning student (last)  access
AuthName "FontysVenlo private sites; USE PEERWEB AUTHENTICATION!"
Require user ${tutors} ${snummer}
EOF
);
}

# my $allusers = join(' ',@users);
# print qq(
# cat <<EOF > .htaccess
# ## allow tutors, student assistent, and owning student (last)  access
# AuthName "FontysVenlo private sites; USE PEERWEB AUTHENTICATION!"
# Require user ${tutors} ${allusers}
# EOF
#     );

