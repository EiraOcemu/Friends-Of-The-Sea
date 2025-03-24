

SMODS.Joker{
    key = 'Ice',
    loc_txt = {
        name = 'Ninja of Frost',
        text = {
            'At the End of each shop,',
            'Remove all stickers from 1 Random Joker,',
            'Perishes after 5 Uses,',
            'If Sold, Grant all Jokers up too the',
            'Amount before Perishing, Left to right,',
            'The Eternal Sticker'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    pos = {x = 0, y = 4},
    config = { extra = {
    }
    }
}

SMODS.Joker{
    key = 'wildred',
    loc_txt = {
        name = 'WildShot',
        text = {
            'All Wild cards are Only [Suit],',
            'Add {X:mult,C:white}X#1#{} Mult for Scored Wild Cards'
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 7,
    unlocked = false,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 1, y = 4},
    config = { extra = {
        Xmult = 1.5
    }
    }
}

SMODS.Joker{
    key = 'pulse',
    loc_txt = {
        name = 'Destructive Pulse',
        text = {
            'Destroys Highest Scored Card,',
            'adds Chips to Jokers Mult,',
            'Must be New Rank to add.'
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    unlocked = false,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 2, y = 4},
    config = { extra = {
        Xmult = 1.25
    }
    }
}

SMODS.Joker{
    key = 'yukkuri',
    loc_txt = {
        name = 'Shiny Servant',
        text = {
            'All Cards are Scored as Diamonds'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    unlocked = false,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 3, y = 4},
    config = { extra = {
        Xmult = 1.25
    }
    }
}

