local EHI = EHI
EHIStopwatchTracker = class(EHITracker)
EHIStopwatchTracker._forced_icons = { EHI.Icons.Wait }
EHIStopwatchTracker._fade_time = nil
function EHIStopwatchTracker:update(t, dt)
	if self._fade_time then
		self._fade_time = self._fade_time - dt
		if self._fade_time <= 0 then
			self:delete()
		end
		return
	end
    self._time = self._time + dt
    self._text:set_text(self:Format())
end

do
	local math_floor = math.floor
    local string_format = string.format
	local function SecondsOnly(self)
		local t = math_floor(self._time * 10) / 10
		if t < 0 then
			return string_format("%d", 0)
		elseif t < 100 then
			return string_format("%.2f", self._time)
		elseif t < 1000 then
			return string_format("%.1f", self._time)
		else
			return string_format("%d", t)
		end
	end

	local function MinutesAndSeconds(self)
		local t = math_floor(self._time * 10) / 10
		if t < 0 then
			return string_format("%d", 0)
		elseif t < 60 then
			return string_format("%.2f", self._time)
		else
			return string_format("%d:%02d", t / 60, t % 60)
		end
	end

	if EHI:GetOption("time_format") == 1 then
		EHIStopwatchTracker.Format = SecondsOnly
	else
		EHIStopwatchTracker.Format = MinutesAndSeconds
	end
end

function EHIStopwatchTracker:Stop()
	self._fade_time = 5
	self:AnimateBG()
end

function EHIStopwatchTracker:Reset()
	self._time = 0
	self._fade_time = nil
end

local tbl =
{
    --levels/instances/unique/chill/hockey_game
    --units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small
    [EHI:GetInstanceUnitID(100056, 15620)] = { ignore = true }
}
EHI:UpdateUnits(tbl)