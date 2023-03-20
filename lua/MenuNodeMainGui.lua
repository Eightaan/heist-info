local EHI = EHI
local old = MenuNodeMainGui._setup_item_rows
function MenuNodeMainGui:_setup_item_rows(...)
    old(self, ...)
    if EHI._cache.SaveFileCorrupted then -- Should always show, because it is important
        QuickMenu:new(
            managers.localization:text("ehi_save_data_corrupted"),
            managers.localization:text("ehi_save_data_corrupted_desc"),
            {
                {
                    text = managers.localization:text("ehi_button_ok"),
                    is_cancel_button = true
                }
            },
            true
        )
        EHI._cache.SaveFileCorrupted = nil
    end
end