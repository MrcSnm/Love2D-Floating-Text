PopupTextManager = Class{}

--Dont forget to include popup text
--This popup text can accept one class that extends popup text, mantaining only timeElapsed and duration is enough
--for accepting it as the input class, you can extend PopupText and create your own render function, even update function
--for instance, you can make a text that change its characters each frame (on update) and still use with popuptextmanager

function PopupTextManager:init(popupClass, renderTextFunction)
    self.popupClass = (popupClass == nil) and PopupText or popupClass
    self.popups = {}
    self.inactivePopups = {}
    self.inactiveCount = 0
    self.x = 0
    self.y = 0
    self.activeCount = 0
    self.renderTextFunction = (renderTextFunction ~= nil) and renderTextFunction or 
    function(popup) 
        love.graphics.print(popup.text, self.x + popup.x, self.y + popup.y, popup.rotation, popup.scaleX, popup.scaleY)
    end

end

function PopupTextManager:addPopup(popupSet)
    local pop
    if(self.inactiveCount > 0) then
        self.inactiveCount = self.inactiveCount - 1
        pop = self.inactivePopups[self.inactiveCount]
    else
        pop = self.popupClass()
    end
    self.popups[self.activeCount] = pop
    self.activeCount = self.activeCount + 1
    pop:set(popupSet)
    return pop
end

--Will do the array swapping
function PopupTextManager:kill(index)
    self.inactivePopups[self.inactiveCount] = self.popups[index]
    self.inactiveCount = self.inactiveCount + 1

    self.popups[index] = self.popups[self.activeCount - 1]
    self.activeCount = self.activeCount - 1
end

--R, G, B, A are the initial to don't change color unless necessary, return if needs to get new current color
function PopupTextManager:setPopupColor(r, g, b, a, pop)

    if(pop.color ~= nil or pop.fadeIn ~= nil or pop.fadeOut ~= nil) then
        local c = pop.color
        local fadeInAlpha = 0
        local fadeOutAlpha = 1
        if(pop.timeElapsed >= pop.fadeIn.start) then
            if(pop.fadeIn.finish == 0 and pop.fadeIn.start == 0) then
                fadeInAlpha = 1
            else
                fadeInAlpha = math.min((pop.timeElapsed - pop.fadeIn.start) / (pop.fadeIn.finish - pop.fadeIn.start), 1)
            end
        end
        if(pop.timeElapsed >= pop.fadeOut.start) then
            fadeOutAlpha = 1 - math.min((pop.timeElapsed - pop.fadeOut.start) / (pop.fadeOut.finish - pop.fadeOut.start), 1)
        end

        if(c.r ~= r or c.g ~= g or c.b ~= b or c.a~= a) then
            love.graphics.setColor(c.r, c.g, c.b, (c.a * fadeInAlpha) * fadeOutAlpha)
            return true
        else
            love.graphics.setColor(255,255,255, (255 * fadeInAlpha) * fadeOutAlpha)
            return true
        end
    end
    return false
end

function PopupTextManager:applyCircularMotion(pop)
    if(pop.duraiton == 0) then
        return
    end

    local currentAngle = (pop.circular.totalAngle / pop.duration) * pop.timeElapsed
    pop.circular._savedMovX = pop.circular.radiusX * math.cos(currentAngle)
    pop.circular._savedMovY = pop.circular.radiusY * math.sin(currentAngle)

    pop.x = pop.x + pop.circular._savedMovX
    pop.y = pop.y + pop.circular._savedMovY
end
function PopupTextManager:update(dt)
    local pop
    local deads = {}
    local deadCount = 0
    for i = 0, self.activeCount - 1 do
        --buffer
        pop = self.popups[i]
        --Check death
        if(pop.timeElapsed >= pop.duration) then
            deads[deadCount] = i
            deadCount = deadCount + 1
        end
        --Apply own update function
        if(pop.update ~= nil) then
            pop:update(dt)
        end
        --Add deltaX and Y
        pop.x = pop.x + pop.dX * dt / pop.duration
        pop.y = pop.y + pop.dY * dt / pop.duration

        --Apply circular motion
        self:applyCircularMotion(pop)
        pop.timeElapsed = pop.timeElapsed + dt
    end
    for i = 0, deadCount - 1 do
        self:kill(i)
    end
end

function PopupTextManager:render()
    local pop
    local blend = love.graphics.getBlendMode() --Used for mantaining while changing
    local initialBlend = love.graphics.getBlendMode() --Save initial state
    local r,g,b,a = love.graphics.getColor()
    local iR,iG,iB,iA = love.graphics.getColor() --Save initial state

    local initialFont = love.graphics.getFont()
    local currentFont = love.graphics.getFont()

    for i = 0, self.activeCount -1 do
        pop = self.popups[i]
        if(pop.render ~= nil) then
            pop:render()
            goto continue
        end

        --Color releated
        if(pop.blendMode ~= nil and pop.blendMode ~= blend) then
            blend = pop.blendMode
            love.graphics.setBlendMode(blend)
        end

        if(self:setPopupColor(r, g, b, a, pop)) then
            r,g,b,a = love.graphics.getColor()
        end
        if(pop.font ~= nil and pop.font ~= currentFont) then
            currentFont = pop.font
            love.graphics.setFont(currentFont)
        end

         --Render
        self.renderTextFunction(pop)
        --After render, reset to state without circular motion
        pop.x = pop.x - pop.circular._savedMovX
        pop.y = pop.y - pop.circular._savedMovY
        ::continue::
    end

    --Reset to initial state
    if(love.graphics.getBlendMode() ~= initialBlend) then
        love.graphics.setBlendMode(initialBlend)
    end
    if(r ~= iR or g ~= iG or b ~= iB or a ~= iA) then
        love.graphics.setColor(iR, iG, iB, iA)
    end
    if(currentFont ~= initialFont) then
        love.graphics.setFont(initialFont)
    end
end