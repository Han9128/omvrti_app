

### 1a. Login Screen

**Objective:**
- To design and implement the Login Screen in Flutter that serves as the entry point of the OmVrti.ai application.
- The screen uses a split-layout design: the top section presents the brand identity through a travel-themed illustration, and the bottom section contains the authentication form.
- On successful login, the user is navigated to the Home Screen.
- New users can navigate to the Sign Up screen via a link at the bottom.

---

#### Layout Overview

The screen is divided into two distinct visual zones:

```
┌─────────────────────────────┐
│                             │
│    ILLUSTRATION ZONE        │  ← Top 55% of screen
│    (Sky gradient + plane)   │
│                             │
├─────────────────────────────┤  ← Rounded top corners (32px)
│    FORM ZONE                │  ← Bottom 45% of screen
│                             │
│    OmVrti.ai  (logo)        │
│                             │
│    Email                    │
│    [__________________]     │
│                             │
│    Password                 │
│    [__________________]     │
│                             │
│    [Error Banner]           │  ← Hidden unless error exists
│                             │
│    [ Sign In ]              │  ← Full width filled button
│                             │
│    Forgot Password?         │  ← Centered text link
│                             │
│  Don't have an account?     │
│  Sign Up                    │  ← Centered text link → /signup
│                             │
└─────────────────────────────┘
```

---

#### Input

**API Call (Mock — Real API to be integrated)**
- Endpoint: TBD
- Method: POST
- Body: `{ email: string, password: string }`

**Request Fields:**

| Field | Type | Validation |
|-------|------|------------|
| `email` | String | Required, valid email format |
| `password` | String | Required, min 6 characters |

**Response Fields:**

| Field | Description |
|-------|-------------|
| `token` | Auth token to store for subsequent API requests |
| `user.name` | Full name of authenticated user |
| `user.avatarUrl` | Profile photo URL |
| `error` | Error message string if login fails |

---

#### 1a.1 Illustration Zone (Top Section)

**Description:**
Full-bleed top section covering 55% of the screen height. Uses a vertical gradient background from dark navy at the top fading to lighter sky blue at the bottom. A subtle plane silhouette image is positioned in the upper-right area flying toward the top-left, giving a sense of motion. This section is purely visual — it carries no interactive elements.

**Visual Specs:**

| Property | Value |
|----------|-------|
| Height | 55% of screen height (`screenHeight * 0.55`) |
| Background | Vertical gradient: `#1A3C8F` (top) → `#4A7FD4` (bottom) |
| Plane image | `assets/images/login_plane.png` — top-right, width ~200px |
| Plane opacity | 0.9 |
| Cloud overlay | `assets/images/login_clouds.png` — bottom of zone, opacity 0.15 |

**Build Logic:**

```
FUNCTION buildIllustrationZone(screenHeight)
    RETURN Container(
        height: screenHeight * 0.55
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter
                end: Alignment.bottomCenter
                colors: [
                    Color(0xFF1A3C8F),    ← dark navy — brand primary
                    Color(0xFF4A7FD4),    ← lighter sky blue
                ]
            )
        )
        child: Stack(
            children:

                // Cloud overlay — sits at the bottom of the zone so it
                // visually blends into the white form panel below
                Positioned(
                    bottom: 0, left: 0, right: 0
                    child: Opacity(
                        opacity: 0.15
                        child: Image.asset(AppImages.loginClouds, fit: BoxFit.cover)
                    )
                )

                // Plane silhouette — upper right, gives travel context
                Positioned(
                    top: 60, right: 20
                    child: Opacity(
                        opacity: 0.9
                        child: Image.asset(AppImages.loginPlane, width: 200)
                    )
                )
        )
    )
END FUNCTION
```

---

#### 1a.2 Form Zone (Bottom Section)

**Description:**
White rounded panel covering the bottom 45% of the screen. Has a large top border radius (32px) on both left and right corners, creating a "card sliding up over the illustration" visual effect. Contains the OmVrti.ai logo, email field, password field, optional error banner, Sign In button, Forgot Password link, and the Sign Up link at the very bottom.

**Visual Specs:**

| Property | Value |
|----------|-------|
| Height | 45% of screen height |
| Background | `AppColors.surface` (white) |
| Top-left radius | 32px |
| Top-right radius | 32px |
| Padding | 28px horizontal, 32px top, 24px bottom |

**Build Logic:**

