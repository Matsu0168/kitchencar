-- ============================================
-- キッチンカー注文システム - Supabase スキーマ
-- Supabase Dashboard > SQL Editor に貼り付けて実行
-- ============================================

-- 1. 店舗テーブル
create table stores (
  id uuid default gen_random_uuid() primary key,
  name text not null default 'キッチンカー',
  catch_phrase text default 'QRコードでご注文・お支払い',
  created_at timestamptz default now()
);

-- 2. メニューテーブル
create table menu_items (
  id uuid default gen_random_uuid() primary key,
  store_id uuid references stores(id) on delete cascade,
  icon text default '🍴',
  name text not null,
  description text default '',
  category text default 'その他',
  price integer not null,
  active boolean default true,
  sort_order integer default 0,
  created_at timestamptz default now()
);

-- 3. 注文テーブル
create table orders (
  id uuid default gen_random_uuid() primary key,
  store_id uuid references stores(id) on delete cascade,
  ticket_number integer not null,
  total integer not null,
  status text default 'waiting', -- waiting / ready
  created_at timestamptz default now()
);

-- 4. 注文明細テーブル
create table order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references orders(id) on delete cascade,
  item_name text not null,
  item_icon text default '🍴',
  price integer not null,
  quantity integer not null
);

-- ============================================
-- RLS（Row Level Security）設定
-- MVP段階は全公開。本番では認証を追加すること。
-- ============================================
alter table stores enable row level security;
alter table menu_items enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

create policy "public_stores_all"      on stores      for all using (true) with check (true);
create policy "public_menu_all"        on menu_items  for all using (true) with check (true);
create policy "public_orders_all"      on orders      for all using (true) with check (true);
create policy "public_order_items_all" on order_items for all using (true) with check (true);

-- ============================================
-- Realtime 有効化（注文のリアルタイム受信に必要）
-- ============================================
alter publication supabase_realtime add table orders;

-- ============================================
-- サンプルデータ（店舗 + メニュー）
-- ============================================
insert into stores (name, catch_phrase)
values ('キッチンカー', 'QRコードでご注文・お支払い')
returning id;

-- ※ 上のinsert実行後、返ってきたUUID（store_id）を下の YOUR_STORE_ID に入れて実行

-- insert into menu_items (store_id, icon, name, description, category, price)
-- values
--   ('YOUR_STORE_ID', '🌮', 'タコス（チキン）', 'スパイシーチキン・コリアンダー', 'フード', 600),
--   ('YOUR_STORE_ID', '🌯', 'ブリトー（ビーフ）', '牛バラ肉・チーズ・ピコデガヨ', 'フード', 800),
--   ('YOUR_STORE_ID', '🥤', 'クラフトコーラ', 'スパイス香るオリジナル', 'ドリンク', 400);
