#!/usr/bin/python
# -*- coding: utf-8 -*-
# Jolanta Filipiak
# gra Kolko-Krzyzyk

import sys
import imp
from random import randint
import os
import math
import subprocess

for arg in sys.argv:
    if arg == "-h" or arg == "--help":
        helpOpt = 1
        print("\n####################################################### ")
        print("##################  KOLKO I KRZYZYK ################### ")
        print("#######################################################\n")
        print(" Gracz rozpoczyna gre klikajac na jedno z dziewieciu\n pol na planszy.\n\n Gracz -> kolko, \n komputer -> krzyzyk.\n")
        print("\n Program wymaga\n srodowiska graficznego oraz biblioteki PYGAME.\n")
        sys.exit(0)

try:
	imp.find_module('pygame')
	import pygame
	from pygame.locals import *

	from pygame import gfxdraw
    
except ImportError:
    print(' # BLAD - brak biblioteki PyGame #\n Zainstaluj \'PyGame\' w celu poprawnego dzialania skryptu.\n')
    sys.exit(1)


checkDisplay = os.popen("echo $DISPLAY")
isGraphicalEnvExist = 1 if checkDisplay.read().strip() else 0
if not isGraphicalEnvExist:
	print(" # BLAD - brak graficznego srodowiska #\n Skrypt potrzebuje graficznego srodowiska do poprawnego dzialania.\n")
	sys.exit(1)


scriptDirectory = os.path.abspath(os.path.dirname(__file__))

width, height = 320, 400

pygame.init()
pygame.font.init()
myfont = pygame.font.SysFont(None, 30)

screen = pygame.display.set_mode((width, height))

global playerType
global areaNumber
global randomAreaNumber
global areasMap
global correct
global computerMove
helpOpt = 0

