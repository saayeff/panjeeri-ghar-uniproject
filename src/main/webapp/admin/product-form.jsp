<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty product ? 'Add' : 'Edit'} Product — Admin</title>
    <%@ include file="admin-style.jsp" %>
</head>
<body>
<%@ include file="admin-nav.jsp" %>
<div class="admin-content">
    <h2 class="page-title">${empty product ? 'Add Product' : 'Edit Product'}</h2>

    <div class="card" style="max-width:700px;">
        <form method="post" action="${pageContext.request.contextPath}/admin/products">
            <input type="hidden" name="action" value="${empty product ? 'add' : 'edit'}">
            <c:if test="${not empty product}">
                <input type="hidden" name="productId" value="${product.productId}">
            </c:if>

            <div class="form-row">
                <div class="form-group">
                    <label>Product Name</label>
                    <input type="text" name="name" value="${product.name}" required>
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="categoryId" required>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}"
                                ${product.categoryId == cat.categoryId ? 'selected' : ''}>
                                ${cat.name}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label>Description</label>
                <textarea name="description" rows="3">${product.description}</textarea>
            </div>

            <div class="form-group">
                <label>Ingredients</label>
                <textarea name="ingredients" rows="2">${product.ingredients}</textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Weight (grams)</label>
                    <input type="number" name="weightGrams" value="${product.weightGrams}" required>
                </div>
                <div class="form-group">
                    <label>Price (&#8377;)</label>
                    <input type="number" name="price" step="0.01" value="${product.price}" required>
                </div>
                <div class="form-group">
                    <label>MRP (&#8377;)</label>
                    <input type="number" name="mrp" step="0.01" value="${product.mrp}" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Stock Qty</label>
                    <input type="number" name="stockQty" value="${product.stockQty}" required>
                </div>
                <div class="form-group">
                    <label>Expiry Date</label>
                    <input type="date" name="expiryDate" value="${product.expiryDate}" required>
                </div>
                <div class="form-group">
                    <label>Batch Number</label>
                    <input type="text" name="batchNumber" value="${product.batchNumber}">
                </div>
            </div>

            <div class="form-group">
                <label>Image URL</label>
                <input type="text" name="imageUrl" value="${product.imageUrl}" placeholder="images/product.jpg">
            </div>

            <div class="form-group" style="display:flex;align-items:center;gap:0.5rem;">
                <input type="checkbox" name="isActive" id="isActive"
                       ${empty product || product.isActive ? 'checked' : ''}>
                <label for="isActive" style="margin:0;">Active (visible on store)</label>
            </div>

            <div style="display:flex;gap:1rem;margin-top:1rem;">
                <button type="submit" class="btn-primary">Save Product</button>
                <a href="${pageContext.request.contextPath}/admin/products" class="btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
