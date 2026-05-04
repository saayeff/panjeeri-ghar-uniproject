<%-- Shared admin CSS --%>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', sans-serif; background: #f5f0eb; color: #3b2a1a; display: flex; }

    .admin-sidebar {
        width: 220px; min-height: 100vh; background: #7b3f00;
        position: fixed; top: 0; left: 0; padding-top: 0;
    }
    .admin-sidebar .brand {
        padding: 1.2rem 1.5rem; font-size: 1.1rem; font-weight: 700;
        color: #fff; border-bottom: 1px solid rgba(255,255,255,0.15);
        display: block; text-decoration: none;
    }
    .admin-sidebar .brand span { display: block; font-size: 0.75rem; font-weight: 400; opacity: 0.7; }
    .admin-sidebar nav a {
        display: block; padding: 0.75rem 1.5rem;
        color: #ffe0b2; text-decoration: none; font-size: 0.92rem;
        border-left: 3px solid transparent; transition: all 0.15s;
    }
    .admin-sidebar nav a:hover, .admin-sidebar nav a.active {
        background: rgba(255,255,255,0.1); border-left-color: #ffe0b2; color: #fff;
    }
    .admin-sidebar .sidebar-footer {
        position: absolute; bottom: 0; width: 100%;
        padding: 1rem 1.5rem; border-top: 1px solid rgba(255,255,255,0.15);
    }
    .admin-sidebar .sidebar-footer a { color: #ffe0b2; font-size: 0.85rem; text-decoration: none; }

    .admin-content { margin-left: 220px; padding: 2rem; width: 100%; min-height: 100vh; }

    .page-title { font-size: 1.5rem; margin-bottom: 1.5rem; color: #7b3f00; }

    .stats-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
    .stat-card {
        background: #fff; border-radius: 10px; padding: 1.2rem;
        box-shadow: 0 2px 6px rgba(0,0,0,0.07); text-align: center;
        border-top: 3px solid #d0b89a;
    }
    .stat-card.highlight { border-top-color: #7b3f00; }
    .stat-card.warn      { border-top-color: #e67e22; }
    .stat-value { font-size: 1.6rem; font-weight: 700; color: #7b3f00; }
    .stat-label { font-size: 0.82rem; color: #888; margin-top: 0.3rem; }

    .card { background: #fff; border-radius: 10px; box-shadow: 0 2px 6px rgba(0,0,0,0.07); padding: 1.5rem; margin-bottom: 1.5rem; }
    .card-title { font-size: 1rem; font-weight: 700; margin-bottom: 1rem; color: #7b3f00; }

    .admin-table { width: 100%; border-collapse: collapse; font-size: 0.88rem; }
    .admin-table th { background: #7b3f00; color: #fff; padding: 0.7rem 0.9rem; text-align: left; white-space: nowrap; }
    .admin-table td { padding: 0.7rem 0.9rem; border-bottom: 1px solid #f0e6d8; vertical-align: middle; }
    .admin-table tr:last-child td { border-bottom: none; }
    .admin-table tr:hover td { background: #fffaf5; }

    .badge { display: inline-block; padding: 0.2rem 0.6rem; border-radius: 20px; font-size: 0.78rem; font-weight: 600; }
    .badge-pending    { background: #fff3cd; color: #856404; }
    .badge-confirmed  { background: #d1e7dd; color: #0a3622; }
    .badge-processing { background: #cfe2ff; color: #084298; }
    .badge-shipped    { background: #d0c9f5; color: #3d1a8e; }
    .badge-delivered  { background: #d1e7dd; color: #0a3622; }
    .badge-cancelled  { background: #f8d7da; color: #842029; }
    .badge-paid       { background: #d1e7dd; color: #0a3622; }
    .badge-unpaid     { background: #fff3cd; color: #856404; }
    .badge-failed     { background: #f8d7da; color: #842029; }

    .filter-bar { display: flex; gap: 0.5rem; margin-bottom: 1rem; flex-wrap: wrap; }
    .filter-bar a {
        padding: 0.4rem 1rem; border-radius: 20px; font-size: 0.85rem;
        text-decoration: none; background: #fff; color: #7b3f00;
        border: 1px solid #d0b89a; transition: all 0.15s;
    }
    .filter-bar a:hover, .filter-bar a.active { background: #7b3f00; color: #fff; border-color: #7b3f00; }

    .alert-success {
        background: #d1e7dd; border: 1px solid #a3cfbb; color: #0a3622;
        padding: 0.7rem 1rem; border-radius: 6px; margin-bottom: 1rem; font-size: 0.9rem;
    }

    .btn-primary {
        display: inline-block; padding: 0.6rem 1.2rem;
        background: #7b3f00; color: #fff; border: none;
        border-radius: 6px; font-size: 0.9rem; font-weight: 600;
        cursor: pointer; text-decoration: none; transition: background 0.2s;
    }
    .btn-primary:hover { background: #5c2e00; }
    .btn-secondary {
        display: inline-block; padding: 0.6rem 1.2rem;
        background: #f0e6d8; color: #7b3f00; border: none;
        border-radius: 6px; font-size: 0.9rem; font-weight: 600;
        cursor: pointer; text-decoration: none; transition: background 0.2s;
    }
    .btn-sm {
        padding: 0.25rem 0.6rem; background: #7b3f00; color: #fff;
        border: none; border-radius: 4px; font-size: 0.8rem; cursor: pointer;
        text-decoration: none; display: inline-block; transition: background 0.2s;
    }
    .btn-sm:hover { background: #5c2e00; }
    .btn-danger { background: #c0392b !important; }
    .btn-danger:hover { background: #922b21 !important; }

    .select-sm {
        padding: 0.25rem 0.4rem; border: 1px solid #d0b89a;
        border-radius: 4px; font-size: 0.8rem; background: #fffaf5;
    }

    .form-row { display: flex; gap: 1rem; }
    .form-group { margin-bottom: 1rem; flex: 1; }
    .form-group label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 0.3rem; }
    .form-group input, .form-group select, .form-group textarea {
        width: 100%; padding: 0.55rem 0.75rem;
        border: 1px solid #d0b89a; border-radius: 6px;
        font-size: 0.9rem; background: #fffaf5;
        outline: none; transition: border-color 0.2s; font-family: inherit;
    }
    .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #7b3f00; }
    .form-group textarea { resize: vertical; min-height: 70px; }
</style>
