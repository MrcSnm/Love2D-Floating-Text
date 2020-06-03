PopupText = Class{}


function PopupText:init()
    --Text related
    self.font = nil
    self.text = ''
    self.textLength = 0

    --Transformation related
    self.x = 0
    self.y = 0
    self.dX = 0 --Delta X during duration
    self.dY = 0 --Delta Y during duration
    self.scaleX = 1
    self.scaleY = 1
    self.rotation = 0
    --Used for circular, sine and cosine motion for total angle during duration
    --Assumed to be radians, as PI is easy to control
    self.circular = {radiusX = 0, radiusY = 0, totalAngle = 0, _savedMovX = 0, _savedMovY = 0}
    
    --Color related
    self.fadeIn = {start = 0, finish = 0} --Start and end
    self.fadeOut = {start = 0, finish = 0} 
    self.color = nil
    self.blendMode = nil

    --Default
    self.duration = 0
    self.timeElapsed = 0
end

function PopupText:set(popupParams)
    --Text related
    self.font = popupParams.font
    self.text = popupParams.text
    self.textLength = (self.text ~= '') and #popupParams.text or 0

    --Default (Dont remove it, or manager will not work)
    self.duration = (popupParams.duration ~= nil) and popupParams.duration or 1
    self.timeElapsed = 0

    --Transformation related
    self.x = (popupParams.x ~= nil) and popupParams.x or 0
    self.y = (popupParams.y ~= nil) and popupParams.y or 0
    self.dX = (popupParams.dX ~= nil) and popupParams.dX or 0
    self.dY = (popupParams.dY ~= nil) and popupParams.dY or 0
    self.scaleX = (popupParams.scaleX ~= nil) and popupParams.scaleX or 1
    self.scaleY = (popupParams.scaleY ~= nil) and popupParams.scaleY or 1
    self.rotation = (popupParams.rotation ~= nil) and popupParams.rotation or 0
    self.circular = (popupParams.circular ~= nil) and popupParams.circular or {radiusX = 0, radiusY = 0, totalAngle = 0, _savedMovX = 0, _savedMovY = 0}
    self.circular.radiusX = (self.circular.radiusX == nil) and 0 or self.circular.radiusX
    self.circular.radiusY = (self.circular.radiusY == nil) and 0 or self.circular.radiusY
    self.circular.totalAngle = (self.circular.totalAngle == nil) and 0 or self.circular.totalAngle
    self.circular._savedMovX = 0
    self.circular._savedMovY = 0

    --Color related
    self.color = popupParams.color
    self.blendMode = popupParams.blendMode

    if(popupParams.fadeIn ~= nil) then
        self.fadeIn = popupParams.fadeIn
    else
        self.fadeIn = {start = 0, finish = 0}
    end

    if(popupParams.fadeOut ~= nil) then
        self.fadeOut = popupParams.fadeOut
        if(self.fadeOut.finish == nil) then
            self.fadeOut.finish = self.duration
        end
    else
        self.fadeOut = {start = 0, finish = self.duration}
        if(self.fadeIn ~= nil) then
            self.fadeOut.start = self.fadeIn.finish
        end
    end
end