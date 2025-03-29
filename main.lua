-----------------------------------------------
--------------------MOD CODE-------------------

SMODS.optional_features.cardareas.unscored = true

function CardArea:Lily_Change_Hand(delta)
    self.config.highlighted_limit = self.config.highlight_limit or G.GAME.Lily_Hand or 5
    if delta ~= 0 then
        G.E_MANAGER:add_event(Event({
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end
    
end

local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.Lily_Hand = 5
    return ret
end

local applyToRunBackHook = Back.apply_to_run

function Back:apply_to_run()
    local c = applyToRunBackHook(self)
    if self.effect.config.selection then
        G.GAME.Lily_Hand = G.GAME.Lily_Hand + self.effect.config.selection
    end
    return c
end


SMODS.Atlas{
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}

SMODS.Joker{
    key = 'princediamonds',
    loc_txt = {
        name = 'Prince of Diamonds',
        text = { 
            'Grants {X:mult,C:white}X#1#{} mult for Every Scored {C:diamonds}Diamond{} card',
            'Add {X:mult,C:white}X0.02{} mult for each Scored {C:diamonds}Diamond{} card',
            'Has a Cap mult of {X:mult,C:white}X5{}'
        }
    },
    atlas = 'Jokers',
    rarity = 4,
    cost = 20,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 0, y = 0},
    config = { extra = {
        Xmult = 1
    }
    },
    loc_vars = function(self,info_queue,center)
        return{vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self,card,context)
        if context.cardarea == G.play and context.individual and not context.blueprint then
            if context.other_card:is_suit("Diamonds") then
                if card.ability.extra.Xmult < 5 then
                    card.ability.extra.Xmult = card.ability.extra.Xmult + 0.02
                    delay(0.1)
                    if card.ability.extra.Xmult > 4.99 then
                        SMODS.calculate_effect({ message = 'Capped X5', colour = G.C.PERISHABLE }, card)
                        card.ability.extra.Xmult = 5
                    end
                    return {
                        Xmult = card.ability.extra.Xmult,
                        message = 'X' .. card.ability.extra.Xmult,
                        colour = G.C.MULT
                    }
                else
                    return {
                        Xmult = card.ability.extra.Xmult,
                        message = 'X' .. card.ability.extra.Xmult,
                        colour = G.C.MULT
                    }
                end
            end
        end
    end
}


SMODS.Joker{
    key = 'blessingsea',
    loc_txt = {
        name = 'Blessing of the Sea',
        text = {
            'Grants {X:mult,C:white}X#1#{} for',
            'Every {C:attention}Untriggered{} Played Card'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 4, y = 1},
    config = { extra = {
        Xmult = 2
    }
    },
    loc_vars = function(self,info_queue,center)
        return{vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self,card,context)
        if context.cardarea == 'unscored' and context.individual then
            return {
                Xmult = card.ability.extra.Xmult,
            }
        end
    end
}


SMODS.Joker{
    key = 'burger',
    loc_txt = {
        name = 'Juicy Burger',
        text = {
            'Scores {X:mult,C:white}X#1#{} mult for {C:attention}First hand{} Played,',
            'Perishes once Scored.'
        }
    },
    atlas = 'Jokers',
    rarity = 1,
    cost = 2,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    pos = {x = 2, y = 2},
    config = { extra = {
        Xmult = 3
    }
    },
    loc_vars = function(self,info_queue,center)
        return{vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return { x_mult = card.ability.extra.Xmult }
          end
          if context.after and context.blueprint then
            return { message = 'nom', colour = G.C.PERISHABLE }
          end
          if context.after and not context.blueprint then
            return { message = 'Eaten', colour = G.C.PERISHABLE },
            delay(0.25),
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            G.jokers:remove_card(card)
                            card:remove()
                            card = nil
                            G.GAME.pool_flags.Burgie = true
                            return true;
                        end
                    }))
                    return true
                end
            }))
          end
    end
}

