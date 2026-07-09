-- 还原 admin 角色菜单权限到出厂状态
-- 之前执行的 SQL：
--   INSERT IGNORE INTO sys_role_menu (role_id, menu_id)
--   SELECT r.role_id, m.menu_id
--   FROM sys_role r, sys_menu m
--   WHERE r.role_key = 'admin'
--     AND m.perms LIKE 'system:user:%';
-- 给 admin 角色插入了 system:user:% 的全部菜单（list/query/add/edit/remove/export/import/resetPwd）
-- 用下面的 DELETE 把这些回退掉，admin 只剩 (1, 2000)

-- 1. 先预览，看哪些行会被删（不会真的删）
SELECT rm.role_id, rm.menu_id, m.menu_name, m.perms
FROM sys_role_menu rm
JOIN sys_role r ON r.role_id = rm.role_id
JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE r.role_key = 'admin'
  AND m.perms LIKE 'system:user:%';

-- 2. 确认无误后，执行删除
DELETE FROM sys_role_menu
WHERE role_id = (SELECT role_id FROM (SELECT role_id FROM sys_role WHERE role_key = 'admin') AS t)
  AND menu_id IN (
    SELECT menu_id FROM (SELECT menu_id FROM sys_menu WHERE perms LIKE 'system:user:%') AS t
  );

-- 3. 验证：admin 应该只剩 menu_id=2000 这一行
SELECT rm.role_id, rm.menu_id, m.menu_name, m.perms
FROM sys_role_menu rm
JOIN sys_role r ON r.role_id = rm.role_id
JOIN sys_menu m ON m.menu_id = rm.menu_id
WHERE r.role_key = 'admin';
