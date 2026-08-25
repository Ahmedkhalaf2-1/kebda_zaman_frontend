package com.kebdtzaman.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders the Kebda Zaman home-screen widget from the key/value data
 * home_widget_service.dart writes via HomeWidget.saveWidgetData. Two
 * mutually-exclusive sections (order vs. loyalty) are toggled by
 * [KEY_MODE] — see kebda_widget.xml for the layout they share.
 */
class KebdaHomeWidgetProvider : HomeWidgetProvider() {

    companion object {
        private const val KEY_MODE = "widget_mode"
        private const val KEY_ORDER_ID = "order_id"
        private const val KEY_ORDER_STATUS_LABEL = "order_status_label"
        private const val KEY_ORDER_ETA = "order_eta"
        private const val KEY_ORDER_PROGRESS = "order_progress"
        private const val KEY_ORDER_IS_PICKUP = "order_is_pickup"
        private const val KEY_LOYALTY_POINTS = "loyalty_points"

        // Node ids/labels for the 4-step sequence tracker. Dart sends the raw
        // 5-state sequence index (pending=0..delivered/pickedUp=4); pending
        // and confirmed collapse into node 0 since "pending" is normally
        // near-instantaneous and the reference design has no node for it.
        private val STEP_NODE_IDS = intArrayOf(R.id.step_node_0, R.id.step_node_1, R.id.step_node_2, R.id.step_node_3)
        private val STEP_LINE_IDS = intArrayOf(R.id.step_line_0, R.id.step_line_1, R.id.step_line_2)
        private val STEP_LABEL_IDS = intArrayOf(R.id.step_label_0, R.id.step_label_1, R.id.step_label_2, R.id.step_label_3)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val isOrderMode = widgetData.getString(KEY_MODE, "loyalty") == "order"
        val orderId = widgetData.getString(KEY_ORDER_ID, null)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.kebda_widget)

            views.setViewVisibility(R.id.order_section, if (isOrderMode) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.loyalty_section, if (isOrderMode) View.GONE else View.VISIBLE)

            if (isOrderMode) {
                views.setTextViewText(
                    R.id.order_status_label,
                    widgetData.getString(KEY_ORDER_STATUS_LABEL, ""),
                )
                val eta = widgetData.getString(KEY_ORDER_ETA, "") ?: ""
                views.setViewVisibility(R.id.order_eta, if (eta.isEmpty()) View.GONE else View.VISIBLE)
                views.setTextViewText(R.id.order_eta, eta)
                bindStepTracker(
                    context,
                    views,
                    rawStepIndex = widgetData.getInt(KEY_ORDER_PROGRESS, 0),
                    isPickup = widgetData.getInt(KEY_ORDER_IS_PICKUP, 0) == 1,
                )

                views.setTextViewText(R.id.order_now_button, "Track Order  ›")
            } else {
                views.setTextViewText(
                    R.id.loyalty_points,
                    widgetData.getInt(KEY_LOYALTY_POINTS, 0).toString(),
                )
                views.setTextViewText(R.id.order_now_button, "Order Now")
            }

            // Tapping the card or the bottom button both open live order
            // tracking when one exists, otherwise fall through to the menu.
            val target = if (isOrderMode && !orderId.isNullOrEmpty()) {
                "kebdazaman://widget/orders/tracking/$orderId"
            } else {
                "kebdazaman://widget/menu"
            }
            val launchIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(target))
            views.setOnClickPendingIntent(R.id.widget_root, launchIntent)
            views.setOnClickPendingIntent(R.id.order_now_button, launchIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /**
     * Renders the 4-node sequence tracker (circle-line-circle-line-circle-
     * line-circle + labels + percent chip) from the order's raw 5-state
     * step index. Node mapping: 0=Confirmed (covers pending+confirmed),
     * 1=Preparing, 2=On the Way/Ready, 3=Delivered/Picked Up.
     */
    private fun bindStepTracker(
        context: Context,
        views: RemoteViews,
        rawStepIndex: Int,
        isPickup: Boolean,
    ) {
        val nodeIndex = (rawStepIndex - 1).coerceIn(0, 3)
        val labels = if (isPickup) {
            arrayOf("Confirmed", "Preparing", "Ready", "Picked Up")
        } else {
            arrayOf("Confirmed", "Preparing", "On the Way", "Delivered")
        }
        val reachedColor = ContextCompat.getColor(context, R.color.kz_primary)
        val reachedTextColor = ContextCompat.getColor(context, R.color.kz_on_surface)
        val upcomingTextColor = ContextCompat.getColor(context, R.color.kz_on_surface_variant)
        val lineColor = ContextCompat.getColor(context, R.color.kz_outline_variant)

        for (i in STEP_NODE_IDS.indices) {
            val reached = i <= nodeIndex
            views.setImageViewResource(
                STEP_NODE_IDS[i],
                if (reached) R.drawable.ic_widget_step_done else R.drawable.ic_widget_step_pending,
            )
            views.setTextViewText(STEP_LABEL_IDS[i], labels[i])
            views.setTextColor(STEP_LABEL_IDS[i], if (reached) reachedTextColor else upcomingTextColor)
        }
        for (i in STEP_LINE_IDS.indices) {
            // Segment i sits between node i and node i+1: filled once the
            // order has reached the node on its right.
            views.setInt(
                STEP_LINE_IDS[i],
                "setBackgroundColor",
                if (i < nodeIndex) reachedColor else lineColor,
            )
        }
        views.setTextViewText(R.id.step_percent, "${(nodeIndex + 1) * 25}%")
    }
}
