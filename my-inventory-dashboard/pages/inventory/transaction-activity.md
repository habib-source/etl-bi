---
title: Transaction Activity
---

How much stock is moving, what kind of movement it is, and when.

> **Use this page to answer:** How busy is the warehouse? Which transaction types drive the activity? Are there seasonal, quarterly or weekday patterns?
>
> **How to read it:** A *transaction* is one recorded stock movement. Quantity is **net**: receipts add stock and issues remove it, so a negative net quantity means more stock left than arrived. Use the type filter to look at one kind of movement at a time.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

```sql types
select dim_transaction_type_transaction_type_name from stock_transactions group by 1 order by 1
```

{% row %}
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}
{% dropdown id="ttype" data="types" value_column="dim_transaction_type_transaction_type_name" title="Transaction type" placeholder="All types" /%}
{% /row %}

```sql kpis
select
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity,
  MEASURE(avg_transaction_quantity) as avg_quantity
from stock_transactions
where {{year.filter}} and {{ttype.filter}}
```

{% row %}
{% big_value data="kpis" value="sum(transactions)" title="Transactions" fmt="num0" info="Number of stock movements recorded: receipts, issues, adjustments and credit notes." /%}
{% big_value data="kpis" value="sum(quantity)" title="Net quantity" fmt="num0" info="Units received minus units issued. Negative means more stock left than arrived." /%}
{% big_value data="kpis" value="sum(avg_quantity)" title="Avg quantity per transaction" fmt="num1" info="Average units moved in a single transaction." /%}
{% /row %}

## Monthly volume by type

```sql monthly_type
select
  date_trunc('month', transaction_occurred_when) as month,
  dim_transaction_type_transaction_type_name as transaction_type,
  MEASURE(transaction_count) as transactions
from stock_transactions
where {{year.filter}} and {{ttype.filter}}
group by 1, 2
order by 1
```

{% bar_chart data="monthly_type" x="month" y="sum(transactions)" series="transaction_type" title="Transactions per month, by type" subtitle="Stacked bars show each type's share of monthly activity." /%}

## Calendar patterns

```sql by_quarter
select
  dim_date_calendar_year as calendar_year,
  dim_date_quarter_name as quarter,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where {{year.filter}} and {{ttype.filter}}
group by 1, 2
order by 1, 2
```

```sql by_weekday
select
  dim_date_day_name as weekday,
  MEASURE(transaction_count) as transactions
from stock_transactions
where {{year.filter}} and {{ttype.filter}}
group by 1
order by 2 desc
```

```sql weekend
select
  dim_date_is_weekend as is_weekend,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where {{year.filter}} and {{ttype.filter}}
group by 1
```

{% row %}
{% horizontal_bar_chart data="by_weekday" y="weekday" x="transactions" title="Transactions by weekday" subtitle="Which days are busiest." /%}
{% stack %}
### Weekend vs weekday
{% table data="weekend" /%}
{% /stack %}
{% /row %}

### By quarter

{% table data="by_quarter" /%}
