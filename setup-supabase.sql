-- ============================================
-- 智算扶手长 - Supabase 数据库建表脚本
-- 请在 Supabase SQL Editor 中运行此脚本
-- Project URL: https://mlzdvwsolkqausywtpqu.supabase.co
-- ============================================

-- 1. 管理员设置（子密码列表、更新URL、收款二维码、手机注册用户）
CREATE TABLE IF NOT EXISTS handrail_settings (
  id int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  extra_entries jsonb DEFAULT '[]'::jsonb,
  update_url text DEFAULT '',
  pay_qr_url text DEFAULT '',
  phone_regs jsonb DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now()
);

-- 插入默认行
INSERT INTO handrail_settings (id, extra_entries) 
VALUES (1, '[]'::jsonb) 
ON CONFLICT (id) DO NOTHING;

-- 2. 会员激活码
CREATE TABLE IF NOT EXISTS handrail_member_codes (
  code text PRIMARY KEY,
  plan text NOT NULL,
  used boolean DEFAULT false,
  used_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- 3. 会员数据（按设备）
CREATE TABLE IF NOT EXISTS handrail_member_data (
  device_id text PRIMARY KEY,
  type text NOT NULL DEFAULT 'free',
  expiry timestamptz,
  active boolean DEFAULT false,
  updated_at timestamptz DEFAULT now()
);

-- 4. 规格配置
CREATE TABLE IF NOT EXISTS handrail_specs (
  id int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  config jsonb DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now()
);

INSERT INTO handrail_specs (id, config) 
VALUES (1, '{}'::jsonb) 
ON CONFLICT (id) DO NOTHING;

-- 5. 用户默认规格（按设备）
CREATE TABLE IF NOT EXISTS handrail_user_specs (
  device_id text PRIMARY KEY,
  specs jsonb DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now()
);

-- 6. 计算历史（按设备）
CREATE TABLE IF NOT EXISTS handrail_history (
  id bigserial PRIMARY KEY,
  device_id text NOT NULL,
  device_label text DEFAULT '',
  data jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- ========== RLS 策略：允许 anon key 公开读写 ==========
ALTER TABLE handrail_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE handrail_member_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE handrail_member_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE handrail_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE handrail_user_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE handrail_history ENABLE ROW LEVEL SECURITY;

-- handrail_settings
CREATE POLICY "settings_select" ON handrail_settings FOR SELECT USING (true);
CREATE POLICY "settings_insert" ON handrail_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "settings_update" ON handrail_settings FOR UPDATE USING (true);

-- handrail_member_codes
CREATE POLICY "codes_select" ON handrail_member_codes FOR SELECT USING (true);
CREATE POLICY "codes_insert" ON handrail_member_codes FOR INSERT WITH CHECK (true);
CREATE POLICY "codes_update" ON handrail_member_codes FOR UPDATE USING (true);
CREATE POLICY "codes_delete" ON handrail_member_codes FOR DELETE USING (true);

-- handrail_member_data
CREATE POLICY "mdata_select" ON handrail_member_data FOR SELECT USING (true);
CREATE POLICY "mdata_insert" ON handrail_member_data FOR INSERT WITH CHECK (true);
CREATE POLICY "mdata_update" ON handrail_member_data FOR UPDATE USING (true);

-- handrail_specs
CREATE POLICY "specs_select" ON handrail_specs FOR SELECT USING (true);
CREATE POLICY "specs_insert" ON handrail_specs FOR INSERT WITH CHECK (true);
CREATE POLICY "specs_update" ON handrail_specs FOR UPDATE USING (true);

-- handrail_user_specs
CREATE POLICY "uspecs_select" ON handrail_user_specs FOR SELECT USING (true);
CREATE POLICY "uspecs_insert" ON handrail_user_specs FOR INSERT WITH CHECK (true);
CREATE POLICY "uspecs_update" ON handrail_user_specs FOR UPDATE USING (true);

-- handrail_history
CREATE POLICY "history_select" ON handrail_history FOR SELECT USING (true);
CREATE POLICY "history_insert" ON handrail_history FOR INSERT WITH CHECK (true);
CREATE POLICY "history_delete" ON handrail_history FOR DELETE USING (true);

-- 索引
CREATE INDEX IF NOT EXISTS idx_codes_plan ON handrail_member_codes(plan);
CREATE INDEX IF NOT EXISTS idx_history_device ON handrail_history(device_id);
CREATE INDEX IF NOT EXISTS idx_history_created ON handrail_history(created_at DESC);

-- 追加：为已存在的表添加 phone_regs 列（忽略已存在的错误）
ALTER TABLE handrail_settings ADD COLUMN IF NOT EXISTS phone_regs jsonb DEFAULT '{}'::jsonb;
