# Smart Gameya Platform (منصة إدارة الجمعيات الذكية)

A digital management system for Rotating Savings and Credit Associations (ROSCAs / الجمعيات المالية), supporting fractional shares, mathematical payout integrity, and WhatsApp coordination.

## Language

### Core Entities

**Gameya**:
A fixed-cycle rotating savings group where participants contribute a fixed monthly installment to create a recurring monthly payout pot.
_Avoid_: Fund, pool, club, savings group

**Organizer**:
The coordinator responsible for creating the Gameya, defining turns, verifying installment payments, and orchestrating payouts.
_Avoid_: Admin, manager, host, owner

**Member**:
An individual participant in one or more Gameyas who holds full or fractional shares.
_Avoid_: User, subscriber, customer, client

### Financial & Structural Terms

**Share**:
A single full participation slot in a Gameya, equal to one full monthly contribution and entitled to one full monthly payout pot across the cycle.
_Avoid_: Slot, position, seat, ticket

**Split Share**:
A single Share divided mathematically between 2 to 4 Members, where each contributes a fraction of the monthly installment. Partners within a Split Share may take their payouts in different Payout Turn months, provided total payouts across every month sum to exactly 100%.
_Avoid_: Partial share, broken share, fractional slot

**Payout Turn**:
The designated calendar month in the Gameya cycle when a Member (or fraction of a Member) receives their scheduled payout.
_Avoid_: Delivery date, receipt month, cash-out round, due date

**Turn Swap**:
A formal exchange of Payout Turn months between two consenting Members with identical share ratios, requiring confirmation from both parties and final validation by the Organizer.
_Avoid_: Turn trade, slot exchange, date change

**Disbursement**:
The delivery of the collected monthly payout pot from the Organizer to the scheduled beneficiary Member, marked with payment method details and automatically confirmed if not acknowledged within 2 days.
_Avoid_: Payout transfer, delivery slip, cash release

**Share Transfer**:
The operational reassignment of a Member's active Share (remaining installments and future payout rights) to a substitute Member when an original Member defaults or drops out.
_Avoid_: Re-subscription, replacement, member swap

**Installment**:
The monthly payment due from each Member based on their share ratio, collected once per month of the Gameya cycle.
_Avoid_: Fee, premium, subscription, charge

**Grace Period**:
The collection window (default: 7 days, configurable per Gameya by the Organizer) from the cycle start date before unpaid installments are marked Overdue.
_Avoid_: Leniency period, delay window, buffer days

**Payment Proof**:
A digital receipt or transaction screenshot (e.g., InstaPay, Vodafone Cash, bank transfer receipt) uploaded by a Member to verify an installment.
_Avoid_: Voucher, invoice, bill

**Retention Policy**:
The automated cleanup cycle where payment proof screenshots in Firebase Storage are deleted 5 months after a Gameya reaches Completed status.
_Avoid_: Purge cycle, photo expiration

**Currency**:
The monetary unit assigned to a Gameya (e.g., EGP / ج.م, SAR / ر.س, AED / د.إ, USD / $), defaulting to Egyptian Pound (ج.م).
_Avoid_: Money type, denomination

### Lifecycle States

**Gameya State**:
The formal lifecycle status of a Gameya:
- `Draft`: Configuration in progress.
- `Recruiting`: Open for member sign-ups; structural terms still editable.
- `Active`: All shares filled and validated; structural financials strictly locked.
- `Completed`: All months concluded and all payouts delivered.
- `Cancelled`: Terminated prior to completion.
