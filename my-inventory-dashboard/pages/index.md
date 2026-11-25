---
title: Stock Operations Overview
---

Inventory movements, holding value and reorder status for Wide World Importers, served live from the Cube `stock_transactions` view.

> **How to use this dashboard.** Pick a calendar year in the filter to focus every number and chart on that year, or leave it on *All years*. Hover over the **i** icon on a tile for its definition, hover over a chart for exact values, and use the links at the bottom to go deeper. A glossary of terms is at the end of the page.
>
> **About the data.** This is the Wide World Importers sample database (2013 to 2016), so "latest" means the end of that period, not today.

```sql years
select dim_date_calendar_year
from stock_transactions
group by 1
order by 1
```

{% row align="center" justify="between" %}
## Headline numbers
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}
{% /row %}

```sql kpis
select
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity_moved,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_reorder_deficit) as reorder_deficit,
  MEASURE(avg_last_cost_price) as avg_last_cost
from stock_transactions
where {{year.filter}}
```

{% row %}
{% big_value data="kpis" value="sum(transactions)" title="Transactions" fmt="num0" info="Number of stock movements recorded: receipts, issues, adjustments and credit notes." /%}
{% big_value data="kpis" value="sum(quantity_moved)" title="Net quantity moved" fmt="num0" info="Units received minus units issued. Negative means more stock left than arrived." /%}
{% big_value data="kpis" value="sum(holding_value)" title="Stock holding value" fmt="usd0" info="Value of the stock held, as defined by the total_stock_holding_value measure in Cube." /%}
{% big_value data="kpis" value="sum(reorder_deficit)" title="Reorder deficit (units)" fmt="num0" info="Units by which stock sits below the item's reorder level. Higher means more urgent." /%}
{% big_value data="kpis" value="sum(avg_last_cost)" title="Avg last cost price" fmt="usd2" info="Average of the most recent cost per unit paid to suppliers." /%}
{% /row %}

## Trend

```sql monthly
select
  date_trunc('month', transaction_occurred_when) as month,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}}
group by 1
order by 1
```

{% row %}
{% line_chart data="monthly" x="month" y="sum(transactions)" title="Transactions per month" subtitle="Overall activity level. Spikes are busy periods." /%}
{% line_chart data="monthly" x="month" y="sum(holding_value)" y_fmt="usd0" title="Stock holding value per month" subtitle="Money tied up in stock over time." /%}
{% /row %}

## Mix

```sql by_type
select
  dim_transaction_type_transaction_type_name as transaction_type,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where {{year.filter}}
group by 1
order by 2 desc
```

```sql top_suppliers
select
  dim_supplier_supplier_name as supplier,
  MEASURE(total_stock_holding_value) as holding_value
from stock_transactions
where {{year.filter}}
group by 1
order by 2 desc
limit 10
```

{% row %}
{% horizontal_bar_chart data="by_type" y="transaction_type" x="transactions" title="Transactions by type" subtitle="Which kinds of movement dominate." /%}
{% horizontal_bar_chart data="top_suppliers" y="supplier" x="holding_value" x_fmt="usd0" title="Top 10 suppliers by holding value" subtitle="The suppliers whose stock is worth the most." /%}
{% /row %}

## Dashboards

- [Stock position](/inventory/stock-position): what we hold, by brand, colour, size and chiller status
- [Reorder risk](/inventory/reorder-risk): reorder deficits and lead times
- [Transaction activity](/inventory/transaction-activity): volumes by type, month, quarter and weekday
- [Item explorer](/inventory/item-explorer): filterable item-level detail
- [Warehouse locations](/inventory/warehouse-locations): bin-level holdings
- [Supplier performance](/suppliers/supplier-performance): value, terms and lead time by supplier
- [Sales and purchasing flow](/traceability/sales-and-purchasing): customer, invoice and purchase-order linked movements

## Glossary

| Term | Meaning |
|---|---|
| **Transaction** | One recorded stock movement: a receipt, issue, adjustment or credit note. |
| **Net quantity** | Units received minus units issued. Negative means more stock left than arrived. |
| **Quantity on hand** | Units currently in stock. |
| **Holding value** | The value of the stock held. |
| **Reorder deficit** | Units below an item's reorder level. Zero means the item is healthy. |
| **Lead time** | Days a supplier needs to deliver after an order. |
| **Chiller stock** | Items that must be stored in chilled (refrigerated) space. |
| **Bin location** | A physical storage spot in the warehouse. |
| **Payment days** | How long we have to pay a supplier after delivery. |

Every figure comes from measures defined once in Cube, so these numbers match any other tool connected to the same semantic layer.