SMODS.Joker{
    key = 'Fastfood',
    loc_txt = {
        name = 'Fast Food Joint',
        text = {
            'At the {C:attention}End{} of Round,',
            'Create a {C:dark_edition}Negative{} {C:attention}Juicy Burger{}'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    yes_pool_flag = 'Burgie',
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 3, y = 2},
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.j_fotsocemu_burger
    end,
    calculate = function(self,card,context)
        if context.end_of_round and context.main_eval then
            local c = SMODS.add_card({set = "Joker", area = G.jokers, key = "j_fotsocemu_burger"})
            c:set_edition({negative = true})
            delay(0.25)
            return { message = 'Burger', colour = G.C.DARK_EDITION }
        end
    end
}



SMODS.Joker{
    key = 'Entity',
    loc_txt = {
        name = 'Glitched Entity',
        text = {
            'Every {C:attention}6 rounds{}, Turn 1 Random Joker {C:dark_edition}Negative{}',
            '{C:inactive}Currently: #1#/#2#{}'
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 10,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 1, y = 0},
    config = { extra = {
        entitytimer = 0, 
        entitycount = 6
    }
    },
    loc_vars = function(self, infoqueue, card)
        return {
            vars = {card.ability.extra.entitytimer, card.ability.extra.entitycount}
        }
    end,
    calculate = function(self,card,context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            card.ability.extra.entitytimer = card.ability.extra.entitytimer + 1
            SMODS.calculate_effect({ message = ''..card.ability.extra.entitytimer, colour = G.C.DARK_EDITION }, card)
            if card.ability.extra.entitytimer == card.ability.extra.entitycount then
                local jokies = {}
                for k,v in ipairs(G.jokers.cards) do
                    if not v.edition then
                        jokies[#jokies+1] = v
                    end
                end
                if next(jokies) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local card = pseudorandom_element(jokies, pseudoseed('entity'))
                            card:set_edition('e_negative', true)
                            return true
                        end
                    }))
                    SMODS.calculate_effect({ message = 'Negative', colour = G.C.DARK_EDITION }, card)
                else
                    SMODS.calculate_effect({ message = 'Fail', colour = G.C.MULT }, card)
                end
                card.ability.extra.entitytimer = card.ability.extra.entitytimer - card.ability.extra.entitycount
            end
        end
    end
}

SMODS.Joker{
    key = 'Spidertrap',
    loc_txt = {
        name = 'Spiders Trap',
        text = {
            '{C:attention}First Poker Hand{} Becomes {C:attention}Locked{} In',
            'All other Hands will not Score',
            'Adds {X:mult,C:white}X#1#{} Mult per Card',
            '{C:inactive}Only #2# will score.'
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 2, y = 0},
    config = { extra = {
        Xmult = 3,
        hand = '[unset]'
    }
    },
    loc_vars = function(self,info_queue,card)
        return{vars = {
            card.ability.extra.Xmult,
            card.ability.extra.hand}}
    end,
    calculate = function(self,card,context)
        if context.scoring_name and (card.ability.extra.hand == '[unset]') then
            card.ability.extra.hand = context.scoring_name
            SMODS.calculate_effect({ message = card.ability.extra.hand, colour = G.C.ATTENTION }, card)
        end
        if context.cardarea == G.play and context.individual and context.scoring_name ~= card.ability.extra.hand then
            hand_chips = 0
            return {
                Xmult = 0,
                message = 'Debuffed',
                colour = G.C.FILTER
            }
        end
        if context.cardarea == G.play and context.scoring_name == card.ability.extra.hand and context.individual then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'skilledluck',
    loc_txt = {
        name = 'Skilled Luck',
        text = {
            'All {C:green}Probabilities{} are {C:attention}Guaranteed'
        }
    },
    atlas = 'Jokers',
    rarity = 4,
    cost = 20,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 2, y = 1},
    config = { extra = {
    }
    },
    add_to_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = G.GAME.probabilities.normal * 99999999999999999999999999
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.probabilities.normal = G.GAME.probabilities.normal / 99999999999999999999999999
    end
}

SMODS.Joker{
    key = 'Lilyvalley',
    loc_txt = {
        name = 'Lily of the Valley',
        text = {
            "{C:attention}Adds 1{} Extra Playing Slot to Hand.",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 4, y = 0},
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.play_mod }
        }
    end,
    config = {
        name = "Playable Cards",
        play_mod = 1,
    },
    add_to_deck = function(self, card, from_debuff)
        G.GAME.Lily_Hand = G.GAME.Lily_Hand + card.ability.play_mod
        G.hand:Lily_Change_Hand(card.ability.play_mod)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.Lily_Hand = G.GAME.Lily_Hand - card.ability.play_mod
        G.hand:Lily_Change_Hand(-card.ability.play_mod)
    end,
}

SMODS.Joker{
    key = 'bapteh',
    loc_txt = {
        name = 'BAP TEH HAND',
        text = {
            "{C:attention}Removes 1{} Playing Slot from Hand.",
            "Grants {X:mult,C:white}X#2#{} Mult"
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 0, y = 1},
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.play_mod, card.ability.extra.Xmult }
           
        }
    end,
    config = {
        name = "Playable Cards",
        play_mod = 1,
        extra = {
            Xmult = 6,
        }
    },
    add_to_deck = function(self, card, from_debuff)
        G.GAME.Lily_Hand = G.GAME.Lily_Hand - card.ability.play_mod
        G.hand:Lily_Change_Hand(-card.ability.play_mod)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.Lily_Hand = G.GAME.Lily_Hand + card.ability.play_mod
        G.hand:Lily_Change_Hand(card.ability.play_mod)
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return { x_mult = card.ability.extra.Xmult }
        end
    end
}

SMODS.Joker{
    key = 'cloudprincess',
    loc_txt = {
        name = 'Omega Cloud',
        text = {
            'Grants {C:green}$1{} for Every Card in Deck,',
            '{C:attention}Perishes{} once Used.'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 5,
    no_pool_flag = 'Cloudfaded',
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    pos = {x = 4, y = 2},
    config = { extra = {
        carddeck = 'Nil'
    }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.carddeck} 
        }
    end,
    calc_dollar_bonus = function(self, card)
        return #G.playing_cards,
        G.E_MANAGER:add_event(Event({
            SMODS.calculate_effect({ message = 'Faded', colour = G.C.PERISHABLE }, card),
            func = function()
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    blockable = false,
                    func = function()
                        G.jokers:remove_card(card)
                        card:remove()
                        card = nil
                        G.GAME.pool_flags.Cloudfaded = true
                        return true;
                    end
                }))
                return true
            end
        }))
    end,
}

