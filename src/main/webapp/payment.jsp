<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment — Panjeeri Ghar</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #fdf6ee;
            display: flex; align-items: center; justify-content: center;
            min-height: 100vh; color: #3b2a1a;
        }
        .payment-card {
            background: #fff; border-radius: 10px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
            padding: 2.5rem; text-align: center; max-width: 400px; width: 90%;
        }
        .payment-card h2 { color: #7b3f00; margin-bottom: 0.5rem; }
        .payment-card p { color: #777; margin-bottom: 1.5rem; font-size: 0.95rem; }
        .amount { font-size: 1.8rem; font-weight: 700; color: #7b3f00; margin-bottom: 1.5rem; }
        .btn-pay {
            padding: 0.85rem 2.5rem;
            background: #7b3f00; color: #fff;
            border: none; border-radius: 6px;
            font-size: 1rem; font-weight: 700; cursor: pointer;
            transition: background 0.2s;
        }
        .btn-pay:hover { background: #5c2e00; }
        .spinner { display: none; margin: 1rem auto; }
    </style>
</head>
<body>

<div class="payment-card">
    <h2>Complete Payment</h2>
    <p>Order #${orderId} — Click below to pay securely via Razorpay</p>
    <div class="amount">&#8377;${amount / 100}</div>
    <button class="btn-pay" id="payBtn">Pay Now</button>
</div>

<!-- Hidden form to submit payment result -->
<form id="paymentForm" method="post" action="${pageContext.request.contextPath}/payment/verify">
    <input type="hidden" name="razorpay_order_id"   id="rzp_order_id">
    <input type="hidden" name="razorpay_payment_id"  id="rzp_payment_id">
    <input type="hidden" name="razorpay_signature"   id="rzp_signature">
    <input type="hidden" name="order_id"             value="${orderId}">
</form>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
    var options = {
        key:         "${razorpayKeyId}",
        amount:      "${amount}",
        currency:    "INR",
        name:        "Panjeeri Ghar",
        description: "Order #${orderId}",
        order_id:    "${razorpayOrderId}",
        prefill: {
            name:    "${userName}",
            email:   "${userEmail}",
            contact: "${userPhone}"
        },
        theme: { color: "#7b3f00" },
        handler: function(payment) {
            document.getElementById("rzp_order_id").value   = payment.razorpay_order_id;
            document.getElementById("rzp_payment_id").value = payment.razorpay_payment_id;
            document.getElementById("rzp_signature").value  = payment.razorpay_signature;
            document.getElementById("paymentForm").submit();
        },
        modal: {
            ondismiss: function() {
                document.getElementById("payBtn").disabled = false;
                document.getElementById("payBtn").textContent = "Pay Now";
            }
        }
    };

    var rzp = new Razorpay(options);

    document.getElementById("payBtn").addEventListener("click", function() {
        this.disabled = true;
        this.textContent = "Opening payment...";
        rzp.open();
    });

    // Auto-open on page load
    window.onload = function() { rzp.open(); };
</script>

</body>
</html>
