local hooked = false
local _f_init = SentryGunDamage.init
function SentryGunDamage:init(...)
    _f_init(self, ...)
    if not self._is_car or hooked then
        return
    end
    local ja22_01_data = tweak_data.achievement.ja22_01
end