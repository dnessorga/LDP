#!/usr/bin/perl

use CGI qw(:standard);
use Pg;
use Date::Calc qw(:all);

$dbmain='ldp';
$conn=Pg::connectdb("dbname=$dbmain");

$today = `date -I`;

# delete prior run for today if one exists
$sql = "DELETE FROM stats WHERE date_entered = '$today'";
$result=$conn->exec($sql);

# doc_cnt
$sql = "select count(*) from document";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt = $row[0];

# doc_cnt_R
$sql = "select count(*) from document where pub_status = 'R'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_R = $row[0];

# doc_cnt_O
$sql = "select count(*) from document where pub_status = 'O'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_O = $row[0];

# doc_cnt_P
$sql = "select count(*) from document where pub_status = 'P'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_P = $row[0];

# doc_cnt_W
$sql = "select count(*) from document where pub_status = 'W'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_W = $row[0];

# doc_cnt_Q (?)
$sql = "select count(*) from document where pub_status = 'Q'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_Q = $row[0];

# doc_cnt_D
$sql = "select count(*) from document where pub_status = 'D'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_D = $row[0];

# doc_cnt_A
$sql = "select count(*) from document where pub_status = 'A'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_A = $row[0];

# doc_cnt_N
$sql = "select count(*) from document where pub_status = 'N'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_N = $row[0];

# doc_cnt_U
$sql = "select count(*) from document where pub_status = 'U'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
@row = $result->fetchrow;
$doc_cnt_U = $row[0];

$msg .= "$today\n\n";

$msg .= "Status\n";
$msg .= "R: $doc_cnt_R\n";
$msg .= "O: $doc_cnt_O\n";
$msg .= "P: $doc_cnt_P\n";
$msg .= "W: $doc_cnt_W\n";
$msg .= "?: $doc_cnt_Q\n";
$msg .= "D: $doc_cnt_D\n";
$msg .= "A: $doc_cnt_A\n";
$msg .= "N: $doc_cnt_N\n";
$msg .= "U: $doc_cnt_U\n\n";


# age_avg, age_max
$sql = "select last_update from document where pub_status='N'";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;

$count   = 0;
$age_avg = 0;
$age_max = 0;
($year2, $month2, $day2) = Today();
while (@row = $result->fetchrow) {

  $last_update = $row[0];
  if (($last_update != "") && ($last_update != "1970-01-01" )) {
    $year1 = substr($last_update,0,4);
    $month1 = substr($last_update,5,2);
    $day1 = substr($last_update,8,2);
    $age = Delta_Days($year1, $month1, $day1, $year2, $month2, $day2);
    if ( $count > 0 ) {
      $age_avg = (($age_avg * ($count - 1)) + $age) / $count;
    }
    else {
      $age_avg = $age;
    }
    if ( $age_max < $age ) { $age_max = $age }

    $count++;
  }
}
$age_avg = int($age_avg + .5);
$msg .= "Age\n";
$msg .= "age_avg: $age_avg\n";
$msg .= "age_max: $age_max\n\n";



$class_HOWTO = $class_MINI = $class_FAQ = $class_TEMPLATE = $class_QUICK = $class_GUIDE = $class_BACKGROUNDER = 0;
$sql = "select class, count(*) from document where pub_status = 'N' group by class";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
while (@row = $result->fetchrow) {
  $class = $row[0];
  $class =~ s/\s+$//;
  $count = $row[1];
  if ( $class eq "HOWTO" ) { $class_HOWTO = $count }
  if ( $class eq "MINI" ) { $class_MINI = $count }
  if ( $class eq "FAQ" ) { $class_FAQ = $count }
  if ( $class eq "TEMPLATE" ) { $class_TEMPLATE = $count }
  if ( $class eq "QUICK" ) { $class_QUICK = $count }
  if ( $class eq "GUIDE" ) { $class_GUIDE = $count }
  if ( $class eq "BACKGROUNDER" ) { $class_BACKGROUNDER = $count }
}

$msg .= "Class\n";
$msg .= "HOWTO: $class_HOWTO\n";
$msg .= "MINI: $class_MINI\n";
$msg .= "FAQ: $class_FAQ\n";
$msg .= "TEMPLATE: $class_TEMPLATE\n";
$msg .= "QUICK: $class_QUICK\n";
$msg .= "GUIDE: $class_GUIDE\n";
$msg .= "BACKGROUNDER: $class_BACKGROUNDER\n\n";



