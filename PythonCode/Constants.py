#VALID_PLAYERS = {"EB": "Erik Bedrosian", "FL": "Francisco Lopez", "BR": "Brice Redmond", "EW": "Elsa Winslow", "DB": "Duncan Brin", "JZ": "Jason Zeidman", "KP": "Kelsey Pennington", "JC":"Jordan Cortes", "PG": "Patrick Godfrey", "SH": "Steven Howard", "SC":"Stefan Crigler", "RO": "Robby Odum", "KJ": "Kyle Johnson", "LY": "Lorenzo Yabut", "RB": "Ryan Barry", "SR": "Spikeball Ryan"}
VALID_PLAYERS = {"BR": "Brice Redmond", "EW": "Elsa Winslow", "JZ": "Jason Zeidman", "KP": "Kelsey Pennington", "PG": "Patrick Godfrey", "SC":"Stefan Crigler", "RO": "Robby Odum", "KJ": "Kyle Johnson", "LY": "Lorenzo Yabut", "RB": "Ryan Barry", "SR": "Spikeball Ryan"}

FILENAME = "ScoresSummer20.txt"

def check_valid_initials(initials):
    return initials in VALID_PLAYERS
