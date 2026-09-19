import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/luxury_theme.dart';
import '../models/order.dart';
import '../providers/shop_provider.dart';
import '../widgets/luxury_divider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? _expandedOrderId;

  String _formatDate(DateTime date) {
    const months = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour == 0 
        ? 12 
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final min = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? "PM" : "AM";
    return "$month $day, $year • $hour:$min $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final orders = provider.orders;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;

    // Expects to be given a bounded height by its parent (e.g. wrapped in
    // an Expanded inside a Column) — the desktop split view scrolls each
    // side independently.
    return orders.isEmpty
        ? _buildEmptyLedger()
        : isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop Left Column: List of standard orders
                  Expanded(
                    flex: 6,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isExpanded = _expandedOrderId == order.id;
                        if (_expandedOrderId == null && index == 0) {
                          // Auto expand first order on desktop
                          _expandedOrderId = order.id;
                        }
                        return _buildOrderListItem(order, isExpanded, true);
                      },
                    ),
                  ),

                  // Desktop Right Column: Focus and trace selected order timeline details
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                      child: _expandedOrderId == null
                          ? const SizedBox()
                          : _buildDetailedTraceBoard(
                              orders.firstWhere((o) => o.id == _expandedOrderId),
                            ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isExpanded = _expandedOrderId == order.id;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildOrderListItem(order, isExpanded, false),
                      if (isExpanded) ...[
                        _buildDetailedTraceBoard(order),
                        const SizedBox(height: 24),
                      ],
                    ],
                  );
                },
              );
  }

  Widget _buildEmptyLedger() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LuxuryTheme.gold.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.all(24),
            child: const Icon(
              Icons.history_edu_rounded,
              size: 48,
              color: LuxuryTheme.gold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Ledger is Blank",
            style: LuxuryTheme.headlineElegant(size: 22, color: LuxuryTheme.forestGreen),
          ),
          const SizedBox(height: 8),
          Text(
            "When you checkout precious reserved jewels, their transit timelines will trace here.",
            style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
          ),
          const SizedBox(height: 16),
          const LuxuryDivider(width: 80),
        ],
      ),
    );
  }

  Widget _buildOrderListItem(OrderModel order, bool isSelected, bool isDesktop) {
    final dateStr = _formatDate(order.orderDate);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? LuxuryTheme.whitePremium : LuxuryTheme.creamText,
        border: Border.all(
          color: isSelected ? LuxuryTheme.gold : LuxuryTheme.warmSand.withValues(alpha: 0.7),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedOrderId = isSelected ? null : order.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Product thumbnail, with an item-count badge when there's more than one.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LuxuryTheme.forestGreen,
                      border: Border.all(color: LuxuryTheme.gold, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: order.items.isEmpty
                        ? Icon(
                            order.status == OrderStatus.delivered
                                ? Icons.card_giftcard_rounded
                                : Icons.history_edu_rounded,
                            color: LuxuryTheme.gold,
                            size: 20,
                          )
                        : Image.network(
                            order.items.first.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              order.status == OrderStatus.delivered
                                  ? Icons.card_giftcard_rounded
                                  : Icons.history_edu_rounded,
                              color: LuxuryTheme.gold,
                              size: 20,
                            ),
                          ),
                  ),
                  if (order.items.length > 1)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: LuxuryTheme.gold,
                          border: Border.all(color: LuxuryTheme.creamText, width: 1),
                        ),
                        child: Text(
                          "+${order.items.length - 1}",
                          style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.forestGreen),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Key Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.id,
                          style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.forestGreen),
                        ),
                        Text(
                          "₹${order.grandTotal.toStringAsFixed(0)}",
                          style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.emerald),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: LuxuryTheme.bodySans(size: 12, color: LuxuryTheme.grayMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: LuxuryTheme.gold, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.statusDisplay.toUpperCase(),
                            style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.gold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (order.paymentMethod != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.credit_card_rounded, color: LuxuryTheme.grayMuted, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.paymentMethod!,
                              style: LuxuryTheme.bodySans(size: 11, color: LuxuryTheme.grayMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              if (!isDesktop) ...[
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: LuxuryTheme.gold,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedTraceBoard(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: LuxuryTheme.whitePremium,
        border: Border.all(color: LuxuryTheme.warmSand, width: 1.5),
        boxShadow: LuxuryTheme.luxuryShadow(blur: 15),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header trace details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ARTISANAL TRACE BOARD",
                style: LuxuryTheme.displayBrand(size: 10, color: LuxuryTheme.gold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: LuxuryTheme.forestGreen,
                child: Text(
                  "SECURE VAULT",
                  style: LuxuryTheme.displayBrand(size: 7, color: LuxuryTheme.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.statusDisplay.toUpperCase(),
            style: LuxuryTheme.headlineElegant(size: 20, color: LuxuryTheme.forestGreen),
          ),
          const SizedBox(height: 4),
          Text(
            order.statusDescription,
            style: LuxuryTheme.bodySerif(size: 15, color: LuxuryTheme.grayMuted),
          ),
          
          const SizedBox(height: 20),
          Divider(color: LuxuryTheme.creamText, height: 1),
          const SizedBox(height: 20),

          // Core secure info details
          _buildQuickDataRow("Sovereign Code", order.secureVaultCode, isCode: true),
          _buildQuickDataRow("Reserved items", "${order.items.fold(0, (sum, i) => sum + i.quantity)} jewel units"),
          _buildQuickDataRow("Adressee Full Name", order.fullName),
          _buildQuickDataRow("Delivery Destination", "${order.addressLine1}, ${order.city}"),
          if (order.paymentMethod != null)
            _buildQuickDataRow("Payment Method", order.paymentMethod!),

          const SizedBox(height: 24),
          Text(
            "DELIVERY TIMELINE",
            style: LuxuryTheme.displayBrand(size: 9, color: LuxuryTheme.gold),
          ),
          const SizedBox(height: 16),

          // Custom visual timeline design
          _buildTimelineStep(
            "Order Confirmed & Reserved",
            "Your selection has been reserved and is being prepared for shipment",
            order.status.index >= OrderStatus.ordered.index,
            order.status == OrderStatus.ordered,
          ),
          _buildTimelineStep(
            "Shipped",
            "Dispatched from our vault under fully insured armored transit",
            order.status.index >= OrderStatus.shipped.index,
            order.status == OrderStatus.shipped,
          ),
          _buildTimelineStep(
            "Out for Delivery",
            "On the road and arriving at your doorstep shortly",
            order.status.index >= OrderStatus.outForDelivery.index,
            order.status == OrderStatus.outForDelivery,
          ),
          _buildTimelineStep(
            "Delivered",
            "Delivered successfully and signed under identity confirmation",
            order.status.index >= OrderStatus.delivered.index,
            order.status == OrderStatus.delivered,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDataRow(String label, String value, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: LuxuryTheme.displayBrand(size: 8, color: LuxuryTheme.grayMuted),
          ),
          isCode
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: LuxuryTheme.gold.withValues(alpha: 0.12),
                  child: Text(
                    value,
                    style: LuxuryTheme.displayBrand(size: 11, color: LuxuryTheme.emerald),
                  ),
                )
              : Expanded(
                  child: Text(
                    value,
                    style: LuxuryTheme.bodySerif(size: 14, color: LuxuryTheme.forestGreen, bold: true),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, String subtitle, bool isCompleted, bool isActive) {
    final markerColor = isCompleted
        ? (isActive ? LuxuryTheme.gold : LuxuryTheme.emerald)
        : LuxuryTheme.grayMuted.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              // Circle bullet marker
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? LuxuryTheme.gold : (isCompleted ? LuxuryTheme.emerald : Colors.transparent),
                  border: Border.all(
                    color: markerColor,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted && !isActive
                    ? Icon(Icons.check, color: LuxuryTheme.creamText, size: 10)
                    : null,
              ),
              
              // Connector Line
              Expanded(
                child: Container(
                  width: 1.5,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isCompleted && !isActive
                      ? LuxuryTheme.emerald
                      : LuxuryTheme.grayMuted.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: LuxuryTheme.bodySerif(
                      size: 14,
                      color: isActive ? LuxuryTheme.gold : (isCompleted ? LuxuryTheme.forestGreen : LuxuryTheme.grayMuted),
                      bold: true,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LuxuryTheme.bodySans(
                      size: 11,
                      color: isActive ? LuxuryTheme.blackJet : LuxuryTheme.grayMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
