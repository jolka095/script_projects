package CCModule;

my @boardArray; # tablica reprezentujaca plansze


sub help {
    print "\n ###################################################### ";
    print "\n ##################  KOLKO I KRZYZYK ################## ";
    print "\n ######################################################\n\n";
    # print "  I Wybierz typ gracza:\n\t 1 => krzyzyk \n\t 2 => kolko\n";
    print "    Rozpocznij gre, wybierajac numer pola, \n    na ktorym chcesz narysowac swoj znak. \n\n";
    print "    Numery pol:\n\n";

    print "\t    |     |    \n";
    print "\t 7  |  8  |  9 \n";
    print "\t    |     |    \n";
    print "\t----|-----|----\n";
    print "\t    |     |    \n";
    print "\t 4  |  5  |  6 \n";
    print "\t    |     |    \n";
    print "\t----|-----|----\n";
    print "\t    |     |    \n";
    print "\t 1  |  2  |  3 \n";
    print "\t    |     |    \n";
    print "\n\n";

    print "\n Twoj symbol:\n";
    CCModule::drawCircle();
    exit;
}

#  wypelnianie tablicy znakami tworzac nowa, pusta plansze
sub generatePlainBoard {

    for (my $i=0; $i < 112; $i++) {

        # if($i % 14 == 0) { print "\n";}
        # printf '%5d',  $i;

        if($i >=28 && $i <= 41 || $i >=70 && $i <= 83 ) {
            if(($i % 14 == 4 || $i % 14 == 9) && ($i != 0)){ push @boardArray, "|"; } 
            else { push @boardArray, "-"; }
        } 
        elsif(($i % 14 == 4 || $i % 14 == 9) && ($i != 0)) { push @boardArray, "|"; }
        else { push @boardArray, " "; }
        
    }
}

# rysuje aktualna plansze
sub drawBoard {
    my $counter = -1;
    foreach my $x (@boardArray){
        $counter++;
        if($counter % 14 == 0) { print "\n";}

        printf '%s',  $x;
    }
    print "\n\n";
}

sub drawCross { print "\n \\/ \n /\\ \n\n"; }

sub drawCircle { print "\n /\\ \n \\/ \n\n"; }

# wybiera i zwraca numer (typ) gracza (kolko lub krzyzyk)
sub chooseGamerType {
    print "\n ###################################################### ";
    print "\n ##################  KOLKO I KRZYZYK ################## ";
    print "\n ######################################################\n\n";

    # print " Wybierz typ gracza:\n 1 => krzyzyk \n 2 => kolko\n WYBIERAM: ";
    # my $playerType = <>;

    my $playerType = 2; # zaczynamy od kolka
    chomp($playerType);

    if($playerType == 1) {
        print "\n Twoj symbol:\n";
        CCModule::drawCross();
        print "Zaznacz pole nr \n";

        return $playerType;
    }
    elsif($playerType == 2) {
        print "\n Twoj symbol:\n";
        CCModule::drawCircle();
        print "Zaznacz pole nr \n";

        return $playerType;
    } 
    else {
        system("clear");
        print "\nBlad: Niepoprawny typ gracza.\n";
        chooseGamerType();
    }
}

# zaznacza pole w planszy podane przez gracza
# zwraca true (1) w przypadku powodzenia operacji, 
# a false (0) gdy pole bylo zajete
sub markArea {
    my $areaNum = shift;
    my $playerType = shift;
    my($mapRef) = @_;
    my $a = 0;

    # if($mapRef->{$areaNum} == undef) { # jesli pole o danym numerze jest wolne 
    if(!defined $mapRef->{$areaNum}) {
        if($areaNum == 7)    { $a = 1; }
        elsif($areaNum == 8) { $a = 6; }
        elsif($areaNum == 9) { $a = 11; }    
        elsif($areaNum == 4) { $a = 43; }    
        elsif($areaNum == 5) { $a = 48; }    
        elsif($areaNum == 6) { $a = 53; }
        elsif($areaNum == 1) { $a = 85; }    
        elsif($areaNum == 2) { $a = 90; }    
        elsif($areaNum == 3) { $a = 95; }
        else { 
            print "\nPodaj poprawny numer pola od 1 do 9.\n";
            return 0; 
        }

        if($a != 0){
            if($playerType == 2) {
                $mapRef->{$areaNum} = $playerType; # update mapy ruchow graczy
                $boardArray[ $a ]           = "/";
                $boardArray[ ($a+1) ]       = "\\";
                $boardArray[ ($a+14) ]      = "\\";
                $boardArray[ ($a+1+14) ]    = "/";
            } 
            elsif($playerType == 1) {
                $mapRef->{$areaNum} = $playerType; # update mapy ruchow graczy
                $boardArray[ $a ]           = "\\";
                $boardArray[ ($a+1) ]       = "/";
                $boardArray[ ($a+14) ]      = "/";
                $boardArray[ ($a+1+14) ]    = "\\";
            } else {
                print " Bledny typ gracza: $playerType \n\t 1 => krzyzyk \n\t 2 => kolko\n";
            }
        }
        return 1;
    } else {
        print "Pole $areaNum zajęte!\n";
        return 0;
    }
}

