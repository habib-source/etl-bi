---
title: Reorder Risk
---

Where stock is short of its reorder level, and how long replenishment takes.

> **Use this page to answer:** Which items are furthest below their reorder level? Which suppliers are behind those shortfalls? Are the shortfalls ones we can fix quickly or slowly?
>
> **How to read it:** *Deficit* is the number of units below the reorder level, so bigger means more urgent. *Lead time* is how many days the supplier needs to deliver. A big deficit with a long lead time is the highest risk, because it takes longest to recover. Items with no deficit are hidden.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

```sql suppliers
select dim_supplier_supplier_name from stock_transactions group by 1 order by 1
```

{% row %}
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}
{% dropdown id="supplier" data="suppliers" value_column="dim_supplier_supplier_name" title="Supplier" placeholder="All suppliers" /%}
{% /row %}

```sql kpis
select
  MEASURE(total_reorder_deficit) as deficit,
  MEASURE(total_quantity_on_hand) as on_hand
from stock_transactions
where {{year.filter}} and {{supplier.filter}}
```

{% row %}
{% big_value data="kpis" value="sum(deficit)" title="Total reorder deficit (units)" fmt="num0" info="Units by which stock sits below the item's reorder level. Higher means more urgent." /%}
{% big_value data="kpis" value="sum(on_hand)" title="Quantity on hand" fmt="num0" info="Units in stock, as defined by the total_quantity_on_hand measure in Cube." /%}
{% /row %}

## Items furthest below reorder level

```sql top_deficit
select
  dim_stock_item_stock_item_name as stock_item,
  MEASURE(total_reorder_deficit) as deficit
from stock_transactions
where {{year.filter}} and {{supplier.filter}}
group by 1
having MEASURE(total_reorder_deficit) > 0
order by 2 desc
limit 20
```

{% horizontal_bar_chart data="top_deficit" y="stock_item" x="deficit" x_fmt="num0" /%}

## Deficit by supplier

```sql deficit_supplier
select
  dim_supplier_supplier_name as supplier,
  MEASURE(total_reorder_deficit) as deficit
from stock_transactions
where {{year.filter}} and {{supplier.filter}}
group by 1
having MEASURE(total_reorder_deficit) > 0
order by 2 desc
limit 15
```

## Lead time vs deficit

Items that are short *and* slow to replenish are the real risk. The chart totals the shortfall for each lead time; the table underneath lists the individual items.

```sql lead_summary
select
  dim_stock_item_lead_time_days as lead_time_days,
  MEASURE(total_reorder_deficit) as deficit
from stock_transactions
where {{year.filter}} and {{supplier.filter}}
group by 1
having MEASURE(total_reorder_deficit) > 0
order by 1
```

```sql lead_time
select
  dim_stock_item_stock_item_name as stock_item,
  dim_stock_item_lead_time_days as lead_time_days,
  MEASURE(total_reorder_deficit) as deficit
from stock_transactions
where {{year.filter}} and {{supplier.filter}}
group by 1, 2
having MEASURE(total_reorder_deficit) > 0
order by 3 desc
limit 200
```

{% row %}
{% bar_chart data="deficit_supplier" x="supplier" y="sum(deficit)" y_fmt="num0" title="Deficit by supplier" subtitle="Suppliers behind the biggest shortfalls." /%}
{% bar_chart data="lead_summary" x="lead_time_days" y="sum(deficit)" y_fmt="num0" title="Total deficit by supplier lead time (days)" subtitle="Tall bars on the right = big shortfalls that take a long time to fix" /%}
{% /row %}

{% table data="lead_time" /%}
