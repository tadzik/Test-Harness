use v6;

class Test::Harness::File {
    has Int $.todos         = 0;
    has Int $.todos-passed  = 0;
    has Int $.tests-ran     = 0;
    has Int $.tests-passed  = 0;
    has Int $.tests-skipped = 0;
    has Int $.tests-planned = 0;
    has &.callback;

    method line (Str $line) {
        if $line ~~ /^ '1..' $<plan>=[\d+] $/ {
            if $!tests-planned {
                die "Plan declared twice"
            }
            # TODO check for plan appearing in the middle of the output
            $!tests-planned = +$<plan>;
        }
        unless $line ~~ /^ 'not '? 'ok'»/ {
            return # doesn't concern us
        }
        $line ~~ /:r ^ $<fail>=['not ']?
                    'ok'
                    \h*
                    $<num>=[\d*]
                    \h*
                    $<description>=[ <-[#]>* ]?
                    [
                        '# '
                        [ $<todo>=[:i 'TODO'] || $<skip>=[:i 'SKIP'] ]
                        [ ' ' $<reason>=[\N+] ]?
                    ]?
                  $/;
        unless $/ {
            die "Malformed TAP output"
        }
        $!tests-ran++;
        if ~$<num> ne '' and +$<num> != $!tests-ran {
            die "Wrong test number"
        }
        if ~$<todo> ne '' {
            $!todos++;
            if ~$<fail> eq '' {
                $!todos-passed++;
                $!tests-passed++;
            }
        } elsif ~$<skip> ne '' {
            $!tests-skipped++;
            $!tests-passed++;
        } elsif ~$<fail> eq '' {
            $!tests-passed++;
        }
    }

    method short-summary {
        if $.tests-planned == $.tests-passed {
            return 'ok';
        } else {
            return "Failed {$.tests-planned - $.tests-passed}"
                ~ "/{$.tests-planned} subtests";
        }
    }

    method successful {
        $.tests-planned == $.tests-passed
    }
}