BLACK = ( 0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (152, 251, 152)
RED = (255, 150, 193)
GREY = (205, 201, 201)

def getAreaNumber(pos):
    areaNumber = 0
    x = pos[0]
    y = pos[1]

    if x >= 0 and x <= 96: # 1 4 7
        if y >= 0 and y <= 96:
            areaNumber = 1
            pass
        elif y >= 100 and y <= 196:
            areaNumber = 4
            pass
        elif y >= 200 and y <= 300:
            areaNumber = 7
            pass
        pass
    elif x >= 100 and x <= 196: # 2 5 8
        if y >= 0 and y <= 96:
            areaNumber = 2
            pass
        elif y >= 100 and y <= 196:
            areaNumber = 5
            pass
        elif y >= 200 and y <= 300:
            areaNumber = 8
            pass
        pass
    elif x >= 200 and x <= 300: # 3 6 9
        if y >= 0 and y <= 96:
            areaNumber = 3
            pass
        elif y >= 100 and y <= 196:
            areaNumber = 6
            pass
        elif y >= 200 and y <= 300:
            areaNumber = 9
            pass
        pass
    if areaNumber != 0:
        return areaNumber
        pass
    else:
        # print("Bledny nr pola")
        return 0
        pass

def drawCircle(n):
    x = -100
    y = -100

    displ = 56

    if n >= 1 and n <= 3:
        x = displ + 100*(n-1)
        y = displ
        pass
    elif n >= 4 and n <= 6:
        x = displ + 100*(n-4)
        y = displ+100
        pass
    elif n >=7 and n <=9:
        x = displ + 100*(n-7)
        y = displ+200
        pass
    else:
		# print("Bledny nr pola")
        pass

    color = GREEN 
    innerColor = WHITE
    lineThickness = 8
    r = 38
    r2 = r-lineThickness
    surface = screen
    
    pygame.gfxdraw.aacircle(surface, x, y, r, color)
    pygame.gfxdraw.filled_circle(surface, x, y, r, color)

    pygame.gfxdraw.aacircle(surface, x, y, r2, innerColor)
    pygame.gfxdraw.filled_circle(surface, x, y, r2, innerColor)

def drawCross(n):
    x = -100
    y = -100

    displ = 20
    displacement = 67

    if n >= 1 and n <= 3:
        x = displ + 100*(n-1)
        y = displ
        
    elif n >= 4 and n <= 6:
        x = displ + 100*(n-4)
        y = 100+displ
        
    elif n >=7 and n <=9:
        x = displ + 100*(n-7)
        y = 200+displ
        
    else:
		# print("Bledny nr pola")
        pass

    color = RED
    lineThickness = 8
    surface = screen

    pygame.draw.line(surface, color, (x, y), (x+displacement, y+displacement), lineThickness)
    pygame.draw.line(surface, color, (x+displacement, y), (x, y+displacement), lineThickness)

def markArea(board, area, player):
    if board.areas.get(area) is None:
        board.areas[area] = player
        return 1
    else:
        return 0


def finished(board):
    isFinished = 1

    for area, player in board.areas.items():
        if player is None:
            isFinished = 0
            pass

    if isFinished == 1:        #  jesli gra zakonczyla sie remisem
        return 1
    else:
        return 0

def areEqual(a, b, c):
    if a is not None and b is not None and c is not None:
        if a == b and a == c:
            return a
            pass
        else:
            return 0
            pass
        pass
    else:
        return 0
        pass

def checkIfWin(board):
    winner = areEqual( board.areas[1], board.areas[2], board.areas[3] ) or \
        areEqual( board.areas[4], board.areas[5], board.areas[6] ) or \
        areEqual( board.areas[7], board.areas[8], board.areas[9] ) or \
        areEqual( board.areas[1], board.areas[4], board.areas[7] ) or \
        areEqual( board.areas[2], board.areas[5], board.areas[8] ) or \
        areEqual( board.areas[3], board.areas[6], board.areas[9] ) or \
        areEqual( board.areas[1], board.areas[5], board.areas[9] ) or \
        areEqual( board.areas[3], board.areas[5], board.areas[7] )

    if winner > 0:
        return winner
    else:
        return 0

def getRandomAreaNum(areasDict):
    n = randint(1, 9)
    if areasDict.get(n) is None:
        return n
        pass
    else:
        return getRandomAreaNum(areasDict)
        pass

def compareTwoValues(player, a, b):
    if a is not None and b is not None and a == player and b == player:
        return 1
        pass
    else:
        return 0
        pass

def check(areasDict, player, a, b, c):

    if areasDict.get(a) is None and compareTwoValues(player, areasDict.get(b), areasDict.get(c)):
        return a
        pass
    elif areasDict.get(b) is None and compareTwoValues(player, areasDict.get(a), areasDict.get(c)):
        return b
        pass
    elif areasDict.get(c) is None and compareTwoValues(player, areasDict.get(a), areasDict.get(b)):
        return c
        pass
    else:
        return 0
        pass

def getFreeAreas(board):
    freeAreas = 0

    for area, player in board.areas.items():
        if player is None:
            freeAreas+=1
        pass
    
    return freeAreas

def getEnemyMove(board, player):

    if player == 2:
        enemy = 1
    elif player == 1:
        enemy = 2

    area = 0
    a, b, c = 0, 0, 0
    
    array = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 4, 7, 2, 5, 8, 3, 6, 9, 1, 5, 9, 3, 5, 7 ]

    for i in range(0,len(array)-1, 3):
        a = array[i]
        b = array[i+1]
        c = array[i+2]
        area = check(board.areas, player, a, b, c)
        if area != 0:
            break
            pass

    #### BLOKOWANIE
    if area == 0:
        for i in range(0,len(array)-1, 3):
            a = array[i]
            b = array[i+1]
            c = array[i+2]
            area = check(board.areas, enemy, a, b, c)

            if area != 0:
                break
                pass

    if area != 0:
        # print "AI ", area
        markArea(board, area, player)
        pass
    else:
        area = getRandomAreaNum(board.areas)
        # print "random ", area
        markArea(board, area, player)

def render_multi_line(text, x, y, fsize):
    lines = text.splitlines()
    for i, l in enumerate(lines):
        screen.blit(myfont.render(l, 0, BLACK), (x, y + fsize*i))

def setNewScreen(text="", color=WHITE):
    screen = pygame.display.set_mode((width, height))
    screen.fill(color)

    # text = "*** KONIEC GRY *** \n\nJeszcze raz?\n\n TAK:  t, \n NIE:  dowolny klawisz.\n"
    textsurface = myfont.render(text, False, BLACK)
    textrect = textsurface.get_rect()
    textrect.centerx = screen.get_rect().centerx
    textrect.centery = 50
    render_multi_line(text, 20, 20, 20)

    pygame.display.flip()

