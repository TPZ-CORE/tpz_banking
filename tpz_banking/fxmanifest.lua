fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Nosmakos'
description 'Titans Prudctions Banking System V 2.0 (VORP)'
version '1.0.3'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'locales.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'html/**/*'
}

escrow_ignore {
    'config.lua',
    'locales.lua',
}

lua54 'yes'