# porownuje 3 wartosci w mapie jesli zadna z nich nie jest undef
sub areEqual {
    my $a = shift;
    my $b = shift;
    my $c = shift;

    if(defined $a && defined $b && defined $c) {
        # print "\n\ta, b, c: ", $a, " & ", $b, " & ", $c, " do porównania\n";
        if($a == $b && $a == $c) { return $a; } # musi zwrocic cos rodzaju true, tu zwraca 'id' wygranego
        else { return 0; }
    } else {
        # print "\n\tNie wszystkie wygrywajace pola sa zaznaczone\n  ";
        return 0;
    }

}

# porownuje 2 (zdefiniowane w mapie pol) wartosci
sub compareTwoValues {
    my $playerType = shift;
    my $a = shift;
    my $b = shift;
    
    if(defined $a && defined $b && $a == $playerType && $b == $playerType) {
        return 1;
    } else {
        return 0;
    }
}

# szuka inteligentnego ruchu dla komputera i zwraca wartosc pola ktore ma zaznaczyc
sub check {
    my $playerType = shift; chomp($playerType);
    my $a = shift;
    my $b = shift;
    my $c = shift;

       if( (!defined $a) && compareTwoValues( $playerType, $b, $c) ) { return $a; } 
    elsif( (!defined $b) && compareTwoValues( $playerType, $a, $c) ) { return $b; } 
    elsif( (!defined $c) && compareTwoValues( $playerType, $a, $b) ) { return $c; }
    else { return 0; }
}


# sprawdzenie czy nastapil koniec gry (wypelniona plansza)
sub finished {
    my($mapRef) = @_;
    my $isFinished = 1;
    for (my $i=1; $i < 10; $i++) {
        if(!defined $mapRef->{$i}) { $isFinished = 0; }
        # print "Pole: ", $i, " ID: ", $mapRef->{$i}, " \n\t\tend? -> ", $isFinished, " \n";
    }

    if($isFinished) { 
        system("clear");
        #  jesli gra zakonczyla sie remisem
        print "\n ************************************** ";
        print "\n *************** REMIS **************** ";
        print "\n ************************************** \n\n";
        drawBoard();

        setNewGame();
        
    } else {
        # print "Gra w toku... \t isFinished: $isFinished \n";
        return 0;
    }
}

sub getFreeAreas {
    my($mapRef) = @_;
    my $freeAreas = 0;

    for (my $i=1; $i < 10; $i++) {
        if(!defined $mapRef->{$i}) { $freeAreas++; }
        # print "Pole: ", $i, " ID: ", $mapRef->{$i}, " \n\t\tend? -> ", $isFinished, " \n";
    }
    return $freeAreas;
}

sub checkIfWin {
    my($mapRef) = @_;
            
    my $winner = areEqual( $mapRef->{1}, $mapRef->{2}, $mapRef->{3} ) 
        || areEqual( $mapRef->{4}, $mapRef->{5}, $mapRef->{6} ) 
        || areEqual( $mapRef->{7}, $mapRef->{8}, $mapRef->{9} ) 
        || areEqual( $mapRef->{1}, $mapRef->{4}, $mapRef->{7} ) 
        || areEqual( $mapRef->{2}, $mapRef->{5}, $mapRef->{8} ) 
        || areEqual( $mapRef->{3}, $mapRef->{6}, $mapRef->{9} ) 
        || areEqual( $mapRef->{1}, $mapRef->{5}, $mapRef->{9} ) 
        || areEqual( $mapRef->{3}, $mapRef->{5}, $mapRef->{7} );

    if($winner > 0) {
        printWinner($winner);
        setNewGame();
    } else {
        return 0;
    }
}

sub printWinner {
    my $winner = shift;

    if($winner == 1 ) {
        system("clear");
        print "\n ******************************** \n";
            print " ******************  \\/ ********* \n";
            print ' ********** WYGRYWA  /\\ ********* ';
        print "\n ******************************** \n\n";
        drawBoard();

    } elsif($winner == 2 ) {
        system("clear");
        print "\n ******************************** \n";
            print " ******************* /\\ ********* \n";
            print ' ********** WYGRYWA  \\/ ********* ';
        print "\n ******************************** \n\n";
        drawBoard();
    }
}

sub nextPlayer {
    my $playerType = shift;

    if($playerType == 1) { $playerType = 2; } 
    elsif($playerType == 2) { $playerType = 1; }
    else { 
        print "Niepoprawny nr gracza: $playerType \n";
        $playerType = 0;
    }

    return $playerType;
}

sub setNewGame {
    print "Jeszcze raz?\n\n\tGRAM DALEJ => t \n\tKONIEC => Enter \n\nWYBIERAM:  ";
    my $new = <>;
    chomp($new);

    if($new eq "t") {
        @boardArray = ();
        main::newGame();
    } else {
        print "\n\n Do zobaczenia! :) \n\n";
        return 1;
    }
}

1;