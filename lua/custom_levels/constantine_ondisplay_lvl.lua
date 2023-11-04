local EHI = EHI

local tbl =
{
    [101807] = { icons = { EHI.Icons.Wait } }
}
EHI:UpdateUnits(tbl)

EHI:ShowLootCounter({
    max = 18, -- Loot objective + 17 paintings
    offset = managers.job:current_job_id() ~= "constantine_ondisplay_nar"
})