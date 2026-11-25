---
title: Supplier Performance
---

Value, terms and replenishment speed by supplier.

> **Use this page to answer:** Which suppliers and supplier categories do we depend on most? What payment terms and delivery methods do they use? Which suppliers are linked to reorder shortfalls?
>
> **How to read it:** *Payment days* is how long we have to pay after delivery. *Avg last cost* is the average of the most recent purchase price per unit. The scorecard is sorted by holding value, so the suppliers at the top matter most to the business.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

```sql categories
select dim_supplier_supplier_category_name from stock_transactions group by 1 order by 1
```

{% row %}
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}
{% dropdown id="category" data="categories" value_column="dim_supplier_supplier_category_name" title="Supplier category" placeholder="All categories" /%}
{% /row %}

```sql by_category
select
  dim_supplier_supplier_category_name as supplier_category,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(transaction_count) as transactions
from stock_transactions
where {{year.filter}} and {{category.filter}}
group by 1
order by 2 desc
```

```sql by_delivery
select
  dim_supplier_delivery_method_name as delivery_method,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_reorder_deficit) as reorder_deficit
from stock_transactions
where {{year.filter}} and {{category.filter}}
group by 1
order by 2 desc
```

{% row %}
{% bar_chart data="by_category" x="supplier_category" y="sum(holding_value)" y_fmt="usd0" title="Holding value by supplier category" subtitle="Which types of supplier we depend on." /%}
{% bar_chart data="by_delivery" x="delivery_method" y="sum(holding_value)" y_fmt="usd0" title="Holding value by delivery method" subtitle="How the stock we hold is delivered." /%}
{% /row %}

## Payment terms

```sql terms
select
  dim_supplier_payment_days as payment_days,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(transaction_count) as transactions
from stock_transactions
where {{year.filter}} and {{category.filter}}
group by 1
order by 1
```

{% bar_chart data="terms" x="payment_days" y="sum(holding_value)" y_fmt="usd0" title="Holding value by payment terms (days)" subtitle="Longer terms give us more time to pay." /%}

## Supplier scorecard

```sql scorecard
select
  dim_supplier_supplier_name as supplier,
  dim_supplier_supplier_category_name as category,
  dim_supplier_delivery_method_name as delivery_method,
  dim_supplier_payment_days as payment_days,
  dim_supplier_delivery_city_name as delivery_city,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_reorder_deficit) as reorder_deficit,
  MEASURE(avg_last_cost_price) as avg_last_cost
from stock_transactions
where {{year.filter}} and {{category.filter}}
group by 1, 2, 3, 4, 5
order by 7 desc
limit 100
```

{% table data="scorecard" /%}

## Supplier locations

```sql cities
select
  dim_supplier_postal_city_name as postal_city,
  dim_supplier_delivery_city_name as delivery_city,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}} and {{category.filter}}
group by 1, 2
order by 3 desc
limit 25
```

{% table data="cities" /%}
