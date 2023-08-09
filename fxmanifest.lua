---
--- @author Neyu
--- @version 1.0.0
--- created at [04/07/2023 21:00]
---

fx_version ('cerulean')

games ({ 'gta5' });

server_scripts ({
    "@mysql-async/lib/MySQL.lua",
    "server/*.lua",
});

shared_scripts ({
    "shared/*.lua",
    '@es_extended/imports.lua',
});

client_scripts ({
    -- RageUI
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    -- Fichier client
    "client/*.lua",
});