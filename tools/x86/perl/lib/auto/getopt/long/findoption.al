# NOTE: Derived from blib/lib/Getopt/Long.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Getopt::Long;

#line 662 "blib/lib/Getopt/Long.pm (autosplit into blib/lib/auto/Getopt/Long/FindOption.al)"
# Option lookup.
sub FindOption ($$$$$$$) {

    # returns (1, $opt, $arg, $dsttype, $incr, $key) if okay,
    # returns (0) otherwise.

    my ($prefix, $argend, $opt, $opctl, $bopctl, $names, $aliases) = @_;
    my $key;			# hash key for a hash option
    my $arg;

    print STDERR ("=> find \"$opt\", prefix=\"$prefix\"\n") if $debug;

    return 0 unless $opt =~ /^$prefix(.*)$/s;
    return 0 if $opt eq "-" && !defined $opctl->{""};

    $opt = $+;
    my ($starter) = $1;

    print STDERR ("=> split \"$starter\"+\"$opt\"\n") if $debug;

    my $optarg = undef;	# value supplied with --opt=value
    my $rest = undef;	# remainder from unbundling

    # If it is a long option, it may include the value.
    # With getopt_compat, not if bundling.
    if ( ($starter eq "--" 
          || ($getopt_compat && ($bundling == 0 || $bundling == 2)))
	  && $opt =~ /^([^=]+)=(.*)$/s ) {
	$opt = $1;
	$optarg = $2;
	print STDERR ("=> option \"", $opt,
		      "\", optarg = \"$optarg\"\n") if $debug;
    }

    #### Look it up ###

    my $tryopt = $opt;		# option to try
    my $optbl = $opctl;		# table to look it up (long names)
    my $type;
    my $dsttype = '';
    my $incr = 0;

    if ( $bundling && $starter eq '-' ) {
	# Unbundle single letter option.
	$rest = length ($tryopt) > 0 ? substr ($tryopt, 1) : "";
	$tryopt = substr ($tryopt, 0, 1);
	$tryopt = lc ($tryopt) if $ignorecase > 1;
	print STDERR ("=> $starter$tryopt unbundled from ",
		      "$starter$tryopt$rest\n") if $debug;
	$rest = undef unless $rest ne '';
	$optbl = $bopctl;	# look it up in the short names table

	# If bundling == 2, long options can override bundles.
	if ( $bundling == 2 and
	     defined ($rest) and
	     defined ($type = $opctl->{$tryopt.$rest}) ) {
	    print STDERR ("=> $starter$tryopt rebundled to ",
			  "$starter$tryopt$rest\n") if $debug;
	    $tryopt .= $rest;
	    undef $rest;
	}
    }

    # Try auto-abbreviation.
    elsif ( $autoabbrev ) {
	# Downcase if allowed.
	$tryopt = $opt = lc ($opt) if $ignorecase;
	# Turn option name into pattern.
	my $pat = quotemeta ($opt);
	# Look up in option names.
	my @hits = grep (/^$pat/, @{$names});
	print STDERR ("=> ", scalar(@hits), " hits (@hits) with \"$pat\" ",
		      "out of ", scalar(@{$names}), "\n") if $debug;

	# Check for ambiguous results.
	unless ( (@hits <= 1) || (grep ($_ eq $opt, @hits) == 1) ) {
	    # See if all matches are for the same option.
	    my %hit;
	    foreach ( @hits ) {
		$_ = $aliases->{$_} if defined $aliases->{$_};
		$hit{$_} = 1;
	    }
	    # Now see if it really is ambiguous.
	    unless ( keys(%hit) == 1 ) {
		return (0) if $passthrough;
		warn ("Option ", $opt, " is ambiguous (",
		      join(", ", @hits), ")\n");
		$error++;
		undef $opt;
		return (1, $opt,$arg,$dsttype,$incr,$key);
	    }
	    @hits = keys(%hit);
	}

	# Complete the option name, if appropriate.
	if ( @hits == 1 && $hits[0] ne $opt ) {
	    $tryopt = $hits[0];
	    $tryopt = lc ($tryopt) if $ignorecase;
	    print STDERR ("=> option \"$opt\" -> \"$tryopt\"\n")
		if $debug;
	}
    }

    # Map to all lowercase if ignoring case.
    elsif ( $ignorecase ) {
	$tryopt = lc ($opt);
    }

    # Check validity by fetching the info.
    $type = $optbl->{$tryopt} unless defined $type;
    unless  ( defined $type ) {
	return (0) if $passthrough;
	warn ("Unknown option: ", $opt, "\n");
	$error++;
	return (1, $opt,$arg,$dsttype,$incr,$key);
    }
    # Apparently valid.
    $opt = $tryopt;
    print STDERR ("=> found \"$type\" for \"", $opt, "\"\n") if $debug;

    #### Determine argument status ####

    # If it is an option w/o argument, we're almost finished with it.
    if ( $type eq '' || $type eq '!' || $type eq '+' ) {
	if ( defined $optarg ) {
	    return (0) if $passthrough;
	    warn ("Option ", $opt, " does not take an argument\n");
	    $error++;
	    undef $opt;
	}
	elsif ( $type eq '' || $type eq '+' ) {
	    $arg = 1;		# supply explicit value
	    $incr = $type eq '+';
	}
	else {
	    substr ($opt, 0, 2) = ''; # strip NO prefix
	    $arg = 0;		# supply explicit value
	}
	unshift (@ARGV, $starter.$rest) if defined $rest;
	return (1, $opt,$arg,$dsttype,$incr,$key);
    }

    # Get mandatory status and type info.
    my $mand;
    ($mand, $type, $dsttype, $key) = $type =~ /^(.)(.)([@%]?)$/;

    # Check if there is an option argument available.
    if ( $gnu_compat ) {
	return (1, $opt, $optarg, $dsttype, $incr, $key)
	  if defined $optarg;
	return (1, $opt, $type eq "s" ? '' : 0, $dsttype, $incr, $key)
	  if $mand eq ':';
    }

    # Check if there is an option argument available.
    if ( defined $optarg
	 ? ($optarg eq '')
	 : !(defined $rest || @ARGV > 0) ) {
	# Complain if this option needs an argument.
	if ( $mand eq "=" ) {
	    return (0) if $passthrough;
	    warn ("Option ", $opt, " requires an argument\n");
	    $error++;
	    undef $opt;
	}
	return (1, $opt, $type eq "s" ? '' : 0, $dsttype, $incr, $key);
    }

    # Get (possibly optional) argument.
    $arg = (defined $rest ? $rest
	    : (defined $optarg ? $optarg : shift (@ARGV)));

    # Get key if this is a "name=value" pair for a hash option.
    $key = undef;
    if ($dsttype eq '%' && defined $arg) {
	($key, $arg) = ($arg =~ /^([^=]*)=(.*)$/s) ? ($1, $2) : ($arg, 1);
    }

    #### Check if the argument is valid for this option ####

    if ( $type eq "s" ) {	# string
	# A mandatory string takes anything.
	return (1, $opt,$arg,$dsttype,$incr,$key) if $mand eq "=";

	# An optional string takes almost anything.
	return (1, $opt,$arg,$dsttype,$incr,$key)
	  if defined $optarg || defined $rest;
	return (1, $opt,$arg,$dsttype,$incr,$key) if $arg eq "-"; # ??

	# Check for option or option list terminator.
	if ($arg eq $argend ||
	    $arg =~ /^$prefix.+/) {
	    # Push back.
	    unshift (@ARGV, $arg);
	    # Supply empty value.
	    $arg = '';
	}
    }

    elsif ( $type eq "n" || $type eq "i" # numeric/integer
	    || $type eq "o" ) { # dec/oct/hex/bin value

	my $o_valid =
	  $type eq "o" ? "[-+]?[1-9][0-9]*|0x[0-9a-f]+|0b[01]+|0[0-7]*"
	    : "[-+]?[0-9]+";

	if ( $bundling && defined $rest && $rest =~ /^($o_valid)(.*)$/si ) {
	    $arg = $1;
	    $rest = $2;
	    $arg = ($type eq "o" && $arg =~ /^0/) ? oct($arg) : 0+$arg;
	    unshift (@ARGV, $starter.$rest) if defined $rest && $rest ne '';
	}
	elsif ( $arg =~ /^($o_valid)$/si ) {
	    $arg = ($type eq "o" && $arg =~ /^0/) ? oct($arg) : 0+$arg;
	}
	else {
	    if ( defined $optarg || $mand eq "=" ) {
		if ( $passthrough ) {
		    unshift (@ARGV, defined $rest ? $starter.$rest : $arg)
		      unless defined $optarg;
		    return (0);
		}
		warn ("Value \"", $arg, "\" invalid for option ",
		      $opt, " (",
		      $type eq "o" ? "extended " : "",
		      "number expected)\n");
		$error++;
		undef $opt;
		# Push back.
		unshift (@ARGV, $starter.$rest) if defined $rest;
	    }
	    else {
		# Push back.
		unshift (@ARGV, defined $rest ? $starter.$rest : $arg);
		# Supply default value.
		$arg = 0;
	    }
	}
    }

    elsif ( $type eq "f" ) { # real number, int is also ok
	# We require at least one digit before a point or 'e',
	# and at least one digit following the point and 'e'.
	# [-]NN[.NN][eNN]
	if ( $bundling && defined $rest &&
	     $rest =~ /^([-+]?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?)(.*)$/s ) {
	    $arg = $1;
	    $rest = $+;
	    unshift (@ARGV, $starter.$rest) if defined $rest && $rest ne '';
	}
	elsif ( $arg !~ /^[-+]?[0-9.]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$/ ) {
	    if ( defined $optarg || $mand eq "=" ) {
		if ( $passthrough ) {
		    unshift (@ARGV, defined $rest ? $starter.$rest : $arg)
		      unless defined $optarg;
		    return (0);
		}
		warn ("Value \"", $arg, "\" invalid for option ",
		      $opt, " (real number expected)\n");
		$error++;
		undef $opt;
		# Push back.
		unshift (@ARGV, $starter.$rest) if defined $rest;
	    }
	    else {
		# Push back.
		unshift (@ARGV, defined $rest ? $starter.$rest : $arg);
		# Supply default value.
		$arg = 0.0;
	    }
	}
    }
    else {
	Croak ("GetOpt::Long internal error (Can't happen)\n");
    }
    return (1, $opt, $arg, $dsttype, $incr, $key);
}

# end of Getopt::Long::FindOption
1;
