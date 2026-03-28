## Screen Documentation

### 1 AutoPilot Alert Screen

**Objective:**
- To design and implement the AutoPilot Alert Screen in Flutter that displays AI-selected trip details including purpose, company, budget status, origin, destination, travel dates, and traveler information in a structured and user-friendly layout.
- The screen serves as the entry point of the AutoPilot booking flow, guiding the user to review trip details and proceed to flight booking.
- Data is fetched from the service layer and rendered dynamically, with loading and error states handled automatically.

---

#### Input

**Call API (Mock — Real API to be integrated)**
- Endpoint: TBD
- Method: GET
- Params: `passId`, `tripId`

**API Response Fields:**

| Field | Description |
|---|---|
| `purpose` | Trip purpose e.g. "Client Meeting" |
| `company` | Company name e.g. "Smart Client Inc." |
| `estimatedBudget` | Approved budget amount |
| `budgetStatus` | Budget approval status e.g. "Approved" |
| `originCity` | Departure city name |
| `originState` | Departure state and country |
| `originAirport` | Full airport name and terminal |
| `destCity` | Arrival city name |
| `destState` | Arrival state and country |
| `destAirport` | Full airport name and terminal |
| `departDate` | Departure date string |
| `returnDate` | Return date string |
| `tripDuration` | Number of days |
| `travelerName` | Full name of traveler |

---

#### 1.1 Header Section

**Input:**

**OmVrtiAppBar (Custom AppBar)**

Description: Reusable AppBar widget used across all screens. Renders hamburger or back arrow on the left based on `showBack` parameter. Logo is always centered. Avatar is always on the right.

**Parameters:**

| Parameter | Type | Required | Default |
|---|---|---|---|
| `showBack` | bool | No | false |
| `onBackPressed` | Function | No | Navigator.pop() |

**Build Logic:**

```
FUNCTION build()
    RETURN Padding(
        child: Row(
            mainAxisAlignment: spaceBetween
            children:
                IF showBack == true
                    GestureDetector(
                        onTap: onBackPressed ?? Navigator.pop(context)
                        child: Container(
                            shape: circle
                            child: BackArrowIcon
                        )
                    )
                ELSE
                    GestureDetector(
                        onTap: openDrawer
                        child: MenuIcon
                    )
                END IF

                RichText(
                    "Om"   → dark blue, w800
                    "V"    → accent red, w800
                    "rti.ai" → dark blue, w800
                )

                CircleAvatar(
                    backgroundImage: userProfilePhoto
                )
        )
    )
END FUNCTION
```

**Rendering Rules:**

```
IF showBack == true
    Show circular back button on left
ELSE
    Show hamburger menu icon on left
END IF

Always show:
    - OmVrti.ai logo (center)
    - User avatar (right)

IF onBackPressed is provided
    Use provided function on back tap
ELSE
    Use Navigator.pop(context) as default
END IF
```

**Example Usage:**

```dart
// First screen — hamburger
OmVrtiAppBar()

// Inner screen — back arrow
OmVrtiAppBar(showBack: true)

// Inner screen — custom back action
OmVrtiAppBar(
    showBack: true,
    onBackPressed: () => context.go('/autopilot/alert'),
)
```

---

#### 1.2 Alert Banner Section

**Input:**
- `Input_banner_title` — "AutoPilot Trip Alert"
- `Input_banner_date` — Alert date string e.g. "Mon, Mar 2, 2026"
- `Input_robot_icon` — AI robot icon

**Output:** Full-width blue banner with robot icon, title, and date

---

**Pseudo Code: AutoPilotBanner**

Description: Informational banner indicating an AI-generated trip alert. Always rendered at the top of the content area.

**Build Logic:**

```
FUNCTION build()
    RETURN Container(
        width: fullWidth
        color: AppColors.primary (blue)
        borderRadius: 16
        child: Row(
            children:
                Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Image.asset(
              AppImages.autoPilotRobot,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
        )
                SizedBox(width: 14)
                Column(
                    Text("AutoPilot Trip Alert")   → bannerTitle style
                    Text(bannerDate)               → bannerSubtitle style @ 75% opacity
                )
        )
    )
END FUNCTION
```

---

#### 1.3 Purpose & Budget Card

**Input:**
- `Input_purpose` — Trip purpose string
- `Input_company` — Company name string
- `Input_estimated_budget` — Budget amount 

**Output:** White card with two rows — purpose row and budget row separated by a divider

---

**Pseudo Code: PurposeBudgetCard**

**Build Logic:**

```
FUNCTION build()
    RETURN Container(
        color: white
        borderRadius: 16
        child: Column(

            // Row 1 — Purpose
            Row(
                BriefcaseIcon (gray)
                Column(
                    Text("Purpose")            → label style (gray)
                    Wrap(
                        Text(purpose)          → h4 style
                        Text("•")              → gray
                        Text(company)          → h4 style
                    )
                )
            )

            Divider()

            // Row 2 — Budget
            Row(
                Container(
                    shape: circle
                    color: successLight (light green)
                    child: MoneyIcon (green)
                )
                Column(
                    Text("Estimated Budget")   → label style (gray)
                    Row(
                        Text("$" + estimatedBudget)  → priceMedium style (green)
                        Container(
                            color: successLight
                            borderRadius: 8
                            child: Text(budgetStatus)  → green, semibold
                        )
                    )
                )
            )
        )
    )
END FUNCTION
```

---

#### 1.4 Route Card