# not used function
def showHelpScreen():
    text = "*** KOLKO I KRZYZYK *** \n\nGracz rozpoczyna gre \nklikajac na jedno \nz dziewieciu pol na planszy.\n\nGracz -> kolko, \nkomputer -> krzyzyk.\n"
    pygame.display.set_caption('Kolko i krzyzyk - POMOC')
    setNewScreen(text)

    while True:
        for event in pygame.event.get():
            if event.type == QUIT:
                sys.exit(0)

def showGameOverScreen():

    waiting = True

    while waiting:
        keys=pygame.key.get_pressed()
        ev = pygame.event.poll()

        if ev.type == pygame.QUIT:
            sys.exit(0)

        if ev.type == pygame.KEYDOWN:
            if ev.key == pygame.K_t:
                newGame()
            else:
                print("\n\nKONIEC GRY\nDziękujemy :) \n\n")
            
            waiting = False
    
def showTieScreen():
    setNewScreen(" REMIS \n\nJeszcze raz?\n\n TAK:  t, \n NIE:  dowolny klawisz.\n", GREY)
    showGameOverScreen()

def showWinScreen(winner):
    if winner == 1:
        text = " PRZEGRANA :( \n\nJeszcze raz?\n\n TAK:  t, \n NIE:  dowolny klawisz.\n"
        setNewScreen(text, RED)
    elif winner == 2:
        text = "*** WYGRANA !!! *** \n\nJeszcze raz?\n\n TAK:  t, \n NIE:  dowolny klawisz.\n"
        setNewScreen(text, GREEN)
    
    showGameOverScreen()

class Board:
    def __init__(self):
        self.areas = { 1 : None, 2 : None, 3 : None, 4 : None, 5 : None, 6 : None, 7 : None, 8 : None, 9 : None }

    def drawPlainBoard(self):
        x = 10 # margines

        a = 0+x
        b = 96+x
        c = 196+x
        d = 296+x

        screen = pygame.display.set_mode((width, height))
        pygame.display.set_caption('Kolko i krzyzyk')
        screen.fill(WHITE)

        #  pionowe linie
        pygame.draw.line(screen, BLACK, (b, a), (b, d), 4)
        pygame.draw.line(screen, BLACK, (c, a), (c, d), 4)
        #  poziome linie
        pygame.draw.line(screen, BLACK, (a, b), (d, b), 4)
        pygame.draw.line(screen, BLACK, (a, c), (d, c), 4)


        text = "Kliknij mysza na obszar, \nw ktorym chcesz postawic \nswoj znak (kolko)"
        textsurface = myfont.render(text, 1, BLACK)
        render_multi_line(text, 20, 315, 25)

        pygame.display.flip()

    def drawBoard(self):
        for area, player in self.areas.items():
            if player is not None:  # if area is not taken by any player
                if player == 1:
                    drawCross(area)
                elif player == 2:
                    drawCircle(area)

def newGame():

    # game data setup
    areasMap = Board()
    areasMap.drawPlainBoard()
    playerType = 2
    correct = 0
    computerMove = 0
    areaNumber = 0

    gameOver = False
    winner = 0

    while True:

        winner = checkIfWin(areasMap)
        
        if winner > 0:
            gameOver = True
            showWinScreen(winner)
            break

        if finished(areasMap):
            gameOver = True
            showTieScreen()
            break

        ev = pygame.event.poll()

        if ev.type == pygame.QUIT:
            break
        if ev.type == pygame.MOUSEBUTTONUP:
            areaNumber = getAreaNumber(pygame.mouse.get_pos())


        if computerMove == 1:
            playerType = 2
            if getFreeAreas(areasMap) == 1:
                if checkIfWin(areasMap) == 0 and finished(areasMap) == 0:
                    # LAST
                    getEnemyMove(areasMap, playerType)
                    # markArea(areasMap, getEnemyMove(areasMap, playerType), playerType) #####################################


            computerMove = 0
        else:
            if areaNumber > 0:
                correct = markArea(areasMap, areaNumber, playerType)
                if correct == 1:

                    winner = checkIfWin(areasMap)
                    
                    if winner > 0:
                        gameOver = True
                        showWinScreen(winner)
                        break

                    if finished(areasMap):
                        gameOver = True
                        showTieScreen()
                        break
                    

                    playerType = 1
                    getEnemyMove(areasMap, playerType)
                    computerMove = 1
                    

        areasMap.drawBoard()

        pygame.display.flip()
    pygame.quit()
    

# if helpOpt == 1:
#     showHelpScreen() # not used
# else:
#     newGame()

newGame()