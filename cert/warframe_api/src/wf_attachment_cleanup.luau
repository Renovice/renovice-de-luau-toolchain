local attachmentByAvatar = {}

function ActivateAbility(ability, avatar, rank, target)
    local old = avatar:GetAttachment("type:Attachment")
    if not IsNull(old) then
        old:Destroy()
    end
    local current = avatar:Attach("type:Attachment", ability:GetType(), rank)
    attachmentByAvatar[avatar] = current
    target:Attach(current)
    return current, old
end

function DeactivateAbility(ability, avatar, effect)
    local current = attachmentByAvatar[avatar]
    if IsNull(current) then
        current = effect
    end
    if not IsNull(current) then
        current:Destroy()
    end
    attachmentByAvatar[avatar] = nil
    return current
end
