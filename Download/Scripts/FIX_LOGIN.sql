USE TEST
exec sp_change_users_login 'Auto_Fix', 'LoginForAll'
exec sp_change_users_login 'Auto_Fix', 'AppAdmin'
