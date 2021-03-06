#------------------------------------------------------------------------
#----                        Widget::blastx                          ---- 
#------------------------------------------------------------------------
package Widget::blastx;
use strict;
use vars qw(@ISA @EXPORT $VERSION);
use Exporter;
use PostData;
use FileHandle;
use Widget;
@ISA = qw(
	Widget
       );

#------------------------------------------------------------------------------
#--------------------------------- METHODS ------------------------------------
#------------------------------------------------------------------------------
sub new {
        my $class  = shift;
        my @args   = @_;

        my $self = $class->SUPER::new(@args);

	bless ($self, $class);
        return $self;
}
#------------------------------------------------------------------------------
sub run {
	my $self    = shift;
	my $command = shift;

	if (defined($command)){
		$self->print_command($command);
		system("$command");
	}
	else {
		die "you must give Widget::blastx a command to run!\n";
	}
}
#-------------------------------------------------------------------------------
#------------------------------ FUNCTIONS --------------------------------------
#-------------------------------------------------------------------------------
sub parse {
        my $report = shift;
        my $params = shift;

        my $hitType = 'Bio::Search::Hit::PhatHit::blastx';
        my $hspType = 'Bio::Search::HSP::PhatHSP::blastx';

        my $sio = new Bio::SearchIO(-format => 'blast',
                                    -file   => $report,
                                   );

        my $hspFactory = new Bio::Search::HSP::HSPFactory(-type =>$hspType);
        my $hitFactory = new Bio::Search::Hit::HitFactory(-type =>$hitType);


        $sio->_eventHandler->register_factory('hsp', $hspFactory);
        $sio->_eventHandler->register_factory('hit', $hitFactory);

        return keepers($sio, $params);

}
#-------------------------------------------------------------------------------
sub keepers {
        my $sio    = shift;
	my $params = shift; 


        my $result = $sio->next_result();

        my @keepers;
        my $start = $result->hits();
        while(my $hit = $result->next_hit) {
                my $significance = $hit->significance();
                $significance = "1".$significance if  $significance =~ /^e/;
                $hit->queryLength($result->query_length);
                $hit->queryName($result->query_name);
                next unless $significance < $params->{significance};
                my @hsps;
                while(my $hsp = $hit->next_hsp) {
                        $hsp->query_name($result->query_name);

                        push(@hsps, $hsp) if $hsp->bits > $params->{hsp_bit_min};
                }
                $hit->hsps(\@hsps);
                push(@keepers, $hit) if $hit->hsps();
        }
        my $end     = @keepers;
        my $deleted = $start - $end;
        print STDERR "deleted:$deleted hits\n";

        return \@keepers;
}
#-----------------------------------------------------------------------------
sub AUTOLOAD {
        my ($self, $arg) = @_;

        my $caller = caller();
        use vars qw($AUTOLOAD);
        my ($call) = $AUTOLOAD =~/.*\:\:(\w+)$/;
        $call =~/DESTROY/ && return;

        print STDERR "Widget::blastx::AutoLoader called for: ",
              "\$self->$call","()\n";
        print STDERR "call to AutoLoader issued from: ", $caller, "\n";

        if (defined($arg)){
                $self->{$call} = $arg;
        }
        else {
                return $self->{$call};
        }
}
#------------------------------------------------------------------------

1;


