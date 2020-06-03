
Class = require 'lib/class'
require 'lib/effects/PopupText'
require 'lib/effects/PopupTextManager'

function love.load()
    
    math.randomseed(os.time())
    gPopupManager = PopupTextManager()--Popup Classbase, Render function
    gPopupManager:addPopup(
    {
        text = "Example Text",
        color = {r = 255, g = 0, b = 0, a = 255},
        x = 200,
        y = 200,
        scaleX = 4,
        scaleY = 4,
        fadeIn = {start = 0.2, finish = 0.7},
        fadeOut = {start = 0.7, finish = 2},
        dX = 40,
        dY = 40,
        duration = 2
    })
    for i = 0, 5 do
        gPopupManager:addPopup({
            text = "-" .. math.random(1, 10) .. ' life',
            color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255), a = 255},
            x = math.random(0, 600),
            y = math.random(0, 400),
            scaleX = math.random(0, 2),
            scaleY = math.random(0, 2),
            fadeIn = {start = 0.2, finish = 0.7},
            fadeOut = {start = 0.7},
            dX = math.random(0, 80),
            dY = math.random(0, 80),
            duration = math.random(0.7, 4),
            circular = {totalAngle = math.random(-math.pi * 4, math.pi * 4), radiusX = math.random(-40, 40), radiusY = math.random(-40, 40)}
        })
    end
end

function love.update(dt)
    gPopupManager:update(dt)
end

function love.draw()
    gPopupManager:render()
end