```
FUNCTION buildFormZone()
    RETURN Container(
        decoration: BoxDecoration(
            color: AppColors.surface
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32)
                topRight: Radius.circular(32)
            )
        )
        padding: EdgeInsets.fromLTRB(28, 32, 28, 24)

        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start
            children:
                _buildLogo()
                SizedBox(height: 24)
                _buildEmailField()
                SizedBox(height: 16)
                _buildPasswordField()
                SizedBox(height: 20)
                _buildErrorBanner(state.errorMessage)   ← renders nothing when null
                SizedBox(height: 8)
                _buildSignInButton()
                SizedBox(height: 16)
                _buildForgotPasswordLink()
                SizedBox(height: 12)
                _buildSignUpLink()
        )
    )
END FUNCTION
```

---

#### 1a.3 Logo

**Description:**
The OmVrti.ai brand logo rendered as RichText — same component used in `OmvrtiAppBar`. Centered horizontally at the top of the form zone. Uses h2 size (22px, weight 800).

**Build Logic:**

```
FUNCTION buildLogo()
    RETURN Center(
        child: RichText(
            text: TextSpan(children: [
                TextSpan("Om"      → color: #1A3C8F, weight: w800, size: 22)
                TextSpan("V"      → color: AppColors.accent, weight: w800, size: 22)
                TextSpan("rti.ai" → color: #1A3C8F, weight: w800, size: 22)
            ])
        )
    )
END FUNCTION
```

---

#### 1a.4 Email Field

**Description:**
Standard text input for work email address. Keyboard type is set to `emailAddress` for correct soft keyboard layout on mobile. Border highlights in brand blue on focus. Prefix icon is a gray mail icon.

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Email" |
| Hint text | "Enter your work email" |
| Keyboard type | `TextInputType.emailAddress` |
| Prefix icon | `Icons.mail_outline` — `AppColors.textMuted` |
| Border radius | 12px |
| Default border color | `AppColors.textMuted` |
| Focused border color | `AppColors.primary` |

**Build Logic:**

```
FUNCTION buildEmailField()
    RETURN Column(
        crossAxisAlignment: CrossAxisAlignment.start
        children:
            Text("Email" → AppTextStyles.label)
            SizedBox(height: 6)
            TextField(
                controller: _emailController
                keyboardType: TextInputType.emailAddress
                decoration: InputDecoration(
                    hintText: "Enter your work email"
                    prefixIcon: Icon(Icons.mail_outline, color: AppColors.textMuted)
                    border: OutlineInputBorder(borderRadius: 12, color: textMuted)
                    focusedBorder: OutlineInputBorder(borderRadius: 12, color: primary)
                    contentPadding: vertical 14, horizontal 16
                )
            )
    )
END FUNCTION
```

---

#### 1a.5 Password Field

**Description:**
Password input with a show/hide visibility toggle on the right side. Password is obscured by default. Tapping the eye icon toggles `_isPasswordHidden` local state. This is why the screen must use `ConsumerStatefulWidget` — we need `setState()` for the toggle and `dispose()` to clean up controllers.

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Password" |
| Hint text | "Enter your password" |
| Obscure text | `true` by default |
| Prefix icon | `Icons.lock_outline` — `AppColors.textMuted` |
| Suffix icon (password hidden) | `Icons.visibility_outline` |
| Suffix icon (password visible) | `Icons.visibility_off_outline` |
| Border radius | 12px |

**Build Logic:**

```
FUNCTION buildPasswordField()
    RETURN Column(
        crossAxisAlignment: CrossAxisAlignment.start
        children:
            Text("Password" → AppTextStyles.label)
            SizedBox(height: 6)
            TextField(
                controller: _passwordController
                obscureText: _isPasswordHidden
                decoration: InputDecoration(
                    hintText: "Enter your password"
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted)
                    suffixIcon: GestureDetector(
                        onTap: () → setState(() _isPasswordHidden = !_isPasswordHidden)
                        child:
                            IF _isPasswordHidden == true
                                Icon(Icons.visibility_outline, color: textMuted)
                            ELSE
                                Icon(Icons.visibility_off_outline, color: textMuted)
                            END IF
                    )
                    border: OutlineInputBorder(borderRadius: 12)
                    focusedBorder: OutlineInputBorder(borderRadius: 12, color: primary)
                    contentPadding: vertical 14, horizontal 16
                )
            )
    )
END FUNCTION
```

---

#### 1a.6 Error Banner

**Description:**
A red-tinted inline banner that appears between the password field and the Sign In button only when an error exists. Renders as `SizedBox.shrink()` (zero height, invisible) when `errorMessage` is null.

