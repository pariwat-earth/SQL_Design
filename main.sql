--1.customers --dimention
create table customers(
  customer_id int not null primary key,
  firstname text,
  lastname text,
  address text,
  phone text,
  remark text
);
insert into customers values
(1,'Pariwat','Paiwong','new apg','111',''),
(2,'Harry','Potter','the lift','222',''),
(3,'Ron','Weasley','The Burrow','333',''),
(4,'Draco','Malfoy','Malfoy Manor','444','');
--2.products --dimention
create table products (
  product_id int not null primary key,
  product_name text,
  product_price real,
  type text
);
insert into products values
(1,'ส้มตำไทย',60.00,'Food'),
(2,'ส้มตำลาว',60.00,'Food'),
(3,'ส้มตำโคราช',60.00,'Food'),
(4,'น้ำส้ม',60.00,'Drink'),
(5,'น้ำมะพร้าว',60.00,'Drink'),
(6,'coca-cola',60.00,'Drink');
--3.Rider --dimention
create table rider (
  rider_id int not null primary key,
  affliliation text,
  rider_phone text,
  rider_nikename text
);
insert into rider values
  (1,'grab','g001','ton'),
  (2,'linemen','l002','pon'),
  (3,'robinhood','r003','toy'),
  (4,'shopee food','s004','boy');
--4.Promotion --dimention
create table promotion(
  code_promotion text not null primary key,
  type text,
  action text,
  strat_promotion text,
  end_promotion text,
  quantity int
);
insert into promotion values
  ('er001','discount','-10%','2022-08-27','2002-12-1',100),
  ('er002','discount','-20%','2022-08-28','2002-08-30',10),
  ('er003','giveaway','MG Car','2022-08-27','2002-08-28',1),
  ('er004','giveaway','The Lift condo','2022-12-30','2002-12-30',50);
--5.sales_delivery_bangkok --fact
create table sales_delivery_bangkok(
  order_id int not null primary key,
  product_id int,
  customer_id int,
  pay_status boolean,
  rider_id int,
  code_promotion text,
  order_date text,
  foreign key (product_id)  REFERENCES products(product_id),
  foreign key (customer_id)  REFERENCES customers(customer_id),
  foreign key (rider_id)  REFERENCES rider(rider_id),
  foreign key (code_promotion)  REFERENCES promotion(code_promotion)
);
insert into sales_delivery_bangkok values
  (1, 1, 1, true, 2, 'er001', '2022-08-25'),
  (2, 2, 2, true, 2, 'er002', '2022-08-25'),
  (3, 2, 3, true, 2, 'er003', '2022-08-25'),
  (4, 3, 4, false, 1, 'er004', '2022-08-25'),
  (5, 1, 1, true, 3, 'er001', '2022-08-26'),
  (6, 2, 2, true, 2, 'er002', '2022-08-26'),
  (7, 5, 3, true, 2, 'er003', '2022-08-26'),
  (8, 3, 3, true, 4, 'er004', '2022-08-26'),
  (9, 1, 1, true, 3, 'er001', '2022-08-26'),
  (10, 2, 3, true, 2, 'er002', '2022-08-26'),
  (11, 5, 3, true, 2, 'er003', '2022-08-26'),
  (12, 3, 4, true, 4, 'er004', '2022-08-26'),
  (13, 1, 1, true, 2, 'er001', '2022-08-27'),
  (14, 2, 2, true, 4, 'er002', '2022-08-27'),
  (15, 5, 3, false, 2, 'er003', '2022-08-27'),
  (16, 3, 4, true, 1, 'er004', '2022-08-27'),
  (17, 3, 4, true, 1, 'er004', '2022-08-27'),
  (18, 3, 4, true, 1, 'er004', '2022-08-27'),
  (19, 3, 4, true, 1, 'er004', '2022-08-27'),
  (20, 3, 4, true, 1, 'er004', '2022-08-27'),
  (21, 3, 4, true, 1, 'er004', '2022-08-27'),
  (22, 3, 4, true, 1, 'er004', '2022-08-27');

  
.mode markdown
.header on;


select * from customers;
select * from products;
select * from rider;
select * from promotion;
select * from sales_delivery_bangkok;

--queries analyze data
--1.ดูว่าลูกค้าสั่งไปคนละกี่ครั้ง ใครซื้อมากที่สุด
select
  count(*) as 'order',
  cus.firstname,
  cus.lastname,
  cus.phone,
  cus.address
from sales_delivery_bangkok as seb
join customers as cus
on seb.customer_id = cus.customer_id
group by seb.customer_id
order by count(*) desc;

--2.ดูสินค้าที่ยอดสั้งซื้อมากกว่า5ครั้ง
select 
  prod.product_name as menu,
  count(*) as 'order'
  from sales_delivery_bangkok as seb
  join products prod
  on seb.product_id = prod.product_id
  group by seb.product_id
  having count(*) >= 5
  order by count(*) desc;

--3.ดูเฉพาะคำสั่งของลูกค้าแยกตามzone
--subquery with
with location_order as(
  select 
  cus.address as address,
  case 
      when cus.address in ('the lift','new apg') then 'bongkok zone1'
      when cus.address in ('Malfoy Manor') then 'bongkok zone2'
      else 'other zone'
    end as location
from sales_delivery_bangkok as seb
join customers cus 
on seb.customer_id = cus.customer_id
)

select 
  location,
  count(*) as 'order'
from location_order
group by 1
order by 2 desc;

--4.ดูโปรที่คนให้ความสนใจ
select 
  seb.code_promotion as 'code',
  case 
    when pro.type in ('discount') then 'ส่วนลด'
    when pro.type in ('giveaway') then 'ลุ้นรับ'
  else 'อื่นๆ'
  end as ประเภท,
  pro.action as กิจกรรม,
  count(*) as จำนวน
from sales_delivery_bangkok as seb
join promotion as pro
on seb.code_promotion = pro.code_promotion
group by code
order by count(*) desc;

