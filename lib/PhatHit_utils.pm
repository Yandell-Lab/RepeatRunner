#------------------------------------------------------------------------
#----                          PhatHit_utils                         ---- 
#------------------------------------------------------------------------
package PhatHit_utils;
use strict;
use vars qw(@ISA @EXPORT $VERSION);
use Exporter;
use PostData;
use FileHandle;
use PostData;
use Exporter;
@ISA = qw(
       );
#------------------------------------------------------------------------
#--------------------------- CLASS FUNCTIONS ----------------------------
#------------------------------------------------------------------------
sub sort_hits {
	my $hit  = shift;
	my $what = shift;

        my $sorted;
        if    ($hit->strand($what) == 1) {
                $sorted = $hit->sortFeatures($what);
        }
        elsif ($hit->strand($what) == -1 ){
                $sorted = $hit->revSortFeatures($what);
        }     
        else {
                print "not yet supported in PhatHit_utils::sort_hits\n";
                die;
        }

	return $sorted;
}
#------------------------------------------------------------------------
sub sort_hsps_by_score {
	my $hit = shift;
	
	my @hsps;
	foreach my $hsp ($hit->hsps){
		push(@hsps, $hsp);
	}
	my @sorted = sort {$b->score() <=> $a->score()} @hsps;
	return \@sorted;

}
#------------------------------------------------------------------------
sub to_begin_and_end_coors {
	my $hits = shift;
	my $what = shift;
	my @coors;
	foreach my $hit (@{$hits}){
		push(@coors, [get_span_of_hit($hit, $what)]);
	}
	return \@coors;
}
#------------------------------------------------------------------------
sub get_span_of_hit {
	my $hit  = shift;
	my $what = shift;
	my $sorted;
	if    ($hit->strand($what) == 1) {
		$sorted = $hit->sortFeatures($what);
	}
	elsif ($hit->strand($what) == -1 ){
		$sorted = $hit->revSortFeatures($what);
	}	
	else {
		print "not yet supported in PhatHit_utils::get_span_of_hit\n";
		die;
	}
	my $alpha = $sorted->[0];
	my $omega = $sorted->[-1];

	return ($alpha->start('query'), $omega->end('query'));
}
#------------------------------------------------------------------------
sub add_offset {
	my $lil_fish = shift;
	my $offset   = shift;

	foreach my $f (@{$lil_fish}){
		foreach my $hsp ($f->hsps){
			my $new_start = $offset + $hsp->start('query');
			my $new_end   = $offset + $hsp->end('query');

			$hsp->query->location->start($new_start);
			$hsp->query->location->end($new_end);
			$hsp->{'_sequenceschanged'} = 1;
		}
		$f->{'_sequenceschanged'} = 1;
	} 

}
#------------------------------------------------------------------------
sub reset_query_lengths {
	my $features       = shift;
        my $query_length   = shift;

        foreach my $f (@{$features}){
		$f->queryLength($query_length);
                $f->{'_sequenceschanged'} = 1;
        }

}
#------------------------------------------------------------------------
sub merge_hits {
        my $big_fish = shift;
        my $lil_fish = shift;
        my $max_sep  = shift;


	
        return unless @{$lil_fish};

        unless (@{$big_fish}){
                @{$big_fish} = @{$lil_fish};
                return;
        }

	print STDERR "merging blast reports...\n";
	my %merged_hits;
        my @merged;
        foreach my $b_hit (@{$big_fish}){
                my $b_start = $b_hit->nB('query');
                my $b_end   = $b_hit->nE('query');

                ($b_start, $b_end) = ($b_end, $b_start)
                if $b_start > $b_end;

                my @new_b_hsps;
                foreach my $b_hsp ($b_hit->hsps) {
                        push(@new_b_hsps, $b_hsp);
                }
                foreach my $l_hit (@{$lil_fish}){

			next unless $b_hit->hsp(0)->hit->seq_id eq $l_hit->hsp(0)->hit->seq_id;

                        my @new_l_hsps;

                        my $l_start = $l_hit->nB('query');
                        my $l_end   = $l_hit->nE('query');

                        ($l_start, $l_end) = ($l_end, $l_start)
                        if $l_start > $l_end;

                        print STDERR "b_start:$b_start l_start:$l_start\n";
                        print STDERR "b_end:$b_end l_end:$l_end\n";
                        my $distance =
                        $b_start <= $l_start ? $l_start - $b_end : $b_start - $l_end;

			print STDERR "distance:$distance\n";

			next unless $distance < $max_sep;

			$merged_hits{$l_hit->description.$l_start} = $distance;

			print STDERR "adding new hsp to ".$b_hit->name." ".$b_hit->description."\n";
                        foreach my $l_hsp ($l_hit->hsps){
                        	push(@new_b_hsps, $l_hsp);
			}
                }
                $b_hit->hsps(\@new_b_hsps);
		$b_hit->{'_sequenceschanged'} = 1;
                push(@merged, $b_hit)
        }

	foreach my $l_hit (@{$lil_fish}){
		my $l_start = $l_hit->nB('query');
                my $l_end   = $l_hit->nE('query');

                ($l_start, $l_end) = ($l_end, $l_start)
                if $l_start > $l_end;

		my $distance = $merged_hits{$l_hit->description.$l_start};

		my $name = $l_hit->description;

		next if defined($distance);

		push(@merged, $l_hit);

	}
	print STDERR "...finished\n";
        @{$big_fish} = @merged;
}
#------------------------------------------------------------------------
#--------------------------- FUNCTIONS ----------------------------------
#------------------------------------------------------------------------
sub AUTOLOAD {
        my ($self, $arg) = @_;

        my $caller = caller();
        use vars qw($AUTOLOAD);
        my ($call) = $AUTOLOAD =~/.*\:\:(\w+)$/;
        $call =~/DESTROY/ && return;

        print STDERR "PhatHit::AutoLoader called for: ",
              "\$self->$call","()\n";
        print STDERR "call to AutoLoader issued from: ", $caller, "\n";

        if ($arg){
                $self->{$call} = $arg;
        }
        else {
                return $self->{$call};
        }
}
#------------------------------------------------------------------------
1;


