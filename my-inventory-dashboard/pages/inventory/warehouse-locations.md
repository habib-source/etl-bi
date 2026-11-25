---
title: Warehouse Locations
---

Bin-level view of where stock sits, and how much of it needs chilled storage.

> **Use this page to answer:** Which bins hold the most value? Which are the busiest? Is chilled storage being used heavily?
>
> **How to read it:** A *bin location* is a physical storage spot in the warehouse. The two charts show the same 25 bins ranked by value, next to how many movements touched them. Valuable but quiet bins are stock sitting still; busy but low-value bins are fast-moving items.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}

```sql chiller
select
  dim_warehouse_location_is_chiller_stock as is_chiller,
  MEASURE(total_quantity_on_hand) as on_hand,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(transaction_count) as transactions
from stock_transactions
where {{year.filter}}
group by 1
```

{% table data="chiller" /%}

## Busiest and most valuable bins

```sql bins
select
  dim_warehouse_location_bin_location as bin_location,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_quantity_on_hand) as on_hand,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_reorder_deficit) as reorder_deficit
from stock_transactions
where {{year.filter}}
group by 1
order by 2 desc
limit 25
```

{% row %}
{% horizontal_bar_chart data="bins" y="bin_location" x="holding_value" x_fmt="usd0" title="Top 25 bins by holding value" subtitle="Where the most valuable stock is stored." /%}
{% horizontal_bar_chart data="bins" y="bin_location" x="transactions" title="Transactions in those bins" subtitle="Activity in the same bins, to separate busy from idle." /%}
{% /row %}

{% table data="bins" /%}