**Build Logic:**

```
FUNCTION buildErrorBanner(String? errorMessage)

    IF errorMessage == null
        RETURN SizedBox.shrink()    ← takes zero space, invisible
    END IF

    RETURN Container(
        width: double.infinity
        padding: EdgeInsets.all(12)
        margin: EdgeInsets.only(bottom: 8)
        decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08)
            borderRadius: 12
            border: Border.all(color: AppColors.error, width: 1)
        )
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start
            children:
                Icon(Icons.error_outline, color: AppColors.error, size: 18)
                SizedBox(width: 8)
                Expanded(
                    Text(errorMessage → AppTextStyles.bodySmall, color: AppColors.error)
                )
        )
    )
END FUNCTION
```

---

#### 1a.7 Sign In Button

**Description:**
Full-width filled button using the reusable `AppFilledButton` widget. Displays a loading spinner when `state.isLoading` is true. Passing `null` to `onPressed` automatically disables the button — this is Flutter's built-in behavior for `ElevatedButton`, preventing double submissions.

**Build Logic:**

```
FUNCTION buildSignInButton()
    RETURN AppFilledButton(
        text: "Sign In"
        isLoading: state.isLoading
        onPressed: state.isLoading
            ? null               ← button auto-disables when null
            : () → _handleSignIn()
    )

FUNCTION _handleSignIn()
    // Local validation first — do not touch the API until fields are valid
    IF _emailController.text.trim().isEmpty
        set errorMessage: "Please enter your email"   RETURN
    END IF
    IF _passwordController.text.isEmpty
        set errorMessage: "Please enter your password"   RETURN
    END IF

    // All valid — call ViewModel
    ref.read(authProvider.notifier).login(
        email: _emailController.text.trim()
        password: _passwordController.text
    )
END FUNCTION
```

---

#### 1a.8 Forgot Password Link

**Description:**
A simple centered text link. Tapping navigates to the Forgot Password screen (not yet implemented — placeholder for now). Styled in brand blue with underline to signal it is tappable.

**Build Logic:**

```
FUNCTION buildForgotPasswordLink()
    RETURN Center(
        child: GestureDetector(
            onTap: () → { /* TODO: context.push('/forgot-password') */ }
            child: Text(
                "Forgot Password?"
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary
                    fontWeight: FontWeight.w500
                    decoration: TextDecoration.underline
                )
            )
        )
    )
END FUNCTION
```

---

#### 1a.9 Sign Up Link

**Description:**
A two-part centered row at the very bottom of the form. Plain gray text followed by a tappable brand-blue "Sign Up" link. Both sit in the same `Row` so they appear inline on one line.

**Build Logic:**

```
FUNCTION buildSignUpLink()
    RETURN Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center
            children:
                Text(
                    "Don't have an account? "
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
                )
                GestureDetector(
                    onTap: () → context.push('/signup')
                    child: Text(
                        "Sign Up"
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary
                            fontWeight: FontWeight.w600
                            decoration: TextDecoration.underline
                        )
                    )
                )
        )
    )
END FUNCTION
```

---

#### 1a.10 State Management

**Widget Type:** `ConsumerStatefulWidget`

**Why not `ConsumerWidget`:** This screen manages local controller state and a visibility bool that require `setState()` and `dispose()` — only available in a `StatefulWidget`.

**Local State:**

| Variable | Type | Purpose |
|----------|------|---------|
| `_emailController` | `TextEditingController` | Captures email input |
| `_passwordController` | `TextEditingController` | Captures password input |
| `_isPasswordHidden` | `bool` | Controls password visibility toggle |

**Provider:**

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | Manages login API call state |

**AuthState Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `isLoading` | `bool` | `true` while API call is in progress |
| `errorMessage` | `String?` | `null` when clean, error string on failure |
| `isAuthenticated` | `bool` | `true` after successful login |

**Data Flow:**

```
User taps "Sign In"
    → _handleSignIn() runs local field validation
        → IF any field empty
            Set local errorMessage → show error banner
            STOP — do not call API
        → IF all fields valid
            → ref.read(authProvider.notifier).login(email, password)
            → AuthState: isLoading = true
                → Button shows spinner and is disabled
            → AuthService.login() completes
                → IF success
                    AuthState: isAuthenticated = true, isLoading = false
                    → ref.listen detects isAuthenticated == true
                    → context.go('/home')   ← replaces stack, no back to login
                → IF error
                    AuthState: isLoading = false, errorMessage = "Invalid credentials"
                    → Error banner appears above Sign In button
```

