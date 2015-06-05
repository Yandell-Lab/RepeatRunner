=head1 NAME

XML::Out - A simple XML dumper.

=head1 SYNOPSIS

 use Out;
 
 # an HTML example that my be more familiar
 $body = xml(
 	TAGNAME => 'BODY'
	ATTLIST => {'BGCOLOR' => 'FFFFFF'}
	ELEMENT => ['This is the body of the text.', 'Some more text.']);

 # a simple piece of XML
 $foo = xml(
 	TAGNAME => 'something',
	ATTLIST => {'cat => 'meow', 'dog' => 'woof'},
	ELEMENT => ['Hello World', 'My dog has fleas']);

 print "$foo\n";

 # note, bar contains foo as one of its elements
 $bar = xml(
 	TAGNAME => 'something_else',
	ELEMENT => [$foo, 'some text']);

 print "$bar\n";

=head1 DESCRIPTION

XML::Out is a very simple XML generator. The module exports a function called
xml() into the calling program. The xml function is actually a constructor that
takes an anonymous HASH as an argument (see synopsis above). Note, there is
only one object method provided at this time, which is implicitly called via
overloading the double quote operator.

=head1 AUTHOR

Ian Korf (ikorf@sapiens.wustl.edu, http://sapiens.wustl.edu/~ikorf)

=head1 ACKNOWLEDGEMENTS

This software was developed at the Genome Sequencing Center at Washington
Univeristy, St. Louis, MO.

=head1 COPYRIGHT

Copyright (C) 1999 Ian Korf. All Rights Reserved.

=head1 DISCLAIMER

This software is provided "as is" without warranty of any kind, including the
idea that it may even be useful for its intended purpose or worthy of the
/dev/null bit-bucket. Use this software at your own risk.

=cut

package XML::Out;
require Exporter;
use strict;
use overload '""' => 'out';
use vars qw(@ISA $VERSION @EXPORT);
$VERSION = "0.03";
@ISA = qw(Exporter);
@EXPORT = qw(xml); # exports browse name into caller's namespace

sub xml {
	my (%p) = @_;
	my $this = bless {};
	while ( my ($key, $val) = each %p) {
		if ($key ne 'ATTLIST' and $key ne 'ELEMENT' and $key ne 'TAGNAME') {
			print STDERR "$key illegal: must be TAGNAME, ELEMENT, or ATTLIST\n";
		}
		
	}
	$this->{TAGNAME} = $p{TAGNAME};
	$this->{ATTLIST} = $p{ATTLIST};
	$this->{ELEMENT} = $p{ELEMENT};
	return $this;
}

sub out {
	my ($this, $level) = @_;
	$level = 0 unless defined $level;
	my $tab = "\t" x $level;
	my @stream_array = ();
	push @stream_array, "$tab<$this->{TAGNAME}";
	while ( my ($attr, $val) = each %{ $this->{ATTLIST} }) {
		if (defined($val)) {
			push @stream_array, " $attr=\"", $val, "\"";
		}
	}
	my $ELEMref = $this->{ELEMENT};
	if (defined @$ELEMref ){
	        push @stream_array, ">\n";
	}
	else {
		push @stream_array, ">";
	}
        foreach my $elem (@$ELEMref) {
		if (defined($elem)) {
			if (ref $elem eq 'XML::Out') {
				push @stream_array, $elem->out($level + 1),
				                    "\n";
			}
			else {
			    #J. Wang added on May 31, 2001
			    $elem =~ s/&/&amp;/g;
			    $elem =~ s/</&lt;/g;
			    $elem =~ s/>/&gt;/g;

 			    push @stream_array, "$tab\t$elem\n";
			    
			}
		}
	}
	if(defined @$ELEMref ){
		push @stream_array, "$tab</$this->{TAGNAME}>";
	}
	else{
		push @stream_array, "</$this->{TAGNAME}>";
	}
	# The final return item should be a string containing the
	# concatenation of all the items on the stream_array.
	return join('', @stream_array);
}


1;
