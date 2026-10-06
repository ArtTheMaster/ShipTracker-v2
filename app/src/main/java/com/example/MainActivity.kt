package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AssignmentReturn
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LocalShipping
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Badge
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.LazadaBlue
import com.example.ui.theme.LazadaBlueContainer
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.theme.ShipNavyPrimary
import com.example.ui.theme.ShipNavySecondary
import com.example.ui.theme.ShipTealAccent
import com.example.ui.theme.ShopeeOrange
import com.example.ui.theme.ShopeeOrangeContainer
import com.example.ui.theme.StatusDelivered
import com.example.ui.theme.StatusDispatched
import com.example.ui.theme.StatusPending
import com.example.ui.theme.StatusReturned
import com.example.ui.theme.TikTokBlack
import com.example.ui.theme.TikTokContainer

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                ShipTrackerApp()
            }
        }
    }
}

@Composable
fun ShipTrackerApp() {
    var selectedTab by remember { mutableIntStateOf(0) }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            NavigationBar(
                containerColor = Color.White,
                tonalElevation = 8.dp
            ) {
                val items = listOf(
                    Triple("Parcels", Icons.Default.LocalShipping, 0),
                    Triple("Dispatch", Icons.Default.Send, 1),
                    Triple("Returns", Icons.Default.AssignmentReturn, 2),
                    Triple("Analytics", Icons.Default.BarChart, 3),
                    Triple("Profile", Icons.Default.Person, 4)
                )

                items.forEach { (label, icon, index) ->
                    NavigationBarItem(
                        modifier = Modifier.testTag("nav_${label.lowercase()}"),
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        icon = {
                            Icon(
                                imageVector = icon,
                                contentDescription = label
                            )
                        },
                        label = {
                            Text(
                                text = label,
                                fontSize = 11.sp,
                                fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Color.White,
                            selectedTextColor = ShipNavyPrimary,
                            indicatorColor = ShipNavyPrimary,
                            unselectedIconColor = Color.Gray,
                            unselectedTextColor = Color.Gray
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(Color(0xFFF8FAFC))
        ) {
            when (selectedTab) {
                0 -> ParcelsDashboardView()
                1 -> DispatchScreenView()
                2 -> ReturnsScreenView()
                3 -> AnalyticsScreenView()
                4 -> ProfileScreenView()
            }
        }
    }
}

@Composable
fun ParcelsDashboardView() {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(12.dp))
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "GJandAsher ShipTracker",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = ShipNavyPrimary
                    )
                    Text(
                        text = "Outbound Logistics & Returns Hub",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.Gray
                    )
                }
                Surface(
                    color = ShipTealAccent.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(20.dp)
                ) {
                    Text(
                        text = "Staff Mode",
                        color = ShipNavyPrimary,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                }
            }
        }

        item {
            // Platform Stats Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                PlatformSummaryChip(
                    name = "Shopee",
                    color = ShopeeOrange,
                    containerColor = ShopeeOrangeContainer,
                    count = 24,
                    modifier = Modifier.weight(1f)
                )
                PlatformSummaryChip(
                    name = "Lazada",
                    color = LazadaBlue,
                    containerColor = LazadaBlueContainer,
                    count = 18,
                    modifier = Modifier.weight(1f)
                )
                PlatformSummaryChip(
                    name = "TikTok",
                    color = TikTokBlack,
                    containerColor = TikTokContainer,
                    count = 15,
                    modifier = Modifier.weight(1f)
                )
            }
        }

        item {
            Text(
                text = "Recent Dispatches",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = ShipNavyPrimary,
                modifier = Modifier.padding(top = 8.dp)
            )
        }

        item {
            ParcelCardItem(
                trackingNumber = "SPXPH0394829104",
                platform = "Shopee",
                courier = "SPX Express",
                customer = "Maria Santos",
                amount = "₱1,250.00",
                status = "Dispatched",
                statusColor = StatusDispatched
            )
        }
        item {
            ParcelCardItem(
                trackingNumber = "LEX-PH-82049102",
                platform = "Lazada",
                courier = "Lazada Express",
                customer = "Juan Dela Cruz",
                amount = "₱3,420.00",
                status = "In Transit",
                statusColor = Color(0xFF8B5CF6)
            )
        }
        item {
            ParcelCardItem(
                trackingNumber = "JT6301948201",
                platform = "TikTok Shop",
                courier = "J&T Express",
                customer = "Elena Garcia",
                amount = "₱890.00",
                status = "Delivered",
                statusColor = StatusDelivered
            )
        }
        item {
            ParcelCardItem(
                trackingNumber = "LBC88301928",
                platform = "Shopee",
                courier = "Flash Express",
                customer = "Roberto Tan",
                amount = "₱2,100.00",
                status = "Return Logged",
                statusColor = StatusReturned
            )
        }
        item {
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
fun PlatformSummaryChip(
    name: String,
    color: Color,
    containerColor: Color,
    count: Int,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = containerColor),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column(
            modifier = Modifier.padding(12.dp)
        ) {
            Text(
                text = name,
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp,
                color = color
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "$count pkgs",
                fontWeight = FontWeight.ExtraBold,
                fontSize = 16.sp,
                color = ShipNavyPrimary
            )
        }
    }
}

@Composable
fun ParcelCardItem(
    trackingNumber: String,
    platform: String,
    courier: String,
    customer: String,
    amount: String,
    status: String,
    statusColor: Color
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = trackingNumber,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = ShipNavyPrimary
                )
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = statusColor.copy(alpha = 0.12f)
                ) {
                    Text(
                        text = status,
                        color = statusColor,
                        fontWeight = FontWeight.Bold,
                        fontSize = 11.sp,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Column {
                    Text(
                        text = customer,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 13.sp,
                        color = Color.Black
                    )
                    Text(
                        text = "$platform • $courier",
                        fontSize = 12.sp,
                        color = Color.Gray
                    )
                }
                Text(
                    text = amount,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = ShipNavyPrimary
                )
            }
        }
    }
}

@Composable
fun DispatchScreenView() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Send,
            contentDescription = "Dispatch",
            tint = ShipNavyPrimary,
            modifier = Modifier.size(56.dp)
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "Manual Dispatch Form",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Module 3: Fast courier entry, platform selector (Shopee/Lazada/TikTok), and auto-fill customer QR code.",
            color = Color.Gray,
            fontSize = 13.sp,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}

@Composable
fun ReturnsScreenView() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.AssignmentReturn,
            contentDescription = "Returns",
            tint = StatusReturned,
            modifier = Modifier.size(56.dp)
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "Returns & Refunds Logger",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Module 5: Log returned parcels with condition assessment, photo evidence, and refund resolution tracking.",
            color = Color.Gray,
            fontSize = 13.sp,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}

@Composable
fun AnalyticsScreenView() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.BarChart,
            contentDescription = "Analytics",
            tint = ShipTealAccent,
            modifier = Modifier.size(56.dp)
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "Admin Visual Analytics & Forecasts",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Modules 6 & 7: Role-guarded for Admin/Owner. Interactive multi-platform line graphs, sales trends, and 1-12 month predictive forecasting.",
            color = Color.Gray,
            fontSize = 13.sp,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}

@Composable
fun ProfileScreenView() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Person,
            contentDescription = "Profile",
            tint = ShipNavySecondary,
            modifier = Modifier.size(56.dp)
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = "User Profile & Security",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Module 2: Google Sign-In, RA 10173 Data Privacy consent, and real-time Firestore Role syncing.",
            color = Color.Gray,
            fontSize = 13.sp,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
    }
}