> **Important:** Use `context.go()` not `context.push()` after login so the Login screen is removed from the navigation stack. Users must not be able to press back to return to Login after signing in.

---

#### 1a.11 Navigation

| Action | Destination | Method | Notes |
|--------|-------------|--------|-------|
| Successful login | `/home` | `context.go()` | Clears login from nav stack |
| Tap "Sign Up" | `/signup` | `context.push()` | Back arrow returns to Login |
| Tap "Forgot Password" | `/forgot-password` | `context.push()` | Not yet implemented |

---

#### 1a.12 Assets Required

| Asset | Path | Notes |
|-------|------|-------|
| Plane silhouette | `assets/images/login_plane.png` | Shared with Sign Up screen |
| Cloud overlay | `assets/images/login_clouds.png` | Shared with Sign Up screen |

> These assets are shared between Login and Sign Up. Register them once in `pubspec.yaml`.

---

#### 1a.13 New Folder Structure

```
lib/features/auth/
    ├── model/
    │   └── auth_state.dart           ← AuthState data class
    ├── viewmodel/
    │   └── auth_viewmodel.dart       ← AuthNotifier + authProvider
    ├── service/
    │   └── auth_service.dart         ← login() and signup() mock calls
    └── view/
        └── screens/
            ├── login_screen.dart     ← Screen 1a
            └── signup_screen.dart    ← Screen 1b
```

---

---

### 1b. Sign Up Screen

**Objective:**
- To design and implement the Sign Up screen that allows new users to create an OmVrti.ai account.
- Uses the same split-layout as the Login screen for visual consistency, but with the illustration zone reduced to 40% height to give the longer form enough room.
- On successful registration the user is navigated directly to the Home Screen.
- Existing users can navigate back to Login via a link at the bottom.

---

#### Layout Overview

```
┌─────────────────────────────┐
│                             │
│    ILLUSTRATION ZONE        │  ← Top 40% of screen (shorter than Login)
│    (Same sky gradient)      │
│                             │
├─────────────────────────────┤  ← Rounded top corners (32px)
│    FORM ZONE                │  ← Bottom 60% of screen (scrollable)
│                             │
│    Create Account           │  ← Title (h2)
│    Start your journey       │  ← Subtitle (bodyMedium, gray)
│                             │
│    Full Name                │
│    [__________________]     │
│                             │
│    Company Name             │
│    [__________________]     │
│                             │
│    Work Email               │
│    [__________________]     │
│                             │
│    Password                 │
│    [__________________]     │
│                             │
│    Confirm Password         │
│    [__________________]     │
│                             │
│    [Error Banner]           │  ← Hidden unless error
│                             │
│    [ Create Account ]       │  ← Full width filled button
│                             │
│  Already have an account?   │
│  Sign In                    │  ← Centered text link → context.pop()
│                             │
└─────────────────────────────┘
```

---

#### Input

**API Call (Mock — Real API to be integrated)**
- Endpoint: TBD
- Method: POST
- Body: `{ fullName, companyName, email, password }`

**Request Fields:**

| Field | Type | Validation |
|-------|------|------------|
| `fullName` | String | Required, min 2 characters |
| `companyName` | String | Required, min 2 characters |
| `email` | String | Required, valid email format |
| `password` | String | Required, min 6 characters |
| `confirmPassword` | String | Required, must match `password` — local only, NOT sent to API |

**Response Fields:**

| Field | Description |
|-------|-------------|
| `token` | Auth token — same structure as login response |
| `user.name` | Full name from registration |
| `user.avatarUrl` | Default avatar assigned by server |
| `error` | Error string if registration fails (e.g. email already exists) |

---

#### 1b.1 Illustration Zone (Top Section)

**Description:**
Identical gradient and assets as the Login screen. The only difference is height — 40% instead of 55% — to give the longer form more vertical space. Plane and cloud are positioned the same way.

**Visual Specs:**

| Property | Value |
|----------|-------|
| Height | 40% of screen height (`screenHeight * 0.40`) |
| Background | Same gradient: `#1A3C8F` → `#4A7FD4` |
| Plane image | `AppImages.loginPlane` — top-right, width ~180px |
| Cloud overlay | `AppImages.loginClouds` — bottom of zone, opacity 0.15 |

**Build Logic:**

