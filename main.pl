#!/usr/bin/perl

# gra "Kolko-krzyzyk"


BEGIN {
    use FindBin '$Bin';
    push @INC, $Bin;
}


require CCModule;

my $playerType;         # nr gracza (1 - X, 2 - O)
my $areaNumber;         # nr pola jakie zaznacza gracz
my $randomAreaNumber;   # losowy numer pola ktory zaznaczy komputer
my %areasMap;           # mapa planszy (K - nr pola, V - nr gracza ktory to pole zaznaczyl)
my $areasMapRef;        # referencja do mapy
my $correct;            # flaga oznaczajaca wykonanie poprawnego ruchu
my $computerMove;       # flaga wyznaczajaca ruch komputera

foreach my $i (@ARGV){ if($i eq "-h" || $i eq "--help") { CCModule::help(); } }

sub getRandomAreaNum {
    my $num = 1 + int rand(9);
    if( (!defined $areasMap{$num}) ) { return $num; } 
    else { return getRandomAreaNum(); }
}

sub getEnemyMove {
    my $playerType = shift;
    my $enemyType = CCModule::nextPlayer($playerType);
    my($areasMap) = @_;

    my $areaNumber = 0;
    my $a;
    my $b;
    my $c;

    # indeksy pol do sprawdzenia (poziomo, pionowo, 2 skosy )
    my @array = (
        1, 2, 3, 
        4, 5, 6, 
        7, 8, 9, 
        1, 4, 7, 
        2, 5, 8, 
        3, 6, 9, 
        1, 5, 9, 
        3, 5, 7
    );

    for (my $i=0; $i < (scalar(@array)); $i+=3) {  # check for win (ALL)
        $a = $array[$i];
        $b = $array[$i+1];
        $c = $array[$i+2];
        
        $areaNumber = CCModule::check($playerType, $areasMap{$a}, $areasMap{$b}, $areasMap{$c});
    }

    #### BLOKOWANIE

    if($areaNumber == 0) {
        for (my $i=0; $i < (scalar(@array)); $i+=3) {  # check for block (ALL)
            $a = $array[$i];
            $b = $array[$i+1];
            $c = $array[$i+2];

            # $areaNumber = CCModule::check($enemyType, $areasMap{$a}, $areasMap{$b}, $areasMap{$c});
            if( (!defined $areasMap{$a}) && CCModule::compareTwoValues( $enemyType, $areasMap{$b}, $areasMap{$c}) ) { $areaNumber = $a; } 
            elsif( (!defined $areasMap{$b}) && CCModule::compareTwoValues( $enemyType, $areasMap{$a}, $areasMap{$c}) ) { $areaNumber = $b; } 
            elsif( (!defined $areasMap{$c}) && CCModule::compareTwoValues( $enemyType, $areasMap{$a}, $areasMap{$b}) ) { $areaNumber = $c; }
        }
    }

    if($areaNumber != 0) {
        # print "AI: $areaNumber\n";
        CCModule::markArea($areaNumber, $playerType, $areasMapRef);
        # return $areaNumber;
    } else {
        # print "Random: \n";
        CCModule::markArea(getRandomAreaNum(), $playerType, $areasMapRef);
        # return getRandomAreaNum();
    }

    if(CCModule::getFreeAreas($areasMapRef) == 1 && !CCModule::checkIfWin($areasMapRef) && !CCModule::finished($areasMapRef)) { 
        # print "LAST MOVE \n"; 
        CCModule::markArea(getEnemyMove($enemyType, $areasMapRef), $enemyType, $areasMapRef); 
    }
}


sub newGame {
    system("clear");

    %areasMap = ( 1 => undef, 2 => undef, 3 => undef, 4 => undef, 5 => undef, 6 => undef, 7 => undef, 8 => undef, 9 => undef);
    $areasMapRef = \%areasMap;

    CCModule::generatePlainBoard();
    $playerType = CCModule::chooseGamerType();
    
    $correct = 0;
    $computerMove = 0;

    do {
      
        CCModule::drawBoard();

        if($computerMove) {
            system("clear");
            if(CCModule::checkIfWin($areasMapRef) || CCModule::finished($areasMapRef)) { exit; } 
            else {
                $playerType = CCModule::nextPlayer($playerType);
                $computerMove = 0; # gracz bedzie mogl wykonac ruch
            }
        } else {
            print "\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Zaznacz pole nr ";
            $areaNumber = <>;
            chomp($areaNumber);
            $areaNumber +=0;

            $correct = CCModule::markArea($areaNumber, $playerType, $areasMapRef);

            if($correct) { # jesli gracz zaznaczyl dobre pole
            system("clear");
                if(CCModule::checkIfWin($areasMapRef) || CCModule::finished($areasMapRef)) {
                    exit;
                } else {
                    $playerType = CCModule::nextPlayer($playerType);
                    $computerMove = 1; # komputer bedzie mogl wykonac ruch
                    getEnemyMove($playerType, $areasMapRef);

                }
            }
        }
    } while( !CCModule::checkIfWin($areasMapRef) && !CCModule::finished($areasMapRef) );

    return 1;
}

newGame();