SMODS.Joker{
    key = 'Otter',
    loc_txt = {
        name = 'Otter of Spades',
        text = {
			"{C:green}#1# in #2#{} chance Played {C:spades}Spade{} Cards are Duplicated",
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = {x = 3, y = 0},
    config = { extra = {
        odds = 3,
        handplace = 0,
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            (G.GAME.probabilities.normal or 1), 
            card.ability.extra.odds, 
        } 
    }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual and not context.blueprint then
            if context.other_card and context.other_card:is_suit("Spades") then
                if pseudorandom('ottorofspades') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    SMODS.calculate_effect({ message = 'Copied', colour = G.C.CHIPS }, card)
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(context.other_card)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card.states.visible = nil
        
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:start_materialize()
                            return true
                        end
                    })) 
                end
            end
        end
    end       
}

SMODS.Joker{
    key = 'Garbage',
    loc_txt = {
        name = 'Garbage Disposal',
        text = {
            'Grants {C:attention}+#1# Discards{},',
            'Lose a Discard Every Round,',
            'Perishes once all discards are Used'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    pos = {x = 3, y = 1},
    config = { extra = {
    discardturns = 5
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.discardturns
        } 
    }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            ease_discard(card.ability.extra.discardturns)
        end
        if context.end_of_round and context.main_eval and not context.blueprint then
            card.ability.extra.discardturns = card.ability.extra.discardturns - 1
            SMODS.calculate_effect({ message = '-1', colour = G.C.MULT }, card)
            if card.ability.extra.discardturns == 0 then
                G.E_MANAGER:add_event(Event({
                    SMODS.calculate_effect({ message = 'Ripped', colour = G.C.PERISHABLE }, card),
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                G.GAME.pool_flags.Cloudfaded = true
                                return true;
                            end
                        }))
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker{
    key = 'moonlight',
    loc_txt = {
        name = 'Moonlight',
        text = {
            'Every {C:blue}Earth{} Card used,', 
            'This Joker Gains {C:blue}+#1#{} Chips',
            'Currently Grants {C:blue}+#2#{} Chips for Each Card Scored'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 1, y = 1},
    config = { extra = {
        Chips = 10,
        TotalChips = 0
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.Chips,
            card.ability.extra.TotalChips
        } 
    }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.config.center.key == "c_earth" and not context.blueprint then
                card.ability.extra.TotalChips = card.ability.extra.TotalChips + card.ability.extra.Chips
                return { message = '+'..card.ability.extra.TotalChips, colour = G.C.CHIPS }
        end
        if context.cardarea == G.play and context.individual and card.ability.extra.TotalChips > 0 then
            return {
                chips = card.ability.extra.TotalChips,
            }
        end
    end
}


SMODS.Joker{
    key = 'tent',
    loc_txt = {
        name = 'Shrieking Tent',
        text = {
            'This Joker Gains {X:mult,C:white}X#2#{} Mult,',
            'For each {C:red}Sold Joker',
            '{C:inactive}(Currently at {}{X:mult,C:white}X#1#{} {C:inactive}Mult){}'
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 0, y = 2},
    config = { extra = {
        Txmult = 1,
        xmult = 0.1
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.Txmult,
            card.ability.extra.xmult
        } 
    }
    end,
    calculate = function(self, card, context)
        if context.selling_card then
            if context.card.ability.set == 'Joker' then
                card.ability.extra.Txmult = card.ability.extra.Txmult + card.ability.extra.xmult
                return { message = 'X'..card.ability.extra.Txmult, colour = G.C.MULT }
            end
        end    
        if context.joker_main then
            return{
                Xmult = card.ability.extra.Txmult
            }
        end
    end
}

SMODS.Joker{
    key = 'pixel',
    loc_txt = {
        name = 'Dead Pixel',
        text = {
            'If Hand Is a {C:attention}High Card{}',
            'Grants {C:red}+#2#{} Mult, And',
            'a {C:green}#3# in #4#{} chance to grant {X:mult,C:white}X#1#{} Mult',
        }
    },
    atlas = 'Jokers',
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 1, y = 2},
    config = { extra = {
        mult = 20,
        xmult = 2,
        odds = 2
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.xmult,
            card.ability.extra.mult,
            (G.GAME.probabilities.normal or 1), 
            card.ability.extra.odds, 
        } 
    }
    end,
    calculate = function(self, card, context)
         if context.joker_main and context.scoring_name == 'High Card' then
            if pseudorandom('pixell') < G.GAME.probabilities.normal / card.ability.extra.odds then
                return{
                    mult = card.ability.extra.mult,
                    Xmult = card.ability.extra.xmult,
                }
            else
                return{
                    mult = card.ability.extra.mult,
                }  
            end
        end
    end
}

-----------------------------------------------
--------------------MOD CODE END---------------