```
FUNCTION buildIllustrationZone(screenHeight)
    RETURN Container(
        height: screenHeight * 0.40    ← shorter than Login (was 0.55)
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter
                end: Alignment.bottomCenter
                colors: [Color(0xFF1A3C8F), Color(0xFF4A7FD4)]
            )
        )
        child: Stack(
            children:
                Positioned(
                    bottom: 0, left: 0, right: 0
                    child: Opacity(opacity: 0.15, child: Image.asset(AppImages.loginClouds))
                )
                Positioned(
                    top: 40, right: 20
                    child: Opacity(opacity: 0.9, child: Image.asset(AppImages.loginPlane, width: 180))
                )
        )
    )
END FUNCTION
```

---

#### 1b.2 Form Zone (Bottom Section)

**Description:**
White rounded panel covering 60% of the screen. Same 32px top border radius as Login. Taller because it holds 5 input fields. The content is wrapped in `SingleChildScrollView` so the form scrolls gracefully when the keyboard appears on smaller devices — without this the overflow error would occur.

**Visual Specs:**

| Property | Value |
|----------|-------|
| Height | 60% of screen height |
| Background | `AppColors.surface` (white) |
| Top border radius | 32px |
| Padding | 28px horizontal, 28px top, 24px bottom |
| Scroll | `SingleChildScrollView` — prevents keyboard overflow |

**Build Logic:**

```
FUNCTION buildFormZone()
    RETURN Expanded(
        child: Container(
            decoration: BoxDecoration(
                color: AppColors.surface
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32)
                    topRight: Radius.circular(32)
                )
            )
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(28, 28, 28, 24)
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start
                    children:
                        _buildHeader()
                        SizedBox(height: 20)
                        _buildFullNameField()
                        SizedBox(height: 16)
                        _buildCompanyNameField()
                        SizedBox(height: 16)
                        _buildEmailField()
                        SizedBox(height: 16)
                        _buildPasswordField()
                        SizedBox(height: 16)
                        _buildConfirmPasswordField()
                        SizedBox(height: 20)
                        _buildErrorBanner(state.errorMessage)
                        SizedBox(height: 8)
                        _buildCreateAccountButton()
                        SizedBox(height: 16)
                        _buildSignInLink()
                )
            )
        )
    )
END FUNCTION
```

---

#### 1b.3 Header

**Description:**
Two lines of text at the top of the form zone replacing the logo used on Login. A bold title and a lighter gray subtitle set context for the user. The logo itself appears implicitly through the brand gradient in the illustration zone so repeating it here is unnecessary.

**Build Logic:**

```
FUNCTION buildHeader()
    RETURN Column(
        crossAxisAlignment: CrossAxisAlignment.start
        children:
            Text(
                "Create Account"
                style: AppTextStyles.h2
            )
            SizedBox(height: 4)
            Text(
                "Start your corporate travel journey"
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
            )
    )
END FUNCTION
```

---

#### 1b.4 Full Name Field

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Full Name" |
| Hint text | "Enter your full name" |
| Keyboard type | `TextInputType.name` |
| Text capitalization | `TextCapitalization.words` |
| Prefix icon | `Icons.person_outline` — `AppColors.textMuted` |
| Border radius | 12px |

---

#### 1b.5 Company Name Field

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Company Name" |
| Hint text | "Enter your company name" |
| Keyboard type | `TextInputType.text` |
| Text capitalization | `TextCapitalization.words` |
| Prefix icon | `Icons.business_outlined` — `AppColors.textMuted` |
| Border radius | 12px |

---

#### 1b.6 Work Email Field

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Work Email" |
| Hint text | "Enter your work email" |
| Keyboard type | `TextInputType.emailAddress` |
| Prefix icon | `Icons.mail_outline` — `AppColors.textMuted` |
| Border radius | 12px |

---

#### 1b.7 Password Field

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Password" |
| Hint text | "Create a password" |
| Obscure text | `true` by default |
| Prefix icon | `Icons.lock_outline` — `AppColors.textMuted` |
| Suffix icon | Show/hide toggle (same as Login) |
| Min length | 6 characters — validated locally |

---

#### 1b.8 Confirm Password Field

**Description:**
A second password field to catch typos. Has its own independent show/hide toggle (`_isConfirmPasswordHidden`). Validated locally — the two password values must match before the API is called. The confirmed value is never sent to the API, only `password` is.

**Parameters:**

| Property | Value |
|----------|-------|
| Label | "Confirm Password" |
| Hint text | "Re-enter your password" |
| Obscure text | `true` by default |
| Prefix icon | `Icons.lock_outline` — `AppColors.textMuted` |
| Suffix icon | Independent show/hide toggle |

**Validation Rule:**

