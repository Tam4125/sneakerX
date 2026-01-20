enum PaymentStatus {
  // --- 1. PRE-PAYMENT ---
  PENDING,             // Initial state. Order created, waiting for user/gateway action.
  AWAITING_PAYMENT,    // (Optional) Distinct from pending; e.g., waiting for bank transfer confirmation.

  // --- 2. SUCCESS PATH ---
  AUTHORIZED,          // (Crucial for Cards) Money is "held" by the bank but not yet moved.
  // Useful so you don't charge until you actually SHIP the item.
  PAID,                // Money has been successfully captured. The transaction is complete.

  // --- 3. FAILURE PATH ---
  FAILED,              // Gateway rejected the transaction (Insufficient funds, fraud).
  CANCELLED,           // User closed the payment window or cancelled the order manually.
  EXPIRED,             // Payment session timed out (Common for QR codes/Wallets like Momo).

  // --- 4. POST-PAYMENT (REFUNDS & DISPUTES) ---
  REFUNDING,           // Refund has been initiated but bank hasn't confirmed yet.
  REFUNDED,            // 100% of the money has been returned.
  PARTIALLY_REFUNDED,  // Crucial: User bought 3 items but returned 1.
  CHARGEBACK,          // DANGER: The user disputed the charge with their bank.
  // This usually incurs a fee for you and flags the user as high-risk.
}