**Input:**
- `Input_origin_city` — Departure city
- `Input_origin_state` — Departure state/country
- `Input_origin_airport` — Departure airport full name
- `Input_dest_city` — Arrival city
- `Input_dest_state` — Arrival state/country
- `Input_dest_airport` — Arrival airport full name
- `Input_depart_date` — Departure date string
- `Input_return_date` — Return date string
- `Input_trip_duration` — Number of days (int)

**Output:** White card showing origin and destination cities, airport details, travel dates, and trip duration

---

**Pseudo Code: RouteCard**

**Build Logic:**

```
FUNCTION build()
    RETURN Container(
        color: white
        borderRadius: 16
        child: Column(

            // Cities Row
            Row(
                Expanded(
                    Column(crossAxisAlignment: start
                        Text(originCity)      → h3 style
                        Text(originState)     → bodySmall style
                        Text(originAirport)   → bodySmall style
                    )
                )
                SwapIcon (accent red)
                Expanded(
                    Column(crossAxisAlignment: end
                        Text(destCity)        → h3 style, textAlign: end
                        Text(destState)       → bodySmall style, textAlign: end
                        Text(destAirport)     → bodySmall style, textAlign: end
                    )
                )
            )

            Divider()

            // Dates Row
            Row(
                mainAxisAlignment: spaceBetween
                Column(crossAxisAlignment: start
                    Text("Depart")            → labelBlue style
                    Text(departDate)          → h4 style
                )
                Column(crossAxisAlignment: end
                    Text("Return")            → labelBlue style
                    Text(returnDate)          → h4 style
                )
            )

            SizedBox(height: 12)

            // Duration
            Text("Trip Duration : " + tripDuration + " Days")  → bodySmall style
        )
    )
END FUNCTION
```

---

#### 1.5 Traveler Card

**Input:**
- `Input_traveler_name` — Full name of traveler e.g. "Mr. Sam Watson"

**Output:** White card showing traveler label and name

---

**Pseudo Code: TravelerCard**

**Build Logic:**

```
FUNCTION build()
    RETURN Container(
        color: white
        borderRadius: 16
        child: Row(
            Text("Travelers")         → label style (gray)
            SizedBox(width: 16)
            PersonIcon
            SizedBox(width: 8)
            Text(travelerName)        → h4 style
        )
    )
END FUNCTION
```

---

#### 1.6 Bottom Button Row

**Input:**
- `Input_edit_action` (OUT FUN) — Action when Edit Trip is tapped
- `Input_next_action` (OUT FUN) — Action when View Flight is tapped

**Output:** Two-button row — outlined Edit Trip and filled View Flight

---

**Pseudo Code: AppButtonRow**

Description: Reusable bottom button row used across all AutoPilot flow screens. Left button is always outlined. Right button is always filled with optional icon.

**Parameters:**

| Parameter | Type | Required |
|---|---|---|
| `outlinedText` | String | Yes |
| `filledText` | String | Yes |
| `onOutlinedPressed` | Function | No |
| `onFilledPressed` | Function | No |
| `filledIcon` | IconData | No |
| `isLoading` | bool | No (default: false) |

**Build Logic:**

```
FUNCTION build()
    RETURN Row(
        Expanded(flex: 1
            OutlinedButton(
                text: outlinedText
                borderColor: accent red
                onPressed: onOutlinedPressed
            )
        )
        SizedBox(width: 12)
        Expanded(flex: 1
            ElevatedButton(
                text: filledText
                backgroundColor: accent red
                icon: filledIcon (optional)
                isLoading: isLoading
                onPressed:
                    IF isLoading == true
                        null (disabled)
                    ELSE
                        onFilledPressed
                    END IF
            )
        )
    )
END FUNCTION
```

**Rendering Rules:**

```
Left button always takes 1/3 of row width (flex: 1)
Right button always takes 1/3 of row width (flex: 1)

IF isLoading == true
    Show spinner inside filled button
    Disable filled button (onPressed = null)
ELSE
    Show text + icon inside filled button
    Enable filled button
END IF

IF filledIcon is provided
    Show icon to the right of filled button text
ELSE
    Show text only
END IF
```

**Example Usage:**

```dart
// Alert Screen
AppButtonRow(
    outlinedText: 'Edit Trip',
    filledText: 'View Flight',
    filledIcon: AppIcons.forward,
    onOutlinedPressed: () {},
    onFilledPressed: () => context.push('/autopilot/flight'),
)

// Car Screen with loading
AppButtonRow(
    outlinedText: 'Edit Car Rental',
    filledText: 'Confirm Booking',
    filledIcon: AppIcons.forward,
    isLoading: state.isLoading,
    onFilledPressed: () => ref.read(autoPilotProvider.notifier).confirmBooking(),
)
```

---

#### 1.7 Data Flow

```
Screen watches tripProvider (FutureProvider)
    → FutureProvider calls AutoPilotService.fetchTrip()
    → AsyncValue state = loading
        → Show CircularProgressIndicator
    → fetchTrip() completes
    → AsyncValue state = data(TripModel)
        → Render all cards with trip data
    → IF fetchTrip() throws exception
        → AsyncValue state = error
        → Show error message with error icon
END
```

#### 1.8 Navigation

| Action | Destination | Method |
|---|---|---|
| Tap View Flight | `/autopilot/flight` | `context.push()` |
| Tap Edit Trip | TBD | Not implemented |
| Tap Home (bottom nav) | `/autopilot/alert` | `context.go()` |