```
IF _confirmController.text != _passwordController.text
    show error: "Passwords do not match"
    STOP — do not call API
END IF
```

---

#### 1b.9 Error Banner

Identical in structure to the Login screen error banner.

```
IF state.errorMessage == null → SizedBox.shrink() (invisible, zero height)
IF state.errorMessage != null → Red-bordered container with icon + message text
```

---

#### 1b.10 Create Account Button

**Build Logic:**

```
FUNCTION buildCreateAccountButton()
    RETURN AppFilledButton(
        text: "Create Account"
        isLoading: state.isLoading
        onPressed: state.isLoading
            ? null
            : () → _handleSignUp()
    )

FUNCTION _handleSignUp()
    // All validation happens locally before touching the API

    IF _fullNameController.text.trim().isEmpty
        show error: "Please enter your full name"     RETURN
    END IF
    IF _companyController.text.trim().isEmpty
        show error: "Please enter your company name"  RETURN
    END IF
    IF _emailController.text.trim().isEmpty
        show error: "Please enter your work email"    RETURN
    END IF
    IF _passwordController.text.length < 6
        show error: "Password must be at least 6 characters"  RETURN
    END IF
    IF _confirmController.text != _passwordController.text
        show error: "Passwords do not match"          RETURN
    END IF

    // All checks passed — call ViewModel
    ref.read(authProvider.notifier).signup(
        fullName:    _fullNameController.text.trim()
        companyName: _companyController.text.trim()
        email:       _emailController.text.trim()
        password:    _passwordController.text
    )
END FUNCTION
```

---

#### 1b.11 Sign In Link

**Description:**
Symmetric to the Sign Up link on Login. A centered inline row — "Already have an account?" in gray, "Sign In" tappable in brand blue. Uses `context.pop()` not `context.push('/login')` because Login is already in the stack — popping is cheaper and keeps the stack clean.

**Build Logic:**

```
FUNCTION buildSignInLink()
    RETURN Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center
            children:
                Text(
                    "Already have an account? "
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)
                )
                GestureDetector(
                    onTap: () → context.pop()   ← Login already in stack, just go back
                    child: Text(
                        "Sign In"
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary
                            fontWeight: FontWeight.w600
                            decoration: TextDecoration.underline
                        )
                    )
                )
        )
    )
END FUNCTION
```

---

#### 1b.12 State Management

**Widget Type:** `ConsumerStatefulWidget`

**Local State:**

| Variable | Type | Purpose |
|----------|------|---------|
| `_fullNameController` | `TextEditingController` | Full name input |
| `_companyController` | `TextEditingController` | Company name input |
| `_emailController` | `TextEditingController` | Email input |
| `_passwordController` | `TextEditingController` | Password input |
| `_confirmController` | `TextEditingController` | Confirm password input |
| `_isPasswordHidden` | `bool` | Password visibility toggle |
| `_isConfirmPasswordHidden` | `bool` | Confirm password visibility toggle |

> All 5 `TextEditingController` instances must be disposed in `dispose()` to prevent memory leaks.

**Provider:**

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | Shared with Login — same notifier handles both |

**Data Flow:**

```
User taps "Create Account"
    → _handleSignUp() runs 5 local validation checks in order
        → IF any check fails
            Show error banner with specific message
            STOP — do not call API
        → IF all 5 checks pass
            → ref.read(authProvider.notifier).signup(...)
            → AuthState: isLoading = true
                → Button shows spinner, is disabled
            → AuthService.signup() completes
                → IF success
                    AuthState: isAuthenticated = true, isLoading = false
                    → ref.listen detects isAuthenticated == true
                    → context.go('/home')   ← clears entire auth stack
                → IF error (e.g. email already registered)
                    AuthState: isLoading = false
                    AuthState: errorMessage = "An account with this email already exists"
                    → Error banner shown above Create Account button
```

---

#### 1b.13 Navigation

| Action | Destination | Method | Notes |
|--------|-------------|--------|-------|
| Successful signup | `/home` | `context.go()` | Clears entire auth stack |
| Tap "Sign In" | Back to Login | `context.pop()` | Login already in stack |

---

#### 1b.14 New Routes to Add in `app_router.dart`

```dart
// These routes must be OUTSIDE the ShellRoute
// so the bottom navigation bar does not appear on auth screens

GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
),
GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, state) => const SignUpScreen(),
),
```

---

### 3. AutoPilot Alert Screen

> Full documentation for this screen exists separately.
> See the original screens.md — Sections 1.1 through 1.8.

---