$license_GFDL = $license_GPL = $license_LDPL = $license_NONE = $license_OPL = $license_OTHER = $license_PD = $license_ = 0;
$sql = "select license, count(*) FROM document where pub_status = 'N' group by license";
$result=$conn->exec($sql);
die $conn->errorMessage unless PGRES_TUPLES_OK eq $result->resultStatus;
while (@row = $result->fetchrow) {
  $license = $row[0];
  $license =~ s/\s+$//;
  $count   = $row[1];
  
  if ( $license eq "GFDL" || $license eq "GPL" || $license eq "OPL" ) {
    $license_FREE += $count;
  }
  elsif ( $license eq "" ) {
    $license_UNKNOWN += $count;
  }
  else {
    $license_NONFREE += $count;
  }
 
  if ( $license eq "GFDL" ) { $license_GFDL = $count; $count = 0 }
  if ( $license eq "GPL" ) { $license_GPL = $count; $count = 0 }
  if ( $license eq "LDPL" ) { $license_LDPL = $count; $count = 0 }
  if ( $license eq "NONE" ) { $license_NONE = $count; $count = 0 }
  if ( $license eq "OPL" ) { $license_OPL = $count; $count = 0 }
  if ( $license eq "OTHER" ) { $license_OTHER = $count; $count = 0 }
  if ( $license eq "PD" ) { $license_PD = $count; $count = 0 }
  $license_ += $count;
}
$license_free_pct = sprintf( '%3.2f', $license_FREE / $doc_cnt_N * 100 );
$license_nonfree_pct = sprintf( '%3.2f', $license_NONFREE / $doc_cnt_N * 100 );
$license_unknown_pct = sprintf( '%3.2f', $license_UNKNWON / $doc_cnt_N * 100 );

$msg .= "Licenses\n";
$msg .= "GFDL: $license_GFDL\n";
$msg .= "GPL: $license_GPL\n";
$msg .= "LDPL: $license_LDPL\n";
$msg .= "NONE: $license_NONE\n";
$msg .= "OPL: $license_OPL\n";
$msg .= "OTHER: $license_OTHER\n";
$msg .= "PD: $license_PD\n";
$msg .= "(blank): $license_\n\n";

$msg .= "Free/Non-Free\n";
$msg .= "Free: $license_FREE\n";
$msg .= "Nonfree: $license_NONFREE\n";
$msg .= "Unknown: $license_UNKNOWN\n\n";




$sql =  "INSERT INTO stats( date_entered,  doc_cnt,  doc_cnt_R,  doc_cnt_O,  doc_cnt_P,  doc_cnt_W,  doc_cnt_Q,  doc_cnt_D,  doc_cnt_A,  doc_cnt_N,  doc_cnt_U,  age_avg,  age_max,  class_HOWTO,  class_MINI,  class_FAQ,  class_TEMPLATE,  class_QUICK,  class_GUIDE,  class_BACKGROUNDER,  license_GFDL,  license_GPL,  license_LDPL,  license_NONE,  license_OPL,  license_OTHER,  license_PD,  license_,  license_FREE,  license_NONFREE,  license_UNKNOWN) ";
$sql .=           "VALUES ('$today', $doc_cnt, $doc_cnt_R, $doc_cnt_O, $doc_cnt_P, $doc_cnt_W, $doc_cnt_Q, $doc_cnt_D, $doc_cnt_A, $doc_cnt_N, $doc_cnt_U, $age_avg, $age_max, $class_HOWTO, $class_MINI, $class_FAQ, $class_TEMPLATE, $class_QUICK, $class_GUIDE, $class_BACKGROUNDER, $license_GFDL, $license_GPL, $license_LDPL, $license_NONE, $license_OPL, $license_OTHER, $license_PD, $license_, $license_FREE, $license_NONFREE, $license_UNKNOWN)";
$result=$conn->exec($sql);

$msg .= "$sql\n\n";

print $msg;

$sql = "DELETE FROM stats_CDF WHERE date_entered='$today'";
$result=$conn->exec($sql);

$sql = "INSERT INTO stats_CDF (date_entered, class, dtd, format, doc_cnt_CDF) select '$today', class, dtd, format, count(*) from document where pub_status = 'N' group by class, dtd, format";
$result=$conn->exec($sql);

