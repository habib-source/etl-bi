---
title: Stock Position
---

What we hold and what it is worth. Holding value and quantity on hand come from the semantic layer, so they match every other tool using Cube.

> **Use this page to answer:** Which brands, colours and sizes tie up the most money? How much of our stock needs chilled storage? Is our stock value rising or falling over time?
>
> **Tip:** Filter by brand to see how a single brand's value and mix change. Value and quantity are measured across stock movements, so read trends rather than single points.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

```sql brands
select dim_stock_item_brand from stock_transactions group by 1 order by 1
```

{% row %}
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}
{% dropdown id="brand" data="brands" value_column="dim_stock_item_brand" title="Brand" placeholder="All brands" /%}
{% /row %}

```sql kpis
select
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_quantity_on_hand) as on_hand,
  MEASURE(avg_stock_holding_value) as avg_holding,
  MEASURE(avg_quantity_on_hand) as avg_on_hand
from stock_transactions
where {{year.filter}} and {{brand.filter}}
```

{% row %}
{% big_value data="kpis" value="sum(holding_value)" title="Holding value" fmt="usd0" info="Value of the stock held, as defined by the total_stock_holding_value measure in Cube." /%}
{% big_value data="kpis" value="sum(on_hand)" title="Quantity on hand" fmt="num0" info="Units in stock, as defined by the total_quantity_on_hand measure in Cube." /%}
{% big_value data="kpis" value="sum(avg_holding)" title="Avg holding value" fmt="usd0" info="Average holding value per record, not a total." /%}
{% big_value data="kpis" value="sum(avg_on_hand)" title="Avg quantity on hand" fmt="num0" info="Average units on hand per record, not a total." /%}
{% /row %}

## Holding value over time

```sql by_month
select
  date_trunc('month', transaction_occurred_when) as month,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1
order by 1
```

{% area_chart data="by_month" x="month" y="sum(holding_value)" y_fmt="usd0" /%}

## Where the value sits

```sql by_brand
select
  dim_stock_item_brand as brand,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1
order by 2 desc
limit 15
```

```sql by_color
select
  dim_stock_item_color_name as color,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1
order by 2 desc
limit 15
```

```sql by_size
select
  dim_stock_item_size as size,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1
order by 2 desc
limit 15
```

```sql by_chiller
select
  dim_stock_item_is_chiller_stock as is_chiller,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_quantity_on_hand) as on_hand
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1
```

{% row %}
{% horizontal_bar_chart data="by_brand" y="brand" x="holding_value" x_fmt="usd0" title="By brand" subtitle="Top 15 brands by value." /%}
{% horizontal_bar_chart data="by_color" y="color" x="holding_value" x_fmt="usd0" title="By colour" subtitle="Top 15 colours by value." /%}
{% /row %}

{% row %}
{% horizontal_bar_chart data="by_size" y="size" x="holding_value" x_fmt="usd0" title="By size" subtitle="Top 15 sizes by value." /%}
{% stack %}
### Chiller vs ambient
{% table data="by_chiller" /%}
{% /stack %}
{% /row %}

## Packaging

```sql by_package
select
  dim_stock_item_unit_package_name as unit_package,
  dim_stock_item_outer_package_name as outer_package,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_quantity_on_hand) as on_hand
from stock_transactions
where {{year.filter}} and {{brand.filter}}
group by 1, 2
order by 3 desc
limit 25
```

{% table data="by_package" /%}
