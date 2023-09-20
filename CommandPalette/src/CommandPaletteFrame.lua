local _, addon = ...;

local L = addon.L;

function MixinCommandPaletteFrame(self)
    self:SetTitle(L["Command Palette"]);

    ButtonFrameTemplate_HidePortrait(self);

    do -- Make Show/Hide secure.
        local _show = self.Show;
        function self:Show()
            return not InCombatLockdown() and _show(self);
        end;

        local _hide = self.Hide;
        function self:Hide()
            return not InCombatLockdown() and _hide(self);
        end;
    end;

    do -- Search Box
        local searchBox = self.SearchBox;
        searchBox:Disable();

        searchBox:HookScript("OnShow", function()
            CommandPalette.SetSearch("");
            -- Hack to ensure certain keybinds do not get inserted into the search box.
            C_Timer.After(0, function()
                searchBox:Enable();
                searchBox:SetFocus();
            end);
        end);

        hooksecurefunc(CommandPalette, "SetSearch", function(search)
            searchBox:SetText(search);
        end);

        searchBox:HookScript("OnTextChanged", function(_, userInput)
            return userInput and CommandPalette.SetSearch(searchBox:GetText());
        end);

        searchBox:HookScript("OnEscapePressed", function()
            self:Hide();
        end);

        searchBox:HookScript("OnHide", function()
            searchBox:Disable();
            ClearOverrideBindings(CommandPaletteSecureActionButton);
        end);

        do
            local _ticker = nil;

            searchBox:HookScript("OnKeyDown", function(_, key)
                if key == "UP" then
                    CommandPalette.OffsetSelected(-1);
                elseif key == "DOWN" then
                    CommandPalette.OffsetSelected(1);
                elseif key == "ENTER" then
                    if _ticker ~= nil then
                        _ticker:Cancel();
                    end;
                    _ticker = C_Timer.NewTicker(0, function()
                        if not IsKeyDown(key) then
                            if _ticker ~= nil then
                                _ticker:Cancel();
                            end;
                            ExecuteFrameScript(CommandPaletteSecureActionButton, "OnClick");
                        end;
                    end);
                end;
                searchBox:SetPropagateKeyboardInput(key == "ENTER");
            end);
        end;
    end;

    do -- Scroll Box
        local scrollBox = self.ScrollBox;
        local scrollBar = self.ScrollBar;
        local scrollView = CreateScrollBoxListLinearView(8, 8, 8, 8, 8);

        scrollView:SetElementInitializer("CommandPaletteButtonTemplate", function(frame, data)
            frame:SetActionData(data);
        end);

        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);

        scrollBox:SetDataProvider(CommandPalette.GetActions());

        scrollBox.ScrollTarget:SetPassThroughButtons("BUTTON1");

        hooksecurefunc(CommandPalette, "SetSelected", function(data)
            scrollBox:ScrollToElementData(data);
        end);
    end;

    do -- Events
        local events = {
            PLAYER_REGEN_DISABLED = function(...)
                self:Hide();
            end,
        };

        self:HookScript("OnEvent", function(_, event, ...)
            return events[event] and events[event](...);
        end);

        for event in pairs(events) do
            self:RegisterEvent(event);
        end;
    end;

    return self;
end;