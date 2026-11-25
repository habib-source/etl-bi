---
title: Sales and Purchasing Flow
---

Stock movements that trace back to a customer invoice (outbound) or a purchase order (inbound).

> **Use this page to answer:** How much stock movement is driven by customer sales versus supplier purchases? Which customers, purchase orders and invoices account for the most activity?
>
> **How to read it:** Each stock movement can point to a customer and invoice (stock going out to a sale) or to a purchase order (stock coming in from a supplier). Movements with neither, such as adjustments, appear in neither group, so the two sets are not expected to add up to the total. Customers and invoices are shown as ID numbers because names are not in this view.

```sql years
select dim_date_calendar_year from stock_transactions group by 1 order by 1
```

{% dropdown id="year" data="years" value_column="dim_date_calendar_year" title="Calendar year" placeholder="All years" /%}

```sql customer_linked
select
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where customer_id is not null and {{year.filter}}
```

```sql po_linked
select
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where purchase_order_id is not null and {{year.filter}}
```

{% row %}
{% big_value data="customer_linked" value="sum(transactions)" title="Customer / invoice-linked movements" fmt="num0" info="Movements that point to a customer invoice, i.e. stock leaving for a sale." /%}
{% big_value data="customer_linked" value="sum(quantity)" title="Net quantity (customer-linked)" fmt="num0" info="Net units on customer/invoice-linked movements. Usually negative because stock leaves." /%}
{% big_value data="po_linked" value="sum(transactions)" title="Purchase-order-linked movements" fmt="num0" info="Movements that point to a purchase order, i.e. stock arriving from a supplier." /%}
{% big_value data="po_linked" value="sum(quantity)" title="Net quantity (PO-linked)" fmt="num0" info="Net units on purchase-order-linked movements. Usually positive because stock arrives." /%}
{% /row %}

## Linked movements per month

```sql monthly_customer
select
  date_trunc('month', transaction_occurred_when) as month,
  MEASURE(transaction_count) as customer_linked
from stock_transactions
where customer_id is not null and {{year.filter}}
group by 1
order by 1
```

```sql monthly_po
select
  date_trunc('month', transaction_occurred_when) as month,
  MEASURE(transaction_count) as po_linked
from stock_transactions
where purchase_order_id is not null and {{year.filter}}
group by 1
order by 1
```

{% row %}
{% line_chart data="monthly_customer" x="month" y="sum(customer_linked)" title="Customer-linked movements" subtitle="Outbound movements tied to a customer invoice." /%}
{% line_chart data="monthly_po" x="month" y="sum(po_linked)" title="Purchase-order-linked movements" subtitle="Inbound movements tied to a purchase order." /%}
{% /row %}

## Top customers by movement volume

```sql top_customers
select
  customer_id,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where customer_id is not null and {{year.filter}}
group by 1
order by 2 desc
limit 20
```

## Top purchase orders by quantity received

```sql top_pos
select
  purchase_order_id,
  dim_supplier_supplier_name as supplier,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where purchase_order_id is not null and {{year.filter}}
group by 1, 2
order by 4 desc
limit 20
```

{% row %}
{% table data="top_customers" /%}
{% table data="top_pos" /%}
{% /row %}

## Invoice lookup

```sql invoices
select
  invoice_id,
  customer_id,
  MEASURE(transaction_count) as transactions,
  MEASURE(total_transaction_quantity) as quantity
from stock_transactions
where invoice_id is not null and {{year.filter}}
group by 1, 2
order by 3 desc
limit 50
```

{% table data="invoices" /%}
