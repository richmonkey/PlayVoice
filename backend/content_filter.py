_BANNED_WORDS = {
    "admin", "administrator", "official", "moderator", "gamevoice_staff",
    "support", "system", "root", "fuck", "shit", "bitch", "asshole",
    "nigger", "nigga", "faggot", "cunt", "rape", "kys",
}


def contains_banned_word(text: str) -> bool:
    lowered = text.lower()
    return any(word in lowered for word in _BANNED_WORDS)
