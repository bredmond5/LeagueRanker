VALID_PLAYERS = {"EB": "Erik Bedrosian", "BR": "Brice Redmond", "EW": "Elsa Winslow", "DB": "Duncan Brin", "FL": "Francisco Lopez", "JZ": "Jason Zeidman", "KP": "Kelsey Pennington", "JC":"Jordan Cortes", "PG": "Patrick Godfrey", "SH": "Steven Howard", "SC":"Stefan Crigler", "RO": "Robby Odum", "KJ": "Kyle Johnson", "LY": "Lorenzo Yabut"}
FILENAME = "scores.txt"

def check_valid_initials(initials):
    return initials in VALID_PLAYERS
