"""
PROJECT: Olist Supply Chain Optimization
AUTHOR: Muhammad Sami Ullah (Data Analyst)
OBJECTIVE: Automated Diagnostic of Delivery Delays and Regional Bottlenecks.
"""

import pandas as pd
import matplotlib.pyplot as plt

# --- GLOBAL CONFIGURATION (Nordic Standard) ---
CRITICAL_DELAY_PCT = 10
OTD_BENCHMARK = 90.0
TOP_N = 10

class SupplyChainAnalyst:
    def __init__(self, orders_file, customers_file, payments_file, items_file):
        self.files = [orders_file, customers_file, payments_file, items_file]
        self.df = None

    def load_and_merge(self):
        print("LOG: Executing Specialist-Grade Ingestion...")
        orders = pd.read_csv(self.files[0])
        customers = pd.read_csv(self.files[1])
        payments_raw = pd.read_csv(self.files[2])
        items = pd.read_csv(self.files[3])

        # Aggregate to maintain 1-row-per-order grain
        payments = payments_raw.groupby('order_id')['payment_value'].sum().reset_index()
        seller_counts = items.groupby('order_id')['seller_id'].nunique().reset_index(name='seller_count')

        orders = orders[orders['order_status'] == 'delivered'].copy()
        for col in ['order_delivered_customer_date', 'order_estimated_delivery_date', 'order_purchase_timestamp']:
            orders[col] = pd.to_datetime(orders[col])

        # Master Merge
        df = pd.merge(orders, customers[['customer_id', 'customer_city']], on='customer_id', how='left')
        df = pd.merge(df, payments, on='order_id', how='left')
        self.df = pd.merge(df, seller_counts, on='order_id', how='left')
        self.df['payment_value'] = self.df['payment_value'].fillna(0)

    def run_diagnostics(self):
        print("LOG: Running Operational & Root Cause Diagnostics...")
        self.df['wait_time'] = (self.df['order_delivered_customer_date'] - self.df['order_purchase_timestamp']).dt.days
        late_mask = self.df['order_delivered_customer_date'] > self.df['order_estimated_delivery_date']
        self.df['is_late'] = late_mask.astype(int)
        self.df['revenue_at_risk'] = self.df['payment_value'].where(late_mask, 0)
        
        # OTD KPI
        self.otd_rate = (1 - self.df['is_late'].mean()) * 100

        # City-Level Risk Matrix
        self.city_risk_matrix = self.df.groupby('customer_city').agg(
            order_volume=('order_id', 'count'),
            revenue_loss=('revenue_at_risk', 'sum'),
            late_pct=('is_late', 'mean')
        ).sort_values('revenue_loss', ascending=False).head(TOP_N)
        self.city_risk_matrix['late_pct'] = (self.city_risk_matrix['late_pct'] * 100).round(2)

        # FIX 7: Seller-City Interaction (The Root Cause Layer)
        self.seller_city_risk = self.df.groupby(['customer_city', 'seller_count']).agg(
            orders=('order_id', 'count'),
            late_pct=('is_late', 'mean'),
            revenue_loss=('revenue_at_risk', 'sum')
        ).sort_values('revenue_loss', ascending=False).head(15)
        self.seller_city_risk['late_pct'] = (self.seller_city_risk['late_pct'] * 100).round(2)

    def export_reports(self):
        # Professional CSV Outputs
        self.city_risk_matrix.to_csv("city_volume_value_matrix.csv")
        self.seller_city_risk.to_csv("seller_city_root_cause.csv")
        
        fig, ax = plt.subplots(2, 1, figsize=(12, 12))
        ax[0].bar(self.city_risk_matrix.index, self.city_risk_matrix['revenue_loss'], color='#d9534f')
        ax[0].set_title("Revenue Leakage by City", fontweight='bold')
        ax[0].tick_params(axis='x', rotation=45)

        ax[1].scatter(self.city_risk_matrix['order_volume'], self.city_risk_matrix['late_pct'], s=100, color='#5bc0de')
        plt.tight_layout()
        plt.savefig("supply_chain_specialist_dashboard.png")
        print("LOG: All Executive Reports & Root Cause Files Exported.")

    def recommend(self):
        print("\n" + "="*45 + "\nROOT CAUSE & STRATEGIC RECOMMENDATIONS\n" + "="*45)
        print(f"GLOBAL OTD: {self.otd_rate:.2f}%")
        
        # Display Interaction Hotspots
        print("\nROOT CAUSE HOTSPOTS (City + Seller Complexity):")
        print(self.seller_city_risk.head(3))

        top_city = self.city_risk_matrix.index[0]
        loss = self.city_risk_matrix.iloc[0]['revenue_loss']
        print(f"\nACTION PRIORITY: Audit logistics in {top_city} (Total Risk: ${loss:,.2f}).")

if __name__ == "__main__":
    analyst = SupplyChainAnalyst('olist_orders_dataset.csv', 'olist_customers_dataset.csv', 'olist_order_payments_dataset.csv', 'olist_order_items_dataset.csv')
    analyst.load_and_merge()
    analyst.run_diagnostics()
    analyst.export_reports()
    analyst.recommend()