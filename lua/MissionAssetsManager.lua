if EHI:CheckLoadHook("MissionAssetsManager") then
    return
end

function MissionAssetsManager:IsEscapeDriverAssetUnlocked()
    local asset = self:_get_asset_by_id("safe_escape")
    return asset and asset.unlocked
end