---
title: Item Explorer
---

Filter down to any slice of the catalogue and see item-level movement, holding and reorder status.

> **Use this page to answer:** "Tell me everything about this item or group of items." Combine the filters, then click column headings in the table to sort. The table is limited to the 500 items with the highest holding value.
>
> **Columns:** *Net quantity* is receipts minus issues. *On hand* is current stock. *Holding value* is what that stock is worth. *Reorder deficit* is units below the reorder level (0 means healthy). *Lead time* is the supplier's delivery time in days.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

```sql brands
select dim_stock_item_brand from stock_transactions group by 1 order by 1
```

```sql suppliers
select dim_supplier_supplier_name from stock_transactions group by 1 order by 1
```

```sql types
select dim_transaction_type_transaction_type_name from stock_transactions group by 1 order by 1
```

{% row %}
{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Year" placeholder="All" /%}
{% dropdown id="brand" data="brands" value_column="dim_stock_item_brand" title="Brand" placeholder="All" /%}
{% dropdown id="supplier" data="suppliers" value_column="dim_supplier_supplier_name" title="Supplier" placeholder="All" /%}
{% dropdown id="ttype" data="types" value_column="dim_transaction_type_transaction_type_name" title="Type" placeholder="All" /%}
{% /row %}

```sql items
select
  dim_stock_item_stock_item_name as stock_item,
  dim_stock_item_brand as brand,
  dim_stock_item_color_name as color,
  dim_stock_item_size as size,
  dim_supplier_supplier_name as supplier,
  dim_stock_item_lead_time_days as lead_time_days,
  dim_stock_item_unit_price as unit_price,
  dim_stock_item_recommended_retail_price as retail_price,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as net_quantity,
  MEASURE(total_quantity_on_hand) as on_hand,
  MEASURE(total_stock_holding_value) as holding_value,
  MEASURE(total_reorder_deficit) as reorder_deficit
from stock_transactions
where {{year.filter}} and {{brand.filter}} and {{supplier.filter}} and {{ttype.filter}}
group by 1, 2, 3, 4, 5, 6, 7, 8
order by 12 desc
limit 500
```

{% row %}
{% big_value data="items" value="count(stock_item)" title="Items matching" fmt="num0" info="Number of items that match the filters above (maximum 500 shown)." /%}
{% big_value data="items" value="sum(holding_value)" title="Holding value" fmt="usd0" info="Value of the stock held, as defined by the total_stock_holding_value measure in Cube." /%}
{% big_value data="items" value="sum(reorder_deficit)" title="Reorder deficit" fmt="num0" info="Units by which stock sits below the item's reorder level. Higher means more urgent." /%}
{% /row %}

{% table data="items" /%}
