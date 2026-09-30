-- Regression fixture (2026-09-30, DEFECTS #52): a closure created per loop iteration captures the
-- element BY VALUE (CAPTURE 0). The decompiled locals are flat (one variable per register for the
-- whole function) and the loop rewrites that register, so every closure saw the LAST element
-- (44.0.2 EE_Interface_Components_List Redraw p54 pc 308). Own code.
local callbacks = {}
local function Redraw(elements)
    for i = 1, #elements do
        local element = elements[i]
        local label = element .. "#" .. i
        callbacks[#callbacks + 1] = function()
            return element, label
        end
    end
end
Redraw({ "a", "b", "c" })
for index = 1, #callbacks do
    print(index, callbacks[index]())
end
