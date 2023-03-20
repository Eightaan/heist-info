local EHI = EHI

local tbl =
{
    [101807] = { icons = { EHI.Icons.Wait } }
}
EHI:UpdateUnits(tbl)

EHI:ShowLootCounter({
    max = 1, -- Loot objective
    additional_loot = 17, -- Paintings
    offset = managers.job:current_job_id() ~= "constantine_ondisplay_nar"
})